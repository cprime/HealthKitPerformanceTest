//
//  HealthKitManager.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/22/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class HealthKitManager {
    static let sharedInstance = HealthKitManager()

    lazy var healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()

    //Mark: Access

    private func getHealthKitAccess(completion: (Bool, NSError?) -> Void) {
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(
            HKQuantityTypeIdentifierStepCount)!

        let dataTypesToWrite = Set(arrayLiteral: stepsCount)
        let dataTypesToRead = Set(arrayLiteral: stepsCount)
        if self.healthStore != nil {
            self.healthStore?.requestAuthorizationToShareTypes(
                dataTypesToWrite,
                readTypes: dataTypesToRead,
                completion:completion
            )
        } else {
            completion(false, nil)
        }
    }

    private func getHealthKitSources(completion: (Set<HKSource>?, NSError?) -> Void) {
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!

        let query = HKSourceQuery(sampleType: sampleType, samplePredicate: nil) {
            query, sources, error in
            completion(sources, error)
        }
        
        self.healthStore!.executeQuery(query)
    }

    //Mark: Historical Step Count From Samples

    func enumerateHistoricalStepCountSamplesWithStartDate(startDate: NSDate, endDate: NSDate, sampleBlock: ([HKQuantitySample]) -> Void, completion: (ErrorType?) -> Void) {
        self.getHealthKitAccess { (success, error) -> Void in
            if success {
                self.getHealthKitSources{ (sources, error) in
                    if sources != nil {
                        let deviceName = UIDevice.currentDevice().name
                        let filteredSources = sources!.filter{ (source) -> Bool in
                            if (source.bundleIdentifier.hasPrefix("com.apple.health.") && source.name != deviceName) {
                                return true
                            }
                            return false
                        }
                        if filteredSources.isEmpty {
                            self.finishOnMainQueue(error, completion: completion)
                        } else {
                            self.enumerationHelperForHistoricalStepCountSamplesWithStartDate(
                                filteredSources.first!,
                                startDate: startDate.dateAtStartOfDay(),
                                endDate: endDate.dateAtEndOfDay(),
                                sampleBlock: sampleBlock,
                                completion: completion
                            )
                        }
                    } else {
                        self.finishOnMainQueue(error, completion: completion)
                    }
                }
            } else {
                self.finishOnMainQueue(error, completion: completion)
            }
        }
    }

    private func enumerationHelperForHistoricalStepCountSamplesWithStartDate(source: HKSource, startDate: NSDate, endDate: NSDate, sampleBlock: ([HKQuantitySample]) -> Void, completion: (ErrorType?) -> Void) {
        if (startDate.compare(endDate) == .OrderedAscending) {
            let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!

            let days = 7
            let queryStartDate = startDate
            let queryEndDate = startDate.dateByAddingDays(days).dateByAddingTimeInterval(-1)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                HKQuery.predicateForSamplesWithStartDate(queryStartDate, endDate: queryEndDate, options: .None),
                HKQuery.predicateForObjectsFromSource(source),
                ])
            let sampleQuery = HKSampleQuery(sampleType: stepsCount,
                predicate: predicate,
                limit: days * 24 * 60,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)])
                { [unowned self] (query, results, error) in
                    if error != nil {
                        self.finishOnMainQueue(error, completion: completion)
                    } else if results is [HKQuantitySample] {
                        sampleBlock(results as! [HKQuantitySample])

                        let nextStart = startDate.dateByAddingDays(days)
                        var nextEnd = endDate.dateByAddingDays(days)
                        if (nextEnd.compare(endDate) == .OrderedDescending) {
                            nextEnd = endDate
                        }
                        self.enumerationHelperForHistoricalStepCountSamplesWithStartDate(
                            source,
                            startDate: nextStart,
                            endDate: nextEnd,
                            sampleBlock: sampleBlock,
                            completion: completion
                        )
                    }
            }
            self.healthStore!.executeQuery(sampleQuery)
        } else {
            self.finishOnMainQueue(nil, completion: completion)
        }
    }

    func getHistoricalStepCountFromSamplesWithStartDate(startDate: NSDate, endDate: NSDate, completion: (HistoricalStepCount?, ErrorType?) -> Void) {
        let startDateAtStartOfDay = startDate.dateAtStartOfDay()
        let endDateAtEndOfDay = endDate.dateAtEndOfDay()
        let historicalStepCount = HistoricalSampleStepCount(startDate: startDateAtStartOfDay, endDate: endDateAtEndOfDay)

        let sampleBlock = { (samples: [HKQuantitySample]) -> Void in
            historicalStepCount.addSamples(samples)
        }
        let innerCompletionBlock = { [unowned self] (error: ErrorType?) -> Void in
            self.finishOnMainQueue(historicalStepCount, error: error, completion: completion)
        }

        self.enumerateHistoricalStepCountSamplesWithStartDate(
            startDateAtStartOfDay,
            endDate: endDateAtEndOfDay,
            sampleBlock: sampleBlock,
            completion: innerCompletionBlock
        )
    }

    //Mark: Historical Step Count From Stats

    func getHistoricalStepCountFromStatsWithStartDate(startDate: NSDate, endDate: NSDate, completion: (HistoricalStepCount?, ErrorType?) -> Void) {
        self.getHealthKitAccess { (success, error) -> Void in
            if success {
                self.getHealthKitSources{ (sources, error) in
                    if sources != nil {
                        let deviceName = UIDevice.currentDevice().name
                        let filteredSources = sources!.filter{ (source) -> Bool in
                            if (source.bundleIdentifier.hasPrefix("com.apple.health.") && source.name != deviceName) {
                                return true
                            }
                            return false
                        }
                        if filteredSources.isEmpty {
                            self.finishOnMainQueue(nil, error: error, completion: completion)
                        } else {
                            let historicalStepCount = HistoricalStatisticalStepCount(startDate: startDate, endDate: endDate)
                            self.getHistoricalStepCountFromStatsWithStartDate(filteredSources.first!, historicalStepCount: historicalStepCount, startDate: startDate.dateAtStartOfDay(), endDate: endDate.dateAtEndOfDay(), completion: { (stepCount, error) in
                                self.finishOnMainQueue(stepCount, error: error, completion: completion)
                            })
                        }
                    }
                }
            } else {
                self.finishOnMainQueue(nil, error: error, completion: completion)
            }
        }
    }

    private func getHistoricalStepCountFromStatsWithStartDate(source: HKSource, historicalStepCount: HistoricalStatisticalStepCount, startDate: NSDate, endDate: NSDate, completion: (HistoricalStepCount?, ErrorType?) -> Void) {
        if (startDate.compare(endDate) == .OrderedAscending) {
            let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!

            let interval = NSDateComponents()
            interval.day = 1

            let queryStartDate = startDate
            let queryEndDate = endDate.dateAtEndOfDay().dateByAddingTimeInterval(-1)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                HKQuery.predicateForObjectsFromSource(source),
                ])

            let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .CumulativeSum,
                anchorDate: queryStartDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = {
                query, results, error in

                if results != nil {
                    results!.enumerateStatisticsFromDate(queryStartDate, toDate: queryEndDate) {
                        statistics, stop in
                        historicalStepCount.addStatistics(statistics)
                    }

                    self.finishOnMainQueue(historicalStepCount, error: error, completion: completion)
                } else {
                    self.finishOnMainQueue(historicalStepCount, error: error, completion: completion)
                }
            }

            self.healthStore!.executeQuery(query)
        } else {
            completion(historicalStepCount, nil)
        }
    }

    //Mark: Helpers

    private func finishOnMainQueue(error: ErrorType?, completion: (ErrorType?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            completion(error)
        }
    }

    private func finishOnMainQueue(stepCount: HistoricalStepCount?, error: ErrorType?, completion: (HistoricalStepCount?, ErrorType?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            completion(stepCount, error)
        }
    }

}
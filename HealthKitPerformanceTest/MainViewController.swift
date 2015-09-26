//
//  MainViewController.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import UIKit
import SwiftSpinner
import HealthKit

let kTotalDays = 365

class MainViewController: UITableViewController {
    enum Section: Int {
        case HealthKit = 0
        case CoreData = 1
        case Actions = 2
    }

    enum HealthKitRow: Int {
        case Samples = 0
        case Stats = 1
    }

    enum CoreDataRow: Int {
        case Samples = 0
    }

    enum ActionRows: Int {
        case Sync = 0
    }

    func setTimeForCell(section: NSInteger, row: NSInteger, timeInterval: NSTimeInterval) {
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
            if let oldText = cell.textLabel?.text {
                let split = oldText.componentsSeparatedByString(" - ")
                if split.count > 0 {
                    cell.textLabel?.text = "\(split[0]) - \(Double(round(1000*timeInterval)/1000)) seconds"
                }
            }
        }
    }

    //MARK: Display HealthKit

    func displayStepsFromHealthKitSamples() {
        let startDate = NSDate();
        SwiftSpinner.show("Processing Samples...")
        HealthKitManager.sharedInstance.getHistoricalStepCountFromSamplesWithStartDate(NSDate().dateBySubtractingDays(kTotalDays), endDate: NSDate()) { [unowned self] (count, error) in
            self.setTimeForCell(Section.HealthKit.rawValue, row: HealthKitRow.Samples.rawValue, timeInterval: NSDate().timeIntervalSinceDate(startDate))
            if count != nil && !(count!.stepCounts.isEmpty) {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HistoricalStepViewController") as! HistoricalStepViewController
                vc.steps = count!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            SwiftSpinner.hide()
        }
    }

    func displayStepsFromHealthKitStats() {
        let startDate = NSDate();
        SwiftSpinner.show("Processing Stats...")
        HealthKitManager.sharedInstance.getHistoricalStepCountFromStatsWithStartDate(NSDate().dateBySubtractingDays(kTotalDays), endDate: NSDate()) { [unowned self] (count, error) in
            self.setTimeForCell(Section.HealthKit.rawValue, row: HealthKitRow.Stats.rawValue, timeInterval: NSDate().timeIntervalSinceDate(startDate))
            if count != nil && count!.stepCounts.count > 0 {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HistoricalStepViewController") as! HistoricalStepViewController
                vc.steps = count!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            SwiftSpinner.hide()
        }
    }

    //MARK: Display CoreData

    func displayStepsFromCoreDataSamples() {
        let startDate = NSDate();
        SwiftSpinner.show("Processing Samples...")

        let startDateAtStartOfDay = NSDate().dateBySubtractingDays(kTotalDays).dateAtStartOfDay()
        let endDateAtEndOfDay = NSDate().dateAtEndOfDay()
        let historicalStepCount = HistoricalSampleStepCount(startDate: startDateAtStartOfDay, endDate: endDateAtEndOfDay)

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let steps = CoreDataManager.sharedInstance.fetchAllStepSamplesBetween(startDateAtStartOfDay, and: endDateAtEndOfDay)

            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                historicalStepCount.addSamples(steps)

                if historicalStepCount.stepCounts.count > 0 {
                    self.setTimeForCell(Section.CoreData.rawValue, row: CoreDataRow.Samples.rawValue, timeInterval: NSDate().timeIntervalSinceDate(startDate))
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("HistoricalStepViewController") as! HistoricalStepViewController
                    vc.steps = historicalStepCount
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                SwiftSpinner.hide()
            }
        }
    }

    //MARK: Actions

    func syncHealthKitToCoreData() {
        SwiftSpinner.show("Processing Samples...")

        CoreDataManager.sharedInstance.deleteAllStepSamples()

        let sampleBlock = { (samples: [HKQuantitySample]) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for sample in samples {
                    CoreDataManager.sharedInstance.createStepSampleWithStartDate(
                        sample.startDate,
                        endDate: sample.endDate,
                        quantity: sample.quantity.doubleValueForUnit(HKUnit.countUnit())
                    )
                }
            })
        }
        let completion = { (error: ErrorType?) -> Void in
            CoreDataManager.sharedInstance.saveContext()
            SwiftSpinner.hide()
        }

        HealthKitManager.sharedInstance.enumerateHistoricalStepCountSamplesWithStartDate(
            NSDate().dateBySubtractingDays(kTotalDays),
            endDate: NSDate(),
            sampleBlock: sampleBlock,
            completion: completion
        )
    }

    //MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case Section.HealthKit.rawValue:
            switch indexPath.row {
            case HealthKitRow.Samples.rawValue:
                self.displayStepsFromHealthKitSamples()
            case HealthKitRow.Stats.rawValue:
                self.displayStepsFromHealthKitStats()
            default:
                print("HealthKit.wtf")
            }
        case Section.CoreData.rawValue:
            switch indexPath.row {
            case HealthKitRow.Samples.rawValue:
                self.displayStepsFromCoreDataSamples()
            default:
                print("CoreData.wtf")
            }
        case Section.Actions.rawValue:
            switch indexPath.row {
            case ActionRows.Sync.rawValue:
                self.syncHealthKitToCoreData()
            default:
                print("Actions.wtf")
            }
        default:
            print("wtf")
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

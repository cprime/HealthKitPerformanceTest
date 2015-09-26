//
//  HistoricalStatisticalStepCount.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import HealthKit

class HistoricalStatisticalStepCount : HistoricalStepCount {
    var stepCounts = [DailyStepCount]()
    private var lastUpdatedStepCount: DailyStatisticalStepCount?

    init() {
    }

    required init(startDate: NSDate, endDate: NSDate) {
        var currentDate = startDate.dateAtStartOfDay()
        let endDateEndOfDay = endDate.dateAtEndOfDay()

        guard currentDate != nil else {
            return
        }
        guard endDateEndOfDay != nil else {
            return
        }

        while currentDate != nil && currentDate?.compare(endDateEndOfDay) == .OrderedAscending {
            if let count = DailyStatisticalStepCount(date: currentDate) {
                self.stepCounts.append(count)
            }
            currentDate = currentDate.dateByAddingDays(1)
        }
    }

    func addStatistics(statistics: HKStatistics) {
        let date = statistics.startDate.dateAtStartOfDay()
        guard date != nil else {
            return
        }

        var added = false

        for count in self.stepCounts {
            if count.date == date! {
                (count as! DailyStatisticalStepCount).setTotalStepsWithStatistics(statistics)
                added = true
            }
        }

        if !added {
            if let count = DailyStatisticalStepCount(statistics: statistics) {
                self.stepCounts.append(count)
            }
        }
    }
}
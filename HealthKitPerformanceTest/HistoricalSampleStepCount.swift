//
//  HistoricalSampleStepCount.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

class HistoricalSampleStepCount : HistoricalStepCount {
    var stepCounts = [DailyStepCount]()
    private var lastStepCount: DailySampleStepCount?

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
            if let count = DailySampleStepCount(date: currentDate) {
                self.stepCounts.append(count)
            }
            currentDate = currentDate.dateByAddingDays(1)
        }
    }

    func addSamples(samples: [StepCountSample]) {
        for sample in samples {
            var added = false
            if self.lastStepCount != nil {
                added = self.lastStepCount!.addSample(sample)
            }
            if !added {
                for count in self.stepCounts {
                    added = (count as! DailySampleStepCount).addSample(sample)
                    if added {
                        self.lastStepCount = (count as! DailySampleStepCount)
                        break
                    }
                }
            }
            if !added {
                if let count = DailySampleStepCount(sample: sample) {
                    self.stepCounts.append(count)
                }
            }
        }
    }
}
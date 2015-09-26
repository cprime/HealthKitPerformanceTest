//
//  DailyStatisticalStepCount.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import HealthKit

class DailyStatisticalStepCount : DailyStepCount {
    var date: NSDate!
    var totalSteps: Double = 0

    init?(date: NSDate) {
        let dateAtStartOfDay = date.dateAtStartOfDay()
        if dateAtStartOfDay == nil {
            return nil
        }
        self.date = dateAtStartOfDay!
    }

    convenience init?(statistics: HKStatistics) {
        self.init(date: statistics.startDate)
        self.setTotalStepsWithStatistics(statistics)
    }

    func setTotalStepsWithStatistics(statistics: HKStatistics) {
        if let quantity = statistics.sumQuantity() {
            self.totalSteps = quantity.doubleValueForUnit(HKUnit.countUnit())
        }
    }
}
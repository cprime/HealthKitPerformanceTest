//
//  DailySampleStepCount.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation

class DailySampleStepCount : DailyStepCount {
    var date: NSDate!
    var startDate : NSDate?
    var endDate : NSDate?
    var totalSamples: Int = 0
    var totalSteps: Double = 0

    init?(date: NSDate) {
        let dateAtStartOfDay = date.dateAtStartOfDay()
        if dateAtStartOfDay == nil {
            return nil
        }
        self.date = dateAtStartOfDay!
    }

    init?(sample: StepCountSample) {
        let dateAtStartOfDay = sample.startDate.dateAtStartOfDay()
        if dateAtStartOfDay == nil {
            return nil
        }
        self.date = dateAtStartOfDay!

        self.startDate = sample.startDate
        self.endDate = sample.endDate

        self.addSample(sample)
    }

    func canAddSample(sample: StepCountSample) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Era, .Year, .Month, .Day]
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: sample.startDate)
        let date = calendar.dateFromComponents(components)

        return date?.compare(self.date) == .OrderedSame
    }

    func addSample(sample: StepCountSample) -> Bool {
        if (self.canAddSample(sample)) {
            self.totalSamples += 1
            self.totalSteps += sample.stepCount
            self.startDate =  ((self.startDate == nil || self.startDate!.compare(sample.startDate) == .OrderedDescending) ? sample.startDate : self.startDate)
            self.endDate = ((self.endDate == nil || self.endDate!.compare(sample.endDate) == .OrderedAscending) ? sample.endDate : self.endDate)
            return true;
        } else {
            return false;
        }
    }
}
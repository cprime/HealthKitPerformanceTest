//
//  StepCountSample.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/25/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import HealthKit

@objc protocol StepCountSample {
    var startDate: NSDate { get }
    var endDate: NSDate { get }
    var stepCount: Double { get }
}

extension StepSampleManagedObject : StepCountSample {
    var startDate: NSDate {
        return self.sampleStartDate!
    }
    var endDate: NSDate {
        return self.sampleEndDate!
    }
    var stepCount: Double {
        return self.sampleQuantity!.doubleValue
    }
}

extension HKQuantitySample : StepCountSample {
    var stepCount: Double {
        return self.quantity.doubleValueForUnit(HKUnit.countUnit())
    }
}
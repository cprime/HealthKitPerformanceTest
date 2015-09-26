//
//  DailyStepCount.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/22/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import HealthKit

protocol DailyStepCount {
    var date: NSDate! { get }
    var totalSteps: Double { get }
}

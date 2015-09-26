//
//  HistoricalStepCount.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/22/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import HealthKit

protocol HistoricalStepCount {
    var stepCounts: [DailyStepCount] { get }

    init(startDate: NSDate, endDate: NSDate)
}
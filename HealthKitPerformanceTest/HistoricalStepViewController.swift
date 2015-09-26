//
//  HistoricalStepViewController.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/22/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import UIKit

let kHistoricalStepViewControllerCellIdentifier = "Cell"

class HistoricalStepViewController: UIViewController {
    var steps: HistoricalStepCount!

    var lineChart: LineChart!

    let dateFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "M/d"
        formatter.timeZone = NSCalendar.currentCalendar().timeZone
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.steps.stepCounts.count > 0 {
            self.lineChart = LineChart()
            self.lineChart.x.labels.visible = false
            self.lineChart.x.axis.inset = 50
            self.lineChart.y.axis.inset = 50
            self.lineChart.dots.visible = false
            self.lineChart.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.lineChart)
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[lineChart]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["lineChart" : self.lineChart])
            )
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[lineChart]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["lineChart" : self.lineChart])
            )

            self.lineChart.addLine(self.steps.stepCounts.map{ CGFloat($0.totalSteps) })
        }
    }

}


//
//  CoreDataManagerAccessExtension.swift
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//

import Foundation
import CoreData

let kStepSampleEntityName = "StepSample"

extension CoreDataManager {
    func createStepSampleWithStartDate(startDate: NSDate, endDate: NSDate, quantity: Double) -> StepSampleManagedObject {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName(kStepSampleEntityName, inManagedObjectContext: self.managedObjectContext!) as! StepSampleManagedObject
        newItem.sampleStartDate = startDate
        newItem.sampleEndDate = endDate
        newItem.sampleQuantity = quantity
        return newItem
    }

    func fetchAllStepSamplesBetween(startDate: NSDate?, and endDate: NSDate?) -> [StepSampleManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: kStepSampleEntityName)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "sampleStartDate", ascending: true) ]

        var predicates = [NSPredicate]()
        if startDate != nil {
            predicates.append(NSPredicate(format: "sampleStartDate >= %@", argumentArray: [startDate!]))
        }
        if endDate != nil {
            predicates.append(NSPredicate(format: "sampleEndDate <= %@", argumentArray: [endDate!]))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        do {
            let results = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            if results is [StepSampleManagedObject] {
                return results as! [StepSampleManagedObject]
            } else {
                return [StepSampleManagedObject]()
            }
        } catch {
            return [StepSampleManagedObject]()
        }
    }

    func deleteAllStepSamples() {
        let steps = self.fetchAllStepSamplesBetween(nil, and: nil)
        for sample in steps {
            self.managedObjectContext?.deleteObject(sample)
        }
        self.saveContext()
    }
}

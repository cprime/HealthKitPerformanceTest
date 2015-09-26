//
//  StepSampleManagedObject+CoreDataProperties.h
//  HealthKitPerformanceTest
//
//  Created by Colden Prime on 9/24/15.
//  Copyright © 2015 IntrepidPursuits. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StepSampleManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface StepSampleManagedObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *sampleStartDate;
@property (nullable, nonatomic, retain) NSDate *sampleEndDate;
@property (nullable, nonatomic, retain) NSNumber *sampleQuantity;

@end

NS_ASSUME_NONNULL_END

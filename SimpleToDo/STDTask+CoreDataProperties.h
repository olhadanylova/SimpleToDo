//
//  STDTask+CoreDataProperties.h
//  SimpleToDo
//
//  Created by Olha Danylova on 05.01.17.
//  Copyright © 2017 Olha Danylova. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "STDTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STDTask (CoreDataProperties)

+ (NSFetchRequest<STDTask *> *)fetchRequest;

@property (nonatomic) BOOL completed;
@property (nullable, nonatomic, copy) NSDate *reminder;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nonatomic) BOOL starred;
@property (nullable, nonatomic, copy) NSString *task;
@property (nullable, nonatomic, retain) STDList *list;

@end

NS_ASSUME_NONNULL_END

//
//  STDList+CoreDataProperties.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "STDList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STDList (CoreDataProperties)

+ (NSFetchRequest<STDList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) NSSet<STDList *> *children;
@property (nullable, nonatomic, retain) STDList *parent;
@property (nullable, nonatomic, retain) NSSet<STDTask *> *tasks;

@end

@interface STDList (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(STDList *)value;
- (void)removeChildrenObject:(STDList *)value;
- (void)addChildren:(NSSet<STDList *> *)values;
- (void)removeChildren:(NSSet<STDList *> *)values;

- (void)addTasksObject:(STDTask *)value;
- (void)removeTasksObject:(STDTask *)value;
- (void)addTasks:(NSSet<STDTask *> *)values;
- (void)removeTasks:(NSSet<STDTask *> *)values;

@end

NS_ASSUME_NONNULL_END

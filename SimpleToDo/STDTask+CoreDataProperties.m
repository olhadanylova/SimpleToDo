//
//  STDTask+CoreDataProperties.m
//  SimpleToDo
//
//  Created by Olha Danylova on 05.01.17.
//  Copyright © 2017 Olha Danylova. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "STDTask+CoreDataProperties.h"

@implementation STDTask (CoreDataProperties)

+ (NSFetchRequest<STDTask *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Task"];
}

@dynamic completed;
@dynamic reminder;
@dynamic notes;
@dynamic starred;
@dynamic task;
@dynamic list;

@end

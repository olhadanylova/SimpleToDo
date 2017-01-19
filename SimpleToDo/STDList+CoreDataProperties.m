//
//  STDList+CoreDataProperties.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "STDList+CoreDataProperties.h"

@implementation STDList (CoreDataProperties)

+ (NSFetchRequest<STDList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"List"];
}

@dynamic title;
@dynamic children;
@dynamic parent;
@dynamic tasks;

@end

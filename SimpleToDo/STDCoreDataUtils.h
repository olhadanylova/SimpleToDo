//
//  STDCoreDataUtils.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDCoreDataUtils class implements Core Data methods for managed object context and its saving.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface STDCoreDataUtils : NSObject

+ (NSManagedObjectContext *)managedObjectContext;
+ (void)saveContext;

@end

//
//  STDCoreDataUtils.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDCoreDataUtils class implements Core Data methods for managed object context and its saving.

#import "STDCoreDataUtils.h"
#import "AppDelegate.h"

@implementation STDCoreDataUtils

static NSManagedObjectContext* _managedObjectContext;

+(NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        _managedObjectContext = appDelegate.persistentContainer.viewContext;
    }
    return _managedObjectContext;
}


+(void) saveContext {
    NSError *error = nil;
    if ([[STDCoreDataUtils managedObjectContext] hasChanges] && ![[STDCoreDataUtils managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end

//
//  AppDelegate.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

@end


//
//  AppDelegate.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

#import "AppDelegate.h"
#import "STDListsAndTasksViewController.h"
#import "STDTaskDetailViewController.h"
#import "STDTask+CoreDataClass.h"
#import "STDCoreDataUtils.h"
#import "STDStyle.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UISplitViewControllerDelegate> {
    UINavigationController *masterNavigationController, *detailNavigationController;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Split View Controller.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    navigationController.topViewController.navigationItem.leftItemsSupplementBackButton = YES;
    splitViewController.delegate = self;
    
    masterNavigationController = splitViewController.viewControllers[0];
    detailNavigationController = splitViewController.viewControllers[1];
    
    // Set navigation controllers style.
    STDStyle *style = [STDStyle sharedStyle];
    masterNavigationController.navigationBar.tintColor = style.mainColor;
    masterNavigationController.toolbar.tintColor = style.mainColor;
    detailNavigationController.navigationBar.tintColor = style.mainColor;
    detailNavigationController.toolbar.tintColor = style.mainColor;
    
    detailNavigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    detailNavigationController.topViewController.navigationItem.leftItemsSupplementBackButton = YES;
    
    
    // Notifications.
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError* _Nullable error) {}];
    }
    application.applicationIconBadgeNumber = 0;
    return YES;
}


// Fired when user quits the application.
- (void)applicationWillResignActive:(UIApplication *)application {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    int badgeNumber = 0;
    // Get all tasks and then select only expired ones.
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Task"];
    NSError *error = nil;
    NSArray *tasks = [[STDCoreDataUtils managedObjectContext] executeFetchRequest:request error:&error];
    for (STDTask *task in tasks) if (task.completed == 0 && [task.reminder compare:[NSDate date]] == NSOrderedAscending) badgeNumber++;
    application.applicationIconBadgeNumber = badgeNumber;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [STDCoreDataUtils saveContext];
}


#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(STDTaskDetailViewController *)secondaryViewController ontoPrimaryViewController:(STDListsAndTasksViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[STDTaskDetailViewController class]]
        && ([(STDTaskDetailViewController *)[(UINavigationController *)secondaryViewController topViewController] task] == nil)) {
        // If the detail controller doesn't have an item, display the primary view controller instead.
        return YES;
    }
    return NO;
}


- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(STDListsAndTasksViewController *)primaryViewController {
    // If details view is already presented.
    if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
        for (UIViewController *controller in [(UINavigationController *)primaryViewController viewControllers]) {
            if ([controller isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)controller visibleViewController] isKindOfClass:[STDTaskDetailViewController class]]) {
                return controller;
            }
        }
    }
    // If details view is not presented yet.
    STDTaskDetailViewController *controller = (STDTaskDetailViewController *)[detailNavigationController visibleViewController];
    controller.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
    return detailNavigationController;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"SimpleToDo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}

@end

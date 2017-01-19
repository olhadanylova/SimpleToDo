//
//  STDActions.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDActions class provides some app logic methods.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "STDList+CoreDataClass.h"
#import "STDTask+CoreDataClass.h"

@class STDCell;

@interface STDActions : NSObject

@property(nonatomic) BOOL editIsEnabled;   // If YES - begin editing.
@property(nonatomic) BOOL segueIsEnabled;  // If YES - segue is enabled.
@property(strong, nonatomic) UNMutableNotificationContent *localNotification;

- (id)initActionsWithTableViewController:(UITableViewController *)_tableViewController
         andWithFetchedResultsController:(NSFetchedResultsController *)_fetchedResultsController
                       andWithEditButton:(UIBarButtonItem *)_editButton
             andWithCreateOrDeleteButton:(UIBarButtonItem *)_createOrDeleteButton
                                 andList:(STDList *)_list;

- (void)doneAction;     // Edit mode off.
- (void)editAction;     // Edit mode on.
- (void)createOrDeleteListAction:(NSMutableArray *)lists;   // Works in 2 ways: (1) for creating new list, (2) for deleting checked lists.
- (void) deleteActionWithLists:(NSMutableArray *)lists andTasks:(NSMutableArray *)tasks andCompletedTasks:(NSMutableArray *)completedTasks;
- (void)noDataAlert;    // Absence of data to edit message.
- (void)showPopupForList:(STDList *)listToEdit;             // Method for creating or editing the list.
- (void)checkButtonPressedOnCell:(STDCell *)clickedCell inTableView:(UITableView *)tableView;
- (void)createOrDeleteButtonIsEnabled;
- (void)addTaskNotification:(STDTask *)task;                // Add notification to notification centre
- (void)removeTaskNotification:(STDTask *)task;             // Remove notification from notification centre.
- (void)removeTaskNotificationsFromList:(STDList *)deletedList; // Recursive method to delete notifications for ALL tasks in deleting list.

@end

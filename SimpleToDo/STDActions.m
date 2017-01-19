//
//  STDActions.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDActions class provides some app logic methods.

#import "STDActions.h"
#import "STDCoreDataUtils.h"
#import "STDCell.h"
#import "STDStyle.h"

@interface STDActions() {
    UITableViewController *tableViewController; // Current table view controller.
    NSFetchedResultsController *fetchedResultsController;
    UIBarButtonItem *editButton, *createOrDeleteButton;
    STDList *list;                              // Current parent list in table view.
    STDStyle *style;
    NSMutableArray *checkedIndexPaths;          // Array of cell's indexes that are checked, array of cell's indexes with checked tasks.

    NSString *id1, *id2;
}
@end

@implementation STDActions

- (id)initActionsWithTableViewController:(UITableViewController *)_tableViewController
  andWithFetchedResultsController:(NSFetchedResultsController *)_fetchedResultsController
                andWithEditButton:(UIBarButtonItem *)_editButton
      andWithCreateOrDeleteButton:(UIBarButtonItem *)_createOrDeleteButton
                          andList:(STDList *)_list {
    tableViewController = _tableViewController;
    fetchedResultsController = _fetchedResultsController;
    editButton = _editButton;
    createOrDeleteButton = _createOrDeleteButton;
    list = _list;
    style = [STDStyle sharedStyle];
    checkedIndexPaths = [[NSMutableArray alloc] init];
    return self;
}


#pragma mark - Buttons Availability

- (void)createOrDeleteButtonIsEnabled {
    if (!self.editIsEnabled) createOrDeleteButton.enabled = YES;
    else {
        if ([checkedIndexPaths count] > 0) createOrDeleteButton.enabled = YES;
        else  createOrDeleteButton.enabled = NO;
    }
}


#pragma mark - Buttons Actions

- (void)checkButtonPressedOnCell:(STDCell *)clickedCell inTableView:(UITableView *)tableView {
    NSIndexPath *indexPath = [tableView indexPathForCell:clickedCell];
    if (clickedCell.isChecked) [checkedIndexPaths addObject:indexPath];
    else [checkedIndexPaths removeObject:indexPath];
    [self createOrDeleteButtonIsEnabled];
}


#pragma mark - Actions

- (void)doneAction {
    if ([editButton.title isEqualToString:style.doneTitle]) {
        editButton.title = style.editTitle;
        self.editIsEnabled = NO;
        createOrDeleteButton.title = style.createNewTitle;
        createOrDeleteButton.enabled = YES;
        checkedIndexPaths = [[NSMutableArray alloc] init];
        self.segueIsEnabled = YES;
    }
}


- (void)editAction {
    //Edit.
    if ([editButton.title isEqualToString:style.editTitle]) {
        self.editIsEnabled = !self.editIsEnabled;
        editButton.title = style.doneTitle;
        //If list(s) is (are) checked then it's possible to delete several lists at once.
        if (self.editIsEnabled) {
            createOrDeleteButton.title = style.deleteTitle;
            createOrDeleteButton.enabled = NO;
            self.segueIsEnabled = NO;
        }
    }
    //Done.
    else [self doneAction];
}


- (void)createOrDeleteListAction:(NSMutableArray *)lists {
    if (!self.editIsEnabled && [checkedIndexPaths count] == 0) [self showPopupForList:nil];  // (1)
    else [self deleteActionWithLists:lists andTasks:nil andCompletedTasks:nil];         // (2)
}


- (void) deleteActionWithLists:(NSMutableArray *)lists andTasks:(NSMutableArray *)tasks andCompletedTasks:(NSMutableArray *)completedTasks {
    if (self.editIsEnabled && [checkedIndexPaths count] > 0) [self showPopupDeletingConfirmationWithLists:lists andTasks:tasks andCompletedTasks:completedTasks];
}


#pragma mark - Alerts and Popups

- (void) noDataAlert {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:style.ooopsString
                                                                message:style.ooopsMessageString
                                                         preferredStyle:UIAlertControllerStyleAlert];
    ac.view.tintColor = style.mainColor;
    // Back button.
    UIAlertAction *back = [UIAlertAction actionWithTitle:style.ooopsButtonString
                                                   style:UIAlertActionStyleCancel
                                                 handler:nil];
    [ac addAction:back];
    [tableViewController presentViewController:ac animated:YES completion:nil];
}


- (void)showPopupForList:(STDList *)listToEdit {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:listToEdit == nil ? style.listPopupCreateString : style.listPopupRenameString
                                                                message:listToEdit.title
                                                         preferredStyle:UIAlertControllerStyleAlert];
    ac.view.tintColor = style.mainColor;
    // Text field.
    [ac addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        if (listToEdit == nil) textField.placeholder = style.listNameString;
        else textField.text = listToEdit.title;
    }];
    // Cancel button.
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:style.cancelTitle
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       [tableViewController.tableView reloadData];
                                                   }];
    [ac addAction:cancel];
    // OK button.
    UIAlertAction *ok = [UIAlertAction actionWithTitle:style.okTitle
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   // There's only one textfield on this alert.
                                                   UITextField *textField = ac.textFields.firstObject;
                                                   // If creating new list.
                                                   if (listToEdit == nil) {
                                                       STDList *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List"
                                                                                                        inManagedObjectContext: [STDCoreDataUtils managedObjectContext]];
                                                       newList.title = textField.text;
                                                       newList.parent = list;
                                                   }
                                                   // If renaming existing list.
                                                   else {
                                                       listToEdit.title = textField.text;
                                                       listToEdit.parent = list;
                                                   }
                                                   [STDCoreDataUtils saveContext];
                                                   [self doneAction];
                                                   [tableViewController.tableView reloadData];
                                               }];
    [ac addAction:ok];
    [tableViewController presentViewController:ac animated:YES completion:nil];
    
    
}


// Method for deleting confirmation.
- (void)showPopupDeletingConfirmationWithLists:(NSMutableArray *)lists andTasks:(NSMutableArray *)tasks andCompletedTasks:(NSMutableArray *)completedTasks {
    
    NSString *title, *message;
    title = style.deleteTitle;
    if ([checkedIndexPaths count] == 1) message = style.deleteItemString;
    if ([checkedIndexPaths count] > 1) message = style.deleteItemsString;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    ac.view.tintColor = style.mainColor;
    // Cancel button.
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:style.cancelTitle
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [ac addAction:cancel];
    // OK button.
    UIAlertAction *ok = [UIAlertAction actionWithTitle:style.okTitle
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   for (int i = 0; i < [checkedIndexPaths count]; i++) {
                                                       NSIndexPath *indexPath = [checkedIndexPaths objectAtIndex:i];
                                                       // Delete lists.
                                                       if (indexPath.section == 0) {
                                                           if (lists == nil) {
                                                               for (int i = 0; i < [checkedIndexPaths count]; i++) {
                                                                   STDList *listForRow = [fetchedResultsController objectAtIndexPath:[checkedIndexPaths objectAtIndex:i]];
                                                                   [self removeTaskNotificationsFromList:listForRow];
                                                                   [[STDCoreDataUtils managedObjectContext] deleteObject:listForRow];
                                                               }
                                                           }
                                                           else {
                                                               STDList *listForRow = lists[indexPath.row];
                                                               [self removeTaskNotificationsFromList:listForRow];
                                                               [[STDCoreDataUtils managedObjectContext] deleteObject:listForRow];
                                                           }
                                                       }
                                                       // Delete tasks.
                                                       if (indexPath.section == 1) {
                                                           STDTask *taskForRow = tasks[indexPath.row];
                                                           [self removeTaskNotification:taskForRow];
                                                           [[STDCoreDataUtils managedObjectContext] deleteObject:taskForRow];
                                                       }
                                                       if (indexPath.section == 2) {
                                                           STDTask *taskForRow = completedTasks[indexPath.row];
                                                           [[STDCoreDataUtils managedObjectContext] deleteObject:taskForRow];
                                                       }
                                                   }
                                                   [STDCoreDataUtils saveContext];
                                                   [self doneAction];
                                                   [tableViewController.tableView reloadData];
                                               }];
    [ac addAction:ok];
    [tableViewController presentViewController:ac animated:YES completion:nil];
}


- (void)addTaskNotification:(STDTask *)task {
    if (task.reminder) {
        style = [STDStyle sharedStyle];
        self.localNotification = [[UNMutableNotificationContent alloc] init];
        self.localNotification.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@ %@ '%@'", task.task, style.inListString, task.list.title] arguments:nil];
        self.localNotification.sound = [UNNotificationSound defaultSound];
        
        self.localNotification.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        
        // Trigger.
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:task.reminder];
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
        
        // Schedule.
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@%@", task.list.title, task.task]
                                                                              content:self.localNotification
                                                                              trigger:trigger];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request
                 withCompletionHandler:^(NSError *_Nullable error) {
                     if (!error) NSLog(@"Add NotificationRequest succeeded!");
                 }];
    }
}


- (void)removeTaskNotification:(STDTask *)task {
    // Delete notification.
    if (task.reminder) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:@[[NSString stringWithFormat:@"%@%@", task.list.title, task.task]]];
    }
}


- (void)removeTaskNotificationsFromList:(STDList *)deletedList {
    for (STDTask *task in deletedList.tasks) [self removeTaskNotification:task];
    for (STDList *lst in deletedList.children) {
        for (STDTask *task in lst.tasks) [self removeTaskNotification:task];
        [self removeTaskNotificationsFromList:lst];
    }
}

@end

//
//  MasterViewController.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDListsAndTasksViewController class implements lists and tasks displaying in table view.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>

@class STDList;
@class STDTaskDetailViewController;

@interface STDListsAndTasksViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) STDList *list;    // Parent list.
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController; // List fetched results controller.

@property(strong, nonatomic) STDTaskDetailViewController *taskDetailViewController;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *createOrDeleteButton;

- (IBAction)pressedEditButton:(id)sender;
- (IBAction)pressedCreateOrDeleteButton:(id)sender;

@end

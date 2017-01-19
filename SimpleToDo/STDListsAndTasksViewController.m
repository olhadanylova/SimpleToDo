//
//  MasterViewController.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDListsAndTasksViewController class implements lists and tasks displaying in table view.

#import "STDListsAndTasksViewController.h"
#import "STDTaskDetailViewController.h"
#import "STDCoreDataUtils.h"
#import "STDActions.h"
#import "STDStyle.h"
#import "STDCell.h"

#define kShowListsAndTasksSegue @"ShowListsAndTasksSegue"
#define kShowTaskDetailSegue @"ShowTaskDetailSegue"
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface STDListsAndTasksViewController () {
    STDStyle *style;
    STDActions *actions;
    STDTask *currentTask;
    NSString *currentTitle;
    NSString *listsHeaderTitle, *tasksHeaderTitle, *completedTasksHeaderTitle;  // Headers for sections.
    BOOL listChecked, detailVCIsEnabled;
    BOOL showSection0, showSection1, showSection2;
}
@property (nonatomic, strong) NSMutableArray *lists, *tasks, *completedTasks;   // Arrays with data.
@end

@implementation STDListsAndTasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    style = [STDStyle sharedStyle];
    self.taskDetailViewController = (STDTaskDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    actions = [[STDActions alloc] initActionsWithTableViewController:self
                                     andWithFetchedResultsController:[self fetchedResultsController]
                                                   andWithEditButton:self.editButton
                                         andWithCreateOrDeleteButton:self.createOrDeleteButton
                                                             andList:self.list];
    actions.segueIsEnabled = YES;
    detailVCIsEnabled = YES;
    // Hide sections headers.
    if (self.list != nil) {
        self.title = self.list.title;
        showSection0 = YES;
        showSection1 = YES;
        showSection2 = NO;
    }
    else self.title = style.standardTitle;
    _lists = nil;
    _tasks = nil;
    _completedTasks = nil;
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    _lists = nil;
    _tasks = nil;
    _completedTasks = nil;
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [self selectRowAuto];
}


// Automatically highlight the task.
- (void)selectRowAuto {
    if (IPAD) {
        if ([self.tableView numberOfSections] > 1 && self.tasks.count > 0 && currentTask) {
            int indexRow = -100;
            for (int i = 0; i < self.tasks.count; i++) if ((STDTask *)[self.tasks objectAtIndex:i] == currentTask) indexRow = i;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexRow inSection:1];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            if (CGRectEqualToRect([UIApplication sharedApplication].delegate.window.frame, [UIApplication sharedApplication].delegate.window.screen.bounds)) [self performSegueWithIdentifier:kShowTaskDetailSegue sender:currentTask];
        }
    }
}


#pragma mark - Buttons Actions

-(void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    [self detailViewControllerBecomesDisabled];
}


- (IBAction)pressedEditButton:(id)sender {
    if ((self.list == nil && self.lists.count == 0) || (self.lists.count == 0 && self.tasks.count == 0 && self.completedTasks.count == 0)) [actions noDataAlert];
    else {
        [self detailViewControllerBecomesDisabled];
        showSection0 = YES;
        showSection1 = YES;
        showSection2 = YES;
        [actions editAction];
        [self.tableView reloadData];
    }
}


- (IBAction)pressedCreateOrDeleteButton:(id)sender {
    if (self.list == nil) [actions createOrDeleteListAction:self.lists];
    else {
        // Creating.
        if (!actions.editIsEnabled) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
            ac.view.tintColor = style.mainColor;
            ac.popoverPresentationController.sourceView = self.view;
            ac.popoverPresentationController.sourceRect = self.view.bounds;
            
            // Cancel button.
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:style.cancelTitle
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
            [ac addAction:cancel];
            
            // Create list button.
            UIAlertAction *createList = [UIAlertAction actionWithTitle:style.listPopupCreateString
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [actions showPopupForList:nil];
                                                                   showSection0 = YES;
                                                               }];
            [ac addAction:createList];
            // Create task button.
            UIAlertAction *createTask = [UIAlertAction actionWithTitle:style.taskPopupCreateString
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   if (!actions.editIsEnabled) {
                                                                       [self performSegueWithIdentifier:kShowTaskDetailSegue sender:nil];
                                                                       showSection1 = YES;
                                                                   }
                                                               }];
            [ac addAction:createTask];
            [self presentViewController:ac animated:YES completion:nil];
        }
        // Deleting.
        else if (actions.editIsEnabled) {
            [actions deleteActionWithLists:_lists andTasks:_tasks andCompletedTasks:_completedTasks];
            [self detailViewControllerBecomesDisabled];
        }
    }
    _lists = nil;
    _tasks = nil;
    _completedTasks = nil;
}


- (void)pressedCheckButton:(id)sender {
    [actions checkButtonPressedOnCell:(STDCell *)[[sender superview] superview] inTableView:self.tableView];
}


- (void)sectionHeaderButtonPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    int sectionIndex = 0;
    if ([button.currentTitle isEqualToString:style.expandListsString] || [button.currentTitle isEqualToString:style.hideListsString]) {
        sectionIndex = 0;
        showSection0 = !showSection0;
    }
    if ([button.currentTitle isEqualToString:style.expandTasksString] || [button.currentTitle isEqualToString:style.hideTasksString]) {
        sectionIndex = 1;
        showSection1 = !showSection1;
    }
    if ([button.currentTitle isEqualToString:style.expandCompletedTasksString] || [button.currentTitle isEqualToString:style.hideCompletedTasksString]) {
        sectionIndex = 2;
        showSection2 = !showSection2;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Logic

// Make detail view controller disabled.
// (Detail view controller becomes disabled when changing current list.)
-(void)detailViewControllerBecomesDisabled {
    if (IPAD) {
        detailVCIsEnabled = NO;
        [self performSegueWithIdentifier:kShowTaskDetailSegue sender:nil];
        detailVCIsEnabled = YES;
    }
}


// Override property lists to sort lists by title.
- (NSMutableArray *) lists {
    if(_lists == nil) {
        NSArray *tempArr;
        if (self.list != nil) tempArr = [self.list.children.allObjects sortedArrayUsingComparator:^NSComparisonResult(STDList* list1, STDList* list2) { return [list1.title compare:list2.title]; }];
        else tempArr = [[self.fetchedResultsController fetchedObjects] sortedArrayUsingComparator:^NSComparisonResult(STDList* list1, STDList* list2) { return [list1.title compare:list2.title]; }];
        _lists = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempArr.count; i++) [_lists insertObject:[tempArr objectAtIndex:i] atIndex:i];
    }
    return _lists;
}


// Override property tasks to sort tasks by "starred" and then by expiration date.
- (NSMutableArray *) tasks {
    if(_tasks == nil) {
        
        // Select only incompleted tasks of list.
        NSMutableArray *tempArrWithIncompletedTasks = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.list.tasks.allObjects.count; i++) {
            STDTask *taskForRow = [self.list.tasks.allObjects objectAtIndex:i];
            if (!taskForRow.completed) [tempArrWithIncompletedTasks addObject:taskForRow];
        }
        // Sort them.
        NSArray *tempArr = [tempArrWithIncompletedTasks sortedArrayUsingComparator:^NSComparisonResult(STDTask* task1, STDTask* task2) {
            if (task1.starred && !task2.starred) return NSOrderedAscending;
            else if (!task1.starred && task2.starred) return NSOrderedDescending;
            else if ((task1.starred && task2.starred) || (!task1.starred && !task2.starred)) {
                if (task1.reminder && task2.reminder) return [task1.reminder compare:task2.reminder];
                else if (task1.reminder && !task2.reminder) return NSOrderedAscending;
                else if (!task1.reminder && task2.reminder) return NSOrderedDescending;
                else if (!task1.reminder && !task2.reminder) return [task1.task compare:task2.task];
            }
            return NSOrderedSame;
        }];
        _tasks = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempArr.count; i++) [_tasks insertObject:[tempArr objectAtIndex:i] atIndex:i];
    }
    return _tasks;
}


// Override property completedTasks to sort completed tasks by "starred" and then by expiration date.
- (NSMutableArray *) completedTasks {
    if (_completedTasks == nil) {
        // Select only completed tasks of list.
        NSMutableArray *tempArrWithCompletedTasks = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.list.tasks.allObjects.count; i++) {
            STDTask *taskForRow = [self.list.tasks.allObjects objectAtIndex:i];
            if (taskForRow.completed) [tempArrWithCompletedTasks addObject:taskForRow];
        }
        // Sort them.
        NSArray *tempArr = [tempArrWithCompletedTasks sortedArrayUsingComparator:^NSComparisonResult(STDTask* task1, STDTask* task2) {
            if (task1.starred && !task2.starred) return NSOrderedAscending;
            else if (!task1.starred && task2.starred) return NSOrderedDescending;
            else if ((task1.starred && task2.starred) || (!task1.starred && !task2.starred)) {
                if (task1.reminder && task2.reminder) return [task1.reminder compare:task2.reminder];
                else if (task1.reminder && !task2.reminder) return NSOrderedAscending;
                else if (!task1.reminder && task2.reminder) return NSOrderedDescending;
                else if (!task1.reminder && !task2.reminder) return [task1.task compare:task2.task];
            }
            return NSOrderedSame;
        }];
        _completedTasks = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempArr.count; i++) [_completedTasks insertObject:[tempArr objectAtIndex:i] atIndex:i];
    }
    return _completedTasks;
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowTaskDetailSegue]) {
        currentTask = (STDTask *)sender;
        STDTaskDetailViewController *tdvc = (STDTaskDetailViewController *)[[segue destinationViewController] topViewController];
        [tdvc setTask:currentTask];
        if (detailVCIsEnabled) [tdvc setList:self.list];
        else [tdvc setList:nil];
    }
}


// Segue doesn't work if edit mode is enabled.
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kShowListsAndTasksSegue])
        if (!actions.segueIsEnabled) return NO;     // Prevent segue from occurring.
    return YES;                                     // By default perform the segue transition.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sectionsCount = 1;                      // 0 - Lists.
    if (self.list != nil) sectionsCount = 3;    // 0 - Lists, 1 - Tasks, 2 - Completed tasks.
    return sectionsCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.list != nil) {
        if (section == 0) {
            if (showSection0) {
                [self tableView:self.tableView viewForHeaderInSection:0];
                [self tableView:self.tableView heightForHeaderInSection:0];
                return self.lists.count;
            }
        }
        if (section == 1) {
            if (showSection1) {
                [self tableView:self.tableView viewForHeaderInSection:1];
                [self tableView:self.tableView heightForHeaderInSection:1];
                return self.tasks.count;
            }
        }
        if (section == 2) {
            if (showSection2) {
                [self tableView:self.tableView viewForHeaderInSection:2];
                [self tableView:self.tableView heightForHeaderInSection:2];
                return self.completedTasks.count;
            }
        }
    }
    else return [[self.fetchedResultsController sections][section] numberOfObjects];
    return 0;
}


// Lists section expandable header.
- (NSString *)listsHeaderTitle {
    if (showSection0) listsHeaderTitle = style.expandListsString;
    else listsHeaderTitle = style.hideListsString;
    return listsHeaderTitle;
}


// Tasks section expandable header.
- (NSString *)tasksHeaderTitle {
    if (showSection1) tasksHeaderTitle = style.expandTasksString;
    else tasksHeaderTitle = style.hideTasksString;
    return tasksHeaderTitle;
}


// Completed tasks section expandable header.
- (NSString *)completedTasksHeaderTitle {
    if (showSection2) completedTasksHeaderTitle = style.expandCompletedTasksString;
    else completedTasksHeaderTitle = style.hideCompletedTasksString;
    return completedTasksHeaderTitle;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int height = style.sectionHeaderHeight;
    if (self.list == nil) height = 0;
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.list == nil) return nil;
    else {
        CGRect tableRect = self.view.frame;
        // Create the parent view that will hold header button.
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableRect.size.width, style.sectionHeaderHeight)];
        [customView setBackgroundColor:style.lightGrayColor];
        NSString *buttonTitle;
        if (section == 0) buttonTitle = self.listsHeaderTitle;
        if (section == 1) buttonTitle = self.tasksHeaderTitle;
        if (section == 2) buttonTitle = self.completedTasksHeaderTitle;
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectZero];
        button.frame = CGRectMake(20.0, 0.0, tableRect.size.width, style.sectionHeaderHeight);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sectionHeaderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:button];
        return customView;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListOrTaskCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath: indexPath];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = style.lightGrayColorForCell;
    [cell setSelectedBackgroundView:bgColorView];
    
    // Track check button tapping.
    cell.radioButton.tag = indexPath.row;
    [cell.radioButton addTarget:self action:@selector(pressedCheckButton:)forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


- (void)configureCell:(STDCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.tintColor = style.mainColor;
    // Radio button is unchecked by default.
    [cell.radioButton setTitle:style.emptyString forState:UIControlStateNormal];
    // Firstly, item is unchecked for updates.
    if (actions.editIsEnabled) {
        cell.radioButton.hidden = NO;
        cell.radioButton.enabled = YES;
        cell.starButton.hidden = YES;
        cell.starButton.enabled = NO;
        if (indexPath.section == 1 || indexPath.section == 2) {
            cell.checkButton.hidden = YES;
            cell.checkButton.enabled = NO;
        }
    }
    else {
        cell.radioButton.hidden = YES;
        cell.radioButton.enabled = NO;
        cell.starButton.hidden = NO;
        cell.starButton.enabled = YES;
        if (indexPath.section == 1 || indexPath.section == 2) {
            cell.checkButton.hidden = NO;
            cell.checkButton.enabled = YES;
        }
    }
    // Configure cell for list.
    if (self.list == nil || indexPath.section == 0) [cell configureCellForList:self.lists[indexPath.row]];
    // Configure cell for task.
    else {
        STDTask *taskForRow;
        if (indexPath.section == 1) taskForRow = self.tasks[indexPath.row];
        else if (indexPath.section == 2) taskForRow = self.completedTasks[indexPath.row];
        [cell configureCellForTask:taskForRow withStarCallback:^ {
            taskForRow.starred = !taskForRow.starred;
            [STDCoreDataUtils saveContext];
            // Resort tasks.
            _tasks = nil;
            _completedTasks = nil;
            [self.tableView reloadData];
        }
          andWithCompletedCallback:^ {
              taskForRow.completed = !taskForRow.completed;
              [STDCoreDataUtils saveContext];
              if (taskForRow.completed) [actions removeTaskNotification:taskForRow];
              else [actions addTaskNotification:taskForRow];
              // Resort tasks.
              _tasks = nil;
              _completedTasks = nil;
              [self.tableView reloadData];
          }];
    }
}


// This method implements tap on cell.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    // If Edit mode is enabled, tap on the cell calls showPopupForList method for renaming.
    if (actions.editIsEnabled) actions.segueIsEnabled = NO;
    // If it's a Lists section - "move into" a list.
    if (indexPath.section == 0 && !actions.editIsEnabled) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        STDListsAndTasksViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"ListsAndTasksViewController"];
        [dest setList:self.lists[indexPath.row]];
        [self.navigationController pushViewController:dest animated:YES];
        
        // Detail view controller becomes disabled when changing list.
        [self detailViewControllerBecomesDisabled];
    }
    if (indexPath.section == 0 && actions.editIsEnabled) [actions showPopupForList:self.lists[indexPath.row]];
    // If it's a Tasks section - show task detail view controller.
    else if (indexPath.section == 1 && !actions.editIsEnabled) {
        STDTask *taskForRow = self.tasks[indexPath.row];
        [self performSegueWithIdentifier:kShowTaskDetailSegue sender:taskForRow];
        [actions doneAction];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Deleting.
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete list.
            if (indexPath.section == 0) {
                STDList *listForRow = self.lists[indexPath.row];
                [[STDCoreDataUtils managedObjectContext] deleteObject:listForRow];
                // Delete notification.
                [actions removeTaskNotificationsFromList:listForRow];
                [[STDCoreDataUtils managedObjectContext] deleteObject:listForRow];
            }
            // Delete task.
            if (indexPath.section == 1 || indexPath.section == 2) {
                STDTask *taskForRow;
                if (indexPath.section == 1) taskForRow = self.tasks[indexPath.row];
                else if (indexPath.section == 2) taskForRow = self.completedTasks[indexPath.row];
                
                // Delete notification.
                [actions removeTaskNotification:taskForRow];
                [[STDCoreDataUtils managedObjectContext] deleteObject:taskForRow];
            }
            [STDCoreDataUtils saveContext];
            _lists = nil;
            _tasks = nil;
            _completedTasks = nil;
            currentTask = nil;
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self detailViewControllerBecomesDisabled];
        }
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    // Type of entity.
    NSFetchRequest *fetchRequest = STDList.fetchRequest;
    
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", self.list];
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:[STDCoreDataUtils managedObjectContext]
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    self.fetchedResultsController = nil;
    self.fetchedResultsController.delegate = nil;
}

@end

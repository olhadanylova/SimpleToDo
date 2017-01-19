//
//  DetailViewController.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDTaskDetailViewController class displays task details.

#import "STDTaskDetailViewController.h"
#import "STDListsAndTasksViewController.h"
#import "STDList+CoreDataClass.h"
#import "STDTask+CoreDataClass.h"
#import "STDCoreDataUtils.h"
#import "STDActions.h"
#import "STDStyle.h"

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface STDTaskDetailViewController () {
    STDStyle *style;
    STDActions *actions;
    BOOL starred;
}
@end

@implementation STDTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide keyboard by tapping on the view's background.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
    [self configureView];
    actions = [[STDActions alloc] init];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Configure View

- (void)configureView {
    // Set style for different controls.
    style = [STDStyle sharedStyle];
    self.taskTextField.tintColor = style.mainColor;
    self.notesTextView.tintColor = style.mainColor;
    [self setNotesTextViewStyle];
    self.dateSwitch.onTintColor = style.mainColor;
    self.navigationController.navigationBar.tintColor = style.mainColor;
    self.navigationController.toolbar.tintColor = style.mainColor;
    
    if (!self.list && !self.task) [self viewIsEnabled:NO];
    else if (self.list && !self.task) {
        [self viewIsEnabled:YES];
        self.navigationItem.title = style.taskPopupCreateString;
        // Hide the Delete button by changing the BarButton items array in the toolbar.
        NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
        [toolbarButtons removeObject:self.deleteButton];
        self.toolbarItems = toolbarButtons;
        [self dateSwitchIsOn];
        [self datePickerIsEnabled];
    }
    else if (self.list && self.task) {
        [self viewIsEnabled:YES];
        self.navigationItem.title = self.task.task;
        starred = self.task.starred;
        self.taskTextField.text = self.task.task;
        self.notesTextView.text = self.task.notes;
        if (self.task.reminder) [self.datePicker setDate:self.task.reminder];
        else [self.datePicker setDate:[NSDate date]];
        [self dateSwitchIsOn];
        [self datePickerIsEnabled];
    }
    [self updateStarImage];
    [self.taskTextField becomeFirstResponder];
    self.datePicker.minimumDate = [NSDate date];
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
}


// Set border around notes text view.
- (void)setNotesTextViewStyle {
    self.notesTextView.layer.borderWidth = style.textBorderWidth;
    self.notesTextView.layer.cornerRadius = style.textCornerRadius;
    self.notesTextView.layer.borderColor = [style.textBorderColor CGColor];
}


- (void) viewIsEnabled:(BOOL)status {
    self.starButton.enabled = status;
    self.taskTextField.enabled = status;
    self.notesTextView.editable = status;
    self.dateSwitch.enabled = status;
    [self.dateSwitch setOn:status];
    self.datePicker.enabled = status;
    self.navigationController.toolbar.hidden = !status;
    if (status == NO) {
        self.task = nil;
        self.navigationItem.title = style.emptyString;
        [self.starButton setImage:style.uncheckedStarImage forState:UIControlStateNormal];
        self.taskTextField.text = self.notesTextView.text = style.emptyString;
        [self.dateSwitch setOn:NO];
    }
}


- (void)updateStarImage {
    if (starred) [self.starButton setImage:style.checkedStarImage forState:UIControlStateNormal];
    else [self.starButton setImage:style.uncheckedStarImage forState:UIControlStateNormal];
}


- (void)dateSwitchIsOn {
    if (self.task.reminder != nil) [self.dateSwitch setOn:YES animated:YES];
    else [self.dateSwitch setOn:NO animated:YES];
}


- (void)datePickerIsEnabled {
    if ([self.dateSwitch isOn]) self.datePicker.enabled = YES;
    else self.datePicker.enabled = NO;
}


#pragma mark - Buttons Actions

- (IBAction)pressedStarButton:(id)sender {
    starred = !starred;
    [self updateStarImage];
}


- (IBAction)toggledDateSwitch:(id)sender {
    [self datePickerIsEnabled];
    if (![self.dateSwitch isOn])[self.datePicker setDate:[NSDate date]];
}


- (IBAction)pressedDeleteButton:(id)sender {
    // Delete notification.
    [actions removeTaskNotification:self.task];
    // Delete task.
    [[STDCoreDataUtils managedObjectContext] deleteObject:self.task];
    [STDCoreDataUtils saveContext];
    [self reloadDataInTableView];
}


- (IBAction)pressedSaveButton:(id)sender {
    if (self.task == nil)
        self.task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[STDCoreDataUtils managedObjectContext]];
    self.task.list = self.list;
    self.task.task = self.taskTextField.text;
    self.task.starred = starred;
    self.task.notes = self.notesTextView.text;
    NSDate *reminder = self.datePicker.date; // To track if reminder becomes nil.
    if (self.datePicker.enabled) self.task.reminder = self.datePicker.date;
    else self.task.reminder = nil;
    // Check reminder.
    if (self.task.reminder) [actions addTaskNotification:self.task];
    else if (reminder && !self.task.reminder) {
        self.task.reminder = reminder;
        [actions removeTaskNotification:self.task];
        self.task.reminder = nil;
    }
    [STDCoreDataUtils saveContext];
    [self reloadDataInTableView];
}


- (void)reloadDataInTableView {
    // If app is running in full screen on iPad.
    if (IPAD && CGRectEqualToRect([UIApplication sharedApplication].delegate.window.frame, [UIApplication sharedApplication].delegate.window.screen.bounds)) {
        UINavigationController *navController = self.splitViewController.viewControllers[0];
        STDListsAndTasksViewController *controller = (STDListsAndTasksViewController *)navController.topViewController;
        [controller.tableView reloadData];
        [controller viewWillAppear:YES];
        [self viewIsEnabled:NO];
    }
    // If app is running on iPhone or iPod.
    else [self.navigationController.navigationController popViewControllerAnimated:YES];
}

@end

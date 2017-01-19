//
//  DetailViewController.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDTaskDetailViewController class displays task details.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>

@class STDList;
@class STDTask;

@interface STDTaskDetailViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) STDList *list;
@property (strong, nonatomic) STDTask *task;

@property (strong, nonatomic) IBOutlet UIButton *starButton;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) IBOutlet UISwitch *dateSwitch;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

- (IBAction)pressedStarButton:(id)sender;
- (IBAction)pressedDeleteButton:(id)sender;
- (IBAction)pressedSaveButton:(id)sender;
- (IBAction)toggledDateSwitch:(id)sender;

- (void)viewIsEnabled:(BOOL)status;

@end


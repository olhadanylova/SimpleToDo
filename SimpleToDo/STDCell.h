//
//  STDCell.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDCell class implements custom table view cell.

#import <UIKit/UIKit.h>

@class STDList;
@class STDTask;

@interface STDCell : UITableViewCell

@property(nonatomic) BOOL isChecked;

@property(strong, nonatomic) IBOutlet UILabel *listOrTaskLabel;
@property(strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property(strong, nonatomic) IBOutlet UIButton *checkButton;
@property(strong, nonatomic) IBOutlet UIButton *starButton;
@property(strong, nonatomic) IBOutlet UIButton *radioButton;

- (IBAction)pressedCheckButton:(id)sender;
- (IBAction)pressedStarButton:(id)sender;
- (IBAction)pressedRadioButton:(id)sender;

- (void)configureCellForTask:(STDTask *)task withStarCallback:(void(^)())starCallBack andWithCompletedCallback:(void(^)())completedCallback;
- (void) configureCellForList:(STDList*)list;

@end

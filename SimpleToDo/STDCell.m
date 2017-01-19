//
//  STDCell.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDCell class implements custom table view cell.

#import "STDCell.h"
#import "STDStyle.h"
#import "STDList+CoreDataClass.h"
#import "STDTask+CoreDataClass.h"

@interface STDCell () {
    STDStyle *style;
    void(^starCallback)();
    void(^completedCallback)();
}
@end

@implementation STDCell

#pragma mark - Style

- (STDStyle *)style {
    style = [STDStyle sharedStyle];
    [self setRadioButtonStyle];
    return style;
}


- (void)setRadioButtonStyle {
    self.radioButton.layer.borderWidth = style.checkBorderWidth;
    self.radioButton.layer.cornerRadius = self.radioButton.bounds.size.width / 2.0;
    self.radioButton.layer.borderColor = [style.mainColor CGColor];
    [self.radioButton setTitleColor:style.mainColor forState:UIControlStateNormal];
}


#pragma mark - Buttons Actions

- (IBAction)pressedCheckButton:(id)sender {
    if (completedCallback != nil) completedCallback();
}


- (IBAction)pressedStarButton:(id)sender {
    if (starCallback != nil) starCallback();
}

- (IBAction)pressedRadioButton:(id)sender {
    if ([self.radioButton.currentTitle isEqualToString:style.emptyString]) {
        [self.radioButton setTitle:style.radioTitle forState:UIControlStateNormal];
        self.isChecked = YES;
    }
    else  {
        [self.radioButton setTitle:style.emptyString forState:UIControlStateNormal];
        self.isChecked = NO;
    }
}


#pragma mark - Cell Configuration

- (void) configureCellForList:(STDList*)list {
    self.listOrTaskLabel.textColor = [UIColor blackColor];
    
    self.checkButton.layer.borderWidth = 0;
    self.checkButton.tintColor = style.grayColor;
    [self.checkButton setImage:style.listImage forState:UIControlStateNormal];
    [self.checkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [self.starButton setImage:nil forState:UIControlStateNormal];
    [self.starButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.listOrTaskLabel.text = list.title;
    self.detailsLabel.text = [[[style.listsString
                           stringByAppendingString:[@(list.children.count) stringValue]] stringByAppendingString:@", "] stringByAppendingString:[style.tasksString stringByAppendingString:[@(list.tasks.count) stringValue]]];
    self.detailsLabel.textColor = style.grayColor;
}


- (void)configureCellForTask:(STDTask *)task withStarCallback:(void(^)())_starCallback andWithCompletedCallback:(void(^)())_completedCallback {
    self.checkButton.layer.borderWidth = style.checkBorderWidth;
    self.checkButton.layer.cornerRadius = self.checkButton.bounds.size.width / 2.0;
    self.checkButton.layer.borderColor = [style.grayColor CGColor];
    [self.checkButton setImage:nil forState:UIControlStateNormal];
    [self.checkButton setTitle:style.emptyString forState:UIControlStateNormal];
    if (task.starred) [self.starButton setImage:style.checkedStarImage forState:UIControlStateNormal];
    else [self.starButton setImage:style.uncheckedStarImage forState:UIControlStateNormal];
    starCallback = _starCallback;
    completedCallback = _completedCallback;    
    // Labels.
    if (task.reminder != nil) {
        // Default labels colors.
        self.listOrTaskLabel.textColor = [UIColor blackColor];
        self.detailsLabel.textColor = style.grayColor;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:style.dateFormat];
        // If task is expired.
        if ([task.reminder compare:[NSDate date]] == NSOrderedAscending) {
            self.listOrTaskLabel.textColor = style.mainColor;
            self.detailsLabel.textColor = style.mainColor;
            self.detailsLabel.text = style.expiredString;
        }
        else {
            // If task expires today but there is still time to do it.
            if ([[dateFormatter stringFromDate:task.reminder] isEqualToString:
                 [dateFormatter stringFromDate:[NSDate date]]]) {
                self.listOrTaskLabel.textColor = style.mainColor;
                self.detailsLabel.textColor = style.mainColor;
            }
            // If there is much time to do task.
            [dateFormatter setDateFormat:style.dateFormatWithHours];
            self.detailsLabel.text = [style.remindString stringByAppendingString:[dateFormatter stringFromDate:task.reminder]];
        }
    }
    // If there is no expiration date.
    else {
        // Default labels colors.
        self.listOrTaskLabel.textColor = [UIColor blackColor];
        self.detailsLabel.textColor = style.grayColor;
        self.detailsLabel.text = style.emptyString;
    }
    // Task completion.
    if (task.completed) {
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        self.listOrTaskLabel.attributedText = [[NSAttributedString alloc] initWithString:task.task attributes:attributes];
        self.checkButton.layer.borderColor = [style.mainColor CGColor];
        self.checkButton.tintColor = style.mainColor;
        [self.checkButton setTitle:style.checkTitle forState:UIControlStateNormal];
    }
    else {
        self.listOrTaskLabel.text = task.task;
        self.checkButton.layer.borderColor = [style.grayColor CGColor];
        self.checkButton.tintColor = style.grayColor;
        [self.checkButton setTitle:style.emptyString forState:UIControlStateNormal];
    }
}

@end

//
//  STDStyle.m
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDStyle class provides different styles for controls and controllers.

#import "STDStyle.h"

@implementation STDStyle

+ (STDStyle *)sharedStyle {
    static dispatch_once_t onceToken;
    static STDStyle *style = nil;
    dispatch_once(&onceToken, ^{ style = [[self alloc] init]; });
    return style;
}


- (id)init {
    if (self = [super init]) {
        // Colors.
        self.mainColor = [UIColor colorWithRed:1.00 green:0.16 blue:0.32 alpha:1.0];
        self.grayColor = [UIColor colorWithRed:0.71 green:0.69 blue:0.69 alpha:1.0];
        
        self.lightGrayColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
        self.lightGrayColorForCell = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0];
        
        // Images.
        self.listImage = [UIImage imageNamed:@"folder"];
        self.checkedStarImage = [UIImage imageNamed:@"checked_star"];
        self.uncheckedStarImage = [UIImage imageNamed:@"unchecked_star"];
        
        // Section header settings.
        self.sectionHeaderHeight = 40.0f;
        
        // Check button and radio button settings.
        self.checkBorderWidth = 1.0f;
        
        // Text controls properties.
        self.textBorderWidth = 1.0f;
        self.textCornerRadius = 10.0f;
        self.textBorderColor = _lightGrayColor;
        
        // Titles.
        self.emptyString = @"";
        self.checkTitle = @"✓";
        self.radioTitle = @"●";
        self.okTitle = @"OK";
        self.standardTitle = NSLocalizedString(@"standardTitle", @"ToDo Lists");
        self.cancelTitle = NSLocalizedString(@"cancelTitle", @"Cancel");
        self.editTitle = NSLocalizedString(@"editTitle", @"Edit");
        self.doneTitle = NSLocalizedString(@"doneTitle", @"Done");
        self.createNewTitle = NSLocalizedString(@"createNewTitle", @"New");
        self.deleteTitle = NSLocalizedString(@"deleteTitle", @"Delete");
        
        // Another strings.
        self.listsString = NSLocalizedString(@"listsString", @"lists:");
        self.tasksString = NSLocalizedString(@"tasksString", @"tasks:");
        self.inListString = NSLocalizedString(@"inListString", @"in list");
        self.dateFormat = NSLocalizedString(@"dateFormat", @"dd/MM/yyyy");
        self.dateFormatWithHours = NSLocalizedString(@"dateFormatWithHours", @"dd/MM/yyyy HH:mm");
        self.remindString = NSLocalizedString(@"remindString", @"remind ");
        self.expiredString = NSLocalizedString(@"expiredString", @"expired");
        self.ooopsString = NSLocalizedString(@"ooopsString", @"Ooooops!");
        self.ooopsMessageString = NSLocalizedString(@"ooopsMessageString", @"There is no data you can edit here");
        self.ooopsButtonString = NSLocalizedString(@"ooopsButtonString", @"Back");
        self.listNameString = NSLocalizedString(@"listNameString", @"List name");
        self.listPopupCreateString = NSLocalizedString(@"listPopupCreateString", @"New list");
        self.listPopupRenameString = NSLocalizedString(@"listPopupRenameString", @"Rename list");
        self.taskPopupCreateString = NSLocalizedString(@"taskPopupCreateString", @"New task");
        self.deleteItemString = NSLocalizedString(@"deleteItemString", @"Delete this item?");
        self.deleteItemsString = NSLocalizedString(@"deleteItemsString", @"Delete these items?");
        self.expandListsString = NSLocalizedString(@"expandLists", @"- Lists");
        self.hideListsString = NSLocalizedString(@"hideLists", @"+ Lists");
        self.expandTasksString = NSLocalizedString(@"expandTasks", @"- Tasks");
        self.hideTasksString = NSLocalizedString(@"hideTasks", @"+ Tasks");
        self.expandCompletedTasksString = NSLocalizedString(@"expandCompletedTasks", @"- Completed tasks");
        self.hideCompletedTasksString = NSLocalizedString(@"hideCompletedTasks", @"+ Completed tasks");
        
    }
    return self;
}

@end

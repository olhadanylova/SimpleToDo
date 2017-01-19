//
//  STDStyle.h
//  SimpleToDo
//
//  Created by Olha Danylova on 27.12.16.
//  Copyright © 2016 Olha Danylova. All rights reserved.
//

// STDStyle class provides different styles for controls and controllers.

#import <UIKit/UIKit.h>

@interface STDStyle : NSObject

@property(strong, nonatomic) UIColor *mainColor;                           // Main color used in the app.
@property(strong, nonatomic) UIColor *grayColor;                           // Gray color.
@property(strong, nonatomic) UIColor *lightGrayColor;                      // Light gray color.
@property(strong, nonatomic) UIColor *lightGrayColorForCell;               // Light gray color for cell. Different from light gray color.

@property(strong, nonatomic) UIImage *listImage;                           // List image.
@property(strong, nonatomic) UIImage *checkedStarImage;                    // Checked star image.
@property(strong, nonatomic) UIImage *uncheckedStarImage;                  // Unchecked star image.

// Section header settings.
@property(nonatomic) float sectionHeaderHeight;

// Titles.
@property(strong, nonatomic) NSString *emptyString;
@property(strong, nonatomic) NSString *standardTitle;
@property(strong, nonatomic) NSString *checkTitle;             // The title "✓" of checked button.
@property(strong, nonatomic) NSString *radioTitle;             // The title "●" of radio button.
@property(strong, nonatomic) NSString *okTitle;                // The title "OK".
@property(strong, nonatomic) NSString *cancelTitle;            // The title "Cancel".
@property(strong, nonatomic) NSString *editTitle;              // The title of "Edit" button.
@property(strong, nonatomic) NSString *doneTitle;              // The title of "Done" button.
@property(strong, nonatomic) NSString *createNewTitle;         // The title of "New" button.
@property(strong, nonatomic) NSString *deleteTitle;            // The title of "Delete" button.

// Another strings.
@property(strong, nonatomic) NSString *listsString, *tasksString, *inListString;
@property(strong, nonatomic) NSString *dateFormat, *dateFormatWithHours;
@property(strong, nonatomic) NSString *remindString, *expiredString;
@property(strong, nonatomic) NSString *listNameString, *listPopupCreateString, *listPopupRenameString, *taskPopupCreateString;
@property(strong, nonatomic) NSString *deleteItemString, *deleteItemsString;
@property(strong, nonatomic) NSString *expandListsString, *hideListsString;
@property(strong, nonatomic) NSString *expandTasksString, *hideTasksString;
@property(strong, nonatomic) NSString *expandCompletedTasksString, *hideCompletedTasksString;
@property(strong, nonatomic) NSString *ooopsString, *ooopsMessageString, *ooopsButtonString;

// Check button and radio button properties.
@property(nonatomic) float checkBorderWidth;           // Border width for check button and radio button.

// Text controls properties.
@property(nonatomic) float textBorderWidth;
@property(nonatomic) float textCornerRadius;
@property(strong, nonatomic) UIColor *textBorderColor;

+ (STDStyle *)sharedStyle;

@end

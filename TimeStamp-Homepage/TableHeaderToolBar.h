//
//  TableHeaderToolBar.h
//  CalendarTracker
//
//  Created by Timothy Chong on 2/3/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TableHeaderToolBar;

@protocol TableHeaderToolBarDelegate <NSObject>
@optional
-(void)update;
-(void)backButtonPressed;
-(void)forwardButtonPressed;
@end

@interface TableHeaderToolBar : UIToolbar
@property (weak, nonatomic) IBOutlet UIBarButtonItem * dateLabelItem;
- (IBAction)forwardButtonPressed:(id)sender;
- (IBAction)backwardButtonPressed:(id)sender;
@property(nonatomic,weak) IBOutlet id <TableHeaderToolBarDelegate>delegate;
@property(nonatomic,weak) NSString* dateString;
-(void) editDateLabelString:(NSString*)str;
@end

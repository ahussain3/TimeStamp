//
//  TableHeaderToolBar.h
//  CalendarTracker
//
//  Created by Awais Hussain on 2/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
@class TableHeaderToolBar;

@protocol TableHeaderToolBarDelegate <NSObject>
-(void)update;
@end

@interface TableHeaderToolBar : UIToolbar
@property (strong, nonatomic) MySingleton *singleton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem * dateLabelItem;
- (IBAction)forwardButtonPressed:(id)sender;
- (IBAction)backwardButtonPressed:(id)sender;
@property(nonatomic,weak) IBOutlet id <TableHeaderToolBarDelegate>delegate;
@property(nonatomic,weak) NSString* dateString;
-(void) editDateLabelString:(NSString*)str;
@end

//
//  TrendGraphViewController.h
//  CalendarTracker
//
//  Created by Awais Hussain on 2/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
#import "TableHeaderToolBar.h"
@class TrendGraphView,SingleCalendarViewController;
@interface TrendGraphViewController : UIViewController <TableHeaderToolBarDelegate>
@property (weak, nonatomic) IBOutlet TableHeaderToolBar *dateBar;
@property (weak, nonatomic) IBOutlet TrendGraphView *graph;
@property(weak, nonatomic)SingleCalendarViewController* previousController;

@property (strong, nonatomic) MySingleton *singleton;
@property(strong,nonatomic)NSDate *startDate;
@property(strong,nonatomic)NSDate *endDate;

@end

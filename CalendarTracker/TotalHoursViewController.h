//
//  TotalHoursViewController.h
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
#import "MySingleton.h"
#import "ColumnGraphView.h"
#import "PieChartView.h"
#import "TableHeaderToolBar.h"
#import "UtilityMethods.h"
#import "TimePeriodToolbar.h"
@class EventKitData,TSCalendarSegment,TableHeaderToolBar;

@interface TotalHoursViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,ColumnGraphViewDataSource,TableHeaderToolBarDelegate, PieChartViewDataSource, TimePeriodToolbarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MySingleton *singleton;

// Data stored by this controller
@property (nonatomic,strong) NSArray *calendars;
@property(strong,nonatomic)NSDate *startDate;
@property(strong,nonatomic)NSDate *endDate;

@property (nonatomic,strong) EventKitData* store;

// Total Hours for time period - accross all calendars and events
@property (assign,nonatomic) NSInteger totalHours;

@property (strong,nonatomic)NSString * identifier;

-(TSCalendarSegment*) getNewCaldendar;

@property (weak, nonatomic) IBOutlet TableHeaderToolBar *dateBar;
@property (weak, nonatomic) IBOutlet TimePeriodToolbar * timeBar;

@end

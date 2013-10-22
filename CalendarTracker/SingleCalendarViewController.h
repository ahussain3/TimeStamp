//
//  SingleCalendarViewController.h
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UtilityMethods.h"
#import "MySingleton.h"
#import "TableHeaderToolBar.h"
#import "TrendGraphView.h"
#import "TimePeriodToolbar.h"

@class TSCalendarSegment,EventKitData,TotalHoursViewController;
@interface SingleCalendarViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,TableHeaderToolBarDelegate,TrendGraphViewDataSource, EKEventViewDelegate, TimePeriodToolbarDelegate>

@property (strong, nonatomic) MySingleton *singleton;

// Data stored by this controller
@property (nonatomic,strong) TSCalendarSegment* calSegment;
@property(strong,nonatomic)NSDate *startDate;
@property(strong,nonatomic)NSDate *endDate;

@property (weak, nonatomic) IBOutlet TableHeaderToolBar *dateBar;
@property (nonatomic,strong) EventKitData* store;
@property (nonatomic,strong) NSArray *calendars;

@property (nonatomic,strong) NSDictionary * eventArray;
@property (nonatomic,strong) NSArray * dateArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic)TotalHoursViewController *previousController;
@property (weak, nonatomic) IBOutlet TimePeriodToolbar * timeBar;
@end

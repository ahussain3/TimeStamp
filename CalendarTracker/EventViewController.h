//
//  EventViewController.h
//  CalendarTracker
//
//  Created by Awais Hussain on 1/25/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UtilityMethods.h"
#import "TableHeaderToolBar.h"
#import "MySingleton.h"
#import "TimePeriodToolbar.h"

@class EKEventStore,TableHeaderToolBar;
@interface EventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,TableHeaderToolBarDelegate,TimePeriodToolbarDelegate,EKEventViewDelegate>

@property (strong, nonatomic) MySingleton *singleton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) EKEventStore *store;

// Events to display
@property (strong, nonatomic) NSDictionary *arrayOfAllEvents;
@property (strong, nonatomic) NSArray *titlesArray;
@property(strong,nonatomic)NSDate * startDate;
@property(strong,nonatomic)NSDate * endDate;

@property (weak, nonatomic) IBOutlet TableHeaderToolBar *dateBar;
@property (weak, nonatomic) IBOutlet TimePeriodToolbar * timeBar;

-(void)initializeDates;

@end

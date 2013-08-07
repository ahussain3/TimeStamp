//
//  TSDayViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "TSDayViewController.h"
#import "GCCalendarEvent.h"
#import "GCCalendarTile.h"
#import "GCCalendar.h"
#import "TSCalendarStore.h"
#import "GCCalendarTodayView.h"
#import "GCGlobalSettings.h"

#define kAnimationDuration 0.3f

@interface TSDayViewController ()
@property (nonatomic, strong) NSDate *date;

@end

@implementation TSDayViewController

@synthesize date = _date;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupCalendar];
    }
    return self;
}

#pragma mark setup methods
- (id)init {
	if(self = [super init]) {
        [self setupCalendar];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    [self setupCalendar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCalendar {
    // create calendar view
    // GCCalendarView delegate / datasource.
    self.dataSource = self;
    
    viewDirty = YES;
    viewVisible = NO;
    
    self.title = @"TimeStamp";
    self.tabBarItem.image = [UIImage imageNamed:@"Calendar.png"];

}

#pragma mark setters and getters
- (NSDate *)date {
    if (_date == nil) {
        _date = [NSDate date];
    }
    return _date;
}

#pragma mark functionality
- (void)createEvent:(GCCalendarEvent *)event AtPoint:(CGPoint)point withDuration:(NSTimeInterval)seconds {
    // Work out which view we're going to draw it in.
    GCCalendarTodayView *activeView;
    CGPoint newPoint = [self.view convertPoint:point toView:todayView];
    CGFloat yValue = newPoint.y;
    if (yValue >= -kTodayViewHeight && yValue < 0) {
        yValue += kTodayViewHeight;
        activeView = yesterdayView;
    } else if (yValue >= 0 && yValue < kTodayViewHeight) {
        activeView = todayView;
    } else if (yValue >= kTodayViewHeight && yValue < 2 * kTodayViewHeight) {
        activeView = tomorrowView;
        yValue -= kTodayViewHeight;
    } else {
        // Should never be here - error.
    }
    
    // Set the date of the created event.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:activeView.date];
    CGFloat time = [self timeForYValue:yValue];
    [components setHour:floorf(time)];
    [components setMinute:(time - floorf(time)) * 60];
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    event.startDate = startDate;
    event.endDate = [NSDate dateWithTimeInterval:seconds sinceDate:startDate];
    
    [activeView drawNewEvent:event];
    
    // Update the model to reflect this new created event.
    [[TSCalendarStore instance] createNewEvent:event];
}

#pragma mark GCCalendarDataSource
- (NSArray *)calendarEventsForDate:(NSDate *)date {
    NSArray *EKArray = [[TSCalendarStore instance] allCalendarEventsForDate:date];
    
    // convert events from EKEvent to GCCalendarEvent
    NSMutableArray *GCEventArray = [[NSMutableArray alloc] init];
    for (EKEvent *e in EKArray) {
        GCCalendarEvent *gce = [GCCalendarEvent createGCEventFromEKEvent:e];
        [GCEventArray addObject:gce];
    }

    return [GCEventArray copy];
}

#pragma mark Utility methods

- (CGFloat)timeForYValue:(CGFloat)yValue {
    // returns time in hours.
    return ((yValue - kTopLineBuffer) / (2 * kHalfHourDiff));
}

// Replacing the GCCalPortraitView functionality
#pragma mark calendar actions
- (void)calendarShouldReload:(NSNotification *)notif {
	viewDirty = YES;
}

#pragma mark button actions
- (void)today {
    self.date = [NSDate date];
	[self reloadData];
}

#pragma mark view notifications
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (viewDirty) {
		[self reloadData];
		viewDirty = NO;
	}
    [self setCalendarBounds];
	viewVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	viewVisible = NO;
}
- (void)setCalendarBounds {
    scrollView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, self.calWrapperView.frame.size.height);
    scrollView.contentSize = CGSizeMake(self.calWrapperView.frame.size.width, 3 * kTodayViewHeight);
    compositeView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, 3 * kTodayViewHeight);
    yesterdayView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, kTodayViewHeight);
    todayView.frame = CGRectMake(0, kTodayViewHeight, self.calWrapperView.frame.size.width, kTodayViewHeight);
    tomorrowView.frame = CGRectMake(0, 2 * kTodayViewHeight, self.calWrapperView.frame.size.width, kTodayViewHeight);
    [scrollView setContentOffset:CGPointMake(0, kTodayViewHeight)];
}

- (void)reloadData {
	// drop all subviews
//	[self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Setup scroll view
    scrollView = [[UIScrollView alloc] init];
    scrollView.userInteractionEnabled = YES;
    scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    scrollView.clipsToBounds = YES;
        
    // Setup yesterday view
//    NSDate *yesterday = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.date];
//    NSArray *events_yesterday = [self calendarEventsForDate:yesterday];
//    yesterdayView = [[GCCalendarTodayView alloc] initWithEvents:events_yesterday];
//    yesterdayView.date = yesterday;
    
    // Setup today view
    NSArray *events_today = [self calendarEventsForDate:self.date];
    todayView = [[GCCalendarTodayView alloc] initWithEvents:events_today];
    todayView.delegate = self;
    todayView.date = self.date;
    
    // Setup tomorrow view
//    NSDate *tomorrow = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.date];
//    NSArray *events_tomorrow = [self calendarEventsForDate:tomorrow];
//    tomorrowView = [[GCCalendarTodayView alloc] initWithEvents:events_tomorrow];
//    tomorrowView.date = tomorrow;
    
    // Create a composite view combining the three we just created.
    compositeView = [[UIView alloc] init];
    NSLog(@"Composite View interaction enabled?: %i", compositeView.userInteractionEnabled);
    [compositeView addSubview:yesterdayView];
    [compositeView addSubview:todayView];
    [compositeView addSubview:tomorrowView];
    compositeView.clipsToBounds = YES;
    
	[scrollView addSubview:compositeView];
    [self.calWrapperView addSubview:scrollView];
    
    if (viewVisible) {[self setCalendarBounds];}
}

#pragma mark GCCalendarTodayViewDelegate methods

- (void)updateEventWithNewTimes:(GCCalendarEvent *)gcevent {
    [[TSCalendarStore instance] updateGCCalendarEvent:gcevent];
}


@end

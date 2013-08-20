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
#import "MyAlertViewDelegate.h"

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
    model = [TSCalendarStore instance];
    
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
    CGPoint newPoint = [self.view convertPoint:point toView:todayView];
    CGFloat yValue = newPoint.y;
    
    // Work out which view we're going to draw it in.
//    GCCalendarTodayView *activeView;
//    if (yValue >= -kTodayViewHeight && yValue < 0) {
//        yValue += kTodayViewHeight;
//        activeView = yesterdayView;
//    } else if (yValue >= 0 && yValue < kTodayViewHeight) {
//        activeView = todayView;
//    } else if (yValue >= kTodayViewHeight && yValue < 2 * kTodayViewHeight) {
//        activeView = tomorrowView;
//        yValue -= kTodayViewHeight;
//    } else {
//        // Should never be here - error.
//    }
    
    // Set the date of the created event.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:todayView.date];
    CGFloat time = [self timeForYValue:yValue];
    [components setHour:floorf(time)];
    NSInteger minutes = (time - floorf(time)) * 60;
    minutes = SNAP_TO_MINUTE_INCREMENT * (int)(minutes / SNAP_TO_MINUTE_INCREMENT + 0.5);
    [components setMinute:minutes];
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    event.startDate = startDate;
    event.endDate = [NSDate dateWithTimeInterval:seconds sinceDate:startDate];
    
    // Update the model to reflect this new created event.
    event = [[TSCalendarStore instance] createNewEvent:event];
    [todayView addNewEvent:event];
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
    scrollView.contentSize = CGSizeMake(self.calWrapperView.frame.size.width, kTodayViewHeight);
    compositeView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, kTodayViewHeight);
    todayView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, kTodayViewHeight);

    
//    yesterdayView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, kTodayViewHeight);
//    tomorrowView.frame = CGRectMake(0, 2 * kTodayViewHeight, self.calWrapperView.frame.size.width, kTodayViewHeight);
    [scrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)reloadData {
	// drop all subviews
    if (todayView) {
        [todayView removeFromSuperview];
        todayView = nil;
    }
    
    // Setup scroll view
    if (!scrollView) scrollView = [[UIScrollView alloc] init];
    scrollView.userInteractionEnabled = YES;
    scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    scrollView.clipsToBounds = YES;
    
    // Setup today view
    NSArray *events_today = [self calendarEventsForDate:self.date];
    todayView = [[GCCalendarTodayView alloc] initWithEvents:events_today];
    todayView.delegate = self;
    todayView.date = self.date;
    
    // Setup yesterday view
//    NSDate *yesterday = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.date];
//    NSArray *events_yesterday = [self calendarEventsForDate:yesterday];
//    yesterdayView = [[GCCalendarTodayView alloc] initWithEvents:events_yesterday];
//    yesterdayView.date = yesterday;
    
    // Setup tomorrow view
//    NSDate *tomorrow = [NSDate dateWithTimeInterval:24*60*60 sinceDate:self.date];
//    NSArray *events_tomorrow = [self calendarEventsForDate:tomorrow];
//    tomorrowView = [[GCCalendarTodayView alloc] initWithEvents:events_tomorrow];
//    tomorrowView.date = tomorrow;
    
    // Create a composite view combining the three we just created.
    if (!compositeView) compositeView = [[UIView alloc] init];
    NSLog(@"Composite View interaction enabled?: %i", compositeView.userInteractionEnabled);
    [compositeView addSubview:todayView];
    
//    [compositeView addSubview:yesterdayView];
//    [compositeView addSubview:tomorrowView];
    
	[scrollView addSubview:compositeView];
    [self.calWrapperView addSubview:scrollView];
    
    if (viewVisible) {[self setCalendarBounds];}
}

#pragma mark GCCalendarTodayViewDelegate methods

- (void)updateEventWithNewTimes:(GCCalendarEvent *)gcevent {
    [[TSCalendarStore instance] updateGCCalendarEvent:gcevent];
}

- (void)respondToTileSlidRight:(GCCalendarTile *)tile inDayView:(GCCalendarTodayView *)dayView {
    // Pop up a warning message, then call the model method to delete.
    NSString *prompt = @"Are you sure you want to remove this event?";
    NSString *info = @"This will also delete the event in your iCal / gCal";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prompt message:info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [MyAlertViewDelegate showAlertView:alert withCallback:^(NSInteger buttonIndex) {
        // code to take action depending on the value of buttonIndex
        NSLog(@"Alert view button pushed");
        if (buttonIndex == 1) {
            [model removeGCCalendarEvent:tile.event];
            [todayView removeEvent:tile.event];
//            [self reloadData];
        } else {
            // Reset the cell. Re-animate it back on screen
            [todayView resetToCenter:tile];
        }
    }];
}



@end

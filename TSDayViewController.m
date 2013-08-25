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

@end

@implementation TSDayViewController

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
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    if (viewDirty) {
        [self reloadData];
        viewDirty = NO;
    }
    
    [self setCalendarBounds];
    [self scrollToCurrentTime];
    
	viewVisible = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	viewVisible = NO;
    viewDirty = YES;
}
- (void)setupCalendar {
    // create calendar view
    // GCCalendarView delegate / datasource.
    model = [TSCalendarStore instance];
    
    self.dataSource = self;
    
    viewDirty = YES;
    viewVisible = NO;
    
    self.title = @"TimeStamp";
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
    NSArray *EKArray = [model allCalendarEventsForDate:date];
    
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
- (CGFloat)yValueForTime:(CGFloat)time {
	return kTopLineBuffer + (kHalfHourDiff * 2 * time);;
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
- (void)setCalendarBounds {
    scrollView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, self.calWrapperView.frame.size.height);
    scrollView.contentSize = CGSizeMake(self.calWrapperView.frame.size.width, kTodayViewHeight);
    compositeView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, kTodayViewHeight);
    todayView.frame = CGRectMake(0, 0, self.calWrapperView.frame.size.width, kTodayViewHeight);
    [scrollView setContentOffset:CGPointMake(0, 0)];
}
- (void)reloadTodayView {
    if (todayView) [todayView reloadData];
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
    todayView.date = self.date;
    todayView.datasource = self;
    todayView.delegate = self;
    
    // Create a composite view combining the three we just created.
    if (!compositeView) compositeView = [[UIView alloc] init];
    NSLog(@"Composite View interaction enabled?: %i", compositeView.userInteractionEnabled);
    [compositeView addSubview:todayView];

	[scrollView addSubview:compositeView];
    [self.calWrapperView addSubview:scrollView];
    
    if (viewVisible) {[self setCalendarBounds];}
}
- (void)scrollToCurrentTime {
    // Note that when there is more than one day this will be tricky.
    
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:now];
    float hours = [nowComponents hour] + ((float)[nowComponents minute] / 60);
    CGFloat yValue = [self yValueForTime:hours];
    CGFloat buffer = scrollView.frame.size.height / 2.0 - 50;
    
    CGFloat yOffset = yValue - buffer;
    yOffset = MAX(0.0, yOffset);
    yOffset = MIN(yOffset, todayView.frame.size.height - scrollView.frame.size.height);
    
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, yOffset) animated:YES];
}
- (void)updateNavBarWithColor:(UIColor *)color {
    [[[UINavigationBar class] appearance] setBackgroundColor:color];
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

#pragma mark GCCalendarTodayViewDatasource
- (NSDate *)dateToDisplay {
    return self.date;
}
- (NSArray *)eventsToDisplay {
    return [self calendarEventsForDate:self.date];
}

@end

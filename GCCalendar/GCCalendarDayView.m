//
//  GCCalendarDayView.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarDayView.h"
#import "GCCalendarTile.h"
#import "GCCalendarView.h"
#import "GCCalendarEvent.h"
#import "GCCalendar.h"
#import "GCCalendarTodayView.h"
#import "GCGlobalSettings.h"

@interface GCCalendarDayView ()
@end

@implementation GCCalendarDayView

@synthesize date;

#pragma mark create and destroy view
+ (void)initialize {
	if(self == [GCCalendarDayView class]) {
	}
}
- (void)setFrame:(CGRect)frame {
    NSLog(@"DayView setFrame, frame: (%f,%f,%f,%f)", frame.origin.x, frame.origin.y, frame.size.width ,frame.size.height);
    [super setFrame:frame];
}
- (id)initWithCalendarView:(GCCalendarView *)view {
	if (self = [super init]) {
//		dataSource = view.dataSource;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        
        dataSource = (id<GCCalendarDataSource>)view;
	}
	return self;
}
- (void)reloadData {
	// get new events for date
	events = [dataSource calendarEventsForDate:self.date];
    NSArray *events_yesterday = [dataSource calendarEventsForDate:[date dateByAddingTimeInterval:-60*60*24]];
	NSArray *events_tomorrow = [dataSource calendarEventsForDate:[date dateByAddingTimeInterval:+60*60*24]];
    
	// drop all subviews
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
	// create scroll view
	scrollView = [[UIScrollView alloc] init];
	scrollView.backgroundColor = [UIColor colorWithRed:(242.0 / 255.0) green:(242.0 / 255.0) blue:(242.0 / 255.0) alpha:1.0];
	scrollView.frame = CGRectMake(0, allDayView.frame.size.height, self.frame.size.width,
								  self.frame.size.height - allDayView.frame.size.height);
	scrollView.contentSize = CGSizeMake(self.frame.size.width, kTodayViewHeight*3);
	scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    scrollView.userInteractionEnabled = YES;
    [self setContentOffset:CGPointMake(0, kTodayViewHeight)];
//    NSLog(@"scroll view offset: (%f, %f)", scrollView.contentOffset.x, scrollView.contentOffset.y);

	[self addSubview:scrollView];
    
    // create 3 views: yesterday, today and tomorrow
    yesterdayView = [[GCCalendarTodayView alloc] initWithEvents:events_yesterday];
    yesterdayView.frame = CGRectMake(0, 0, self.frame.size.width, kTodayViewHeight);
    yesterdayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    yesterdayView.date = [date dateByAddingTimeInterval:-60*60*24];
    
	// create today view
	todayView = [[GCCalendarTodayView alloc] initWithEvents:events];
	todayView.frame = CGRectMake(0, kTodayViewHeight, self.frame.size.width, kTodayViewHeight);
	todayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    todayView.date = date;
    
    // create tomorrow view
    tomorrowView = [[GCCalendarTodayView alloc] initWithEvents:events_tomorrow];
    tomorrowView.frame = CGRectMake(0, 0 + 2 * kTodayViewHeight, self.frame.size.width, kTodayViewHeight);
    tomorrowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tomorrowView.date = [date dateByAddingTimeInterval:60*60*24];
    
    // Create a composite view combining the three we just created.
    UIView *compositeView = [[UIView alloc] init];
    [compositeView addSubview:yesterdayView];
    [compositeView addSubview:todayView];
    [compositeView addSubview:tomorrowView];
    
    NSLog(@"dimensions of dayview in dayview: (%f,%f,%f,%f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
	[scrollView addSubview:compositeView];
}

- (void)setContentOffset:(CGPoint)p {
	scrollView.contentOffset = p;
}

- (CGPoint)contentOffset {
	return scrollView.contentOffset;
}

-(void)createEvent:(GCCalendarEvent *)event AtPoint:(CGPoint)point withDuration:(NSTimeInterval)seconds {
    // Convert the point into the correct frame. Then turn it into a date - set the start date of the event. Then tell the today view to draw it.
    
    // Work out which view we're going to draw it in.
    GCCalendarTodayView *activeView;
    CGPoint newPoint = [self convertPoint:point toView:todayView];
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
}

- (CGFloat)timeForYValue:(CGFloat)yValue {
    // returns time in hours.
    return ((yValue - kTopLineBuffer) / (2 * kHalfHourDiff));
}

@end
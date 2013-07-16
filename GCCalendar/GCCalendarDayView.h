//
//  GCCalendarDayView.h
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCCalendarProtocols.h"
@class GCCalendarTodayView;

/*
 GCCalendarDayView is responsible for displaying all calendar information
 for a single day.  It sets up the appropriate scroll view and all day
 view, lays out all calendar tiles, and draws the calendar grid
 background.
 */
@interface GCCalendarDayView : UIView {
	// view shown at the top of the calendar containing all day events
	UIView *allDayView;
	// view containing events that occur on the given date
	GCCalendarTodayView *todayView;
    // view for previous day
    GCCalendarTodayView *yesterdayView;
    // view for next day
    GCCalendarTodayView *tomorrowView;
	// adds scrolling function to the calendar
	UIScrollView *scrollView;
	// the date to show events from
	NSDate *date;
	// an array of events for this date
	NSArray *events;
	// data source
	id<GCCalendarDataSource> dataSource;
}

@property (nonatomic, strong) NSDate *date;
/*
 accessor methods for accessing the contentOffset of the scroll view.
 this is used to keep the scroll position the same from one day view
 to the next.
 */
@property (nonatomic) CGPoint contentOffset;

- (id)initWithCalendarView:(GCCalendarView *)view;
- (void)reloadData;
-(void)selectTile:(GCCalendarTile *)t;

@end

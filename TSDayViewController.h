//
//  TSDayViewController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCalendar.h"

@class GCDatePickerControl;
@class GCCalendarDayView;
@class TableHeaderToolBar;
@class TSMenuBoxContainer;
@class GCCalendarTodayView;

/*
 GCCalendarPortraitView defines the top-level view controller containing
 calendar events for a single day.  This view works best when placed in
 the stack of a navigation controller.  If no navigation controller is present,
 the "Today" button will not be available to the user.
 
 The most notable method inside this class is calendarTileTouch: which is called
 whenever a CGCalendarTileTouchNotification is posted to the default notification
 center.  Use the userInfo field of the event (not of the notification) to
 push a detailed view controller onto the stack with more information about the
 event (currently unimplemnted)
 */
 @interface TSDayViewController : GCCalendarView <GCCalendarDataSource> {
    
    // scrollView wraps the today views
    UIScrollView *scrollView;
    UIView *compositeView;
    GCCalendarTodayView *todayView;
    GCCalendarTodayView *yesterdayView;
    GCCalendarTodayView *tomorrowView;
    
    // view has changed since last time on screen
    BOOL viewDirty;
    
    // view is on screen
    BOOL viewVisible;
}

-(void)createEvent:(GCCalendarEvent *)event AtPoint:(CGPoint)point withDuration:(NSTimeInterval)seconds;

@property (weak, nonatomic) IBOutlet UIView *calWrapperView;

@end
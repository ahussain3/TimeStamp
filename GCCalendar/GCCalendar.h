//
//  GCCalendar.h
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCCalendarView.h"
#import "GCCalendarEvent.h"
#import "GCCalendarProtocols.h"

@interface GCCalendar : NSObject {
	
}

#pragma mark date utilities
// asks if a given date is today by comparing day, month, and year values
+ (BOOL)dateIsToday:(NSDate *)date;

#pragma mark get date formatters
// returns a single date formatter with a "medium" date style
+ (NSDateFormatter *)dateFormatter;
// returns a single time formatter with a "short" time style
+ (NSDateFormatter *)timeFormatter;

@end

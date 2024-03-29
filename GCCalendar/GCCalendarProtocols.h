/*
 *  GCCalendarProtocols.h
 *  iBeautify
 *
 *  Created by Caleb Davenport on 2/27/10.
 *  Copyright 2010 GUI Cocoa Software. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol GCCalendarDataSource <NSObject>
@required
- (NSArray *)calendarEventsForDate:(NSDate *)date;
@end
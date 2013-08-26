//
//  GCCalendarEvent.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarEvent.h"
#import <EventKit/EventKit.h>
#import "UIColor+CalendarPalette.h"

@implementation GCCalendarEvent

@synthesize eventName;
@synthesize eventDescription;
@synthesize startDate;
@synthesize endDate;
@synthesize allDayEvent;
@synthesize color;
@synthesize userInfo;

- (id)init {
	if (self = [super init]) {
        // Initialization code here
	}
	
	return self;
}

+ (GCCalendarEvent *)createGCEventFromEKEvent:(EKEvent *)ekevent {
    GCCalendarEvent *gcevent = [[GCCalendarEvent alloc] init];
    
    gcevent.startDate = ekevent.startDate;
    gcevent.endDate = ekevent.endDate;
    gcevent.eventName = ekevent.title;
    gcevent.eventDescription = ekevent.notes;
    gcevent.allDayEvent = ekevent.allDay;
    gcevent.color = [[UIColor colorWithCGColor:ekevent.calendar.CGColor] prettyColor];
    gcevent.calendarIdentifier = ekevent.calendar.calendarIdentifier;
    gcevent.eventIdentifier = ekevent.eventIdentifier;
    return gcevent;
}


@end

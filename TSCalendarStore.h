//
//  TSCalendarStore.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/31/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EKEventStore;
@class GCCalendarEvent;

@interface TSCalendarStore : NSObject

// Event store
@property (nonatomic, strong) EKEventStore *store;

// Singleton methods
+ (TSCalendarStore *)instance;

// data methods
- (NSArray *)allCalendarEventsForDate:(NSDate *)date;

// CRUD methods
- (GCCalendarEvent *)createNewEvent:(GCCalendarEvent *)gcEvent;
- (GCCalendarEvent *)updateGCCalendarEvent:(GCCalendarEvent *)gcEvent;

@end


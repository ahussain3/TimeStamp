//
//  TSCalendarStore.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/31/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSCalendarStore.h"
#import <EventKit/EventKit.h>
#import "GCCalendarEvent.h"

@interface TSCalendarStore () {
    BOOL updateICalRecord;
}

@end

@implementation TSCalendarStore

@synthesize activeCalendars = _activeCalendars;

#pragma mark - Singleton methods
- (id) initSingleton
{
    if ((self = [super init]))
    {
        // Initialization code here.
        [self setup];
        updateICalRecord =  YES;
    }
    
    return self;
}

- (void)setup {
    if (self.store == nil) {
        self.store = [[EKEventStore alloc] init];
        if([self.store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            // iOS 6 and later
            [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    //NSLog(@"Events calendar accessed");
                    //---- codes here when user allow your app to access theirs' calendar.
                } else
                {
                    //NSLog(@"Failed to access events calendar");
                    //----- codes here when user NOT allow your app to access the calendar.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar access failed" message:@"This app is not especially useful without calendar access - go to Settings to grant permission :)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
    }
}
- (void)setActiveCalendars:(NSArray *)activeCalendars {
    if (activeCalendars != _activeCalendars) {
        _activeCalendars = activeCalendars;
        [[NSUserDefaults standardUserDefaults] setObject:_activeCalendars forKey:CAL_STORAGE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (NSArray *)activeCalendars {
    self.calsDirty = YES;
    if (self.calsDirty) {
        NSMutableArray *calArray = [[NSMutableArray alloc] init];
        NSDictionary *calDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CAL_STORAGE_KEY];
        NSArray *allKeys = [calDict allKeys];
        for (NSString *key in allKeys) {
            NSString *calID = [calDict valueForKey:key];
            EKCalendar *calendar = [self.store calendarWithIdentifier:calID];
            if (calendar) [calArray addObject:calendar];
        }
        _activeCalendars = calArray;
    }
    return _activeCalendars;
}
+ (TSCalendarStore *) instance
{
    // Persistent instance.
    static TSCalendarStore *_default = nil;
    
    // Small optimization to avoid wasting time after the
    // singleton being initialized.
    if (_default != nil)
    {
        return _default;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      _default = [[TSCalendarStore alloc] initSingleton];
                  });
#else
    // Allocates once using the old approach, it's slower.
    // It's thread safe.
    @synchronized([MySingleton class])
    {
        // The synchronized instruction will make sure,
        // that only one thread will access this point at a time.
        if (_default == nil)
        {
            _default = [[TSCategoryList alloc] initSingleton];
        }
    }
#endif
    return _default;
}

- (NSArray *)allCalendarEventsForDate:(NSDate *)date {
    // retrieve all calendars
    NSArray *calendars = self.activeCalendars;
#warning Eventually we should remove the line below.
    if (calendars.count == 0) calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
    
    // This array will store all the events from all calendars.
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    
    // Make sure you are at midnight on the current day
    // Set startDay to today at midnight
    NSDate *today = [self getMidnightForDate:date];
    
    // The date period goes from the beginning of yesterday to the start of today. This ensures we don't miss events that started yesterday but ended today. It's a hackish solution
    NSDate *startDate = [today dateByAddingTimeInterval:-60*60*24];
    NSDate *endDate = [today dateByAddingTimeInterval:60*60*24 - 1];
    
    // Loop through calendars, pull events.
    for (EKCalendar *calendar in calendars) {
        // Get events for calendar
        NSArray *calendarArray = [NSArray arrayWithObject:calendar];
        NSPredicate *searchPredicate = [self.store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
        
        // create temporary array to store events for THIS calendar
        NSMutableArray *eventsForCalendar = [[self.store eventsMatchingPredicate:searchPredicate]mutableCopy];
        NSMutableArray * temp = [[NSMutableArray alloc]init];
        
        // remove 'all-day' events
        for (EKEvent *event in eventsForCalendar) {
            if (event.allDay) {
                [temp addObject:event];
            }
        }
        [eventsForCalendar removeObjectsInArray:temp];
        
        // merge with main storage array
        [eventArray addObjectsFromArray:eventsForCalendar];
    }
    
    // sort events in order of start date.
    [eventArray sortUsingSelector:@selector(compareStartDateWithEvent:)];
    
    // delete events that don't begin today.
    NSMutableArray *remove = [[NSMutableArray alloc] init];
    for (EKEvent *e in eventArray) {
        if ([e.startDate compare:today] == NSOrderedAscending) {
            // Event starts yesterday
            if ([e.endDate compare:today] == NSOrderedAscending) {
                // Event ends yesterday, remove it
                [remove addObject:e];
            } else {
                // Event spans two days, start it at midnight
                e.startDate = today;
            }
        }
    }
    
    [eventArray removeObjectsInArray:remove];
    
    return eventArray;
}

- (GCCalendarEvent *)createNewEvent:(GCCalendarEvent *)gcEvent {
    if (updateICalRecord) {
        EKEvent *ekEvent = [EKEvent eventWithEventStore:self.store];
        
        ekEvent.startDate = gcEvent.startDate;
        ekEvent.endDate = gcEvent.endDate;
        ekEvent.title = gcEvent.eventName;
        ekEvent.notes = gcEvent.eventDescription;
        ekEvent.allDay = gcEvent.allDayEvent;
        EKCalendar *calendar = [self.store calendarWithIdentifier:gcEvent.calendarIdentifier];
        ekEvent.calendar = calendar;
    
        NSError *err;
        BOOL success = [self.store saveEvent:ekEvent span:EKSpanThisEvent commit:YES error:&err];
        
        if (success == NO) {
            NSLog(@"Error creating new event: %@", err);
        } else {
            NSLog(@"Successfully created new event");
        }
        return [GCCalendarEvent createGCEventFromEKEvent:ekEvent];
    }
    return gcEvent;
}

- (GCCalendarEvent *)updateGCCalendarEvent:(GCCalendarEvent *)gcEvent {
    if (updateICalRecord) {
        // Find matching EKEvent with identifier / calendar information.
        EKEvent *ekEvent = [self.store eventWithIdentifier:gcEvent.eventIdentifier];
        
        // Change the event to match the new event.
        ekEvent.startDate = gcEvent.startDate;
        ekEvent.endDate = gcEvent.endDate;
        
        if (updateICalRecord) {
            NSError *err;
            BOOL success = [self.store saveEvent:ekEvent span:EKSpanThisEvent commit:YES error:&err];
            
            if (success == NO) {
                NSLog(@"Error updating event start/end times: %@", err);
            } else {
                NSLog(@"Successfully updated event!");
            }
        }
    
        // Convert back to GC and return it.
        gcEvent = [GCCalendarEvent createGCEventFromEKEvent:ekEvent];
    }
    return gcEvent;
}

- (void)removeGCCalendarEvent:(GCCalendarEvent *)gcEvent {
    if (updateICalRecord) {
        // Find matching EKEvent with identifier / calendar information.
        EKEvent *ekEvent = [self.store eventWithIdentifier:gcEvent.eventIdentifier];
        
        if (updateICalRecord) {
            NSError *err;
            BOOL success = [self.store removeEvent:ekEvent span:EKSpanThisEvent commit:YES error:&err];
            
            if (success == NO) {
                NSLog(@"Error deleting event: %@", err);
            } else {
                NSLog(@"Successfully deleted event!");
            }
        }
    }
}

# pragma mark Utility Methods
- (NSDate *)getMidnightForDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end

//
//  EventKitData.m
//  PullEventKitData
//
//  Created by Awais Hussain on 1/25/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "EventKitData.h"
#import "TSCalendarSegment.h"

@implementation EventKitData
@synthesize store = _store;


-(id)init
{
    self = [super init];
    if(self)
    {
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar access failed" message:@"We can't do much if access to phone calendar is not granted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
    }
    return self;
}

- (EKEventStore *)store {
    if (!_store) {
        _store = [[EKEventStore alloc] init];
    }
    return _store;
}

- (void)askUserForPermission {
    // internet code ask user for permission
    if([self.store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            if (granted) {
                //NSLog(@"Events calendar accessed");
                //---- codes here when user allow your app to access theirs' calendar.
                
            } else
            {
                NSLog(@"Failed to access events calendar");
                //----- codes here when user NOT allow your app to access the calendar.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar access failed" message:@"We can't do much if access to phone calendar is not granted" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
}

// Returns array of EKEvent objects
// calendars is an NSArray of EKCalendar objects
- (NSArray *) eventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    // internet code ask user for permission
    [self askUserForPermission];
    
    // retrieve all calendars
    NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
    
    // This array will store all the events from all calendars.
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    
    for (EKCalendar *calendar in calendars) {
        
        // Print calendar information
        //NSLog(@"Calendar Title: %@", calendar.title);
        
        // Get events for calendar
        NSArray *calendarArray = [NSArray arrayWithObject:calendar];
        NSPredicate *searchPredicate = [self.store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
        
        // create temporary array to store events for THIS calendar
        NSMutableArray *eventsForCalendar = [[self.store eventsMatchingPredicate:searchPredicate]mutableCopy];
        //NSLog(@"No. of events found for '%@' calendar: %i", calendar.title, [eventArray count]);
        NSMutableArray * temp = [[NSMutableArray alloc]init];
        
        // remove all day events
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
    
    // print events in log file
    // NSLog(@"Full List of Sorted Events:");
    //for (EKEvent* event in eventArray) {
    //    NSLog(@"Event Calendar: %@", event.calendar.title);
    //    NSLog(@"Event Title: %@", event.title);
    //    NSLog(@"Event Location: %@", event.location);
    //    NSLog(@"Event Start Date: %@", event.startDate);
    //    NSLog(@"Event End Date: %@", event.endDate);
    //}
    return eventArray;
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (NSDictionary *) eventsGroupedByDayforStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NSMutableArray *allEvents = [[self eventsForStartDate:startDate endDate:endDate] mutableCopy];
    
    // remove all day events
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    for (EKEvent *event in allEvents) {
        if (event.allDay) {
            [temp addObject:event];
        }
    }
    [allEvents removeObjectsInArray:temp];
    
    NSMutableDictionary *sections = [[NSMutableDictionary alloc]init];
    for (EKEvent *event in allEvents)
    {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event.startDate];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [[NSMutableArray alloc] init];
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
    }
    
    // Create a sorted list of days
    // NSArray *unsortedDays = [sections allKeys];
    // NSArray *sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    // print what we have to check
   // NSLog(@"Number of entries in full dict: %i", [sections count]);
    //NSArray *allKeys = [sections allKeys];
    //NSLog(@"Keys in dictionary (days): %@", allKeys);

    /*for (NSArray *n in [sections allValues]) {
        NSLog(@"\n\n\nNEW GROUPS\n\n\n");
        for (EKEvent * event in n) {
            NSLog(@"Event Calendar: %@", event.calendar.title);
            NSLog(@"Event Title: %@", event.title);
            NSLog(@"Event Location: %@", event.location);
            NSLog(@"Event Start Date: %@", event.startDate);
            NSLog(@"Event End Date: %@", event.endDate);
            
        }
    }
    */
    return sections;
}

- (NSArray *) eventsForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate andCalendar:(EKCalendar *)calendar {
    //NSLog(@"Enter Get Events for Calendar function");
    
    // retrieve calendar - is a parameter in the function
    
    // Print calendar information
    //NSLog(@"Calendar Title: %@", calendar.title);
    
    // Get events for calendar
    NSArray *calendarArray = [[NSArray alloc]initWithObjects:calendar, nil];
    NSPredicate *searchPredicate = [self.store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
    
    NSMutableArray *eventArray = [[self.store eventsMatchingPredicate:searchPredicate]mutableCopy];
    //NSLog(@"No. of events found: %i", [eventArray count]);
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    // print events in log file

    // remove all day events
    for (EKEvent *event in eventArray) {
        if (event.allDay) {
            [temp addObject:event];
        }
    }
    [eventArray removeObjectsInArray:temp];
    
    return eventArray;
}


- (NSArray *) eventsGroupedByCalendarforStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NSMutableArray *allEvents = [[self eventsForStartDate:startDate endDate:endDate] mutableCopy];
    
    // remove all day events
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    for (EKEvent *event in allEvents) {
        if (event.allDay) {
            [temp addObject:event];
        }
    }
    [allEvents removeObjectsInArray:temp];
    
    
    // Dictionary grouping events by calendar
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    
    for (EKEvent *event in allEvents)
    {
        // Get the events calendar
        EKCalendar *calendar = event.calendar;
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsForThisCalendar = [sections objectForKey:calendar.calendarIdentifier];
        if (eventsForThisCalendar == nil) {
            eventsForThisCalendar = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sections setObject:eventsForThisCalendar forKey:calendar.calendarIdentifier];
        }
        
        // Add the event to the list for this day
        [eventsForThisCalendar addObject:event];
    }
    
    // Convert the data from a dictionary into an array of TSCalendarSegment objects.
    
    // Array of TSCalendarSegment objects
    NSMutableArray *calendarSegments = [[NSMutableArray alloc] init];
    
    NSArray *calendarIdentfiers = [sections allKeys];
    for (NSString *identifier in calendarIdentfiers) {
        TSCalendarSegment *calSegment = [[TSCalendarSegment alloc] initWithStartDate:startDate andEndDate:endDate];
        
        EKCalendar *calendar = [self.store calendarWithIdentifier:identifier];
        calSegment.calendar = calendar;
        
        NSArray *events = [sections objectForKey:identifier];
        calSegment.events = events;
        [calendarSegments addObject:calSegment];
    }
    
    // print for diagnostic purposes
    //NSLog(@"Calendar Identifiers: %@", calendarIdentfiers);
    //NSLog(@"Calendar Segments Array: %@", calendarSegments);
    
    return calendarSegments;
}

- (NSDictionary *) eventsGroupedByDayForCalendar:(TSCalendarSegment *)calSegment {
    
    NSDictionary *eventsGroupedByDay = [self groupEventsByDay:calSegment.events];
    
    return eventsGroupedByDay;
}

- (NSDictionary *) groupEventsByDay:(NSArray *)events {
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    
    for (EKEvent *event in events)
    {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event.startDate];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
    }
    
    return sections;
}

+(NSArray*) startAndEndDatesWithTimePeriodIndicator:(int) ind
{
    
    NSDate * today = [NSDate date];
    NSCalendar * gregorian = [NSCalendar currentCalendar];
    NSDateComponents * timeComponents;
    NSDateComponents *component;
    switch (ind) {
        case TimePeriodIndicatorCustom:
        {
        }break;
        case TimePeriodIndicatorDay:
        {
            component = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:today];
            [component setHour:0];
            [component setMinute:0];
            [component setSecond:0];
        }break;
        case TimePeriodIndicatorWeek:
        {
            timeComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
            NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
            [componentsToSubtract setDay: - ([timeComponents weekday] - [gregorian firstWeekday])];
            NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
            component = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
        }break;
        case TimePeriodIndicatorMonth:
        {
            component = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
            [component setDay:1];
        }
            break;
        default:
            break;
    }
    NSDate * startDate = [gregorian dateFromComponents:component];
    NSTimeInterval interval;
    switch (ind) {
        case TimePeriodIndicatorCustom: interval = 0; break;
        case TimePeriodIndicatorDay:interval = 60*60*24;break;
        case TimePeriodIndicatorWeek:interval = 60*60*24*7;break;
        case TimePeriodIndicatorMonth:{
            NSRange days = [gregorian rangeOfUnit:NSDayCalendarUnit
                                           inUnit:NSMonthCalendarUnit
                                          forDate:today];
            interval = 60*60*24*days.length;
        }break;
        default:interval = 0;NSLog(@" ERROR In Mysingleton, start and End Date");
            break;
    }
    NSDate * endDate = [NSDate dateWithTimeInterval:interval sinceDate:startDate];
    return [NSArray arrayWithObjects:startDate,endDate, nil];
}

+(NSTimeInterval) timeIntervalBetweenTimePeriodWithTimerPeiodIndicator:(int)ind
{
    switch (ind) {
        case TimePeriodIndicatorCustom:
            return 0; break;
            
        case TimePeriodIndicatorDay:
            return 60*60*24;break;
        case TimePeriodIndicatorMonth:{
            NSDate * today = [NSDate date];
            NSCalendar * gregorian = [NSCalendar currentCalendar];
            NSRange days = [gregorian rangeOfUnit:NSDayCalendarUnit
                                           inUnit:NSMonthCalendarUnit
                                          forDate:today];
            return 60*60*24*days.length;
        }break;
        case TimePeriodIndicatorWeek:
            return 60*60*24*7;
        default:
            return 0;
            break;
    }
}

@end



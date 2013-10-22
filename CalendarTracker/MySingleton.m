//
//  MySingleton.m
//  Jebbit
//
//  Created by Balaji Pandian on 12/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySingleton.h"

@interface MySingleton()

// Make any initialization of your class.
- (id) initSingleton;

@end

@implementation MySingleton

@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize activeDate = _activeDate;
@synthesize timePeriod = _timePeriod;

- (id) initSingleton
{
    if ((self = [super init]))
    {
        // Initialization code here.
    }
    
    return self;
}

- (NSInteger)timePeriod {
    if (!_timePeriod) {
        _timePeriod = TimePeriodIndicatorWeek;
    }
    return _timePeriod;
}

- (NSDate *)startDate {
    // use active date and time period to generate start date.
    
    //NSLog(@"StartDate -> Active Date: %@", self.activeDate);
    NSDate *currentDate = self.activeDate;
    NSDateComponents *component;
    NSDateComponents *timeComponents;
    NSCalendar * gregorian = [NSCalendar currentCalendar];

    if (self.timePeriod == TimePeriodIndicatorDay) {
        // Set startDay to today at midnight
        component = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:currentDate];
        [component setHour:0];
        [component setMinute:0];
        [component setSecond:0];
    }
    
    if (self.timePeriod == TimePeriodIndicatorWeek) {
        // Set startDay to midnight on Monday
        timeComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:currentDate];
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay: - ([timeComponents weekday] - [gregorian firstWeekday])];
        NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:currentDate options:0];
        component = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
    }
    
    if (self.timePeriod == TimePeriodIndicatorMonth) {
        // Do something. Set startDay to midnight on the first day of the month.
        component = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:currentDate];
        [component setDay:1];
        [component setHour:0];
        [component setMinute:0];
        [component setSecond:0];
    }
    
    _startDate = [gregorian dateFromComponents:component];
    //NSLog(@"Start Date: %@", _startDate);
    
    return _startDate;
}

- (NSDate *)endDate {
    // use active date and time period to generate end date.
    
    //NSLog(@"EndDate -> Active Date: %@", self.activeDate);
    NSDate *currentDate = self.activeDate;
    NSDateComponents *component;
    NSDateComponents *timeComponents;
    NSCalendar * gregorian = [NSCalendar currentCalendar];
    
    if (self.timePeriod == TimePeriodIndicatorDay) {
        // Do something. Set endDate to today at 11:59pm
        component = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:currentDate];
        [component setHour:23];
        [component setMinute:59];
        [component setSecond:59];
    }
    
    if (self.timePeriod == TimePeriodIndicatorWeek) {
        // Do something. Set endDate to 11:59pm on the upcoming Sunday
        timeComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:currentDate];
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay: - ([timeComponents weekday] - [gregorian firstWeekday])];
        NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:currentDate options:0];
        component = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
        [component setDay:[component day] + 7];
    }
    
    if (self.timePeriod == TimePeriodIndicatorMonth) {
        // Set endDate to 11:59pm on the last day of the month.
        component = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:currentDate];
        NSRange daysRange =
        [gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:currentDate];
        [component setDay:daysRange.length];
        [component setHour:23];
        [component setMinute:59];
        [component setSecond:59];
    }
    
    _endDate = [gregorian dateFromComponents:component];
    //NSLog(@"End Date: %@", _endDate);
    
    return _endDate;
}

- (void)goBackward {
    // go back the by the relevant time period. Remember to reset active date to be the first day of the new time period.
    NSDate *newActiveDate;
    NSTimeInterval interval;
    NSDateComponents *component = [[NSDateComponents alloc] init];
    NSCalendar * gregorian = [NSCalendar currentCalendar];
    
    if (self.timePeriod == TimePeriodIndicatorDay) {
        interval = -60*60*24;
        newActiveDate = [NSDate dateWithTimeInterval:interval sinceDate:self.activeDate];
    }
    
    if (self.timePeriod == TimePeriodIndicatorWeek) {
        // Go back one week
        interval = -60*60*24*7;
        newActiveDate = [NSDate dateWithTimeInterval:interval sinceDate:self.activeDate];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:newActiveDate];
        [comps setWeekday:1];
        newActiveDate = [gregorian dateFromComponents:comps];
    }
    
    if (self.timePeriod == TimePeriodIndicatorMonth) {
        // Go back to previous month
        [component setMonth:-1];
        newActiveDate = [gregorian dateByAddingComponents:component toDate:self.activeDate options:0];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:newActiveDate];
        [comps setDay:1];
        newActiveDate = [gregorian dateFromComponents:comps];

    }
    self.activeDate = newActiveDate;
}

- (void)goForward {
    // go to the next time period. E.g. activeDate + one week. Remember to reset activeDate to be the first day of the new time period.
    NSDate *newActiveDate;
    NSTimeInterval interval;
    NSDateComponents *component = [[NSDateComponents alloc]init];
    NSCalendar * gregorian = [NSCalendar currentCalendar];
    
    if (self.timePeriod == TimePeriodIndicatorDay) {
        interval = 60*60*24;
        newActiveDate = [NSDate dateWithTimeInterval:interval sinceDate:self.activeDate];
    }
    
    if (self.timePeriod == TimePeriodIndicatorWeek) {
        // Go back one week
        interval = 60*60*24*7;
        newActiveDate = [NSDate dateWithTimeInterval:interval sinceDate:self.activeDate];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:newActiveDate];
        [comps setWeekday:1];
        newActiveDate = [gregorian dateFromComponents:comps];
    }
    
    if (self.timePeriod == TimePeriodIndicatorMonth) {
        // Go back to previous month
        [component setMonth:1];
        newActiveDate = [gregorian dateByAddingComponents:component toDate:self.activeDate options:0];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:newActiveDate];
        [comps setDay:1];
        newActiveDate = [gregorian dateFromComponents:comps];
    }
    self.activeDate = newActiveDate;
}

+ (MySingleton *) instance
{
    // Persistent instance.
    static MySingleton *_default = nil;
    
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
                      _default = [[MySingleton alloc] initSingleton];
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
            _default = [[MySingleton alloc] initSingleton];
        }
    }
#endif
    return _default;
}

@end


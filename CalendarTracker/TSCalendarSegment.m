//
//  TSCalendarSegment.m
//  PullEventKitData
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSCalendarSegment.h"

@implementation TSCalendarSegment

@synthesize events = _events;
@synthesize calendar = _calendar;
@synthesize color = _color;
@synthesize title = _title;
@synthesize totalHours = _totalHours;
@synthesize totalTimeInSeconds = _totalTimeInSeconds;
@synthesize totalTimeInMinutes = _totalTimeInMinutes;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize numberOfEvents = _numberOfEvents;

- (TSCalendarSegment *)initWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    self = [super init];
    if(self)
    {
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

- (UIColor *)color {
    return [UIColor colorWithCGColor:self.calendar.CGColor];
}

- (NSString *)title {
    return [self.calendar.title copy];
}

- (NSTimeInterval)totalTimeInSeconds {
    NSTimeInterval runningTotal = 0;
    
    for (EKEvent *event in self.events) {
        NSTimeInterval duration = [event.endDate timeIntervalSinceDate:event.startDate];
        runningTotal += duration;
    }
    
    NSInteger totalTime = runningTotal;
    return totalTime;
}

- (NSInteger)totalTimeInMinutes {
    NSInteger totalTime = [self totalTimeInSeconds] / 60;
    
    return totalTime;
}

- (NSNumber *) totalHours {
    NSNumber *totalTime = [NSNumber numberWithDouble:[self totalTimeInSeconds] / (60*60)];

    return totalTime;
}

- (NSInteger) numberOfEvents {
    return self.events.count;
}

@end

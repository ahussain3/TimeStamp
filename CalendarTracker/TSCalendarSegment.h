//
//  TSCalendarSegment.h
//  PullEventKitData
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

// A TSCalendarSegment is a complex object consisting of an EKCalendar object and all the EKEvents which fall under that calendar for a specified time period. We do not currently do consistency checks to check that all the events in the class fall within the time period. That's the programmers responsibility.

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "UtilityMethods.h"

@interface TSCalendarSegment : NSObject

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) EKCalendar *calendar;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *totalHours;
@property (nonatomic) NSTimeInterval totalTimeInSeconds;
@property (nonatomic) NSInteger totalTimeInMinutes;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic) NSInteger numberOfEvents;
@property (nonatomic) int percentage;

- (TSCalendarSegment *)initWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

@end

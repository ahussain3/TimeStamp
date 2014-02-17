//
//  TSCategory.m
//  TSCategories
//
//  Created by Awais Hussain on 7/21/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSCategory.h"
#import "TSCalendarStore.h"
#import <EventKit/EventKit.h>

@implementation TSCategory

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        // Unable to encode EKCalendar
        
        NSString *calIdentifier = [decoder decodeObjectForKey:@"calendar"];
        self.calendar = [[TSCalendarStore instance].store calendarWithIdentifier:calIdentifier];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.path = [decoder decodeObjectForKey:@"path"];
        self.level = [decoder decodeIntegerForKey:@"level"];
        self.color = [decoder decodeObjectForKey:@"color"];
        self.subCategories = [decoder decodeObjectForKey:@"subCategories"];
        self.active = [decoder decodeBoolForKey:@"active"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
    // Unable to encode EKCalendar
    [encoder encodeObject:self.calendar.calendarIdentifier forKey:@"calendar"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeInt:self.level forKey:@"level"];
    [encoder encodeObject:self.color forKey:@"color"];
    [encoder encodeObject:self.subCategories forKey:@"subCategories"];
    [encoder encodeBool:self.active forKey:@"active"];
}

- (void)addSubcategory:(NSString *)name {
    if (self.subCategories == nil) {
        self.subCategories = [[NSMutableArray alloc] init];
    }
    
    TSCategory *subCategory = [[TSCategory alloc] init];
    subCategory.title = name;
    subCategory.calendar = self.calendar;
    subCategory.level = self.level + 1;
    subCategory.color = self.color;
    subCategory.active = self.active;
    subCategory.path = [self.path stringByAppendingFormat:@":%@", self.title];
    
    [self.subCategories insertObject:subCategory atIndex:0];
}

@end

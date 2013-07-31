//
//  TSCalendarStore.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/31/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCalendarStore : NSObject

// Singleton methods
- (id)initSingleton;
+ (TSCalendarStore *)instance;

// data methods
- (NSArray *)allCalendarEventsForDate:(NSDate *)date;

@end

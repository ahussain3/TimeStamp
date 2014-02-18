//
//  TSHelpers.h
//  TimeStamp
//
//  Created by Awais Hussain on 1/31/14.
//  Copyright (c) 2014 Awais Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSHelpers : NSObject

+ (void)registerDefaults;
+ (BOOL)isFirstRun;
+ (void)makeFirstRun;
+ (void)syncCalendarsAndShit;
@end

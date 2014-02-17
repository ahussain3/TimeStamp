//
//  TSHelpers.m
//  TimeStamp
//
//  Created by Awais Hussain on 1/31/14.
//  Copyright (c) 2014 Awais Hussain. All rights reserved.
//

#import "TSHelpers.h"

@implementation TSHelpers

+ (void)registerDefaults {
//	NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"app.runBefore", nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"app.runBefore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstRun {
    NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"app.runBefore"]);

	return ![[NSUserDefaults standardUserDefaults] boolForKey:@"app.runBefore"];
}

+ (void)makeFirstRun {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"app.runBefore"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

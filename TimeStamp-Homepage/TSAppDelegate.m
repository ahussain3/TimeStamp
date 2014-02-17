//
//  TSAppDelegate.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSAppDelegate.h"
#import "UIColor+CalendarPalette.h"
#import "TSTabBar.h"
#import "Heap.h"
//#import "Flurry.h"

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[Heap sharedInstance] setAppId:@"2473989496"];
    
    /* Other launch code goes here */
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorFromHexString:@"#3D478C"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
                UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                UITextAttributeFont: [UIFont fontWithName:@"Helvetica-Bold" size:0.0],
    }];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorFromHexString:@"#282E5C"]];
    [[TSTabBar appearance] setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [[TSTabBar appearance] setBackgroundColor:[UIColor colorFromHexString:@"#eeeeee"]];
    [[UIToolbar appearance] setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundColor:[UIColor colorFromHexString:@"#666666"]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    // Simlulate first run every time
//    [TSHelpers makeFirstRun];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	UIViewController* rootViewController = nil;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

	if ([TSHelpers isFirstRun]) {
        NSLog(@"This is the first run:");
		rootViewController = [sb instantiateViewControllerWithIdentifier:@"tutorialController"];
	}
	else {
		rootViewController = [sb instantiateViewControllerWithIdentifier:@"homeController"];
	}
    
	self.window.rootViewController = rootViewController;
    
    NSLog(@"%@", rootViewController);
    [self.window makeKeyAndVisible];
    
    [TSHelpers registerDefaults];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

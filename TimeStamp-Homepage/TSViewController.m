//
//  TSViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSViewController.h"

@interface TSViewController ()

@end

@implementation TSViewController

@synthesize calContainer = _calContainer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    HomePageCalObj *sleep = [[HomePageCalObj alloc] init];
    sleep.title = @"Sleep";
    sleep.color = [UIColor blueColor];
    sleep.recentEvents = [NSArray arrayWithObjects:@"Sleep", @"Nap", @"Long Nap", nil];
    
    HomePageCalObj *work = [[HomePageCalObj alloc] init];
    work.title = @"Work";
    work.color = [UIColor redColor];
    work.recentEvents = [NSArray arrayWithObjects:@"Physics", @"Philosophy", @"Econometrics", nil];

    NSArray *calendars = [NSArray arrayWithObjects:sleep, work, nil];
    
    self.calContainer.calendarInfo = calendars;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

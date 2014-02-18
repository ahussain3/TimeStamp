//
//  TSCalendarChooser.m
//  TimeStamp
//
//  Created by Awais Hussain on 2/17/14.
//  Copyright (c) 2014 Awais Hussain. All rights reserved.
//

#import "TSCalendarChooser.h"
#import "UIColor+CalendarPalette.h"

@interface TSCalendarChooser ()

@end

@implementation TSCalendarChooser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"#3D478C"];
        self.navigationController.navigationBar.translucent = NO;
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorFromHexString:@"#3D478C"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

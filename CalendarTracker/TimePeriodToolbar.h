//
//  TimePeriodToolbar.h
//  TimeStamp
//
//  Created by Awais Hussain on 2/23/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
#import "MySingleton.h"
#import "TSTabBar.h"

@class TimePeriodToolbar;

@protocol TimePeriodToolbarDelegate <NSObject>
-(void)TimePeriodToolbarValueChanged:(TimePeriodToolbar*) timeBar value:(int)val;
-(void)update;
@end

@interface TimePeriodToolbar : TSTabBar
@property (strong, nonatomic) MySingleton *singleton;
- (IBAction)segmentControlPressed:(id)sender;
@property(nonatomic,weak) IBOutlet id <TimePeriodToolbarDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

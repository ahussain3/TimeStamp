//
//  TimePeriodToolbar.m
//  TimeStamp
//
//  Created by Awais Hussain on 2/23/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TimePeriodToolbar.h"

@implementation TimePeriodToolbar
@synthesize delegate;
@synthesize singleton = _singleton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (MySingleton *)singleton {
    if (!_singleton) {
        _singleton = [MySingleton instance];
    }
    return _singleton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)segmentControlPressed:(id)sender
{
    self.singleton.timePeriod = self.segmentedControl.selectedSegmentIndex + 1;
    [delegate TimePeriodToolbarValueChanged:self value:self.segmentedControl.selectedSegmentIndex];
    [delegate update];
//    [delegate TimePeriodToolbarValueChanged:self value:[((UISegmentedControl*)(sender)) selectedSegmentIndex]];
}

@end

//
//  TrendGraphViewController.m
//  CalendarTracker
//
//  Created by Awais Hussain on 2/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TrendGraphViewController.h"
#import "TrendGraphView.h"
#import "SingleCalendarViewController.h"
@interface TrendGraphViewController ()

@end

@implementation TrendGraphViewController

@synthesize singleton = _singleton;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

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
    self.navigationItem.title = self.previousController.navigationItem.title;
    self.graph.datasource = self.previousController;
    [self update];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated {
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Overwriting standard getters and setters to ensure that the date displayed is consistent with that in the Singleton data source. */
- (MySingleton *)singleton {
    if (!_singleton) {
        _singleton = [MySingleton instance];
    }
    return _singleton;
}

- (void)setStartDate:(NSDate *)startDate {
    if (_startDate != startDate) {
        _startDate = startDate;
        // Update singleton
        self.singleton.startDate = startDate;
    }
}

- (NSDate *)startDate {
    _startDate = self.singleton.startDate;
    return _startDate;
}

- (NSDate *)endDate {
    _endDate = self.singleton.endDate;
    return _endDate;
}

#pragma TablehHeaderToolBarDelegate
-(void)update {
    [self.previousController update];
    [self.graph setNeedsDisplay];
    [self updateDateLabelOnDateBar];
}

-(void) updateDateLabelOnDateBar {
    NSTimeInterval interval = -1;
    NSDate *endDate = [NSDate dateWithTimeInterval:interval sinceDate:self.endDate];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM d"];
    if(self.singleton.timePeriod != 1)
        [self.dateBar editDateLabelString:[NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:self.startDate],[dateFormatter stringFromDate:endDate]]];
    else
        [self.dateBar editDateLabelString:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.startDate]]];
}

@end

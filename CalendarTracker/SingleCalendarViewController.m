//
//  SingleCalendarViewController.m
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "SingleCalendarViewController.h"
#import "ClassEventCell.h"
#import "EventKitData.h"
#import "TSCalendarSegment.h"
#import "TotalHoursViewController.h"
#import "TrendGraphViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface SingleCalendarViewController ()

@end

@implementation SingleCalendarViewController

@synthesize calSegment = _calSegment;
@synthesize eventArray = _eventArray;
@synthesize dateArray = _dateArray;
@synthesize singleton = _singleton;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize calendars = _calendars;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (EventKitData *)store {
    if (!_store) {
        _store = [[EventKitData alloc] init];
    }
    return _store;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(!_store)
    _store = [[EventKitData alloc]init];
    self.timeBar.delegate = self;
    self.dateBar.delegate = self;
    self.navigationItem.title = self.calSegment.title;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Graph" style:UIBarButtonItemStyleBordered target:self action:@selector(graphButtonPressed:)];
    [self update];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timeBar.segmentedControl.selectedSegmentIndex = self.singleton.timePeriod - 1;
    [self update];
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

- (NSArray *)calendars{
    _calendars = [self.store eventsGroupedByCalendarforStartDate:self.startDate andEndDate:self.endDate];
    return _calendars;
}

- (void) update {
    [self.previousController update];
    NSArray *calendars = self.calendars;
    self.calSegment = nil;
    // Get correct calSegment
    for(TSCalendarSegment* t in calendars)
    {
        //NSLog(@"Identifier of current calendar: %@", t.calendar.calendarIdentifier);
        //NSLog(@"Calendar Identifier We Are Searching for: %@", self.previousController.identifier);
        if([t.calendar.calendarIdentifier isEqualToString: self.previousController.identifier]) {
            self.calSegment = t;
            break;
        }
    }
    
    self.eventArray = [self.store eventsGroupedByDayForCalendar:self.calSegment];
    self.dateArray = [[self.eventArray allKeys]sortedArrayUsingSelector:@selector(compare:)];
    [self updateDateLabelOnDateBar];
    [[self tableView] reloadData];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UITableView Delegate and Data Source Protocol fulfilment.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * CellIdentifier = @"ClassEventCell";
     ClassEventCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        NSArray * topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ClassEventCell" owner:self options:nil];
        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[ClassEventCell class]]) {
                cell = (ClassEventCell *)currentObject;
                break;
            }
        }
    }
   EKEvent * event = [[self.eventArray objectForKey:[self.dateArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    
    cell.title.text = event.title;
    cell.locationLabel.text = event.location;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"h:mma"];
    cell.beginLabel.text = [[dateFormatter stringFromDate:event.startDate] lowercaseString];
    cell.endLabel.text = [[dateFormatter stringFromDate:event.endDate] lowercaseString];
    UIColor * color = [[UIColor alloc]initWithCGColor:event.calendar.CGColor];
    cell.colorView.backgroundColor = color;
    cell.colorView.layer.cornerRadius = 8.0;
    cell.beginLabel.textColor = color;
    cell.endLabel.textColor = color;
    NSTimeInterval distanceBetweenDates = [event.endDate timeIntervalSinceDate:event.startDate];
    double hoursBetweenDates = distanceBetweenDates /3600.0;
    cell.durationLabel.text = [NSString stringWithFormat:@"%.1fh",hoursBetweenDates];
    cell.durationLabel.textColor = color; 

    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_eventArray objectForKey:[_dateArray objectAtIndex:section] ] count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dateArray count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    double totalHour = 0.0;
    for (EKEvent* e in [_eventArray objectForKey:[_dateArray objectAtIndex:section]])
    {
        NSTimeInterval distanceBetweenDates = [e.endDate timeIntervalSinceDate:e.startDate];
        double hoursBetweenDates = distanceBetweenDates /3600.0;
        totalHour+= hoursBetweenDates;
    }
    NSDate * str = [_dateArray objectAtIndex:section];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    //dateFormatter.locale = [NSLocale loc]
    [dateFormatter setDateFormat:@"EEEE MMM d"];
    return [NSString stringWithFormat:@"%@ %.1fh",[dateFormatter stringFromDate:str],totalHour];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventViewController *eventCtr = [[EKEventViewController alloc] init];
    EKEvent * event = [[self.eventArray objectForKey:[self.dateArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    eventCtr.event = event;
    eventCtr.delegate = self;
    
    [self.navigationController pushViewController:eventCtr animated:YES];
}

//delegate method for EKEventViewController
- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)graphButtonPressed:(id)sender
{
    TrendGraphViewController* newController = [[TrendGraphViewController alloc]init];
    newController.previousController = self;
    
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma TrendGraphViewDelegate

-(NSDictionary *)valuesForPointsWithTrendGraphView:(TrendGraphView *)tgView
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    for(int a = 0; a<[self.dateArray count]; a++)
    {
        double totalHour = 0.0;
        for (EKEvent* e in [_eventArray objectForKey:[_dateArray objectAtIndex:a]])
        {
            NSTimeInterval distanceBetweenDates = [e.endDate timeIntervalSinceDate:e.startDate];
            double hoursBetweenDates = distanceBetweenDates /3600.0;
            totalHour+= hoursBetweenDates;
        }
        [dict setObject:[NSNumber numberWithDouble:totalHour] forKey:[_dateArray objectAtIndex:a]];
    }
    return dict;
}
-(UIColor *)colorForCalendarWithTrendGraphView:(TrendGraphView *)tgView
{
    return self.calSegment.color;
}
- (IBAction)switchScreens:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

-(void)TimePeriodToolbarValueChanged:(TimePeriodToolbar *)timeBar value:(int)val
{
    self.singleton.timePeriod = val+1;
    //[self initializeDates];
    [self update];
}

@end

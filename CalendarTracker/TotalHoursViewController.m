//
//  TotalHoursViewController.m
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TotalHoursViewController.h"
#import "TotalHourCell.h"
#import "TSCalendarSegment.h"
#import "EventKitData.h"
#import "GraphViewController.h"
#import "SingleCalendarViewController.h"
#import "TableHeaderToolBar.h"
#import "TSCalendarStore.h"
#import <QuartzCore/QuartzCore.h>

@interface TotalHoursViewController ()

@end

@implementation TotalHoursViewController
@synthesize calendars = _calendars;
@synthesize endDate = _endDate;
@synthesize startDate = _startDate;
@synthesize store = _store,tableView;
@synthesize totalHours = _totalHours;
@synthesize singleton = _singleton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeDates];
    }
    return self;
}

/* Overwriting standard getters and setters to ensure that the date displayed is consistent with that in the Singleton data source. */
- (MySingleton *)singleton {
    if (!_singleton) {
        _singleton = [MySingleton instance];
    }
    return _singleton;
}

- (NSDate *)startDate {
    _startDate = self.singleton.startDate;
    return _startDate;
}

- (NSDate *)endDate {
    _endDate = self.singleton.endDate;
    return _endDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Calendars";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Graph" style:UIBarButtonItemStyleBordered target:self action:@selector(graphButtonPressed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(todayButtonPressed:)];
    self.timeBar.delegate = self;
    self.dateBar.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.singleton.activeDate) {
        [self initializeDates];
    }
    self.timeBar.segmentedControl.selectedSegmentIndex = self.singleton.timePeriod - 1;
    [self update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) update {
    if(!_store){
        self.store= [[EventKitData alloc] init];
    }
    [self updateDateLabelOnDateBar];
    self.calendars = [_store eventsGroupedByCalendarforStartDate:self.startDate andEndDate:self.endDate];
    self.totalHours = 0;
    for (TSCalendarSegment *t in self.calendars) {
        self.totalHours += [t.totalHours intValue];
        //NSLog(@"Total Hours Running Total: %i", self.totalHours);
    }
    [self.tableView reloadData];
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

-(void) initializeDates
{
    self.singleton.activeDate = [NSDate date];
    self.singleton.timePeriod = TimePeriodIndicatorWeek;
}

// UITableView Delegate and Datasource Protocols
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * CellIdentifier = @"TotalHourCell";
    TotalHourCell * cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray * topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"TotalHourCell" owner:self options:nil];
        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[TotalHourCell class]]) {
                cell = (TotalHourCell *)currentObject;
                break;
            }
        }
    }
    
    TSCalendarSegment * ts = ((TSCalendarSegment*)([self.calendars objectAtIndex:[indexPath row]]));
    
    cell.titleLabel.text = ts.title;
    int events = ts.numberOfEvents;
    NSMutableString* tense = [[NSMutableString alloc]initWithString:@"event"];
    
    if(events >1)
        [tense appendString:@"s"];
    cell.numberOfEventsLabel.text = [NSString stringWithFormat:@"%d %@",events,tense];
    cell.imageView.backgroundColor = ts.color;
    NSString *hours;
    if (ts.totalTimeInMinutes % 60 == 0) {
        hours = [NSString stringWithFormat:@"%@h",ts.totalHours];
    } else {
        hours = [NSString stringWithFormat:@"%i:%i", (int)(floor(ts.totalTimeInMinutes / 60)), ts.totalTimeInMinutes % 60];
    }
    cell.totalHourLabel.text = hours;
    cell.totalHourLabel.textColor = ts.color;
    cell.colorView.backgroundColor = ts.color;
    cell.colorView.layer.cornerRadius = 8.0;
    //NSLog(@"Total Hours: %i", self.totalHours);
    cell.percentLabel.text = [NSString stringWithFormat:@"%d%%", [ts.totalHours intValue]*100/(self.totalHours)];
    cell.percentLabel.textColor = ts.color;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.calendars count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SingleCalendarViewController * svc = [[SingleCalendarViewController alloc]init];
    svc.calSegment = ([self.calendars objectAtIndex:[indexPath row]]);
    self.identifier = svc.calSegment.calendar.calendarIdentifier;
    
    svc.previousController = self;
    [self.navigationController pushViewController:svc animated:YES];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark Nav Bar Methods
-(IBAction)graphButtonPressed:(id)sender
{
    GraphViewController* newController = [[GraphViewController alloc]init];
    newController.previousController = self;
    [self.navigationController pushViewController:newController animated:YES];
}
-(IBAction)todayButtonPressed:(id)sender {
    self.singleton.activeDate = [NSDate date];
    [self update];
}
#pragma mark Toolbar Methods
- (IBAction)switchScreens:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

-(NSDictionary *)valuesForBars
{
#define INDEX_COLOR 0
#define INDEX_HOURS 1
#define INDEX_PERCENT 2
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    for (TSCalendarSegment*s in self.calendars) {
        NSArray * array = [NSArray arrayWithObjects:s.color, s.totalHours,[NSNumber numberWithInt:[s.totalHours intValue]*100.0/(_totalHours)], nil];
        [dictionary setObject:array forKey:s.title];
    }
    return dictionary;
}

-(TSCalendarSegment*) getNewCaldendar
{
   for(TSCalendarSegment* t in self.calendars)
   {
       //NSLog(@"%@",t.calendar);
       if([t.calendar.calendarIdentifier isEqualToString: self.identifier])
           return t;
   }
    return nil;
}

- (NSArray *)calendars {
    NSMutableArray *sortedCalendars;
    sortedCalendars = [NSMutableArray arrayWithArray:_calendars];
    // NSLog(@"Before Sorting: %@", _calendars);
    if (sortedCalendars) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"totalHours" ascending:NO selector:@selector(compare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
        [sortedCalendars sortUsingDescriptors:sortDescriptors];
    }
    // NSLog(@"Sorted Calendars: %@", sortedCalendars);
    return [sortedCalendars copy];
}

-(void)TimePeriodToolbarValueChanged:(TimePeriodToolbar *)timeBar value:(int)val
{
    self.singleton.timePeriod = val+1;
    //[self initializeDates];
    [self update];
}
 
#pragma TablehHeaderToolBarDelegate

@end

//
//  EventViewController.m
//  CalendarTracker
//
//  Created by Awais Hussain on 1/25/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "EventViewController.h"
#import "EventCell.h"
#import "EventKitData.h"
#import "TotalHoursViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController

@synthesize arrayOfAllEvents = _arrayOfAllEvents;
@synthesize titlesArray=_titlesArray;
@synthesize store = _store;
@synthesize tableView = _tableView;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize singleton = _singleton;

/* Initialization Functions */
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
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"All Events";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Calendars" style:UIBarButtonItemStyleBordered target:self action:@selector(calendarButtonClicked:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(goToToday:)];
    self.timeBar.delegate = self;
    self.dateBar.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//  The line below seems unncessary so is commented out. 
//    self.tableView.contentSize = CGSizeMake(320, self.tableView.contentSize.height+50);
    // Get the start date from the singleton.
    if (!self.singleton.activeDate) {
        [self initializeDates];
    }
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

- (NSDate *)startDate {
    _startDate = self.singleton.startDate;
    return _startDate;
}

- (NSDate *)endDate {
    _endDate = self.singleton.endDate;
    return _endDate;
}

// Updates the Dates with the two dates from EventKit
-(void) initializeDates
{
    self.singleton.activeDate = [NSDate date];
    self.singleton.timePeriod = TimePeriodIndicatorWeek;
}

-(void) update
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [self updateDateLabelOnDateBar];
    [self updateCalendarData];
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

-(void) updateCalendarData
{
    EventKitData *eventKitData = [[EventKitData alloc] init];
    self.store = eventKitData.store;
    _arrayOfAllEvents = [eventKitData eventsGroupedByDayforStartDate:self.startDate andEndDate:self.endDate];
    _titlesArray = [[_arrayOfAllEvents allKeys]sortedArrayUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UITable View Delegate and Datasource Protocols.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"EventCell";
    EventCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray * topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"EventCell" owner:self options:nil];
        for(id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[EventCell class]]) {
                cell = (EventCell *)currentObject;
                break;
            }
        }
    }

    EKEvent* event = [[self.arrayOfAllEvents objectForKey:[self.titlesArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    cell.titleLabel.text = event.title;
    
    cell.locationLabel.text = event.location;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
     [dateFormatter setDateFormat:@"h:mma"];
    cell.beginTimeLabel.text = [[dateFormatter stringFromDate:event.startDate] lowercaseString];
    cell.endTimeLabel.text = [[dateFormatter stringFromDate:event.endDate] lowercaseString];
    UIColor * color = [[UIColor alloc]initWithCGColor:event.calendar.CGColor];
    
    cell.colorView.backgroundColor = color;
    cell.beginTimeLabel.textColor = color;
    cell.endTimeLabel.textColor = color;
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_arrayOfAllEvents objectForKey:[_titlesArray objectAtIndex:section]]count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate * str = [_titlesArray objectAtIndex:section];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    //dateFormatter.locale = [NSLocale loc]
    [dateFormatter setDateFormat:@"EEEE MMM d"];
    return [dateFormatter stringFromDate:str];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_titlesArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventViewController *eventCtr = [[EKEventViewController alloc] init];
    EKEvent* event = [[self.arrayOfAllEvents objectForKey:[self.titlesArray objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    eventCtr.event = event;
    eventCtr.delegate = self;
    
    [self.navigationController pushViewController:eventCtr animated:YES];
}

//delegate method for EKEventViewController
- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Segue into the next screen which displays calendars and time spent on each.
-(IBAction)calendarButtonClicked:(id)sender
{
    TotalHoursViewController * thvc =[[TotalHoursViewController alloc]init];
    [self.navigationController pushViewController:thvc animated:YES];
}

-(IBAction)goToToday:(id)sender
{
    self.singleton.activeDate = [NSDate date];
    [self update];
}

-(void)TimePeriodToolbarValueChanged:(TimePeriodToolbar *)timeBar value:(int)val
{
    self.singleton.timePeriod = val+1;
    //[self initializeDates];
    [self update];
}

@end

//
//  TSDayViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "TSDayViewController.h"
#import "GCCalendarEvent.h"
#import "GCCalendarDayView.h"
#import "GCCalendarTile.h"
#import "GCDatePickerControl.h"
#import "GCCalendar.h"
#import "TableHeaderToolBar.h"
#import "TSMenuBoxContainer.h"
#import "TSCalBoxesContainer.h"
#import "HomePageCalObj.h"
#import "TSMenuObjectStore.h"
#import "TSCalBoxView.h"
#import "TSCalendarStore.h"

#define kAnimationDuration 0.3f

@interface TSDayViewController ()
@property (nonatomic, strong) NSDate *date;
- (void)reloadDayAnimated:(BOOL)animated context:(void *)context;
@end

@implementation TSDayViewController

@synthesize date = _date;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupCalendar];
    }
    return self;
}

#pragma mark create and destroy calendar view
- (id)init {
	if(self = [super init]) {
        [self setupCalendar];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    [self setupCalendar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCalendar {
    // create calendar view
    // GCCalendarView delegate / datasource.
    self.dataSource = self;
    self.delegate = self;
        
    viewDirty = YES;
    viewVisible = NO;
    
    self.title = @"TimeStamp";
    self.tabBarItem.image = [UIImage imageNamed:@"Calendar.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarShouldReload:)
                                                 name:GCCalendarShouldReloadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarTileTouch:)
                                                 name:__GCCalendarTileTouchNotification
                                               object:nil];
}

-(void)createEvent:(GCCalendarEvent *)event AtPoint:(CGPoint)point withDuration:(NSTimeInterval)seconds {
    [dayView createEvent:event AtPoint:point withDuration:seconds];
}

#pragma mark GCCalendarDataSource
- (NSArray *)calendarEventsForDate:(NSDate *)date {
    NSArray *EKArray = [[TSCalendarStore instance] allCalendarEventsForDate:[NSDate dateWithTimeInterval:-60*60*24*4 sinceDate: date]];
    
    // convert events from EKEvent to GCCalendarEvent
    NSMutableArray *GCEventArray = [[NSMutableArray alloc] init];
    for (EKEvent *e in EKArray) {
        GCCalendarEvent *gce = [self createGCEventFromEKEvent:e];
        [GCEventArray addObject:gce];
    }

    return [GCEventArray copy];
}

#pragma mark Utility methods
- (GCCalendarEvent *)createGCEventFromEKEvent:(EKEvent *)ekevent {
    GCCalendarEvent *gcevent = [[GCCalendarEvent alloc] init];
    
    gcevent.startDate = ekevent.startDate;
    gcevent.endDate = ekevent.endDate;
    gcevent.eventName = ekevent.title;
    gcevent.eventDescription = ekevent.notes;
    gcevent.allDayEvent = ekevent.allDay;
    gcevent.color = [UIColor colorWithCGColor:ekevent.calendar.CGColor];
    
    return gcevent;
}

// Replacing the GCCalPortraitView functionality
#pragma mark calendar actions
- (void)calendarShouldReload:(NSNotification *)notif {
	viewDirty = YES;
}

#pragma mark button actions
- (void)today {
	[[NSUserDefaults standardUserDefaults] setObject:self.date forKey:@"GCCalendarDate"];
	[dayView reloadData];
}
- (void)add {
	if (delegate != nil) {
		[delegate calendarViewAddButtonPressed:self];
	}
}

#pragma mark view notifications
- (void)loadView {
	[super loadView];
	
	self.date = [[NSUserDefaults standardUserDefaults] objectForKey:@"GCCalendarDate"];
	if (self.date == nil) {
		self.date = [NSDate date];
	}
		
	// setup initial day view
	dayView = [[GCCalendarDayView alloc] initWithCalendarView:self];
	dayView.frame = CGRectMake(0,
							   0,
							   self.calWrapperView.frame.size.width,
							   self.calWrapperView.frame.size.height);
	dayView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	[self.calWrapperView addSubview:dayView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (viewDirty) {
		[dayView reloadData];
		viewDirty = NO;
	}
	
	viewVisible = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	viewVisible = NO;
}

@end

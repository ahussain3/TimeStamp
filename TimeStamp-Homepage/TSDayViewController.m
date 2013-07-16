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

#define kAnimationDuration 0.3f


@interface TSDayViewController ()
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) GCCalendarDayView *dayView;
@property (nonatomic, strong) EKEventStore *store;

- (void)reloadDayAnimated:(BOOL)animated context:(void *)context;
@end

@implementation TSDayViewController

@synthesize date, dayView, hasAddButton, store;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Initialize MenuContainer
    self.menuBoxContainer = [[TSMenuBoxContainer alloc]initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, [[TSMenuObjectStore defaultStore]calendars].count * BOX_HEIGHT)];
    
    //addMenuContainer to scrollView
    [self.scrollView addSubview:self.menuBoxContainer];
    
    //Allow scrollView to scroll and set it's content size of that of the menuContainer
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = self.menuBoxContainer.frame.size;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup {
// create calendar view
    self.dataSource = self;
    self.delegate = self;
    
    
    dateBar.delegate = dayPicker;
    self.hasAddButton = NO;
    
    viewDirty = YES;
    viewVisible = NO;
    
    self.title = @"TimeStamp";
    self.tabBarItem.image = [UIImage imageNamed:@"Calendar.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarTileTouch:)
                                                 name:__GCCalendarTileTouchNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calendarShouldReload:)
                                                 name:GCCalendarShouldReloadNotification
                                               object:nil];
    
    

    store = [[EKEventStore alloc] init];
    if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            if (granted) {
                //NSLog(@"Events calendar accessed");
                //---- codes here when user allow your app to access theirs' calendar.
            } else
            {
                //NSLog(@"Failed to access events calendar");
                //----- codes here when user NOT allow your app to access the calendar.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar access failed" message:@"We can't do much if access to phone calendar is not granted - go to Settings to grant permission :)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
}

- (GCCalendarEvent *)createFromEKEvent:(EKEvent *)ekevent {
    GCCalendarEvent *gcevent = [[GCCalendarEvent alloc] init];
    
    gcevent.startDate = ekevent.startDate;
    gcevent.endDate = ekevent.endDate;
    gcevent.eventName = ekevent.title;
    gcevent.eventDescription = ekevent.notes;
    gcevent.allDayEvent = ekevent.allDay;
    gcevent.color = [UIColor colorWithCGColor:ekevent.calendar.CGColor];

    return gcevent;
}

#pragma mark GCCalendarDataSource
- (NSArray *)calendarEventsForDate:(NSDate *)d {

    // internet code ask user for permission
    // retrieve all calendars
    NSArray *calendars = [store calendarsForEntityType:EKEntityTypeEvent];
    
    // This array will store all the events from all calendars.
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    
    // Make sure you are at midnight on the current day
    // Set startDay to today at midnight
    NSDateComponents *components;
    components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:d];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];

    // The date period goes from the beginning of yesterday to the start of today. This ensures we don't miss events that started yesterday but ended today.
//    NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:components];
//    NSDate *startDate = [today dateByAddingTimeInterval:-24*60*60];
//    NSDate *endDate = [today dateByAddingTimeInterval:24*60*60];

//    [components setDay:[components day] - 1];
//    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
//    [components setDay:[components day] + 2];
//    NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSDate *startDate = [today dateByAddingTimeInterval:-60*60*24];
    NSDate *endDate = [today dateByAddingTimeInterval:60*60*24];
    
    NSLog(@"Start date (should be midnight): %@", startDate);
    
    for (EKCalendar *calendar in calendars) {
        
        // Print calendar information
        //NSLog(@"Calendar Title: %@", calendar.title);
        
        // Get events for calendar
        NSArray *calendarArray = [NSArray arrayWithObject:calendar];
        NSPredicate *searchPredicate = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendarArray];
        
        // create temporary array to store events for THIS calendar
        NSMutableArray *eventsForCalendar = [[store eventsMatchingPredicate:searchPredicate]mutableCopy];
        //NSLog(@"No. of events found for '%@' calendar: %i", calendar.title, [eventArray count]);
        NSMutableArray * temp = [[NSMutableArray alloc]init];
        
        // remove 'all-day' events
        for (EKEvent *event in eventsForCalendar) {
            if (event.allDay) {
                [temp addObject:event];
            }
        }
        [eventsForCalendar removeObjectsInArray:temp];
        
        // merge with main storage array
        [eventArray addObjectsFromArray:eventsForCalendar];
    }
    
    // sort events in order of start date.
    [eventArray sortUsingSelector:@selector(compareStartDateWithEvent:)];

    // delete events that don't begin today.
//    NSLog(@"Event array before deletions: %@", eventArray);
    NSMutableArray *remove = [[NSMutableArray alloc] init];
    for (EKEvent *e in eventArray) {
        if ([e.endDate compare:[today dateByAddingTimeInterval:1]] == NSOrderedAscending) {
            [remove addObject:e];
        }
    }
    [eventArray removeObjectsInArray:remove];
//    NSLog(@"Event array after deletions: %@", eventArray);
    
    // convert events from EKEvent to GCCalendarEvent
    NSMutableArray *GCEventArray = [[NSMutableArray alloc] init];
    for (EKEvent *e in eventArray) {
        GCCalendarEvent *gce = [self createFromEKEvent:e];
        [GCEventArray addObject:gce];
    }
    
//    NSLog(@"\n\nPulling events for date: %@", self.date);
//    for (GCCalendarEvent *e in GCEventArray) {
//        NSLog(@"Events pulled from phone - name: %@", e.eventName);
//        NSLog(@"Current event start time: %@", e.startDate);
//        NSLog(@"Current event end time: %@", e.endDate);
//    }
    
    return GCEventArray;
    
//    NSMutableArray *events = [NSMutableArray array];
//
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *now = [NSDate date];
//    NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit ) fromDate:now];
//        
//    [components setHour:0];
//    [components setMinute:0];
//        
//    NSDate *midnight = [cal dateFromComponents:components];
//    
//    NSArray *durations = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5*60*60], [NSNumber numberWithInt:30*60], [NSNumber numberWithInt:30*60], [NSNumber numberWithInt:30*60], [NSNumber numberWithInt:60*60], [NSNumber numberWithInt:90*60], [NSNumber numberWithInt:4*60*60], [NSNumber numberWithInt:60*60], [NSNumber numberWithInt:4*60*60], [NSNumber numberWithInt:30*60], [NSNumber numberWithInt:90*60], [NSNumber numberWithInt:45*60], [NSNumber numberWithInt:30*60], [NSNumber numberWithInt:60*60], [NSNumber numberWithInt:45*60], [NSNumber numberWithInt:59*60], nil];
//    NSArray *activities = [[NSArray alloc] initWithObjects:@"Sleep", @"Eat", @"TV", @"Travel", @"Fitness", @"Travel", @"Work", @"Eat", @"Work", @"Travel", @"Social", @"Eat", @"Sleep", @"Study", @"Web", @"Sleep", nil];
//        
//    GCCalendarEvent *oldEvent = [[GCCalendarEvent alloc] init];
//        BOOL firstEvent = YES;
//        
//        for (int ii = 0; ii < activities.count; ii++) {
//            GCCalendarEvent *newEvent = [[GCCalendarEvent alloc] init];
//            
//            if (firstEvent) {
//                newEvent.startDate = midnight;
//                firstEvent = NO;
//            } else {
//                newEvent.startDate = oldEvent.endDate;
//            }
//
//            newEvent.endDate = [newEvent.startDate dateByAddingTimeInterval:[[durations objectAtIndex:ii] doubleValue]];
//            newEvent.eventName = [activities objectAtIndex:ii];
////            newEvent.color = ;
//            [events addObject:newEvent];
//            oldEvent = newEvent;
//        }
//    
//    [events removeObjectAtIndex:2];
//    [events removeObjectAtIndex:4];
//    [events removeObjectAtIndex:5];
//    [events removeObjectAtIndex:8];
//    [events removeObjectAtIndex:10];
//    
//    return [events copy];
}

#pragma mark GCCalendarDelegate
- (void)calendarTileTouchedInView:(GCCalendarView *)view withEvent:(GCCalendarEvent *)event andTile:(GCCalendarTile *)tile {
	NSLog(@"Touch event %@", event.eventName);
    [self.dayView selectTile:tile];    
    viewDirty = YES;
}
- (void)calendarViewAddButtonPressed:(GCCalendarView *)view {
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Replacing the GCCalPortraitView functionality
#pragma mark create and destroy view
- (id)init {
	if(self = [super init]) {
		self.title = @"TimeStamp";
		self.tabBarItem.image = [UIImage imageNamed:@"Calendar.png"];
		
		viewDirty = YES;
		viewVisible = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarTileTouch:)
													 name:__GCCalendarTileTouchNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarShouldReload:)
													 name:GCCalendarShouldReloadNotification
												   object:nil];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark calendar actions
- (void)calendarShouldReload:(NSNotification *)notif {
	viewDirty = YES;
}
- (void)calendarTileTouch:(NSNotification *)notif {
	if (delegate != nil) {
		GCCalendarTile *tile = [notif object];
		[delegate calendarTileTouchedInView:self withEvent:[tile event] andTile:tile];
	}
}

#pragma mark GCDatePickerControl actions
- (void)datePickerDidChangeDate:(GCDatePickerControl *)picker {
	NSTimeInterval interval = [date timeIntervalSinceDate:picker.date];
	
	self.date = picker.date;
	
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"GCCalendarDate"];
	
	[self reloadDayAnimated:YES context:(__bridge void *)([NSNumber numberWithInt:interval])];
}

#pragma mark button actions
- (void)today {
	dayPicker.date = [NSDate date];
	
	self.date = dayPicker.date;
	
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"GCCalendarDate"];
	
	[self reloadDayAnimated:NO context:NULL];
}
- (void)add {
	if (delegate != nil) {
		[delegate calendarViewAddButtonPressed:self];
	}
}

#pragma mark custom setters
- (void)setHasAddButton:(BOOL)b {
	hasAddButton = b;
	
	if (hasAddButton) {
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				target:self
																				action:@selector(add)];
		self.navigationItem.leftBarButtonItem = button;
	}
	else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

#pragma mark view notifications
- (void)loadView {
	[super loadView];
	
	self.date = [[NSUserDefaults standardUserDefaults] objectForKey:@"GCCalendarDate"];
	if (date == nil) {
		self.date = [NSDate date];
	}
		
	// setup initial day view
	self.dayView = [[GCCalendarDayView alloc] initWithCalendarView:self];
	dayView.frame = CGRectMake(0,
							   0,
							   self.calWrapperView.frame.size.width,
							   self.calWrapperView.frame.size.height);
	dayView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
//    self.calWrapperView.backgroundColor = [UIColor blackColor];
	[self.calWrapperView addSubview:dayView];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (viewDirty) {
		[self reloadDayAnimated:NO context:NULL];
		viewDirty = NO;
	}
	
	viewVisible = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	viewVisible = NO;
}

#pragma mark view animation functions
- (void)reloadDayAnimated:(BOOL)animated context:(void *)context {
	if (animated) {
		NSTimeInterval interval = [(__bridge NSNumber *)context doubleValue];
		
		// block user interaction
		dayPicker.userInteractionEnabled = NO;
		
		// setup next day view
		GCCalendarDayView *nextDayView = [[GCCalendarDayView alloc] initWithCalendarView:self];
		CGRect initialFrame = dayView.frame;
		if (interval < 0) {
			initialFrame.origin.x = initialFrame.size.width;
		}
		else if (interval > 0) {
			initialFrame.origin.x = 0 - initialFrame.size.width;
		}
		else {
			return;
		}
		nextDayView.frame = initialFrame;
		nextDayView.date = date;
		[nextDayView reloadData];
		nextDayView.contentOffset = dayView.contentOffset;
        
		[self.calWrapperView addSubview:nextDayView];
		
		[UIView beginAnimations:nil context:(__bridge void *)(nextDayView)];
		[UIView setAnimationDuration:kAnimationDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		CGRect finalFrame = dayView.frame;
		if(interval < 0) {
			finalFrame.origin.x = 0 - finalFrame.size.width;
		} else if(interval > 0) {
			finalFrame.origin.x = finalFrame.size.width;
		}
		nextDayView.frame = dayView.frame;
		dayView.frame = finalFrame;
		[UIView commitAnimations];
	}
	else {
        
//		CGPoint contentOffset = dayView.contentOffset;
//      NSLog(@"Day view content offset: (%f,%f)", contentOffset.x, contentOffset.y);
		dayView.date = date;
		[dayView reloadData];
//		dayView.contentOffset = contentOffset;
	}
}
- (void)animationDidStop:(NSString *)animationID
				finished:(NSNumber *)finished
				 context:(void *)context {
	
	GCCalendarDayView *nextDayView = (__bridge GCCalendarDayView *)context;
	
	// cut variables
	[dayView removeFromSuperview];
	
	// reassign variables
	self.dayView = nextDayView;
		
	// reset pickers
	dayPicker.userInteractionEnabled = YES;
}

@end

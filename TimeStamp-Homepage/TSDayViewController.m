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
@property (nonatomic, strong) GCCalendarDayView *dayView;
@property (nonatomic, strong) UIView *dummyView;

- (void)reloadDayAnimated:(BOOL)animated context:(void *)context;
@end

@implementation TSDayViewController

@synthesize date, dayView, hasAddButton;

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
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc
                                    ] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:press];
    
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    // create calendar view
    // GCCalendarView delegate / datasource.
    self.dataSource = self;
    self.delegate = self;
    
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
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [[sender valueForKey:@"_startPointScreen"] CGPointValue];
    UIView *view = [self.view hitTest:point withEvent:nil];
    if ([view isKindOfClass:[TSCalBoxView class]]) {
        CGPoint dummyOrigin = [[view superview] convertPoint:view.frame.origin toView:self.view];
        CGRect dummyFrame = CGRectMake(dummyOrigin.x, dummyOrigin.y, view.frame.size.width, view.frame.size.height);
        if (TRUE) {self.dummyView = [[UIView alloc] initWithFrame:dummyFrame];}
        self.dummyView.backgroundColor = [UIColor blueColor];
        [self.view addSubview:self.dummyView];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender translationInView:self.view];
    UIView *view = [self.view hitTest:point withEvent:nil];
    if ([view isKindOfClass:[TSCalBoxView class]]) {
        UIView *dummyView = [[UIView alloc] initWithFrame:view.frame];
        dummyView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:dummyView];

        CGPoint translation = [sender translationInView:dummyView];
        dummyView.center = CGPointMake(dummyView.center.x + translation.x, dummyView.center.y + translation.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];

    }
}

-(void)createEvent:(GCCalendarEvent *)event AtPoint:(CGPoint)point withDuration:(NSTimeInterval)seconds {
    [dayView createEvent:event AtPoint:point withDuration:seconds];
}

#pragma mark GCCalendarDataSource
- (NSArray *)calendarEventsForDate:(NSDate *)d {
    NSArray *EKArray = [[TSCalendarStore instance] allCalendarEventsForDate:d];
    
    // convert events from EKEvent to GCCalendarEvent
    NSMutableArray *GCEventArray = [[NSMutableArray alloc] init];
    for (EKEvent *e in EKArray) {
        GCCalendarEvent *gce = [self createGCEventFromEKEvent:e];
        [GCEventArray addObject:gce];
    }

    return [GCEventArray copy];
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

#pragma mark button actions
- (void)today {
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

    dayView.date = date;
    [dayView reloadData];
        
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
}

@end

//
//  GCCalendarDayView.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarDayView.h"
#import "GCCalendarTile.h"
#import "GCCalendarView.h"
#import "GCCalendarEvent.h"
#import "GCCalendar.h"
#import "GCCalendarTodayView.h"
#import "GCGlobalSettings.h"

@interface GCCalendarAllDayView : UIView {
	NSArray *events;
}

- (id)initWithEvents:(NSArray *)a;
- (BOOL)hasEvents;

@end

@implementation GCCalendarAllDayView
- (id)initWithEvents:(NSArray *)a {
	if (self = [super init]) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"allDayEvent == YES"];
		events = [a filteredArrayUsingPredicate:pred];
		
		NSInteger eventCount = 0;
		for (GCCalendarEvent *e in events) {
			if (eventCount < 5) {
				GCCalendarTile *tile = [[GCCalendarTile alloc] init];
				tile.event = e;
                tile.color = e.color;
				[self addSubview:tile];
				
				eventCount++;
			}
		}
	}
	
	return self;
}
- (void)dealloc {
	events = nil;
	
}
- (BOOL)hasEvents {
	return ([events count] != 0);
}
- (CGSize)sizeThatFits:(CGSize)size {
	CGSize toReturn = CGSizeMake(0, 0);
	
	if ([self hasEvents]) {
		NSInteger eventsCount = ([events count] > 5) ? 5 : [events count];
		toReturn.height = (5 * 2) + (27 * eventsCount) + (eventsCount - 1);
	}
	
	return toReturn;
}
- (void)layoutSubviews {
	CGFloat start_y = 5.0f;
	CGFloat height = 27.0f;
	
	for (UIView *view in self.subviews) {
		// get calendar tile and associated event
		GCCalendarTile *tile = (GCCalendarTile *)view;
		tile.frame = CGRectMake(kTileLeftSide,
								start_y,
								self.frame.size.width - kTileLeftSide - kTileRightSide,
								height);
		start_y += (height + 1);
	}
}

- (void)drawRect:(CGRect)rect {
	// grab current graphics context
	CGContextRef g = UIGraphicsGetCurrentContext();
	
	// fill white background
	CGContextSetRGBFillColor(g, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(g, self.frame);
	
	// draw border line
	CGContextMoveToPoint(g, 0, self.frame.size.height);
	CGContextAddLineToPoint(g, self.frame.size.width, self.frame.size.height);
	
	// draw all day text
	UIFont *numberFont = [UIFont boldSystemFontOfSize:12.0];
	[[UIColor blackColor] set];
	NSString *text = [[NSBundle mainBundle] localizedStringForKey:@"ALL_DAY" value:@"" table:@"GCCalendar"];
	CGRect textRect = CGRectMake(6, 10, 40, [text sizeWithFont:numberFont].height);
	[text drawInRect:textRect withFont:numberFont];
	
	// stroke the path
	CGContextStrokePath(g);
}
@end

@interface GCCalendarDayView ()
@end

@implementation GCCalendarDayView

@synthesize date;

#pragma mark create and destroy view
+ (void)initialize {
	if(self == [GCCalendarDayView class]) {
	}
}
- (id)initWithCalendarView:(GCCalendarView *)view {
	if (self = [super init]) {
//		dataSource = view.dataSource;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        
        dataSource = (id<GCCalendarDataSource>)view;
	}
	return self;
}
- (void)reloadData {
	// get new events for date
	events = [dataSource calendarEventsForDate:date];
    NSArray *events_yesterday = [dataSource calendarEventsForDate:[date dateByAddingTimeInterval:-60*60*24]];
	NSArray *events_tomorrow = [dataSource calendarEventsForDate:[date dateByAddingTimeInterval:+60*60*24]];
    
	// drop all subviews
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	// create all day view
	allDayView = [[GCCalendarAllDayView alloc] initWithEvents:events];
	[allDayView sizeToFit];
	allDayView.frame = CGRectMake(0, 0, self.frame.size.width, allDayView.frame.size.height);
	allDayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:(UIView *)allDayView];
	
	// create scroll view
	scrollView = [[UIScrollView alloc] init];
	scrollView.backgroundColor = [UIColor colorWithRed:(242.0 / 255.0) green:(242.0 / 255.0) blue:(242.0 / 255.0) alpha:1.0];
	scrollView.frame = CGRectMake(0, allDayView.frame.size.height, self.frame.size.width,
								  self.frame.size.height - allDayView.frame.size.height);
	scrollView.contentSize = CGSizeMake(self.frame.size.width, kTodayViewHeight*3);
	scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    scrollView.userInteractionEnabled = YES;
    [self setContentOffset:CGPointMake(0, kTodayViewHeight)];
    NSLog(@"scroll view offset: (%f, %f)", scrollView.contentOffset.x, scrollView.contentOffset.y);

	[self addSubview:scrollView];
    
    // create 3 views: yesterday, today and tomorrow
    yesterdayView = [[GCCalendarTodayView alloc] initWithEvents:events_yesterday];
    yesterdayView.frame = CGRectMake(0, 0, self.frame.size.width, kTodayViewHeight);
    yesterdayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    yesterdayView.scrollView = scrollView;
    yesterdayView.date = [date dateByAddingTimeInterval:-60*60*24];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside:)];
//    [yesterdayView addGestureRecognizer:tap];
    
	// create today view
	todayView = [[GCCalendarTodayView alloc] initWithEvents:events];
	todayView.frame = CGRectMake(0, kTodayViewHeight, self.frame.size.width, kTodayViewHeight);
	todayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    todayView.scrollView = scrollView;
    todayView.date = date;
    [todayView addGestureRecognizer:tap];
    
    // create tomorrow view
    tomorrowView = [[GCCalendarTodayView alloc] initWithEvents:events_tomorrow];
    tomorrowView.frame = CGRectMake(0, 0 + 2 * kTodayViewHeight, self.frame.size.width, kTodayViewHeight);
    tomorrowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tomorrowView.scrollView = scrollView;
    tomorrowView.date = [date dateByAddingTimeInterval:60*60*24];
//    [tomorrowView addGestureRecognizer:tap];
    
    // Create a composite view combining the three we just created.
    UIView *compositeView = [[UIView alloc] init];
    [compositeView addSubview:yesterdayView];
    [compositeView addSubview:todayView];
    [compositeView addSubview:tomorrowView];
    
	[scrollView addSubview:compositeView];
}
-(void)selectTile:(GCCalendarTile *)t {
    if (!t.selected) {
        // This tile unselected, select it
        [self deselectAllTiles];
        t.selected = true;
        todayView.selectedTile = t;
        /* changing the order doesn't work yet - it will work once I configure it so that dragging events actually changes the start and end dates.
        [todayView bringSubviewToFront:todayView.selectedTile]; */
        scrollView.scrollEnabled = NO;
    } else {
        // This tile is already selected, deselect it
        t.selected = false;
        /* changing the order doesn't work yet - it will work once I configure it so that dragging events actually changes the start and end dates.
        [todayView sendSub/Users/awaishussain/Developer/TimeStamp-Homepage/GCCalendar/GCCalendarTile.mviewToBack:todayView.selectedTile];*/
        todayView.selectedTile = nil;
        scrollView.scrollEnabled = YES;
    }
}
-(void)tapOutside:(UITapGestureRecognizer *)sender {
    // NSLog(@"tapped view:%@", sender.view);
    CGPoint point = [sender locationInView:sender.view];
    UIView *subview = [sender.view hitTest:point withEvent:nil];
    if ([subview isKindOfClass:[GCCalendarTile class]]) {
        // Select the tile
        [self selectTile:(GCCalendarTile *)subview];
    } else if (0) {
        
    } else {
        // deselect all tiles
        [self deselectAllTiles];
    }
}
-(void)deselectAllTiles {
    // NSLog(@"deselectAllTiles");
    scrollView.scrollEnabled = YES;
    for (UIView *view in todayView.subviews) {
        if ([view respondsToSelector:@selector(setSelected:)]){
            // get calendar tile
            GCCalendarTile *tile = (GCCalendarTile *)view;
            [tile setSelected:false];
        }
    }
}
- (void)setContentOffset:(CGPoint)p {
	scrollView.contentOffset = p;
}
- (CGPoint)contentOffset {
	return scrollView.contentOffset;
}
- (void)addNewEvent {
    GCCalendarEvent *event = [[GCCalendarEvent alloc] init];
    event.startDate = [NSDate date];
    event.endDate = [NSDate dateWithTimeInterval:60*60 sinceDate:event.startDate];
    event.eventName = @"New Event Created!";
    event.color = [UIColor redColor];
    [todayView addNewEvent:event];
}

#pragma mark touch handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-began state
    [[self nextResponder] touchesBegan:touches withEvent:e];;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)e {
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)e {

    
//	UITouch *touch = [touches anyObject];
//	
//	if ([self pointInside:[touch locationInView:self] withEvent:nil]) {
//		[self touchesCancelled:touches withEvent:e];
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:__GCCalendarTileTouchNotification
//															object:self];
//	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-end state
}

@end
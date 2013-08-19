//
//  GCCalendarTodayView.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "GCCalendarTodayView.h"
#import "GCCalendarTile.h"
#import "GCCalendarView.h"
#import "GCCalendarEvent.h"
#import "GCCalendar.h"
#import "GCGlobalSettings.h"

static NSArray *timeStrings;

@interface GCCalendarTodayView () {
	// Array of the event objects which will be shown for this day
    NSArray *events;
    
    CGFloat yOffset;
}

- (id)initWithEvents:(NSArray *)a;
- (BOOL)hasEvents;
- (CGFloat)yValueForTime:(CGFloat)time;

@property (nonatomic, strong) UIView *nowArrow;

@end

@implementation GCCalendarTodayView
@synthesize nowArrow = _nowArrow, date = _date;

- (id)initWithEvents:(NSArray *)a {
	if (self = [super init]) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"allDayEvent == NO"];
		events = [a filteredArrayUsingPredicate:pred];
		for (GCCalendarEvent *e in events) {
            [self drawNewEvent:e];
		}
        
        [self initialize];
	}
	return self;
}
- (BOOL)hasEvents {
	return ([events count] != 0);
}
- (void)dealloc {
	events = nil;
}
- (void) initialize {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    
    timeStrings = [NSArray arrayWithObjects:@"12",
                   @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11",
                   @"12", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];

}
- (void) setDate:(NSDate *)date {
    // ensure date is set to midnight of today.
    if (date != _date) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:date];
        
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        
        NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
        _date = midnight;
    }
}
# pragma mark Utility methods
- (CGFloat)snappedYValueForYValue:(CGFloat)yValue {
    ;
    float step = (kHalfHourDiff * 2.0) / (60.0 / SNAP_TO_MINUTE_INCREMENT); // Grid step size.
    CGFloat newYValue = step * floor(((yValue - kTopLineBuffer) / step) + 0.5) + kTopLineBuffer;
    
    return newYValue;
}

- (CGFloat)yValueForTime:(CGFloat)time {
	return kTopLineBuffer + (kHalfHourDiff * 2 * time);;
}

- (NSDate *)timeForYValue:(CGFloat)yValue {
    if (yValue > self.frame.size.height) {
        NSLog(@"Warning: The event is a multiday event");
        return nil;
    }
    
    NSDate *date = self.date;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:self.date];
    CGFloat hours = (yValue - kTopLineBuffer) / (kHalfHourDiff * 2);
    [components setHour:floorf(hours)];
    [components setMinute:(hours - floorf(hours)) * 60.0f];
    date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return date;
}

# pragma mark Drawing / Subview methods
- (void)drawNewEvent:(GCCalendarEvent *)event {
    GCCalendarTile *tile = [[GCCalendarTile alloc] initWithEvent:event];
    tile.delegate = self;
    [self addGesturerecognizersForTile:tile];
    [self addSubview:tile];
}
- (void)layoutSubviews {
    if (userIsDraggingTile) return;
	for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GCCalendarTile class]]) {
            // get calendar tile and associated event
            GCCalendarTile *tile = (GCCalendarTile *)view;
            
            NSDateComponents *components;
            components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:tile.event.startDate];
            NSInteger startHour = [components hour];
            NSInteger startMinute = [components minute];
            
            components = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:tile.event.endDate];
            NSInteger endHour = [components hour];
            NSInteger endMinute = [components minute];
                        
            if ([tile.event.startDate compare:self.date] == NSOrderedAscending) {
                // the event bleeds in from the previous day
                startHour = 0;
                startMinute = 0;
            }
            if ([tile.event.endDate compare:[self.date dateByAddingTimeInterval:60*60*24 - 1]] == NSOrderedDescending) {
                // the event bleeds into the next day
                endHour = 23;
                endMinute = 60;
            }
            
            
            CGFloat startPos = kTopLineBuffer + startHour * 2 * kHalfHourDiff;
            startPos += (startMinute / 60.0) * (kHalfHourDiff * 2.0);
            startPos = floor(startPos);
            
            CGFloat endPos = kTopLineBuffer + endHour * 2 * kHalfHourDiff;
            endPos += (endMinute / 60.0) * (kHalfHourDiff * 2.0);
            endPos = floor(endPos);
            
            tile.naturalFrame = CGRectMake(kTileLeftSide,
                                    startPos,
                                    self.bounds.size.width - kTileLeftSide - kTileRightSide,
                                    endPos - startPos);
            
        }
	}
    [self drawLineForCurrentTime];
}

- (void)drawRect:(CGRect)rect {
    // grab current graphics context
	CGContextRef g = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(g, (242.0 / 255.0), (242.0 / 255.0), (242.0 / 255.0), 1.0);
	
	// fill morning hours light grey
	CGFloat morningHourMax = [self yValueForTime:(CGFloat)8];
	CGRect morningHours = CGRectMake(0, 0, self.frame.size.width, morningHourMax - 1);
	CGContextFillRect(g, morningHours);
    
	// fill evening hours light grey
	CGFloat eveningHourMax = [self yValueForTime:(CGFloat)20];
	CGRect eveningHours = CGRectMake(0, eveningHourMax - 1, self.frame.size.width, self.frame.size.height - eveningHourMax + 1);
	CGContextFillRect(g, eveningHours);
	
	// fill day hours white
	CGContextSetRGBFillColor(g, 1.0, 1.0, 1.0, 1.0);
	CGRect dayHours = CGRectMake(0, morningHourMax - 1, self.frame.size.width, eveningHourMax - morningHourMax);
	CGContextFillRect(g, dayHours);
	
	// draw hour lines
	CGContextSetShouldAntialias(g, NO);
	CGContextSetRGBStrokeColor(g, 0.0, 0.0, 0.0, .3);
	for (NSInteger i = 0; i < 25; i++) {
		CGFloat yVal = [self yValueForTime:(CGFloat)i];
		CGContextMoveToPoint(g, kSideLineBuffer, yVal);
		CGContextAddLineToPoint(g, self.frame.size.width, yVal);
	}
	CGContextStrokePath(g);
	
	// draw half hour lines
	CGContextSetShouldAntialias(g, NO);
	const CGFloat dashPattern[2] = {1.0, 1.0};
	CGContextSetRGBStrokeColor(g, 0.0, 0.0, 0.0, .2);
	CGContextSetLineDash(g, 0, dashPattern, 2);
	for (NSInteger i = 0; i < 24; i++) {
		CGFloat time = (CGFloat)i + 0.5f;
		CGFloat yVal = [self yValueForTime:time];
		CGContextMoveToPoint(g, kSideLineBuffer, yVal);
		CGContextAddLineToPoint(g, self.frame.size.width, yVal);
	}
	CGContextStrokePath(g);
	
	// draw hour numbers
	CGContextSetShouldAntialias(g, YES);
	[[UIColor blackColor] set];
	UIFont *numberFont = [UIFont systemFontOfSize:12.0];
	for (NSInteger i = 0; i < 25; i++) {
		CGFloat yVal = [self yValueForTime:(CGFloat)i];
		NSString *number = [timeStrings objectAtIndex:i];
		CGSize numberSize = [number sizeWithFont:numberFont];
        [number drawInRect:CGRectMake(0,
                                      yVal - floor(numberSize.height / 2) - 1,
                                      kSideLineBuffer - 10 - 10,
                                      numberSize.height)
                  withFont:numberFont
             lineBreakMode:NSLineBreakByTruncatingTail
                 alignment:NSTextAlignmentRight];
	}
	
	// draw am / pm text
	CGContextSetShouldAntialias(g, YES);
	[[UIColor grayColor] set];
	UIFont *textFont = [UIFont systemFontOfSize:12.0];
	for (NSInteger i = 0; i < 25; i++) {
		NSString *text = nil;
		if (i < 12 || i == 24) {
			text = @"am";
		}
		else if (i >= 12) {
			text = @"pm";
		}
		if (true) {
			CGFloat yVal = [self yValueForTime:(CGFloat)i];
			CGSize textSize = [text sizeWithFont:textFont];
			[text drawInRect:CGRectMake(kSideLineBuffer - 2 - textSize.width,
										yVal - (textSize.height / 2),
										textSize.width,
										textSize.height)
					withFont:textFont];
		}
	}
}

- (void)drawLineForCurrentTime {
    // Draws the (currently blue) line across the screen which indicates the current time.
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:now];
    float hours = [nowComponents hour] + ((float)[nowComponents minute] / 60);
    CGFloat yVal = [self yValueForTime:hours];
    
    NSDateComponents *displayDateComponents = [[NSCalendar currentCalendar] components:NSUIntegerMax fromDate:self.date];
    
    // Ensure line only appears on today's screen and is not drawn for every day
    BOOL viewIsToday = FALSE;
    if (nowComponents.day == displayDateComponents.day && nowComponents.month == displayDateComponents.month && nowComponents.year == displayDateComponents.year) {
        viewIsToday = TRUE;
    }
    if (!self.nowArrow && viewIsToday) {
        self.nowArrow = [[UIView alloc] initWithFrame:CGRectMake(0, yVal, self.bounds.size.width, 5)];
        [self addSubview:self.nowArrow];
    }
    
    self.nowArrow.backgroundColor = [UIColor blueColor];
    self.nowArrow.frame = CGRectMake(0, yVal, self.bounds.size.width, 3);
    
    // Still to do: automatically scroll so that 'now' is in the middle of the screen.
    
    [self performSelector:@selector(drawLineForCurrentTime) withObject:nil afterDelay:NOW_ARROW_TIME_PERIOD];
}

#pragma mark GCCalendarTileDelegate methods

- (void)deselectAllTiles {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GCCalendarTile class]]) {
            GCCalendarTile *tile = (GCCalendarTile *)view;
            tile.selected = NO;
        }
    }
    self.selectedTile = nil;
}

- (void)setSelectedTile:(GCCalendarTile *)tile {
    // Bring tile to front. So you can touch both draggable areas.
    [self bringSubviewToFront:tile];
    
    if (_selectedTile != tile) {
        _selectedTile = tile;
    }
}

#pragma mark Dealing with Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer.view isKindOfClass:[GCCalendarTile class]]) {
        if ([gestureRecognizer.view isKindOfClass:[GCCalendarTile class]]  && [(GCCalendarTile *)gestureRecognizer.view selected] == TRUE){
            return TRUE;
        } else {
            return FALSE;
        }
    }
    return TRUE;
}

- (void)addGesturerecognizersForTile:(GCCalendarTile *)tile {
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragEvent:)];
    drag.delegate = self;
    [tile addGestureRecognizer:drag];
    
    UIPanGestureRecognizer *startTimeGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(startTimeDragged:)];
    [tile.startTimeDragView addGestureRecognizer:startTimeGR];

    UIPanGestureRecognizer *endTimeGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeDragged:)];
    [tile.endTimeDragView addGestureRecognizer:endTimeGR];
}

- (void)handleDragEvent:(UIPanGestureRecognizer *)sender {
    if (sender.view == self.selectedTile) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            yOffset = [sender locationInView:self].y - self.selectedTile.naturalFrame.origin.y;
            return;
        }

        CGFloat newY = [sender locationInView:self].y - yOffset;
        CGFloat snappedY = [self snappedYValueForYValue:newY];
        
        CGRect newNatFrame = CGRectMake(self.selectedTile.naturalFrame.origin.x,
                                        snappedY,
                                        self.selectedTile.naturalFrame.size.width,
                                        self.selectedTile.naturalFrame.size.height);
        self.selectedTile.naturalFrame = newNatFrame;
        [sender setTranslation:CGPointMake(0, 0) inView:self];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"Drag gesture ended");
        [self updateTileToReflectNewPosition:self.selectedTile];
        return;
    }
}

- (void)startTimeDragged:(UIPanGestureRecognizer *)sender {
    if (sender.view == self.selectedTile.startTimeDragView) {
        userIsDraggingTile = TRUE;
        if (sender.state == UIGestureRecognizerStateBegan) {
            yOffset = [sender locationInView:self.selectedTile].y - sender.view.frame.origin.y;
        }

        CGFloat startYPosition = [sender locationInView:self].y - yOffset + tDragAreaHeight;
        startYPosition = [self snappedYValueForYValue:startYPosition];
        CGFloat height = (self.selectedTile.naturalFrame.origin.y + self.selectedTile.naturalFrame.size.height) - startYPosition;
        
        self.selectedTile.naturalFrame = CGRectMake(self.selectedTile.naturalFrame.origin.x,
                                                    startYPosition,
                                                    self.selectedTile.naturalFrame.size.width,
                                                    height);
        
        [sender setTranslation:CGPointMake(0, 0) inView:self];
        
        if (sender.state == UIGestureRecognizerStateEnded) {
            userIsDraggingTile = FALSE;
            
            // Update model to reflect new start time
//            NSLog(@"Gesture Ended");
            [self updateTileToReflectNewPosition:self.selectedTile];
        }
    }
}

- (void)endTimeDragged:(UIPanGestureRecognizer *)sender {
    if (sender.view == self.selectedTile.endTimeDragView) {
        userIsDraggingTile = TRUE;
        if (sender.state == UIGestureRecognizerStateBegan) {
            // calculate y offset
            yOffset = [sender locationInView:self.selectedTile].y - sender.view.frame.origin.y;
            return;
        }
        
        // work out the y position of the top of the end drag time.
        CGFloat endYPosition = [sender locationInView:self].y - yOffset + CORNER_RADIUS * 2;
        endYPosition = [self snappedYValueForYValue:endYPosition];
        
        // set the height of natural frame to be y pos - origin.
        CGFloat newTileHeight = endYPosition - self.selectedTile.naturalFrame.origin.y;
        
        self.selectedTile.naturalFrame = CGRectMake(self.selectedTile.naturalFrame.origin.x,
                                                    self.selectedTile.naturalFrame.origin.y,
                                                    self.selectedTile.naturalFrame.size.width,
                                                    newTileHeight);
        
        [sender setTranslation:CGPointMake(0, 0) inView:self];
        
        if (sender.state == UIGestureRecognizerStateEnded) {
            userIsDraggingTile = FALSE;
            
            // Update model to reflect new start time
//            NSLog(@"Gesture Ended");
            [self updateTileToReflectNewPosition:self.selectedTile];
        }
    }
}

- (void)updateTileToReflectNewPosition:(GCCalendarTile *)tile {
    // Calculate new start times based on new location.
    GCCalendarEvent *event = tile.event;
    event.startDate = [self timeForYValue:tile.naturalFrame.origin.y];
    event.endDate = [self timeForYValue:tile.naturalFrame.origin.y + tile.naturalFrame.size.height];
    tile.event = event;
    
    // Update model to reflect new start time
    [self.delegate updateEventWithNewTimes:tile.event];
}

@end


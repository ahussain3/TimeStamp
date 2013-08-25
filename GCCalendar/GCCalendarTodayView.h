//
//  GCCalendarTodayView.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GCCalendarProtocols.h"
#import "GCCalendarTile.h"
@class GCCalendarTile;
@class GCCalendarEvent;
@class GCCalendarTodayView;

@protocol GCCalendarTodayViewDelegate <NSObject>
- (void)updateEventWithNewTimes:(GCCalendarEvent *)gcevent;
- (void)respondToTileSlidRight:(GCCalendarTile *)tile inDayView:(GCCalendarTodayView *)dayView;
- (void)updateNavBarWithColor:(UIColor *)color;
@end

@protocol GCCalendarTodayViewDatasource <NSObject>
- (NSDate *)dateToDisplay;
- (NSArray *)eventsToDisplay;
@end

@interface GCCalendarTodayView : UIView <GCCalendarTileDelegate, UIGestureRecognizerDelegate> {
    BOOL userIsDraggingTile;
    // Array of the event objects which will be shown for this day
    NSArray *events;
    
    CGPoint offset;
    CGPoint initialCenter;
    CGFloat yOffset;
    BOOL dragState;
}

- (id)initWithEvents:(NSArray *)a;
- (void)removeEvent:(GCCalendarEvent *)event;
- (void)addNewEvent:(GCCalendarEvent *)event;
- (void)resetToCenter:(GCCalendarTile *)tile;

@property (nonatomic, strong) GCCalendarTile *selectedTile;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, weak) id<GCCalendarTodayViewDelegate> delegate;
@property (nonatomic, weak) id<GCCalendarTodayViewDatasource> datasource;

@end
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

@protocol GCCalendarTodayViewDelegate <NSObject>
- (void)updateEventWithNewTimes:(GCCalendarEvent *)gcevent;
@end

@interface GCCalendarTodayView : UIView <GCCalendarTileDelegate, UIGestureRecognizerDelegate> {
    BOOL userIsDraggingTile;
}

- (id)initWithEvents:(NSArray *)a;
- (void)drawNewEvent:(GCCalendarEvent *)event;

@property (nonatomic, strong) GCCalendarTile *selectedTile;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, weak) id<GCCalendarTodayViewDelegate> delegate;

@end
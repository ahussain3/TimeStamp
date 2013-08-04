//
//  GCCalendarTodayView.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GCCalendarProtocols.h"
@class GCCalendarTile;
@class GCCalendarEvent;

@interface GCCalendarTodayView : UIView {
}

- (id)initWithEvents:(NSArray *)a;
- (void)drawNewEvent:(GCCalendarEvent *)event;

@property (nonatomic, strong) GCCalendarTile *selectedTile;
@property (nonatomic, strong) NSDate *date;

@end
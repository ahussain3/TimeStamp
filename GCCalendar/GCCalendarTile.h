//
//  GCCalendarTile.h
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCCalendarEvent;
@class GCCalendarTile;

@protocol GCCalendarTileDelegate <NSObject>

- (void)deselectAllTiles;
- (void)setSelectedTile:(GCCalendarTile *)tile;

@end


/*
 A GCCalendarTile draws itself using data in the event passed to it.
 
 Each tile posts a notification whenever a touch ends inside its frame.
*/
@interface GCCalendarTile : UIView {
	// event title label
	UILabel *titleLabel;
	// event description label
	UILabel *descriptionLabel;
}

- (id)initWithEvent:(GCCalendarEvent *)event;

@property (nonatomic, strong) GCCalendarEvent *event;
@property (nonatomic) BOOL selected;

@property (nonatomic, weak) id<GCCalendarTileDelegate> delegate;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) UIView *startTimeDragView;
@property (nonatomic, strong) UIView *endTimeDragView;

@end

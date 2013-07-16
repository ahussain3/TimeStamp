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

@interface GCCalendarTodayView : UIView {
}

- (id)initWithEvents:(NSArray *)a;

@property (nonatomic, strong) GCCalendarTile *selectedTile;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSDate *date;

@end
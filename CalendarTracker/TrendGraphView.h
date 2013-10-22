//
//  TrendGraphView.h
//  PullEventKitData
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "UtilityMethods.h"
@class TrendGraphView;

@protocol TrendGraphViewDataSource <NSObject>
// Dictionary key should be NSDate object, value is (NSTimeInterval) representing duration of event.
- (NSDictionary *)valuesForPointsWithTrendGraphView:(TrendGraphView*)tgView;
- (UIColor *)colorForCalendarWithTrendGraphView:(TrendGraphView*)tgView;
@optional
- (NSString *)titleOfCalendarWithTrendGraphView:(TrendGraphView*)tgView;
@end

@interface TrendGraphView : UIView
@property (nonatomic, weak) IBOutlet id <TrendGraphViewDataSource> datasource;
@property (nonatomic,strong) NSMutableArray * labels;
@end

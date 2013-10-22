//
//  PieChartView.h
//  PullEventKitData
//
//  Created by Awais Hussain on 2/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
@class PieChartView;

@protocol PieChartViewDataSource <NSObject>
// Dictionary key should be calendar title, array should contain bar color, bar value, and percentage.
- (NSDictionary *)valuesForBars;
@end

@interface PieChartView : UIView <PieChartViewDataSource>
@property (nonatomic, weak) IBOutlet id <PieChartViewDataSource> dataSource;
@property (nonatomic,strong) NSMutableArray * labels;
@end

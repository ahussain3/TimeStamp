//
//  ColumnGraphView.h
//  PullEventKitData
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
@class ColumnGraphView;

@protocol ColumnGraphViewDataSource <NSObject>
// Dictionary key should be calendar title, array should contain bar color, bar value, and percentage. 
- (NSDictionary *)valuesForBars;
@end

@interface ColumnGraphView : UIScrollView <ColumnGraphViewDataSource>
@property (nonatomic, weak) IBOutlet id <ColumnGraphViewDataSource> dataSource;
@property (nonatomic,strong) NSMutableArray * labels;
@end

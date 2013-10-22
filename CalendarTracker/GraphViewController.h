//
//  GraphViewController.h
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"
#import "PieChartView.h"
#import "ColumnGraphView.h"
@class ColumnGraphView,TotalHoursViewController,PieChartView;

#import "TableHeaderToolBar.h"
@interface GraphViewController : UIViewController <TableHeaderToolBarDelegate>
@property (weak, nonatomic) IBOutlet PieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet ColumnGraphView *graphView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic)TotalHoursViewController* previousController;
@property (weak, nonatomic) IBOutlet TableHeaderToolBar *dateBar;
@property (nonatomic) CGRect savedFrame;

@end

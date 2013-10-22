//
//  PieChartView.m
//  PullEventKitData
//
//  Created by Awais Hussain on 2/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "PieChartView.h"

@implementation PieChartView

@synthesize dataSource = _dataSource;
@synthesize labels = _labels;

- (NSDictionary *)valuesForBars {
    NSMutableDictionary *valuesForBars = [[NSMutableDictionary alloc] init];
    
    // keys
#define KEY_1 @"Sleep"
#define KEY_2 @"Study"
#define KEY_3 @"Class"
#define KEY_4 @"Social"
#define KEY_5 @"Surv."
#define KEY_6 @"Fitness"
#define KEY_7 @"Misc"
#define KEY_8 @"Ex.Cur."
    
    // Arrays with data for keys
    NSArray *value_1 = [NSArray arrayWithObjects:[UIColor redColor], [NSNumber numberWithInt:53], [NSNumber numberWithInt:37], nil];
    NSArray *value_2 = [NSArray arrayWithObjects:[UIColor grayColor], [NSNumber numberWithInt:37], [NSNumber numberWithInt:22], nil];
    NSArray *value_3 = [NSArray arrayWithObjects:[UIColor blueColor], [NSNumber numberWithInt:28], [NSNumber numberWithInt:18], nil];
    NSArray *value_4 = [NSArray arrayWithObjects:[UIColor orangeColor], [NSNumber numberWithInt:14], [NSNumber numberWithInt:8], nil];
    NSArray *value_5 = [NSArray arrayWithObjects:[UIColor brownColor], [NSNumber numberWithInt:12], [NSNumber numberWithInt:7], nil];
    
    [valuesForBars setObject:value_1 forKey:KEY_1];
    [valuesForBars setObject:value_2 forKey:KEY_2];
    [valuesForBars setObject:value_3 forKey:KEY_3];
    [valuesForBars setObject:value_4 forKey:KEY_4];
    [valuesForBars setObject:value_5 forKey:KEY_5];
    
    return valuesForBars;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define SPACE_BELOW_GRAPH 15
#define SPACE_ABOVE_GRAPH 15
#define LEFT_MARGIN 15
#define RIGHT_MARGIN 15

#define INDEX_COLOR 0
#define INDEX_HOURS 1
#define INDEX_PERCENT 2

#define ALPHA 0.6
#define COLUMN_STROKE_WIDTH 2.5
#define AXIS_LINE_WIDTH 4.0
#define GRIDLINE_LINE_WIDTH 0.5
#define GRIDLINE_INCREMENT 50.0

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Set delegate
    // self.dataSource = self;
    
    // Clear View
    if (self.labels) {
        for (UILabel * l in self.labels) {
            [l removeFromSuperview];
        }
        [self.labels removeAllObjects];
    } else {
        self.labels = [[NSMutableArray alloc]init];
    }
    
    // Drawing code
    
    // Get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Define geometry
    CGPoint centreOfChart = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
    NSInteger radiusOfChart = (rect.size.width > rect.size.height) ? (rect.size.height / 2) - SPACE_ABOVE_GRAPH - SPACE_BELOW_GRAPH : (rect.size.width / 2) - LEFT_MARGIN - RIGHT_MARGIN;
    NSInteger radiusOfLabels = radiusOfChart + 20;
    
    // Massage Data into usable forms
    NSDictionary *allCals = [self.dataSource valuesForBars];
    NSArray *calTitles = [[self.dataSource valuesForBars] allKeys];

    float startAngle = 0;
    CGPoint startPoint = CGPointMake(centreOfChart.x + radiusOfChart, centreOfChart.y);
    
    double totalHours = 0;
    // Calculate total time spent
    for (NSString *title in calTitles) {
        NSArray *segmentInfo = [allCals objectForKey:title];
        NSNumber *hours = [segmentInfo objectAtIndex:INDEX_HOURS];
        totalHours += hours.doubleValue;
    }

    // Draw the pie chart
    for (NSString *title in calTitles) {
        NSArray *segmentInfo = [allCals objectForKey:title];

        // Calculate where the segment is going to go
        NSNumber *hours = [segmentInfo objectAtIndex:INDEX_HOURS];
        //NSLog(@"hours spent: %@", hours);
        double endAngle = startAngle + ((hours.doubleValue / totalHours) * 2*M_PI);
        //NSLog(@"startAngle: %f", startAngle);
        //NSLog(@"endAngle: %f", endAngle);
        
        // Draw Circular Segments - Preparation
        UIColor *strokeColor = [segmentInfo objectAtIndex:INDEX_COLOR];
        CGContextSetLineWidth(context, COLUMN_STROKE_WIDTH);
        UIColor *segmentColor = [strokeColor colorWithAlphaComponent:ALPHA];
        CGContextSetFillColorWithColor(context, segmentColor.CGColor);
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        
        // Draw Circular Segments
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, centreOfChart.x, centreOfChart.y);
        CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
//        NSLog(@"Centre Point x,y: %f, %f", centreOfChart.x, centreOfChart.y);
//        NSLog(@"StartPoint, x,y: %f, %f", startPoint.x, startPoint.y);
        CGContextAddArc(context, centreOfChart.x, centreOfChart.y, radiusOfChart, startAngle, endAngle, 0);
        CGPoint endPoint = CGContextGetPathCurrentPoint(context);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        // Add labels
        double bisectAngle = (startAngle + endAngle) / 2;
        UILabel *hoursLabel = [[UILabel alloc] initWithFrame:CGRectMake((centreOfChart.x + radiusOfLabels * cos(bisectAngle)) - 40/2, (centreOfChart.y + radiusOfLabels * sin(bisectAngle)) - 15, 40, 15)];
        hoursLabel.text = [NSString stringWithFormat:@"%2@h", hours];
        hoursLabel.backgroundColor = [UIColor clearColor];
        hoursLabel.font = [UIFont boldSystemFontOfSize:15.0];
        hoursLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:hoursLabel];
        
        UILabel *percentLabel = [[UILabel alloc] initWithFrame:CGRectMake((centreOfChart.x + radiusOfLabels * cos(bisectAngle)) - 40/2, (centreOfChart.y + radiusOfLabels * sin(bisectAngle)) + 5, 40, 15)];
        percentLabel.text = [NSString stringWithFormat:@"%2@%%", [segmentInfo objectAtIndex:INDEX_PERCENT]];
        percentLabel.backgroundColor = [UIColor clearColor];
        percentLabel.font = [UIFont systemFontOfSize:13.0];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:percentLabel];
        
        [self.labels addObjectsFromArray:[NSArray arrayWithObjects:hoursLabel, percentLabel, nil]];
        
        startPoint = endPoint;
        startAngle = endAngle;
    }
}


@end

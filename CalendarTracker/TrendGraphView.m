//
//  TrendGraphView.m
//  PullEventKitData
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TrendGraphView.h"

@implementation TrendGraphView

@synthesize datasource = _datasource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Dictionary key should be NSDate object, value is NSNumber of hours representing duration of event.
- (NSDictionary *)valuesForPoints {
    NSDate *date_7 = [NSDate date];
    NSDate *date_6 = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date_7];
    NSDate *date_5 = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date_6];
    NSDate *date_4 = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date_5];
    NSDate *date_3 = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date_4];
    NSDate *date_2 = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date_3];
    NSDate *date_1 = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date_2];

    NSDictionary *points = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:2.5], date_1, [NSNumber numberWithDouble:4.0], date_2, [NSNumber numberWithDouble:6.0], date_3, [NSNumber numberWithDouble:3.0], date_4, [NSNumber numberWithDouble:1.0], date_5, [NSNumber numberWithDouble:0], date_6, [NSNumber numberWithDouble:1.0], date_7, nil];
    
    return points;
}

- (UIColor *)colorForCalendar {
    UIColor *color = [UIColor redColor];
    return color;
}

#define LEFT_MARGIN 15
#define RIGHT_MARGIN 15
#define SPACE_BELOW_GRAPH 25
#define SPACE_ABOVE_GRAPH 45

#define ALPHA 0.4
#define COLUMN_STROKE_WIDTH 2.5
#define AXIS_LINE_WIDTH 4.0
#define PLOTTED_LINE_WIDTH 3.0
#define GRIDLINE_LINE_WIDTH 0.5
#define GRIDLINE_INCREMENT 50.0


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.labels) {
        for (UILabel * l in self.labels) {
            [l removeFromSuperview];
        }
        [self.labels removeAllObjects];
    }else{
        self.labels = [[NSMutableArray alloc]init];
    }
    
    // Pull points to plot
    NSDictionary *pointValues = [self.datasource valuesForPointsWithTrendGraphView:self];
    
    NSArray *unsortedPoints = [pointValues allKeys];
    NSArray *points = [unsortedPoints sortedArrayUsingSelector:@selector(compare:)];
    
    // Get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Define geometry
    CGPoint graphOrigin = CGPointMake(LEFT_MARGIN, rect.size.height - SPACE_BELOW_GRAPH);
    
    CGFloat distBetweenPoints = (rect.size.width - LEFT_MARGIN - RIGHT_MARGIN) / ([points count] - 1);
    CGFloat gridlineLocation = graphOrigin.y;
    
    // Draw major gridlines
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, GRIDLINE_LINE_WIDTH);
    do {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, graphOrigin.x, gridlineLocation - GRIDLINE_INCREMENT);
        CGContextAddLineToPoint(context, graphOrigin.x + (rect.size.width - LEFT_MARGIN - RIGHT_MARGIN), gridlineLocation - GRIDLINE_INCREMENT);
        CGContextStrokePath(context);
        gridlineLocation -= GRIDLINE_INCREMENT;
    } while (gridlineLocation > 0);

    
    NSNumber *max;
    
    for (NSDate *date in points) {
        NSNumber *valueForPoint = [pointValues objectForKey:date];
        //NSLog(@"pointValues: %@", pointValues);
        //NSLog(@"sortedPoints: %@", points);
        //NSLog(@"max.doublevalue: %f", max.doubleValue);
        //NSLog(@"valueForPoint.doublevalue: %f", valueForPoint.doubleValue);
        max = (max.doubleValue < valueForPoint.doubleValue) ? valueForPoint : max;
    }
    
    double conversion = (rect.size.height - SPACE_ABOVE_GRAPH - SPACE_BELOW_GRAPH) / max.doubleValue;
    //NSLog(@"conversion factor: %f", conversion);
    
    // Set parameters for drawing
    CGContextSetStrokeColorWithColor(context, [self.datasource colorForCalendarWithTrendGraphView:self].CGColor);
    CGContextSetLineWidth(context, PLOTTED_LINE_WIDTH);
    CGContextSetFillColorWithColor(context, [[self.datasource colorForCalendarWithTrendGraphView:self] colorWithAlphaComponent:ALPHA].CGColor);
    CGContextBeginPath(context);
    
    // Display "No Data" if there is no data to display
#define TEXT_WIDTH 100
#define TEXT_HEIGHT 50
    if([pointValues allKeys].count <2) {
        UILabel *noData = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x + (rect.size.width / 2) - (TEXT_WIDTH/2), rect.origin.y + (rect.size.height / 2) - (TEXT_HEIGHT/2), TEXT_WIDTH, TEXT_HEIGHT)];
        noData.text = @"No Data";
        noData.textAlignment = NSTextAlignmentCenter;
        noData.font = [UIFont boldSystemFontOfSize:25.0];
        noData.backgroundColor = [UIColor clearColor];
        noData.textColor = [UIColor grayColor];
        [self.labels addObject:noData];
        [self addSubview:noData];
        return;
    }
    
    int ii = 0;
    // draw line connecting points
    for (NSDate *date in points) {
        NSNumber *value = [pointValues objectForKey:date];
        CGFloat pointHeight = rect.size.height - SPACE_BELOW_GRAPH - (value.doubleValue * conversion);
        //NSLog(@"Point x-position: %f", (graphOrigin.x + distBetweenPoints * ii));
        //NSLog(@"Point y-position: %f", pointHeight);
        
        if (ii == 0) {
            CGContextMoveToPoint(context, graphOrigin.x, pointHeight);
        } else {
            CGContextAddLineToPoint(context, graphOrigin.x + distBetweenPoints * ii, pointHeight);
        }
        
        // Add labels to disply hours spent at each point
        CGPoint curPoint = CGContextGetPathCurrentPoint(context);
        UILabel *hours = [[UILabel alloc] initWithFrame:CGRectMake(curPoint.x - 20, curPoint.y - 20, 60, 15)];
        hours.text = [NSString stringWithFormat:@"%@h", value];
        hours.backgroundColor = [UIColor clearColor];
        hours.font = [UIFont boldSystemFontOfSize:15.0];
        hours.textAlignment = NSTextAlignmentCenter;
        [self addSubview:hours];
        [self.labels addObject:hours];
        
        
        ii ++;
    }
    CGContextStrokePath(context);
        
    // Fill in the area beneath the graph = you have to redraw the path
    // Set parameters for drawing
    CGContextSetStrokeColorWithColor(context, [self.datasource colorForCalendarWithTrendGraphView:self].CGColor);
    CGContextSetLineWidth(context, PLOTTED_LINE_WIDTH);
    CGContextSetFillColorWithColor(context, [[self.datasource colorForCalendarWithTrendGraphView:self] colorWithAlphaComponent:ALPHA].CGColor);
    CGContextBeginPath(context);

    int jj = 0;
    for (NSDate *date in points) {
        NSNumber *value = [pointValues objectForKey:date];
        CGFloat pointHeight = rect.size.height - SPACE_BELOW_GRAPH - (value.doubleValue * conversion);
        //NSLog(@"Point x-position: %f", (graphOrigin.x + distBetweenPoints * jj));
        //NSLog(@"Point y-position: %f", pointHeight);
        
        if (jj == 0) {
            CGContextMoveToPoint(context, graphOrigin.x, pointHeight);
        } else {
            CGContextAddLineToPoint(context, graphOrigin.x + distBetweenPoints * jj, pointHeight);
        }
        
        if (jj >= [points count] - 1) {
            // Fill in area below graph;
            //NSLog(@"jj: %i", jj);
            CGContextAddLineToPoint(context, graphOrigin.x + distBetweenPoints * (jj), graphOrigin.y + 1);
            CGContextAddLineToPoint(context, graphOrigin.x, graphOrigin.y + 1);
            //NSLog(@"Point x-position: %f", (graphOrigin.x + distBetweenPoints * (jj)));
            //NSLog(@"Point y-position: %f", pointHeight);
            CGContextClosePath(context);
            CGContextFillPath(context);
        }
        
        jj ++;
    }
    // Draw Horizontal Axis
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, AXIS_LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, graphOrigin.x, graphOrigin.y);
    CGContextAddLineToPoint(context, graphOrigin.x + (rect.size.width - LEFT_MARGIN - RIGHT_MARGIN), graphOrigin.y);
    CGContextStrokePath(context);
    
    // Add Labels below the Horizonal Axis
    int kk = 0;
    for (NSDate *date in points) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"E"];
        NSString *day = [formatter stringFromDate:date];
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(graphOrigin.x + distBetweenPoints * kk - 20 , graphOrigin.y + 5, 40, 15)];
        dayLabel.text = [NSString stringWithFormat:@"%@",day];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.font = [UIFont boldSystemFontOfSize:15.0];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:dayLabel];
        [self.labels addObject:dayLabel];
        kk++;
    }
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


@end

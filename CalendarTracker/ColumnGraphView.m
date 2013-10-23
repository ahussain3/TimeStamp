//
//  ColumnGraphView.m
//  PullEventKitData
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "ColumnGraphView.h"

@implementation ColumnGraphView

@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

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

#define BAR_WIDTH 40
#define BAR_SPACING 15
#define SPACE_BELOW_GRAPH 25
#define SPACE_ABOVE_GRAPH 35

#define INDEX_COLOR 0
#define INDEX_HOURS 1
#define INDEX_PERCENT 2

#define ALPHA 0.6
#define COLUMN_STROKE_WIDTH 2.5
#define AXIS_LINE_WIDTH 4.0

#define GRIDLINE_INCREMENT 50.0

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height));
    
    // Diagnostics
    //NSLog(@"In ColumnGraphView - width: %f", self.bounds.size.width);
    //NSLog(@"In ColumnGraphView - height: %f", self.bounds.size.height);
    //NSLog(@"In ColumnGraphView - x: %f", self.bounds.origin.x);
    //NSLog(@"In ColumnGraphView - y: %f", self.bounds.origin.y);
    
    // Get Data
    NSDictionary *allBars = [self.dataSource valuesForBars];
    NSArray *allBarTitles = [[self.dataSource valuesForBars] allKeys];
    
    if (self.labels) {
        for (UILabel * l in self.labels) {
            [l removeFromSuperview];
        }
        [self.labels removeAllObjects];
    } else {
        self.labels = [[NSMutableArray alloc]init];
    }
    
    // Set delegate
    //self.dataSource = self;
    
    // Drawing code
    // Get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Define geometry
    CGPoint graphOrigin = CGPointMake(BAR_SPACING / 2, rect.size.height - SPACE_BELOW_GRAPH);
    CGPoint barOrigin = graphOrigin;
    CGFloat gridlineLocation = graphOrigin.y;
    
    // Draw major gridlines
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 0.5);
    do {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, graphOrigin.x, gridlineLocation - GRIDLINE_INCREMENT);
        CGContextAddLineToPoint(context, graphOrigin.x + (rect.size.width - BAR_SPACING), gridlineLocation - GRIDLINE_INCREMENT);
        CGContextStrokePath(context);
        gridlineLocation -= GRIDLINE_INCREMENT;
    } while (abs(gridlineLocation) < rect.size.height - SPACE_ABOVE_GRAPH - SPACE_BELOW_GRAPH);
    
    // Draw rectangles - columns
    CGContextBeginPath(context);
    NSNumber *max;
    
    for (NSString *barTitle in allBarTitles) {
        NSArray *barValues = [allBars objectForKey:barTitle];
        NSNumber *hours = [barValues objectAtIndex:INDEX_HOURS];
        max = (max.doubleValue < hours.doubleValue) ? hours : max;
    }
    
    double conversion = (rect.size.height - SPACE_ABOVE_GRAPH - SPACE_BELOW_GRAPH) / max.doubleValue;

    // Draw the columns for the chart
    for (NSString *barTitle in allBarTitles) {
        // Drawing the rectangles
        NSArray *barValues = [allBars objectForKey:barTitle];
        //NSLog(@"Bar Title: %@", barTitle);
        //NSLog(@"Bar Color: %@", [barValues objectAtIndex:INDEX_COLOR]);
        //NSLog(@"Bar Value: %@", [barValues objectAtIndex:INDEX_HOURS]);
        //NSLog(@"Bar Percentage: %@", [barValues objectAtIndex:INDEX_PERCENT]);
        
        NSNumber *noOfHours = [barValues objectAtIndex:INDEX_HOURS];
        CGFloat barHeight = noOfHours.doubleValue * conversion;
        CGRect rectangle = CGRectMake(barOrigin.x, barOrigin.y - barHeight, BAR_WIDTH, barHeight);
        
        UIColor *strokeColor = [barValues objectAtIndex:INDEX_COLOR];
        UIColor *barColor = [strokeColor colorWithAlphaComponent:ALPHA];
        CGContextSetFillColorWithColor(context, barColor.CGColor);
        CGContextFillRect(context, rectangle);
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextStrokeRectWithWidth(context, rectangle, COLUMN_STROKE_WIDTH);
        
        // Column labels above and below the column itself.
        UILabel *hours = [[UILabel alloc] initWithFrame:CGRectMake(barOrigin.x - BAR_SPACING / 2, barOrigin.y - barHeight - 33, BAR_WIDTH + BAR_SPACING, 15)];
        hours.text = [NSString stringWithFormat:@"%@h",[barValues objectAtIndex:INDEX_HOURS]];
        hours.backgroundColor = [UIColor clearColor];
        hours.font = [UIFont boldSystemFontOfSize:15.0];
        hours.textAlignment = NSTextAlignmentCenter;
        [self addSubview:hours];
        
        UILabel *percent = [[UILabel alloc] initWithFrame:CGRectMake(barOrigin.x - BAR_SPACING / 2, barOrigin.y - barHeight - 18, BAR_WIDTH + BAR_SPACING, 15)];
        percent.text = [NSString stringWithFormat:@"%@%%",[barValues objectAtIndex:INDEX_PERCENT]];
        percent.backgroundColor = [UIColor clearColor];
        percent.font = [UIFont systemFontOfSize:12.0];
        percent.textAlignment = NSTextAlignmentCenter;
        [self addSubview:percent];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(barOrigin.x - BAR_SPACING / 2, barOrigin.y + 5, BAR_WIDTH + BAR_SPACING, 15)];
        title.text = barTitle;
        title.textColor = [barValues objectAtIndex:0];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:15.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        [self.labels addObjectsFromArray:[NSArray arrayWithObjects:title, percent, hours,nil]];
        
        barOrigin = CGPointMake(barOrigin.x + BAR_WIDTH + BAR_SPACING, barOrigin.y);
    }

    // Draw Horizontal Axis
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, AXIS_LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, graphOrigin.x, graphOrigin.y);
    CGContextAddLineToPoint(context, graphOrigin.x + (rect.size.width - BAR_SPACING), graphOrigin.y);
    CGContextStrokePath(context);
    
    // Display "No Data" if there is no data to display
#define TEXT_WIDTH 100
#define TEXT_HEIGHT 50
    if (allBars.count == 0) {
        UILabel *noData = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x + (rect.size.width / 2) - (TEXT_WIDTH/2), rect.origin.y + (rect.size.height / 2) - (TEXT_HEIGHT/2), TEXT_WIDTH, TEXT_HEIGHT)];
        noData.text = @"No Data";
        noData.textAlignment = NSTextAlignmentCenter;
        noData.font = [UIFont boldSystemFontOfSize:25.0];
        noData.backgroundColor = [UIColor clearColor];
        noData.textColor = [UIColor grayColor];
        [self.labels addObject:noData];
        [self addSubview:noData];
    }
}

@end

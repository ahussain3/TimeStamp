//
//  GraphViewController.m
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "GraphViewController.h"
#import "ColumnGraphView.h"
#import "TotalHoursViewController.h"
@interface GraphViewController ()

@end

@implementation GraphViewController

@synthesize savedFrame;

- (IBAction)switchGraphs:(id)sender {
    if (!self.graphView.hidden) {
        self.graphView.hidden = TRUE;
        self.pieChartView.hidden = FALSE;
    } else {
        self.graphView.hidden = FALSE;
        self.pieChartView.hidden = TRUE;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"                     style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                        action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = customBackButton;
    self.navigationItem.title = @"Graph";
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define BAR_WIDTH 40
#define BAR_SPACING 15

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.graphView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    self.graphView.dataSource = self.previousController;
    [self.graphView setNeedsDisplay];

    [self.pieChartView setNeedsDisplay];
    self.pieChartView.dataSource = self.previousController;

    [self resetTimePeriod];
}

- (void)viewDidAppear:(BOOL)animated {
    self.savedFrame = self.graphView.frame;
    [self updateGraphViewSize];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.savedFrame = self.graphView.frame;
    [self updateGraphViewSize];
}

- (void)updateGraphViewSize {
    // Get Data
    NSDictionary *allBars = [self.graphView.dataSource valuesForBars];
    
    // Ensure that the view is sufficiently large
    int reqWidth = (allBars.count * (BAR_SPACING + BAR_WIDTH));
    NSLog(@"Required Width: %d", reqWidth);
    NSLog(@"Actual Width: %f", self.graphView.frame.size.width);

    CGRect newFrame = CGRectMake(self.graphView.frame.origin.x, self.graphView.frame.origin.y, reqWidth, self.graphView.frame.size.height);
    if (self.graphView.frame.size.width < reqWidth) {
        self.graphView.frame = newFrame;
    } else {
        // Go back to original width?
        // The line below doesn't seem to quite to be working properly. The self.savedFrame is not what should be there. 
        self.graphView.frame = self.savedFrame;
    }
    self.scrollView.contentSize = self.graphView.bounds.size;
}

- (void)update {
    [self.previousController update];
    [self.graphView setNeedsDisplay];
    [self.pieChartView setNeedsDisplay];
    [self updateGraphViewSize];
    [self resetTimePeriod];
}

-(void) resetTimePeriod
{
    [self.dateBar editDateLabelString: self.previousController.dateBar.dateString];
}
-(IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];  
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
@end

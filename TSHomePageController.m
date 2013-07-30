//
//  TSHomePageController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSHomePageController.h"
#import "TSListTableViewController.h"

@interface TSHomePageController ()

@end

@implementation TSHomePageController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"listSegue"]) {
        TSListTableViewController *controller = (TSListTableViewController *)segue.destinationViewController;
        controller.superController = self;
//        controller.reorderingEnabled = NO;
    }
}

-(void)respondToDragAcross:(UIPanGestureRecognizer *)sender {
    NSLog(@"Dragging across screen");
}

@end

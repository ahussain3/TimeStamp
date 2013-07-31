//
//  TSHomePageController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSHomePageController.h"
#import "TSListTableViewController.h"
#import "TSDayViewController.h"

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
    
    // Add a button to the nav bar to create new events
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    button.width = 40.0;
    self.navigationItem.rightBarButtonItem = button;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Initialization
    if ([[segue identifier] isEqualToString:@"listSegue"]) {
        listController = (TSListTableViewController *)segue.destinationViewController;
    }
    if ([[segue identifier] isEqualToString:@"daySegue"]) {
        dayViewController = (TSDayViewController *)segue.destinationViewController;
    }
    [self initializeControllers];
}

- (void)initializeControllers {
    listController.superController = self;
    listController.dragDelegate = self;
}

-(void)respondToDragAcross:(UIPanGestureRecognizer *)sender {
    NSLog(@"Dragging across screen");
}

#pragma mark - ATSDragToReorderTableViewControllerDelegate methods
- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController draggedCellOutsideTableView:(UITableViewCell *)cell {
    NSLog(@"Delegate method for drag across called.");
    
    [dayViewController createEventAtPoint:CGPointZero withDuration:60*60];
}


@end

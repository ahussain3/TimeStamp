//
//  TSHomePageController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "TSHomePageController.h"
#import "TSListTableViewController.h"
#import "TSDayViewController.h"
#import "GCCalendarEvent.h"
#import "TSCategory.h"
#import "TSCategoryStore.h"

@interface TSHomePageController ()
@property (weak, nonatomic) IBOutlet UIView *dismissKeyboardView;

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
    // Initialization
    if ([[segue identifier] isEqualToString:@"listSegue"]) {
        listNavController = (UINavigationController *)segue.destinationViewController;        
        listController = (TSListTableViewController *)listNavController.topViewController;
        
    }
    if ([[segue identifier] isEqualToString:@"daySegue"]) {
        dayViewController = (TSDayViewController *)segue.destinationViewController;
    }
    [self initializeControllers];
    [self initalizeKeyboardNotifications];
}

- (void)initalizeKeyboardNotifications {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardViewTapped:)];
    [self.dismissKeyboardView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initializeControllers {
    listNavController.navigationBarHidden = YES;    
    listController.dragDelegate = self;
    listController.path = ROOT_CATEGORY_PATH;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:listController action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Add a button to the nav bar to create new events
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                                            action:@selector(addNewCategory:)];
    button.width = 40.0;
    self.navigationItem.rightBarButtonItem = button;
}

#pragma mark - ATSDragToReorderTableViewControllerDelegate methods
- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController draggedCellOutsideTableView:(TSListTableViewCell *)cell {
    
    CGPoint center = [listController.view convertPoint:cell.center toView:dayViewController.calWrapperView];
    
    GCCalendarEvent *event = [[GCCalendarEvent alloc] init];
    event.eventName = cell.textLabel.text;
    event.color = cell.contentView.backgroundColor;
    event.calendarIdentifier = cell.category.calendar.calendarIdentifier;
    
//    event.calender // need to set this once we have a list of calendars; Create a TSCalendarStore model object which contains this array.
    [dayViewController createEvent:event AtPoint:center withDuration:60*60];
}

- (void)addNewCategory:(id)sender {
    NSLog(@"Creating new category");
    TSListTableViewController *list = (TSListTableViewController *)listNavController.topViewController;
    [[TSCategoryStore instance] addSubcategory:@"Test" AtPathLevel:list.path];
    [list reloadData];
}

- (void)keyboardWillShow {
    self.dismissKeyboardView.hidden = NO;
}
- (void)keyboardWillHide {
    self.dismissKeyboardView.hidden = YES;
}

- (void)keyboardViewTapped:(UITapGestureRecognizer *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideKeyboard" object:self];
    self.dismissKeyboardView.hidden = YES;
}
@end

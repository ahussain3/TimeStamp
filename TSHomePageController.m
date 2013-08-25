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
    
    dragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToCellDragged:)];
    [self.view addGestureRecognizer:dragGestureRecognizer];
    dragGestureRecognizer.delegate = self;
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
        dayViewController.superController = self;
    }
    [self initializeControllers];
    [self initializeKeyboardNotifications];
    [self initializeCalendarNotifications];
}
- (void)initializeCalendarNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:nil];
}
- (void)initializeKeyboardNotifications {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardViewTapped:)];
    [self.dismissKeyboardView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initializeControllers {
    listNavController.navigationBarHidden = YES;    
    listController.dragDelegate = self;
    listController.path = ROOT_CATEGORY_PATH;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:listController action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Add a button to the nav bar to create new events
//    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:dayViewController action:@selector(reloadTodayView)];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:UIBarButtonItemStyleBordered target:dayViewController action:@selector(scrollToCurrentTime)];

    button.width = 40.0;
    self.navigationItem.rightBarButtonItem = button;
}

#pragma mark - ATSDragToReorderTableViewControllerDelegate methods
- (void)dealWithDraggedCell:(UITableViewCell *)cell inTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cellCopy;
    cellCopy = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
	cellCopy.frame = [tableView rectForRowAtIndexPath:indexPath];
    cellCopy.frame = [self.view convertRect:cellCopy.frame fromView:tableView];
    cellCopy.selected = YES;
    
    initialListCellCenter = cellCopy.center;
    
    self.draggedCell = cellCopy;
    [self.view addSubview:cellCopy];
}

- (void)respondToCellDragged:(UIPanGestureRecognizer *)sender {
    if (!self.draggedCell) return;
    
	CGPoint translation = [sender translationInView:self.view];
    
    NSLog(@"drag gesture state: %i", sender.state);
    
	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self draggingEndedOnCell:(TSListTableViewCell *)self.draggedCell];
    } else {
		[self updateFrameOfDraggedCellForTranlationPoint:translation];
    }
}
- (void)draggingEndedOnCell:(TSListTableViewCell *)cell {
    if (cell.center.x > listController.view.frame.size.width + 50) {
        CGPoint center = [cell.superview convertPoint:cell.center toView:dayViewController.view];
        
        GCCalendarEvent *event = [[GCCalendarEvent alloc] init];
        NSString *name = [[NSString alloc] init];
        if ([cell.category.path isEqualToString:ROOT_CATEGORY_PATH]) {
            name = cell.textLabel.text;
        } else {
            name = [NSString stringWithFormat:@"%@:%@",cell.category.path, cell.textLabel.text];
            name = [name substringFromIndex:[ROOT_CATEGORY_PATH length] + 1];
        }
        event.eventName = name;
        event.color = cell.contentView.backgroundColor;
        event.calendarIdentifier = cell.category.calendar.calendarIdentifier;
        
        //    event.calender // need to set this once we have a list of calendars; Create a TSCalendarStore model object which contains this array.
        [dayViewController createEvent:event AtPoint:center withDuration:60*60];
    }
    
    [self cleanUpAfterDraggingEnded];
}
- (void)cleanUpAfterDraggingEnded {
    if (self.draggedCell) {
        [self.draggedCell removeFromSuperview];
        self.draggedCell = nil;
    }
}
- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController willEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
    [self cleanUpAfterDraggingEnded];
}
- (void)updateFrameOfDraggedCellForTranlationPoint:(CGPoint)translation {
    CGFloat newXCenter = initialListCellCenter.x + translation.x;
	CGFloat newYCenter = initialListCellCenter.y + translation.y;
    
	/*
     draggedCell.center shouldn't go offscreen.
     Check that it's at least the contentOffset and no further than the contentoffset plus the contentsize.
	 */
    newXCenter = MIN(newXCenter, self.view.frame.size.width);
	newYCenter = MIN(newYCenter, self.view.frame.size.height);
    
	CGPoint newDraggedCellCenter = {
		.x = newXCenter,
		.y = newYCenter
	};
    
	self.draggedCell.center = newDraggedCellCenter;
}

- (UIView *)viewOnWhichToAddCell {
    return self.view;
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
- (void)storeChanged:(NSNotification *)notif {
    if (dayViewController && [dayViewController respondsToSelector:@selector(reloadTodayView)]) {
        [dayViewController reloadTodayView];
    }
}
     
#pragma mark UIGestureRecognizerDelegate methods
/*
 *	Defaults to NO, needs to be YES for press and drag to be one continuous action.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

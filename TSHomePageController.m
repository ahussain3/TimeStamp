//
//  TSHomePageController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "TSHomePageController.h"
#import "TSListTableViewController.h"
#import "TSDayViewController.h"
#import "GCCalendarEvent.h"
#import "TSCategory.h"
#import "TSCategoryStore.h"
#import "TSCalendarStore.h"
#import "UIColor+CalendarPalette.h"

@interface TSHomePageController () {
    BOOL userIsDragging;
    TSCalendarStore *calStore;
}
@property (weak, nonatomic) IBOutlet UIView *dismissKeyboardView;
@property (strong, nonatomic) NSSet *tempSet;

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
    calStore = [TSCalendarStore instance];
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

- (void)initializeControllers {
    listNavController.navigationBarHidden = YES;
    listController.dragDelegate = self;
    listController.path = ROOT_CATEGORY_PATH;
    
    [self updateNavBarWithDate:[NSDate date]];
    dayViewController.date = [NSDate date];
    
    // Set up navigation bar buttons. 
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorFromHexString:@"#282E5C"];
    [button setTitle:@"Home" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
    button.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
    [button addTarget:self action:@selector(goHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Add a button to the nav bar to create new events
    //    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:dayViewController action:@selector(reloadTodayView)];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor colorFromHexString:@"#282E5C"];
    [button2 setTitle:@"Today" forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [button2.layer setCornerRadius:5.0f];
    [button2.layer setMasksToBounds:YES];
    button2.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
    [button2 addTarget:self action:@selector(scrollToCurrentTime:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* todayButton = [[UIBarButtonItem alloc] initWithCustomView:button2];
        
    self.navigationItem.rightBarButtonItem = todayButton;
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
- (void)updateNavBarWithDate:(NSDate *)date {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE, MMM d"];
    NSString *string = [dateFormatter stringFromDate:date];
    self.title = string;
}
- (void)scrollToCurrentTime:(id)sender {
//    self.nextButton.hidden = !self.nextButton.hidden;
//    self.prevButton.hidden = !self.prevButton.hidden;
    if (dayViewController) {
        [self updateNavBarWithDate:[NSDate date]];
        dayViewController.date = [NSDate date];
        [dayViewController reloadTodayView];
        [dayViewController scrollToCurrentTime];
    }
}
- (void)goHome:(id)sender {
    if ([listController respondsToSelector:@selector(goHome:)]) [listController goHome:sender];
}

#pragma mark Show Calendar Chooser 
- (IBAction)showCalChooser:(id)sender {
    EKCalendarChooser *calChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:[calStore store]];
//    [calChooser setEditing:YES];
    calChooser.selectedCalendars = calStore.activeCalendars;
    //    calChooser.selectedCalendars = self.tempSet;
    calChooser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    calChooser.showsCancelButton = YES;
    calChooser.showsDoneButton = YES;
    calChooser.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:calChooser];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark EKCalendarChooserDelegate
- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    [calendarChooser dismissViewControllerAnimated:YES completion:^{
        if ([calStore.activeCalendars isEqualToSet:calendarChooser.selectedCalendars]) return;
        [calStore setActiveCalendars:calendarChooser.selectedCalendars];
        [dayViewController reloadTodayView];
        [listController reloadData];
    }];
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [calendarChooser dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Change date methods.
- (IBAction)nextDay:(id)sender {
    NSDate *newDate = [dayViewController.date dateByAddingTimeInterval:60*60*24];
    [self updateNavBarWithDate:newDate];
    dayViewController.date = newDate;
    [dayViewController reloadTodayView];
}

- (IBAction)prevDay:(id)sender {
    NSDate *newDate = [dayViewController.date dateByAddingTimeInterval:-60*60*24];
    [self updateNavBarWithDate:newDate];
    dayViewController.date = newDate;
    [dayViewController reloadTodayView];
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
    if (sender.state == UIGestureRecognizerStateBegan && self.draggedCell) userIsDragging = TRUE;
    if (!userIsDragging) return;
    
	CGPoint translation = [sender translationInView:self.view];
    
//    NSLog(@"drag gesture state: %i", sender.state);
    
	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self draggingEndedOnCell:(TSListTableViewCell *)self.draggedCell];
        userIsDragging = FALSE;
    } else {
		[self updateFrameOfDraggedCellForTranlationPoint:translation];
    }
}
- (void)draggingEndedOnCell:(TSListTableViewCell *)cell {
    if (cell.center.x > listController.view.frame.size.width + 50) {
        CGPoint center = [cell.superview convertPoint:cell.center toView:dayViewController.view];
        
        GCCalendarEvent *event = [[GCCalendarEvent alloc] init];
        NSString *name = [[NSString alloc] init];
        NSMutableArray *string = [[cell.category.path componentsSeparatedByString:@":"] mutableCopy];
        [string removeObjectAtIndex:0]; // remove the $ROOT text.
        if (string.count > 1) {
            [string removeObjectAtIndex:0]; // Remove the "category" label.
            name = [NSString stringWithFormat:@"%@ : %@",[string componentsJoinedByString:@" : "], cell.textLabel.text];
        } else {
            name = cell.textLabel.text;
        }
        
        event.eventName = name;
        event.color = cell.contentView.backgroundColor;
        event.calendarIdentifier = cell.category.calendar.calendarIdentifier;
        
// need to set this once we have a list of calendars; Create a TSCalendarStore model object which contains this array.
        [dayViewController createEvent:event AtCenterPoint:center withDuration:60*60];
    }
    
    [self cleanUpAfterDraggingEnded];
}
- (void)cleanUpAfterDraggingEnded {
    if (self.draggedCell) {
        [self.draggedCell removeFromSuperview];
        self.draggedCell = nil;
    }
}
- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
    [self draggingEndedOnCell:(TSListTableViewCell *)self.draggedCell];
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
    [[TSCalendarStore instance] setEventsShouldReload:YES];
}
     
#pragma mark UIGestureRecognizerDelegate methods
/*
 *	Defaults to NO, needs to be YES for press and drag to be one continuous action.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

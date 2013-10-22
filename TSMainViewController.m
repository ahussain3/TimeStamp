//
//  TSMainViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 9/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSMainViewController.h"
#import "DMLazyScrollView.h"
#import "TSHomePageController.h"
#import "TSCalendarStore.h"
#import <EventKitUI/EventKitUI.h>
#import "TotalHoursViewController.h"
#import "EventViewController.h"

@interface TSMainViewController () <DMLazyScrollViewDelegate, EKCalendarChooserDelegate>{
    TSCalendarStore *calStore;
    
    NSArray *viewControllerArray;
    TSHomePageController *homeController;
    UIViewController *dataController;
}

@end

@implementation TSMainViewController

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
    calStore = [TSCalendarStore instance];
    
	// Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *controller1 = [storyboard instantiateViewControllerWithIdentifier:@"homeController"];
    homeController = (TSHomePageController *)controller1.topViewController;
    
    // Load data side of the app.
    TotalHoursViewController * tc = [[TotalHoursViewController alloc]initWithNibName:@"TotalHoursViewController" bundle:nil];
//    EventViewController *tc = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tc];
    dataController = nav;
    
//    dataController = [storyboard instantiateViewControllerWithIdentifier:@"dataController"];
    viewControllerArray = [NSArray arrayWithObjects:controller1, dataController, nil];
//    [self initializeToolbar];
    
    // PREPARE LAZY VIEW
    self.lazyView.scrollEnabled = NO;
    __weak __typeof(&*self)weakSelf = self;
    self.lazyView.dataSource = ^(NSUInteger index) {
        return [weakSelf controllerAtIndex:index];
    };
    self.lazyView.numberOfPages = 2;
    self.lazyView.controlDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIViewController *) controllerAtIndex:(NSInteger) index {
    if (index > viewControllerArray.count || index < 0) return nil;
    
    return [viewControllerArray objectAtIndex:index];
}
- (void)initializeToolbar {
    UIImage *image = [UIImage imageNamed:@"gear_icon_blue"];
    UIBarButtonItem *calsButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(goToSettingsScreen:)];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    homeButton.backgroundColor = [UIColor clearColor];
    image = [UIImage imageNamed:@"home_icon_blue"];
    [homeButton setImage:image forState:UIControlStateNormal];
    homeButton.frame = CGRectMake(0.0, 0.0, 60.0, 40.0);
    [homeButton addTarget:self action:@selector(goToHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* homeBarButton = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    
    UIButton *dataButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dataButton.backgroundColor = [UIColor clearColor];
    image = [UIImage imageNamed:@"data_icon_blue"];
    [dataButton setImage:image forState:UIControlStateNormal];
    dataButton.frame = CGRectMake(0.0, 0.0, 60.0, 40.0);
    [dataButton addTarget:self action:@selector(goToHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* dataBarButton = [[UIBarButtonItem alloc] initWithCustomView:dataButton];
    
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(goToToday:)];
    
    UIBarButtonItem *flexible1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *flexible2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:calsButton, flexible1, homeBarButton, dataBarButton, flexible2, todayButton, nil]];
}
- (IBAction)switchScreens:(id)sender {
    if (self.lazyView.currentPage == 0) {
        [self goToData:sender];
    } else if (self.lazyView.currentPage == 1) {
        [self goToHome:sender];
    }
}
- (IBAction)goToHome:(id)sender {
    [self.lazyView setPage:0 transition:DMLazyScrollViewTransitionBackward animated:YES];
}
- (IBAction)goToData:(id)sender {
    [self.lazyView setPage:1 transition:DMLazyScrollViewTransitionForward animated:YES];
}
- (IBAction)goToSettingsScreen:(id)sender {
    EKCalendarChooser *calChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:[calStore store]];
    //    [calChooser setEditing:YES];
    calChooser.selectedCalendars = calStore.activeCalendars;
    //    calChooser.selectedCalendars = self.tempSet;
    calChooser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    calChooser.showsCancelButton = YES;
    calChooser.showsDoneButton = YES;
    calChooser.delegate = homeController;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:calChooser];
    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)goToToday:(id)sender {
    if (self.lazyView.currentPage == 0) {
        [homeController scrollToCurrentTime:sender];
    } else if (self.lazyView.currentPage == 1) {
        // Do something within 
    }
}

@end

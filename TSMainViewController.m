//
//  TSMainViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 9/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSMainViewController.h"
#import "DMLazyScrollView.h"

@interface TSMainViewController () <DMLazyScrollViewDelegate>{
    NSArray *viewControllerArray;
    UIViewController *homeController;
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
	// Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *controller1 = [storyboard instantiateViewControllerWithIdentifier:@"homeController"];
    UIViewController *controller2 = [storyboard instantiateViewControllerWithIdentifier:@"dataController"];
    viewControllerArray = [NSArray arrayWithObjects:controller1, controller2, nil];
    
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
- (IBAction)goToHome:(id)sender {
    [self.lazyView setPage:0 transition:DMLazyScrollViewTransitionBackward animated:YES];
}
- (IBAction)goToData:(id)sender {
    [self.lazyView setPage:1 transition:DMLazyScrollViewTransitionForward animated:YES];
}
- (IBAction)goToSettingsScreen:(id)sender {
}
- (IBAction)goToToday:(id)sender {
}

@end

//
//  TSTutorialViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 9/21/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSTutorialViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "UIColor+CalendarPalette.h"
#import "TSCalendarStore.h"
#import "TSCategoryStore.h"
#import "TSHelpers.h"

#define NUM_TUT_PAGES 8

@interface TSTutorialViewController () <UIScrollViewDelegate> {
    UIView *containerView;
    UISwitch *onOff;
    UIButton *welcomeBtn;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation TSTutorialViewController

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
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    if (!containerView) containerView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImage *im0 = [UIImage imageNamed:@"Tutorial-0"];
    UIImageView *tut0 = [[UIImageView alloc] initWithFrame:CGRectMake(0 * width, 0, width, height)];
    tut0.image = im0;
    
    UIImage *im1 = [UIImage imageNamed:@"Tutorial-1"];
    UIImageView *tut1 = [[UIImageView alloc] initWithFrame:CGRectMake(1 * width, 0, width, height)];
    tut1.image = im1;
    
    UIImage *im2 = [UIImage imageNamed:@"Tutorial-2"];
    UIImageView *tut2 = [[UIImageView alloc] initWithFrame:CGRectMake(2 * width, 0, width, height)];
    tut2.image = im2;
    
    UIImage *im3 = [UIImage imageNamed:@"Tutorial-3"];
    UIImageView *tut3 = [[UIImageView alloc] initWithFrame:CGRectMake(3 * width, 0, width, height)];
    tut3.image = im3;
    
    UIImage *im4 = [UIImage imageNamed:@"Tutorial-4"];
    UIImageView *tut4 = [[UIImageView alloc] initWithFrame:CGRectMake(4 * width, 0, width, height)];
    tut4.image = im4;
    
    UIImage *im5 = [UIImage imageNamed:@"Tutorial-5"];
    UIImageView *tut5 = [[UIImageView alloc] initWithFrame:CGRectMake(5 * width, 0, width, height)];
    tut5.image = im5;
    
    UIImage *im6 = [UIImage imageNamed:@"Tutorial-6"];
    UIImageView *tut6 = [[UIImageView alloc] initWithFrame:CGRectMake(6 * width, 0, width, height)];
    tut6.image = im6;
    
    UIImage *im7 = [UIImage imageNamed:@"Tutorial"];
    UIImageView *tutIm7 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    tutIm7.image = im7;
    UIView *tut7 = [[UIView alloc] initWithFrame:CGRectMake(7 * width, 0, width, height)];
    [tut7 addSubview:tutIm7];
    
    welcomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    welcomeBtn.center = CGPointMake(self.view.frame.size.width / 2, 175);
    welcomeBtn.bounds = CGRectMake(0, 0, 150, 150);
//    [welcomeBtn setBackgroundColor:[UIColor colorFromHexString:@"#3D478C"]];
//    welcomeBtn.layer.cornerRadius = 75.0;
    [welcomeBtn setTitle:@"Tap to Get Started!" forState:UIControlStateNormal];
    welcomeBtn.titleLabel.numberOfLines = 2;
    welcomeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    welcomeBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [welcomeBtn setTitleColor:[UIColor colorFromHexString:@"#3D478C"] forState:UIControlStateHighlighted];
    [welcomeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *start = [UIImage imageNamed:@"GetStarted"];
    UIImage *sel = [UIImage imageNamed:@"GetStarted_Sel"];
    [welcomeBtn setBackgroundImage:start forState:UIControlStateNormal];
    [welcomeBtn setBackgroundImage:sel forState:UIControlStateHighlighted];
    [welcomeBtn addTarget:self action:@selector(getStarted:) forControlEvents:UIControlEventTouchUpInside];
    [welcomeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [tut7 addSubview:welcomeBtn];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = welcomeBtn.frame;
    activityIndicator.hidden = YES;
    activityIndicator.color = [UIColor darkGrayColor];
    [tut7 addSubview:activityIndicator];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.text = @"Include default categories? \n(recommended :)";
    label.center = CGPointMake(self.view.frame.size.width / 2, 300);
    label.bounds = CGRectMake(0, 0, self.view.bounds.size.width, 50);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    [tut7 addSubview:label];
    
    onOff = [[UISwitch alloc] initWithFrame:CGRectZero];
    onOff.bounds = CGRectMake(0, 0, 60, 54);
    onOff.center = CGPointMake(tut7.bounds.size.width / 2, 375);
    onOff.onTintColor = [UIColor colorFromHexString:@"#3D478C"];
    onOff.on = YES;
    [tut7 addSubview:onOff];
    
    containerView.frame = CGRectMake(0, 0, NUM_TUT_PAGES * width, height);
    
    [containerView addSubview:tut0];
    [containerView addSubview:tut1];
    [containerView addSubview:tut2];
    [containerView addSubview:tut3];
    [containerView addSubview:tut4];
    [containerView addSubview:tut5];
    [containerView addSubview:tut6];
    [containerView addSubview:tut7];
    
    containerView.backgroundColor = [UIColor colorFromHexString:@"d9d6d1"];
    self.view.backgroundColor = [UIColor colorFromHexString:@"d9d6d1"];
    [self.scrollView addSubview:containerView];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.pageControl.numberOfPages = NUM_TUT_PAGES;
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorFromHexString:@"#3D478C"];
    self.pageControl.pageIndicatorTintColor = [UIColor colorFromHexString:@"#dddddd"];
}

- (void)viewDidLayoutSubviews {
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.scrollView  setContentSize:CGSizeMake(containerView.frame.size.width, containerView.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)showCalChooser:(id)sender {
    // Get permission to use calendars
    [[TSCalendarStore instance] requestCalAccess];
    
    // Import Default Calendars
    if (onOff.on) {
        [[TSCategoryStore instance] importDefaultCategories];
    }
    
    // Show cal chooser
    NSLog(@"Show Cal Chooser to get started!");
    [self dismissViewControllerAnimated:YES completion:^{
        // On home page controller, call show cal chooser
        [self.homeController showCalChooser:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Calendars" message:@"Select which calendars you'd like to import into TimeStamp" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)getStarted:(id)sender {
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    welcomeBtn.hidden = YES;
 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        // import default calendars
//        if (onOff.on) {
//            [[TSCategoryStore instance] importDefaultCategories];
//        }
        
        /*
         // Show cal chooser
         NSLog(@"Show Cal Chooser to get started!");
         [self dismissViewControllerAnimated:YES completion:^{
         // On home page controller, call show cal chooser
         [self.homeController showCalChooser:nil];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Calendars" message:@"Select which calendars you'd like to import into TimeStamp" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         }];
         */
    
    });
    
    // Get permission to use calendars
    [[TSCalendarStore instance] requestCalAccess];

    // Do necessary imports/synchronization here.
    [TSHelpers syncCalendarsAndShit];
    [[TSCategoryStore instance] makeAllCategoriesActive];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *nav = [sb instantiateViewControllerWithIdentifier:@"homeController"];
    nav.modalPresentationCapturesStatusBarAppearance = YES;
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:NO completion:^{}];
}

@end

//
//  TSTutorialViewController.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 9/21/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSTutorialViewController.h"
#import "UIColor+MLPFlatColors.h"

@interface TSTutorialViewController () <UIScrollViewDelegate> {
    UIView *containerView;
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
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0 * width, 0, width, height)];
    tempView.backgroundColor = [UIColor randomFlatColor];
    UIView *tempView2 = [[UIView alloc] initWithFrame:CGRectMake(1 * width, 0, width, height)];
    tempView2.backgroundColor = [UIColor randomFlatColor];
    UIView *tempView3 = [[UIView alloc] initWithFrame:CGRectMake(2 * width, 0, width, height)];
    tempView3.backgroundColor = [UIColor randomFlatColor];
    UIView *tempView4 = [[UIView alloc] initWithFrame:CGRectMake(3 * width, 0, width, height)];
    tempView4.backgroundColor = [UIColor randomFlatColor];
    UIButton *welcomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    welcomeBtn.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100);
    welcomeBtn.bounds = CGRectMake(0, 0, 150, 150);
    [welcomeBtn setBackgroundColor:[UIColor flatTealColor]];
    welcomeBtn.layer.cornerRadius = 75.0;
    [welcomeBtn setTitle:@"Get Started!" forState:UIControlStateNormal];
    [welcomeBtn addTarget:self action:@selector(showCalChooser:) forControlEvents:UIControlEventTouchUpInside];
    [tempView4 addSubview:welcomeBtn];
    
    containerView.frame = CGRectMake(0, 0, 4 * width, height);
    
    [containerView addSubview:tempView];
    [containerView addSubview:tempView2];
    [containerView addSubview:tempView3];
    [containerView addSubview:tempView4];
    
    [self.scrollView addSubview:containerView];
    self.pageControl.numberOfPages = 4;
}

- (void)viewDidLayoutSubviews {
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.scrollView  setContentSize:CGSizeMake(containerView.frame.size.width, containerView.frame.size.height)];
    NSLog(@"Scroll View Size: (%f, %f)", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scroll view offset: (%f,%f)", scrollView.contentOffset.x, scrollView.contentOffset.y);
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)showCalChooser:(id)sender {
    // Get permission to use calendars
    
    // Import Default Calendars
    
    // Show cal chooser
    NSLog(@"Show Cal Chooser to get started!");
    [self dismissViewControllerAnimated:YES completion:^{
        // On home page controller, call show cal chooser
    }];
}

@end

//
//  TSTutorialViewController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 9/21/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSHomePageController.h"

@interface TSTutorialViewController : UIViewController

@property (nonatomic, strong) TSHomePageController *homeController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

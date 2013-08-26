//
//  TSHomePageController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"

@class TSDayViewController;
@class TSListTableViewController;

@interface TSHomePageController : UIViewController <ATSDragToReorderTableViewControllerDelegate, UIGestureRecognizerDelegate, EKCalendarChooserDelegate> {
    TSListTableViewController *listController;
    TSDayViewController *dayViewController;
    UINavigationController *listNavController;
    CGPoint initialListCellCenter;
    UIPanGestureRecognizer *dragGestureRecognizer;
}

@property (nonatomic, strong) UITableViewCell *draggedCell;

@end

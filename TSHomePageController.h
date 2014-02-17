//
//  TSHomePageController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
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
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) UITableViewCell *draggedCell;

- (void)scrollToCurrentTime:(id)sender;
- (void)showCalChooserOnStartup;
- (IBAction)showCalChooser:(id)sender;
- (IBAction)prevDay:(id)sender;
- (IBAction)nextDay:(id)sender;

@end

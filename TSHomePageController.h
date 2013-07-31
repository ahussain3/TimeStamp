//
//  TSHomePageController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"

@interface TSHomePageController : UIViewController <ATSDragToReorderTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *categoryListContainer;

@end

//
//  TSListTableViewController.h
//  TSCategories
//
//  Created by Awais Hussain on 7/25/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATSDragToReorderTableViewController.h"
#import "TSListTableViewCell.h"

@class TSCategoryStore;

@interface TSListTableViewController : ATSDragToReorderTableViewController <TSSlideToDeleteCellDelegate> {
    // Local store of category data
    NSMutableArray *categoryArray;
    
    TSCategoryStore *model;
}

@property (weak, nonatomic) IBOutlet UITableView *view;
@property (strong, nonatomic) UIViewController *superController;

@end

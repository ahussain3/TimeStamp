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
#import "TSAddNewTableViewCell.h"

@class TSCategoryStore;
@class TSCategory;

@interface TSListTableViewController : ATSDragToReorderTableViewController <TSSlideToDeleteCellDelegate, TSAddNewTableCellDelegate> {
    // Local store of category data
    NSMutableArray *categoryArray;
    TSCategory *rootCategory;
    
    TSCategoryStore *model;
}

// The Path property should be of format Sleep:Short:Nap:InTheRoom
@property (strong, nonatomic) NSString *path;
@property (weak, nonatomic) IBOutlet UITableView *view;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;

- (void)reloadData;
- (void)goHome:(id)sender;
@end

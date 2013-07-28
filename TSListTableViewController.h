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

@interface TSListTableViewController : ATSDragToReorderTableViewController <TSSlideToDeleteCellDelegate> {
    NSMutableArray *categoryArray;
}

@property (weak, nonatomic) IBOutlet UITableView *view;

@end

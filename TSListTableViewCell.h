//
//  TSListTableViewCell.h
//  TSCategories
//
//  Created by Awais Hussain on 7/26/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSSlidableCell.h"
@class TSCategory;

@interface TSListTableViewCell : TSSlidableCell

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) TSCategory *category;

@end

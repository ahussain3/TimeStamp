//
//  TSAddNewTableViewCell.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 8/17/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSListTableViewCell.h"

@interface TSAddNewTableViewCell : TSListTableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

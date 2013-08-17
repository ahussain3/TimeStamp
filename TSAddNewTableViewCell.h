//
//  TSAddNewTableViewCell.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 8/17/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSListTableViewCell.h"

@protocol TSAddNewTableCellDelegate <NSObject>

- (void)addNewSubcategoryWithString:(NSString *)string;

@end

@interface TSAddNewTableViewCell : TSListTableViewCell <UITextFieldDelegate> {
    BOOL userCancelledTextEntry;
}

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) id<TSAddNewTableCellDelegate> addDelegate;


@end

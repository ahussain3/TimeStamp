//
//  TSAddBoxView.h
//  TimeStamp-Homepage
//
//  Created by Timothy Chong on 3/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSAddBoxView : UIView <UITextFieldDelegate>

@property (strong,nonatomic)UITextField * textField;
@property (strong,nonatomic)UIButton * cancelButton;
@end

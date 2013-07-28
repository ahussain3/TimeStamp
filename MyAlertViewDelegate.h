//
//  MyAlertViewDelegate.h
//  TSCategories
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAlertViewDelegate : NSObject<UIAlertViewDelegate>

typedef void (^AlertViewCompletionBlock)(NSInteger buttonIndex);
@property (strong,nonatomic) AlertViewCompletionBlock callback;

+ (void)showAlertView:(UIAlertView *)alertView withCallback:(AlertViewCompletionBlock)callback;

@end
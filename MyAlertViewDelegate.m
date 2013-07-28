//
//  MyAlertViewDelegate.m
//  TSCategories
//
//  Created by Awais Hussain on 7/28/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "MyAlertViewDelegate.h"

@implementation MyAlertViewDelegate
@synthesize callback;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    callback(buttonIndex);
}

+ (void)showAlertView:(UIAlertView *)alertView
         withCallback:(AlertViewCompletionBlock)callback {
    __block MyAlertViewDelegate *delegate = [[MyAlertViewDelegate alloc] init];
    alertView.delegate = delegate;
    delegate.callback = ^(NSInteger buttonIndex) {
        callback(buttonIndex);
        alertView.delegate = nil;
        delegate = nil;
    };
    [alertView show];
}

@end
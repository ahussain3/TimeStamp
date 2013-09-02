//
//  TSMainViewController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 9/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DMLazyScrollView;

@interface TSMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet DMLazyScrollView *lazyView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

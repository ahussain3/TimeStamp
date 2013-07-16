//
//  TSCalBoxView.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface TSCalBoxView : UIView

@property (nonatomic) UIButton * deleteButton;
@property (nonatomic) UILabel * titleLabel;

//At the moment, we support only one level of indentation
-(id)initWithFrame:(CGRect)frame title:(NSString*)title backgroundColor:(UIColor*)color indentation:(int)indent;
-(void)showDeleteButton;
@end

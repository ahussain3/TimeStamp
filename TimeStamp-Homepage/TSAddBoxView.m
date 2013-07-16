//
//  TSAddBoxView.m
//  TimeStamp-Homepage
//
//  Created by Timothy Chong on 3/16/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSAddBoxView.h"
#import "TSCalBoxesContainer.h"
#import "HomePageCalObj.h"
#import "TSMenuObjectStore.h"

#define ADD_BEFORE_X 0
#define ADD_BEFORE_Y 15
#define ADD_AFTER_X 10

#define TEXT_BEFORE_X 25.0
#define TEXT_AFTER_X 50.0
#define TEXT_BEFORE_Y 15.0

#define CANCEL_AFTER_RIGHT_MARGIN_X 40
#define CANCEL_BEFORE_Y 10.0

@implementation TSAddBoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldShouldBeginEditing:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(TEXT_BEFORE_X,TEXT_BEFORE_Y, self.bounds.size.width - 50, self.bounds.size.height)];
    self.textField.font = [UIFont fontWithName:@"Verdana" size:(12.0)];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.placeholder = @"+ Add New";
    self.textField.minimumFontSize = 12.0;
    self.textField.delegate = self;
    [self addSubview:self.textField];


/*
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(self.bounds.size.width, CANCEL_BEFORE_Y, 30, 30);
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton.png"] forState:UIControlStateNormal];
    self.cancelButton.alpha = 0;
    [self.cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
*/
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    [((TSCalBoxesContainer*)self.superview)stopEditing];
    if (textField == self.textField) {
        UIScrollView * scrollView = (UIScrollView*)self.superview.superview.superview;
        [UIView animateWithDuration:0.5 animations:^{
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.bounds.size.height-216);}];
        
                [UIView animateWithDuration:0.5 animations:^{
            /*self.addButton.alpha = 1;
            self.addButton.frame = CGRectMake(ADD_AFTER_X, ADD_BEFORE_Y, self.addButton.frame.size.width, self.addButton.frame.size.height);*/

            self.cancelButton.alpha = 1;
            self.cancelButton.frame = CGRectMake(self.bounds.size.width-CANCEL_AFTER_RIGHT_MARGIN_X, CANCEL_BEFORE_Y, 30, 30);
            //textField.frame = CGRectMake(TEXT_AFTER_X, TEXT_BEFORE_Y, self.bounds.size.width - 100, self.bounds.size.height);
        }];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.textField) {
        if(self.textField.text.length != 0)
            [self addCalendarElement];
        self.textField.text = nil;
        [UIView animateWithDuration:0.5 animations:^{
            UIScrollView * scrollView = (UIScrollView*)self.superview.superview.superview;
    scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.bounds.size.height+216);
            /*self.addButton.alpha = 0;
            self.addButton.frame = CGRectMake(ADD_BEFORE_X, ADD_BEFORE_Y, self.addButton.frame.size.width, self.addButton.frame.size.height);*/
            
            self.cancelButton.alpha = 0;
            self.cancelButton.frame = CGRectMake(self.bounds.size.width, CANCEL_BEFORE_Y, 30, 30);
            //textField.frame = CGRectMake(TEXT_BEFORE_X, TEXT_BEFORE_Y, self.bounds.size.width - 100, self.bounds.size.height);
        }];
    }
    return YES;
}

-(IBAction)cancelClicked:(id)sender
{
    self.textField.text = nil;
    [self.textField resignFirstResponder];
}

-(void)addCalendarElement
{
    [((TSCalBoxesContainer*)self.superview)addElement:self.textField.text];
}

-(void)stopEditing
{
    self.textField.text = nil;
    [self textFieldShouldReturn:nil];
}
@end

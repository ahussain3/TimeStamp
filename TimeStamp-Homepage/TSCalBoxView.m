//
//  TSCalBoxView.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSCalBoxView.h"
#import "TSCalBoxesContainer.h"
#import "HomePageCalObj.h"
#import "TSMenuBoxContainer.h"

#define CAL_BOX_LEFT_MARGIN 10.0
#define CAL_BOX_TEXT_LABEL_HEIGHT 43.0
#define DELETE_AFTER_RIGHT_MARGIN_X 40
#define DELETE_BEFORE_Y 10.0

@implementation TSCalBoxView


- (id)initWithFrame:(CGRect)frame title:(NSString *)title backgroundColor:(UIColor *)color indentation:(int)indent
{
    self = [super initWithFrame:frame];
    if (self) {
        //Swipe recognizer for deleting
        UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showDeleteButton)];
        sgr.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:sgr];
        
        //Set background color
        self.backgroundColor = color;
        
        //Deal with indentation - at the moment we support only one level of indentation. Differentiate between lower level and title level boxes
        if (indent == 1) {
            //Adding title Label
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CAL_BOX_LEFT_MARGIN + 15.0, 0.0 / 2, self.bounds.size.width - CAL_BOX_LEFT_MARGIN, self.bounds.size.height)];
            self.titleLabel.font = [UIFont fontWithName:@"Verdana" size:(12.0)];
            self.titleLabel.lineBreakMode = NSLineBreakByClipping;
            
            //Adding DeleteButton, but hidden
            self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteButton.frame = CGRectMake(self.bounds.size.width, DELETE_BEFORE_Y, 50, 50);
            [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"cancelButton.png"] forState:UIControlStateNormal];
            self.deleteButton.alpha = 0;
            [self addSubview:self.deleteButton];
            //Set Target for delete button
            [self.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            //Adding title Label
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CAL_BOX_LEFT_MARGIN, 0.0, self.bounds.size.width - 2 * CAL_BOX_LEFT_MARGIN, self.bounds.size.height)];
            self.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:(16.0)];
            self.titleLabel.lineBreakMode = NSLineBreakByClipping;
        }
        
        // Configure text
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        self.titleLabel.text = title;
    }
    return self;
}

//Call when the view is swiped to the left
-(void)showDeleteButton
{
    //Hide all the other labels' delete button
//    [((TSCalBoxesContainer*)self.superview)stopEditing];
    
    //Show the button
    [UIView animateWithDuration:0.5 animations:^{
        self.deleteButton.frame = CGRectMake(self.bounds.size.width-DELETE_AFTER_RIGHT_MARGIN_X, DELETE_BEFORE_Y, 30, 30);
        self.deleteButton.alpha = 1;
    }];
    //Swipe right to hide button
    UISwipeGestureRecognizer * sgr = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideDeleteButton:)];
    [self addGestureRecognizer:sgr];

}
-(IBAction)hideDeleteButton:(id)sender
{
    if (self.deleteButton.alpha) 
        [UIView animateWithDuration:0.5 animations:^{
            self.deleteButton.frame = CGRectMake(self.bounds.size.width, DELETE_BEFORE_Y, 50, 50);
            self.deleteButton.alpha = 0;
        }];
    [self removeGestureRecognizer:sender];
    
}

-(IBAction)deleteButtonClicked:(id)sender
{
    [self.titleLabel removeFromSuperview];
    [self.deleteButton removeFromSuperview];
    [((TSCalBoxesContainer*)self.superview) deleteElement:self];
}

-(void)stopEditing
{
    [self hideDeleteButton:nil];
}
    

@end

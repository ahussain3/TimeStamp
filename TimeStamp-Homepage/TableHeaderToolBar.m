//
//  TableHeaderToolBar.m
//  CalendarTracker
//
//  Created by Timothy Chong on 2/3/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import "TableHeaderToolBar.h"

@implementation TableHeaderToolBar
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    ((UIButton*)self.dateLabelItem.customView).titleLabel.textAlignment= NSTextAlignmentCenter;
}

- (IBAction)forwardButtonPressed:(id)sender
{
    [self.delegate update];
    [self.delegate forwardButtonPressed];
}

- (IBAction)backwardButtonPressed:(id)sender
{
    [self.delegate backButtonPressed];
    [self.delegate update];
}

-(void) editDateLabelString:(NSString*)str
{
    ((UIButton*)self.dateLabelItem.customView).titleLabel.text = [str copy];
}

-(NSString*) dateString
{
    return ((UIButton*)self.dateLabelItem.customView).titleLabel.text;
}

@end

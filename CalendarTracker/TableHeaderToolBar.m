//
//  TableHeaderToolBar.m
//  CalendarTracker
//
//  Created by Awais Hussain on 2/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TableHeaderToolBar.h"

@implementation TableHeaderToolBar
@synthesize delegate;
@synthesize singleton = _singleton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (MySingleton *)singleton {
    if (!_singleton) {
        _singleton = [MySingleton instance];
    }
    return _singleton;
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
    [self.singleton goForward];
    [self.delegate update];
}

- (IBAction)backwardButtonPressed:(id)sender
{
    [self.singleton goBackward];
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

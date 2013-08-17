//
//  TSAddNewTableViewCell.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 8/17/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSAddNewTableViewCell.h"

@implementation TSAddNewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.hidden = YES;

        self.textField = [[UITextField alloc] init];
        self.textField.textColor = self.textField.textColor;
        self.textField.font = self.textLabel.font;
        self.textField.placeholder = @"Add New";
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.delegate = self;
        [self addSubview:self.textField];
    }
    return self;
}

- (void)drawPlusSign {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textField.center = self.center;
    self.textField.bounds = self.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark UITextViewDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.textField) {

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
 
    }
    return YES;
}


@end

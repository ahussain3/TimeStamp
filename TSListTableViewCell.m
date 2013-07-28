//
//  TSListTableViewCell.m
//  TSCategories
//
//  Created by Awais Hussain on 7/26/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#define PI 3.1415

#import "TSListTableViewCell.h"

@interface TSListTableViewCell () {
    CGFloat circleDiameter;
}

@end

@implementation TSListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.color = [UIColor purpleColor];
        
        if (self.bounds.size.height > self.bounds.size.width) {
            circleDiameter = self.bounds.size.width;
        } else {
            circleDiameter = self.bounds.size.height;
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

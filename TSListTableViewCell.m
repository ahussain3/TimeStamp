//
//  TSListTableViewCell.m
//  TSCategories
//
//  Created by Awais Hussain on 7/26/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#define PI 3.1415

#import "TSListTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+CalendarPalette.h"

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
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        self.textLabel.numberOfLines = 1;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.8f;
        
        if (self.bounds.size.height > self.bounds.size.width) {
            circleDiameter = self.bounds.size.width;
        } else {
            circleDiameter = self.bounds.size.height;
        }
        self.contentView.layer.cornerRadius = BOX_HEIGHT / 2.0;
    }
    return self;
}
//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    [self setSelected:selected animated:YES];
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.selectedBackgroundView.backgroundColor = [UIColor colorFromHexString:@"#dddddd"];
    self.selectedBackgroundView.layer.borderColor = self.color.CGColor;
    self.selectedBackgroundView.layer.borderWidth = 6.0;
    self.selectedBackgroundView.layer.cornerRadius = BOX_HEIGHT / 2.0;
}

@end

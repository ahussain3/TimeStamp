//
//  TSInfiniteScrollView.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 7/3/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSInfiniteScrollView.h"

@implementation TSInfiniteScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    }
    return self;
}


#pragma mark Layout

- (void) recenterIfNecessary {
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentHeight = self.contentSize.height;
    CGFloat centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.y - centerOffsetY);
    
    if (distanceFromCenter > (contentHeight / 3.0)) {
        self.contentOffset = CGPointMake(self.contentOffset.x, centerOffsetY);
        
        // move content by same amount so it appears to stay the same.
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self recenterIfNecessary];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

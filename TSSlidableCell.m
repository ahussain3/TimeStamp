//
//  TSSlideToDeleteCell.m
//  TSSlideToDelete
//
//  Created by Awais Hussain on 7/27/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSSlidableCell.h"

typedef enum {
    TSSlideStateDormant,
    TSSlideStateToTheLeft,
    TSSlideStateToTheRight,
    TSSlideStateSliding
} TSSlideState;

@interface TSSlidableCell () {
    
}

@end

@implementation TSSlidableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideGestureHandler:)];
        pan.delegate = self;
        [self.contentView addGestureRecognizer:pan];
    
        slideState = TSSlideStateDormant;
        
        self.slideRightDisabled = TRUE;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.slideToLeftView != nil) {
        if (self.backgroundView) [self insertSubview:self.slideToLeftView aboveSubview:self.backgroundView];
        else [self insertSubview:self.slideToLeftView atIndex:0];
    }
    if (self.slideToLeftHighlightedView != nil) {
        if (self.backgroundView) [self insertSubview:self.slideToLeftHighlightedView aboveSubview:self.backgroundView];
        else [self insertSubview:self.slideToLeftHighlightedView atIndex:0];
    }
    if (self.slideToRightView != nil) {
        if (self.backgroundView) [self insertSubview:self.slideToRightView aboveSubview:self.backgroundView];
        else [self insertSubview:self.slideToRightView atIndex:0];
    }
    if (self.slideToRightHighlightedView != nil) {
        if (self.backgroundView) [self insertSubview:self.slideToRightHighlightedView aboveSubview:self.backgroundView];
        else [self insertSubview:self.slideToRightHighlightedView atIndex:0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)slideGestureHandler:(UIPanGestureRecognizer *)sender {
    UITableView *tableView = (UITableView *)self.superview;
    CGPoint translation = [sender translationInView:self];
    
    // Remove interference with scrollView pan gesture recognizer
    if (slideState == TSSlideStateDormant) {
        CGFloat theta =  (180 / M_PI) * atanf(translation.y / translation.x);
        if (fabsf(theta) > 20.0) {
            tableView.scrollEnabled = YES;
            return;
        } else {
            tableView.scrollEnabled = NO;
        }
    }
    
    CGFloat xThreshold = self.frame.size.width * 0.4;
    CGFloat xOffset = self.contentView.center.x - self.center.x;
    CGFloat yCenter = self.contentView.center.y;
    CGFloat finalXPosition = self.center.x;
    
    // Animate the 'drag' movement of the cell.
    if (translation.x < 0 && !(self.slideLeftDisabled && slideState == TSSlideStateDormant)) {
        slideState = TSSlideStateToTheLeft;
        
        self.contentView.center = CGPointMake(self.contentView.center.x + translation.x, self.contentView.center.y);
        self.selectedBackgroundView.center = CGPointMake(self.selectedBackgroundView.center.x + translation.x, self.selectedBackgroundView.center.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self];
        
    } else if (translation.x > 0 && !(self.slideRightDisabled && slideState == TSSlideStateDormant)) {
        slideState = TSSlideStateToTheRight;
        self.contentView.center = CGPointMake(fminf(self.contentView.center.x + translation.x, self.center.x), self.contentView.center.y);
        self.selectedBackgroundView.center = CGPointMake(fminf(self.selectedBackgroundView.center.x + translation.x, self.center.x), self.selectedBackgroundView.center.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self];
    }
    
    if (xOffset < -xThreshold) {self.slideToLeftView.hidden = YES; self.slideToLeftHighlightedView.hidden = NO;}
    else {self.slideToLeftView.hidden = NO; self.slideToLeftHighlightedView.hidden = NO;}
    if (xOffset > xThreshold) {self.slideToRightView.hidden = YES; self.slideToRightHighlightedView.hidden = NO;}
    else {self.slideToRightView.hidden = NO; self.slideToRightHighlightedView.hidden = NO;}
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // Animate cell to correct final position
        if (slideState == TSSlideStateToTheLeft && xOffset < -xThreshold) {
            finalXPosition = -(self.contentView.bounds.size.width  / 2.0 + xThreshold);
            [self.deleteDelegate respondToCellSlidLeft:self];

        }
        if (slideState == TSSlideStateToTheRight && xOffset > xThreshold) {
            finalXPosition = (self.contentView.bounds.size.width  * 1.5) + xThreshold;
            [self.deleteDelegate respondToCellSlidRight:self];
        }
        
        CGPoint finalCenterPosition = CGPointMake(finalXPosition, yCenter);
        CGPoint velocity = [sender velocityInView:self];
        NSTimeInterval duration = fmaxf(0.1f,fminf(0.3f, fabs((xOffset - finalXPosition) / velocity.x)));
 
        [UIView animateWithDuration:duration animations:^{
            self.contentView.center = finalCenterPosition;
            self.selectedBackgroundView.center = finalCenterPosition;
        } completion:^(BOOL completion){

        }];
        
        slideState = TSSlideStateDormant;
        tableView.scrollEnabled = YES;
    }
}

- (void)resetCellToCenter {
    self.slideToLeftView.hidden = NO;
    
    CGFloat yCenter = self.contentView.center.y;
    CGFloat finalXPosition = self.center.x;
    
    CGPoint finalCenterPosition = CGPointMake(finalXPosition, yCenter);
    NSTimeInterval duration = 0.3f;
    
    [UIView animateWithDuration:duration animations:^{
        self.contentView.center = finalCenterPosition;
        self.selectedBackgroundView.center = finalCenterPosition;
    } completion:^(BOOL completion){
        
    }];
    
    slideState = TSSlideStateDormant;
//    tableView.scrollEnabled = YES;
}

#pragma  mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

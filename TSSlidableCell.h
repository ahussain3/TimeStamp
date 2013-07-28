//
//  TSSlideToDeleteCell.h
//  TSSlideToDelete
//
//  Created by Awais Hussain on 7/27/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

//*********************************************************************/
/*
IMPLEMENTATION NOTES:

1) Import TSSLidableCell.m/h into your project.
 
2) In your custom UITableViewCell, subclass TSSlidableCell instead of UITableViewCell.

3) 




*/
/***********************************************************************/

#import <UIKit/UIKit.h>
@class TSSlidableCell;

@protocol TSSlideToDeleteCellDelegate <NSObject>
@optional
-(void)respondToCellSlidLeft:(TSSlidableCell *)cell;
-(void)respondToCellSlidRight:(TSSlidableCell *)cell;
@end

@interface TSSlidableCell : UITableViewCell <UIGestureRecognizerDelegate> {
    NSUInteger slideState;
}

// Configuration settings
@property (nonatomic) BOOL slideLeftDisabled;
@property (nonatomic) BOOL slideRightDisabled;

// Subclass should assign these views. The cell will slide out of the way to reveal these views.
@property (nonatomic, strong) UIView *slideToLeftView;
@property (nonatomic, strong) UIView *slideToRightView;
@property (nonatomic, strong) UIView *slideToLeftHighlightedView;
@property (nonatomic, strong) UIView *slideToRightHighlightedView;

@property (nonatomic, strong) id<TSSlideToDeleteCellDelegate> delegate;

@end

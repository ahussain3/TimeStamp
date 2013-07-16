//
//  TSMenuBoxContainer.m
//  TimeStamp-Homepage
//
//  Created by Timothy Chong on 3/15/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSMenuBoxContainer.h"
#import "TSCalBoxesContainer.h"
#import "HomePageCalObj.h"
#import "TSMenuObjectStore.h"
#import "TSDayViewController.h"

@implementation TSMenuBoxContainer
@synthesize categoryBoxes = _categoryBoxes;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        TSMenuObjectStore *data = [TSMenuObjectStore defaultStore];
        self.categoryBoxes = [data.calendars mutableCopy];
        [self initSubviews];
        }
    return self;
}

-(NSMutableArray *)categoryBoxes
{
    if (!_categoryBoxes) {
        _categoryBoxes = [[NSMutableArray alloc]init];
    }
    return _categoryBoxes;
}

-(void)initSubviews {
    CGPoint boxOrigin = CGPointMake(0, 0);
    
    //Look through the categories, and add containers
    for (HomePageCalObj* boxInfo in self.categoryBoxes) {
        CGRect frame = CGRectMake(boxOrigin.x, boxOrigin.y, self.bounds.size.width, BOX_HEIGHT);
        TSCalBoxesContainer *box = [[TSCalBoxesContainer alloc] initWithFrame:frame];
        box.homePageCalendarObject = boxInfo;
        [self addSubview:box];
        
        ///the y-coordinate is incremented so that each container will be below the previous one
        boxOrigin = CGPointMake(boxOrigin.x, boxOrigin.y + BOX_HEIGHT);
    }
}

-(void) layoutSubviews {
    [super layoutSubviews];
/*
    CGPoint boxOrigin = CGPointMake(0, 0);
    for (UIView *container in self.subviews) {
        CGRect frame = CGRectMake(boxOrigin.x, boxOrigin.y, self.bounds.size.width, container.bounds.size.height);
        [UIView setAnimationBeginsFromCurrentState:TRUE];
        [UIView animateWithDuration:0.5 animations:^{
            container.frame = frame;
        }];
        
        ///the y-coordinate is incremented so that each container will be below the previous one
        boxOrigin = CGPointMake(boxOrigin.x, boxOrigin.y + container.bounds.size.height);
    }
 */
}

-(void)updateBoxesWithChange
{
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint origin = CGPointMake(self.frame.origin.x, self.frame.origin.y);
        
        //Look through the list of categories. origin is incremented every time to make sure the category containers are lined up in the right place
        
        for (TSCalBoxesContainer * cal in self.subviews) {
            //Updating the frame for the category containers according to the elements inside
            cal.frame = CGRectMake(origin.x, origin.y, cal.bounds.size.width, cal.bounds.size.height);
            //orign incremented for the next category container
            origin = CGPointMake(origin.x, origin.y + cal.bounds.size.height);
        }
    
        //Updating the MenuContainer so that it fits the category containers inside
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, origin.y);
        
        //Making the categories container inside the scrollview content
        ((UIScrollView*)self.superview).contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);//Don't know why this 2*BOX_HEIGHT fix is needed but it works
    }];
}


@end

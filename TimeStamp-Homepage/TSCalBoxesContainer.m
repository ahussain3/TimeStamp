//
//  TSCalBoxesContainer.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/2/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSCalBoxesContainer.h"
#import "HomePageCalObj.h"
#import "TSMenuBoxContainer.h"
#import "TSAddBoxView.h"
#import "TSCalBoxView.h"
#import "TSMenuObjectStore.h"

@interface TSCalBoxesContainer ()
@property (nonatomic) int totalHeight;
@end

@implementation TSCalBoxesContainer
@synthesize homePageCalendarObject = _homePageCalendarObject;
@synthesize totalHeight = _totalHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubviews];
        self.clipsToBounds = YES;
    }
return self;
}

- (UIColor *)lighterColorForColor:(UIColor *)color
{
    float h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s * 0.5
                          brightness:b
                               alpha:a];
    return nil;
}
//When the homePageCalendarObject is set, the elementViews are added
-(void)setHomePageCalendarObject:(HomePageCalObj *)homePageCalendarObject
{
    if (_homePageCalendarObject != homePageCalendarObject) {
    _homePageCalendarObject = homePageCalendarObject;
        [self initSubviews];
    }
}

-(void)initSubviews {
    // Takes the data stored in the homePageCalendarObject and converts it into the boxes that are displayed on screen.
    if (self.homePageCalendarObject) {
        //Adding the main box view for this segment
        CGPoint boxOrigin = CGPointMake(0,0);
        CGRect calBoxFrame =  CGRectMake(boxOrigin.x, boxOrigin.y, self.bounds.size.width, BOX_HEIGHT);
        TSCalBoxView *categoryView = [[TSCalBoxView alloc]initWithFrame:calBoxFrame title:self.homePageCalendarObject.title backgroundColor:self.homePageCalendarObject.color indentation:0];
        //Adding tap recognizer to sense when a category is clicked
        UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(expandContract:)];
        [categoryView addGestureRecognizer:tgr];
        [self addSubview:categoryView];
        
        //Adding the +Add New view
        boxOrigin =  CGPointMake(boxOrigin.x, boxOrigin.y + BOX_HEIGHT);
        TSAddBoxView * addCal = [[TSAddBoxView alloc]initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y, self.bounds.size.width, DETAIL_BOX_HEIGHT)];
        addCal.backgroundColor = [self lighterColorForColor:self.homePageCalendarObject.color];
        [self addSubview:addCal];
        
        //Add the rest of the activities below the main one
        boxOrigin = CGPointMake(boxOrigin.x, boxOrigin.y + DETAIL_BOX_HEIGHT);
        for (NSString *recent in self.homePageCalendarObject.recentEvents) {
            CGRect detailCalBoxFrame = CGRectMake(boxOrigin.x, boxOrigin.y, self.bounds.size.width, DETAIL_BOX_HEIGHT);
            TSCalBoxView *detailCalBox = [[TSCalBoxView alloc] initWithFrame:detailCalBoxFrame title:recent backgroundColor:[self lighterColorForColor:self.homePageCalendarObject.color] indentation:1];
            boxOrigin = CGPointMake(boxOrigin.x, boxOrigin.y + DETAIL_BOX_HEIGHT);
            [self addSubview:detailCalBox];
        }
        
        self.totalHeight = boxOrigin.y;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];

}

-(void)addElement:(NSString *)str
{    
    //Inserting it to the array of element views
    [self.homePageCalendarObject.recentEvents insertObject:str atIndex:0];
    
    // Layout the objects again
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
}
-(void)deleteElement:(TSCalBoxView*) e
{
    for (NSString *str in self.homePageCalendarObject.recentEvents) {
        if ([str isEqualToString:e.titleLabel.text]) {
            [self.homePageCalendarObject.recentEvents removeObject:str];
        }
    }
    
    // Layout the boxes again since we just deleted one.
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
}
-(IBAction)expandContract:(id)sender
{
    // toggle the state
    self.expanded = self.expanded ? 0 : 1;
    
    // Set the new height of the container
    CGRect newFrame;
    if (self.expanded) {
        // make the container full sized - show all sub activities
        newFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.totalHeight);
    } else {
        // shrink container - only show the main category
        newFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, BOX_HEIGHT);
    }
    
    // animate the transition
    [UIView animateWithDuration:0.5 animations:^{
        self.bounds = newFrame;
    }];
    
    NSLog(@"The container height is now: %f", self.frame.size.height);

    // superview update
    TSMenuBoxContainer *superView = (TSMenuBoxContainer *)self.superview;
    [superView updateBoxesWithChange];
}

@end

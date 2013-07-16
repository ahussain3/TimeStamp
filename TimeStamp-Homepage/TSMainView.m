//
//  TSMainView.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 6/28/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSMainView.h"

@implementation TSMainView

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

#pragma touch events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Main view touched");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}








@end

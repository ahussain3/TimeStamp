//
//  TSMenuBoxContainer.h
//  TimeStamp-Homepage
//
//  Created by Timothy Chong on 3/15/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSMenuBoxContainer : UIView

// An array storing TSCalBoxesContainers- containers containing the category and and the elemnets
@property (nonatomic) NSMutableArray * categoryBoxes;

// Update the Frame of the Menu according to the individual elements inside
-(void)updateBoxesWithChange;

@end

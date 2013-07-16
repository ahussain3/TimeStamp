//
//  TSCalBoxesContainer.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/2/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TSCalBoxView,HomePageCalObj;

@interface TSCalBoxesContainer : UIView

//The calendar object associated to the category
@property (strong, nonatomic) HomePageCalObj *homePageCalendarObject;

//Expand : 1, collapse : 0
@property (nonatomic) Boolean expanded;

-(void)addElement:(NSString*)str;
-(void)deleteElement:(TSCalBoxView*) e;

@end

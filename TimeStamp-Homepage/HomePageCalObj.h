//
//  HomePageCalObj.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/2/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomePageCalObj : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSMutableArray *recentEvents;
@property (nonatomic)float index;
@end

//
//  TSCategory.h
//  TSCategories
//
//  Created by Awais Hussain on 7/21/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EKCalendar;

@interface TSCategory : NSObject <NSCoding>

// EKCalendar affiliated with this
@property (nonatomic, strong) EKCalendar *calendar;

// The title of the event / category.
@property (nonatomic, strong) NSString *title;

// May possibly in future want to include a location.
@property (nonatomic, strong) NSString *location;

// Of the format Classes:Physics:Reading:Griffiths: (always end in a colon).
@property (nonatomic, strong) NSString *path;

// Hierarchical level. 0 is top level.
@property (nonatomic) NSInteger level;

// Color associated with the category
@property (nonatomic, strong) UIColor *color;

// Array of TSCategoryBox views. These are the next level of the hierarchy.
@property (nonatomic, strong) NSArray *subCategories;

@end

//
//  TSCategoryList.h
//  TSCategories
//
//  Created by Awais Hussain on 7/21/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TSCategory;

@interface TSCategoryStore : NSObject {
    
}

+ (TSCategoryStore *) instance;

// returns an array of TSCategoryBox objects. This is the top level.
- (NSArray *)data;

// CRUD functions
// Path should colon separated, for example "ROOT:Sleep:Nap:"
- (TSCategory *)addNewCalendar:(TSCategory *)category;
- (void)switchCategoryAtIndex:(NSInteger)ind1 withIndex:(NSInteger)ind2 forPath:(NSString *)path;

@end

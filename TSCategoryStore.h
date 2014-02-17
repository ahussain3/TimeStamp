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

- (void)importDefaultCategories;
- (void)syncStoredDataWithGCalData;

// returns an array of TSCategoryBox objects at a given level of the hierarchy.
- (NSArray *)dataForPath:(NSString *)path;
- (TSCategory *)categoryForPath:(NSString *)path;

// Set of EKCalendar objects representing 'unhidden' calendars
@property (nonatomic, strong) NSSet *activeCalendars;

// CRUD functions
// Path should colon separated, for example "ROOT:Sleep:Nap:"
- (TSCategory *)addNewCalendar:(TSCategory *)category;
- (void)addSubcategory:(NSString *)name AtPathLevel:(NSString *)path;
- (void)deleteCategory:(TSCategory *)category atPath:(NSString *)path;
- (void)exchangeCategoryAtIndex:(NSInteger)ind1 withIndex:(NSInteger)ind2 forPath:(NSString *)path;

@end

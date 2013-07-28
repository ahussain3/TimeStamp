//
//  TSCategoryList.m
//  TSCategories
//
//  Created by Awais Hussain on 7/21/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSCategoryStore.h"
#import "TSCategory.h"
#import "UIColor+CalendarPalette.h"

@interface TSCategoryStore () {
    
}

@property (nonatomic, strong) NSMutableArray *categoryArray;

@end

@implementation TSCategoryStore
@synthesize categoryArray = _categoryArray;

#pragma mark - Singleton methods
- (id) initSingleton
{
    if ((self = [super init]))
    {
        // Initialization code here.
    }
    
    return self;
}

+ (TSCategoryStore *) instance
{
    // Persistent instance.
    static TSCategoryStore *_default = nil;
    
    // Small optimization to avoid wasting time after the
    // singleton being initialized.
    if (_default != nil)
    {
        return _default;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      _default = [[TSCategoryStore alloc] initSingleton];
                  });
#else
    // Allocates once using the old approach, it's slower.
    // It's thread safe.
    @synchronized([MySingleton class])
    {
        // The synchronized instruction will make sure,
        // that only one thread will access this point at a time.
        if (_default == nil)
        {
            _default = [[TSCategoryList alloc] initSingleton];
        }
    }
#endif
    return _default;
}

#pragma mark - database methods

- (NSArray *) categoryArray {
    if (_categoryArray == nil) {
        TSCategory *sleep = [[TSCategory alloc] init];
        sleep.title = @"Sleep";
        sleep.color = [UIColor colorFromHexString:@"9e9e9e"];
        
        TSCategory *work = [[TSCategory alloc] init];
        work.title = @"Work";
        work.color = [UIColor colorFromHexString:@"91565e"];
        
        TSCategory * school = [[TSCategory alloc]init];
        school.title = @"School";
        school.color = [UIColor colorFromHexString:@"C5B46f"];
        
        TSCategory *survival = [[TSCategory alloc]init];
        survival.title = @"Survival";
        survival.color = [UIColor colorFromHexString:@"A07B64"];
        
        TSCategory * sport = [[TSCategory alloc]init];
        sport.title = @"Fitness";
        sport.color = [UIColor colorFromHexString:@"6C9B5C"];
        
        TSCategory * procras = [[TSCategory alloc]init];
        procras.title = @"Procrastination";
        procras.color = [UIColor colorFromHexString:@"8F6A77"];
        
        _categoryArray = [NSArray arrayWithObjects:sleep,work,school,survival,sport,procras, nil];
    }
    return _categoryArray;
}

- (NSArray *)data {
    return self.categoryArray;
}

- (void)addNewCategory:(TSCategory *)category withPath:(NSString *)path {
    NSArray *pathComponents = [path componentsSeparatedByString:@":"];
    if (![[pathComponents objectAtIndex:0] isEqualToString:@"ROOT"]) {
        return;
    }
    
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"title == %@", [pathComponents objectAtIndex:1]];
//    NSArray
//    TSCategory
}

@end

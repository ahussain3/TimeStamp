//
//  TSCategoryList.m
//  TSCategories
//
//  Created by Awais Hussain on 7/21/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSCategoryStore.h"
#import <EventKit/EventKit.h>
#import "TSCalendarStore.h"
#import "TSCategory.h"
#import "UIColor+CalendarPalette.h"

@interface TSCategoryStore () {
}

@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) EKEventStore *store;

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

- (EKEventStore *)store {
    if (_store == nil) {
        _store = [[TSCalendarStore instance] store];
    }
    return _store;
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
        _categoryArray = [[NSMutableArray alloc] init];
        
        // retrieve all calendars
        NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
        
        // Convert EKCalendars to TSCatgories.
        for (EKCalendar *cal in calendars) {
            if (!cal.allowsContentModifications) {
                // Remove calendars that do not allow editing
                NSLog(@"Error, calendar: %@ cannot be modfied", cal);
            } else {
                TSCategory *cat = [self TSCategoryWithEKCalendar:cal];
                [_categoryArray addObject:cat];
            }
        }
    }
    
    // Output the array.
    return _categoryArray;
}

#pragma mark Utility Methods
- (TSCategory *)TSCategoryWithEKCalendar:(EKCalendar *)calendar {
    TSCategory *category = [[TSCategory alloc] init];
    
    category.title = calendar.title;
    category.color = [UIColor colorWithCGColor:calendar.CGColor];
    category.calendar = calendar;
    
    return category;
}

- (EKCalendar *)createEKCalendarWithTSCategory:(TSCategory *)category {
    // Find "iCloud" source for new calendar
    EKSource* localSource=nil;
//    for (EKSource* source in store.sources) {
//        if(source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
//            localSource = source;
//            break;
//        }
//    }
    
    // Create new calendar
    EKCalendar *cal = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.store];
    cal.source = localSource;
    cal.title = category.title;
    cal.CGColor = category.color.CGColor;
    
    NSError *err;
    BOOL success = [self.store saveCalendar:cal commit:YES error:&err];
    if (success == NO) {
        NSLog(@"Error creating new calendar: %@", err);
    }
    
    return cal;
}

- (NSArray *)data {
    return self.categoryArray;
}

- (void)addNewCategory:(TSCategory *)category {
    // Create a new EKCalendar.
    
    // Convert it to a TSCategory.
}

- (void)updateCategory:(TSCategory *)category {
    // Only works if the category identifier is not changed.
}


@end

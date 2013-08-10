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
    BOOL loadCategoryArrayFromCoder = YES;
    
    if ((self = [super init]))
    {
        // Initialization code here.
        if (loadCategoryArrayFromCoder) {
            [self loadData];
        } else {
            [self initCategoryArray];
        }
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

#pragma mark setters and getters
- (void)initCategoryArray {
    if (self.categoryArray == nil) {
        self.categoryArray = [[NSMutableArray alloc] init];
        
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
                cat.level = 0;
            }
        }
        
        [self saveData];
    }
}

#pragma mark - database methods

- (NSArray *)data {
    return [self.categoryArray copy];
}
- (TSCategory *)addNewCalendar:(TSCategory *)category {
    // This should be changed to match user's preferences.
    BOOL useICloudStorage = YES;
    
    // Find " source for new calendar
    EKSource* localSource=nil;
    for (EKSource* source in self.store.sources) {
        if (useICloudStorage) {
            if(source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
                localSource = source;
                break;
            }
        } else {
            if (source.sourceType == EKSourceTypeLocal) {
                localSource = source;
                break;
            }
        }
    }
    
    // Create new calendar
    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.store];
    calendar.source = localSource;
    calendar.title = category.title;
    calendar.CGColor = category.color.CGColor;
    
    NSError *err;
    BOOL success = [self.store saveCalendar:calendar commit:YES error:&err];
    if (success == NO) {
        NSLog(@"Error creating new calendar: %@", err);
    } else {
        NSLog(@"Successfully created new calendar:%@", calendar);
    }
    
    // Update level of calendar.
    TSCategory *cat = [self TSCategoryWithEKCalendar:calendar];
    cat.level = 0;
    
    // Let the database know.
    [self.categoryArray addObject:cat];
    [self saveData];
    
    return cat;
}
- (void)updateCategory:(TSCategory *)category {
    // Only works if the category identifier is not changed.
}
- (void)switchCategoryAtIndex:(NSInteger)ind1 withIndex:(NSInteger)ind2 forPath:(NSString *)path {

}
- (void)deleteCategory:(TSCategory *)category atPath:(NSString *)path {
        
}

#pragma mark Persistence Methods
-(void)saveData
{
    NSLog(@"Save data method called");
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *savePath = [rootPath stringByAppendingPathComponent:@"TSCategoryData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableData *saveData = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:saveData];
    [archiver encodeObject:self.categoryArray forKey:@"categoryData"];
    [archiver finishEncoding];
    
    [fileManager createFileAtPath:savePath contents:saveData attributes:nil];
}

-(void)loadData
{
    NSLog(@"Load data method called");
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *savePath = [rootPath stringByAppendingPathComponent:@"TSCategoryData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:savePath])
    {
        NSData *data = [fileManager contentsAtPath:savePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.categoryArray = [unarchiver decodeObjectForKey:@"categoryData"];
    }
}


#pragma mark Utility Methods
- (TSCategory *)TSCategoryWithEKCalendar:(EKCalendar *)calendar {
    TSCategory *category = [[TSCategory alloc] init];
    
    category.title = calendar.title;
    category.color = [UIColor colorWithCGColor:calendar.CGColor];
    category.calendar = calendar;
    
    return category;
}

@end

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
    int loadDataFrom = 3;
    
    if ((self = [super init]))
    {
        // Initialization code here.
        if (loadDataFrom == 0) {
            // Load from calendar
            self.categoryArray = [self loadCalendarData];
        } else if (loadDataFrom == 1) {
            // Load from encoder (saved data)
            [self loadData];
        } else {
            self.categoryArray = [self loadCustomData];
        }
        [self saveData];
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
- (NSMutableArray *)loadCalendarData {
    NSMutableArray *catArray = [[NSMutableArray alloc] init];
    
    // retrieve all calendars
    NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
    
    // Convert EKCalendars to TSCatgories.
    for (EKCalendar *cal in calendars) {
        if (!cal.allowsContentModifications) {
            // Remove calendars that do not allow editing
            NSLog(@"Error, calendar: %@ cannot be modfied", cal);
        } else {
            TSCategory *cat = [self TSCategoryWithEKCalendar:cal];
            [catArray addObject:cat];
            cat.level = 0;
            cat.path = ROOT_CATEGORY_PATH;
        }
    }
    
    return catArray;
}

- (NSMutableArray *)loadCustomData {
    NSMutableArray *catArray = [[NSMutableArray alloc] init];
    
    TSCategory *sleep = [[TSCategory alloc] init];
    sleep.title = @"Sleep";
    sleep.color = [UIColor colorFromHexString:@"9e9e9e"];
    [sleep addSubcategory:@"Sleep"];
    [sleep addSubcategory:@"Nap"];
    
    TSCategory *work = [[TSCategory alloc] init];
    work.title = @"Work";
    work.color = [UIColor colorFromHexString:@"91565e"];
    
    TSCategory * school = [[TSCategory alloc]init];
    school.title = @"School";
    school.color = [UIColor colorFromHexString:@"C5B46f"];
    [school addSubcategory:@"Class"];
    [school addSubcategory:@"Studying"];
    [school addSubcategory:@"Extra Curriculars"];
    
    TSCategory *social = [[TSCategory alloc] init];
    social.title = @"Social";
    social.color = [UIColor colorFromHexString:@"BE8260"];
    [social addSubcategory:@"Friends"];
    [social addSubcategory:@"Co-workers"];
    
    TSCategory *food = [[TSCategory alloc] init];
    food.title = @"Food";
    food.color = [UIColor colorFromHexString:@"254540"];
    [food addSubcategory:@"Breakfast"];
    [food addSubcategory:@"Lunch"];
    [food addSubcategory:@"Dinner"];
    [food addSubcategory:@"Snacks"];
    
    TSCategory *travel = [[TSCategory alloc] init];
    travel.title = @"Travel";
    travel.color = [UIColor colorFromHexString:@"052F3B"];
    [travel addSubcategory:@"Commute"];
    [travel addSubcategory:@"Driving"];
    [travel addSubcategory:@"Bus"];
    [travel addSubcategory:@"Cycling"];
    
    TSCategory * sport = [[TSCategory alloc]init];
    sport.title = @"Fitness";
    sport.color = [UIColor colorFromHexString:@"6C9B5C"];
    [sport addSubcategory:@"Gym"];
    [sport addSubcategory:@"Sports"];
    [sport addSubcategory:@"Running"];
    
    TSCategory * procras = [[TSCategory alloc]init];
    procras.title = @"Wasted Time";
    procras.color = [UIColor colorFromHexString:@"8F6A77"];
    [procras addSubcategory:@"Internet"];
    [procras addSubcategory:@"Fatigue"];
    
    TSCategory *misc = [[TSCategory alloc] init];
    misc.title = @"Miscellaneous";
    misc.color = [UIColor colorFromHexString:@"517795"];
    
    catArray = [NSMutableArray arrayWithObjects:sleep,work,school,social,food,travel,sport,procras, misc, nil];
    
    return catArray;
}

#pragma mark - database methods

- (NSArray *)dataForPath:(NSString *)path {
    return [self goToPath:path inArray:self.categoryArray];
}

- (NSArray *)goToPath:(NSString *)path inArray:(NSArray *)array {
    NSMutableArray *elements = [[path componentsSeparatedByString:@":"] mutableCopy];
    [elements removeObjectAtIndex:0];
    NSString *newPath = [elements componentsJoinedByString:@":"];
    if ([newPath length] == 0) {
        return array;
    }
    
    NSString *element = [elements objectAtIndex:0];
    for (TSCategory *cat in array) {
        if ([cat.title isEqualToString:element]) {
            return [self goToPath:newPath inArray:cat.subCategories];
        }
    }
    NSLog(@"Error: The path (%@) specified doesn't exist", path);
    return nil;
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
    cat.path = ROOT_CATEGORY_PATH;
    
    // Let the database know.
    [self.categoryArray addObject:cat];
    [self saveData];
    
    return cat;
}

- (void)switchCategoryAtIndex:(NSInteger)ind1 withIndex:(NSInteger)ind2 forPath:(NSString *)path {
    
    [self.categoryArray exchangeObjectAtIndex:ind1 withObjectAtIndex:ind2];
    [self saveData];
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

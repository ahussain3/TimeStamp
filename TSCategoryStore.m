//
//  TSCategoryList.m
//  TSCategories
//
//  Created by Awais Hussain on 7/21/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSCategoryStore.h"
#import <EventKit/EventKit.h>
#import <dispatch/dispatch.h>
#import "TSCalendarStore.h"
#import "TSCategory.h"
#import "UIColor+CalendarPalette.h"
#import "UIColor+MLPFlatColors.h"

@interface TSCategoryStore () {
    BOOL saveToFile;
    dispatch_queue_t backgroundQueue;
}
// Set of EKCalendar objects representing 'unhidden' calendars
@property (nonatomic, strong) NSSet *activeCalendars;
// Store of all the categories and subcategories ever created (hidden and unhidden).
@property (nonatomic, strong) NSMutableArray *allCategories;
// This is the curated list of only unhidden categories. Use active calendars to derive this list.
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) EKEventStore *store;

@end

@implementation TSCategoryStore
@synthesize allCategories = _allCategories;

#pragma mark - Singleton methods
- (id) initSingleton
{
    backgroundQueue = dispatch_queue_create("com.timestamp.bgqueue", NULL);
    NSLog(@"FUNC called: initSingleton");
    
    int loadDataFrom = 3;
    if ((self = [super init]))
    {
        // Initialization code here.
        if (loadDataFrom == 0) {
            // Load from calendar
            saveToFile = YES;
            self.allCategories = [self loadCalendarData];
        } else if (loadDataFrom == 1) {
            // Load from encoder (saved data)
            saveToFile = YES;
            [self loadData];
        } else if (loadDataFrom == 2){
            // Load custom data (with subcategories)
            saveToFile = YES;
            [self loadData];
            [self importDefaultCalendars];
        } else if (loadDataFrom == 3) {
            saveToFile = YES;
            [self loadData];
            [self syncStoredDataWithGCalData];
        } else if (loadDataFrom == 4) {
            // Usually only run this on first launch
            [self loadData];
            [self importDefaultCalendars];
            [self syncStoredDataWithGCalData];
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
- (NSMutableArray *)allCategories {
    if(!_allCategories) {
        _allCategories = [[NSMutableArray alloc] init];
    }
    return  _allCategories;
}
- (void)setActiveCalendars:(NSSet *)activeCalendars {
    [[TSCalendarStore instance] setActiveCalendars:activeCalendars];
}
- (NSSet *)activeCalendars {
    return [[TSCalendarStore instance] activeCalendars];
}
- (NSMutableArray *)categoryArray {
    // Check to ensure that each category has a corresponding entry in the active calendars list.
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:_categoryArray.count];
    for (TSCategory *cat in self.allCategories) {
        for (EKCalendar *cal in self.activeCalendars) {
            if ([cal.calendarIdentifier isEqualToString:cat.calendar.calendarIdentifier]) {
                [tempArray addObject:cat];
                break;
            }
        }
    }
    return tempArray;
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
- (void)importCalendarData {

}

- (NSMutableArray *)loadCalendarData {
    NSMutableArray *catArray = [[NSMutableArray alloc] init];
    
    // retrieve only active calendars
    NSArray *calendars = [self.activeCalendars allObjects];
#warning Eventually we should remove the line below.
    if (calendars.count == 0) calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
    
    // Convert EKCalendars to TSCatgories.
    for (EKCalendar *cal in calendars) {
        if (!cal.allowsContentModifications || [cal.title isEqualToString:@"jeremynixon@college.harvard.edu"]) {
            // Remove calendars that do not allow editing
            NSLog(@"Error, calendar: %@ cannot be modfied", cal);
        } else {
            NSLog(@"Calendar added: %@", cal);
            TSCategory *cat = [self TSCategoryWithEKCalendar:cal];
            [catArray addObject:cat];
            cat.level = 0;
            cat.path = ROOT_CATEGORY_PATH;
        }
    }
    
    return catArray;
}
- (void)syncStoredDataWithGCalData {
    NSLog(@"FUNC called: syncStoredDataWithGCalData");
//    dispatch_async(backgroundQueue, ^{
    // get all calendars
    NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *existingCategories = [[NSMutableArray alloc] initWithCapacity:calendars.count];
    
    NSLog(@"Calendars from EKCal are:");
    for (EKCalendar *cal in calendars) {
        NSLog(@"%@", cal.title);
    }
    
    NSLog(@"Categories stored in phone are:");
    for (TSCategory *cat in self.allCategories) {
        NSLog(@"%@", cat.title);
    }
        
    BOOL catExists;
    for (EKCalendar *cal in calendars) {
        if (cal.allowsContentModifications) {
            for (TSCategory *cat in self.allCategories) {
                catExists = FALSE;
                if ([cal.title isEqualToString:cat.title] || [cal.title isEqualToString:cat.calendar.title] || [cal.calendarIdentifier isEqualToString:cat.calendar.calendarIdentifier]) {
                    catExists = TRUE;
                    [existingCategories addObject:cat];
                    break;
                }
            }
            // We have a new gCal calendar that doesn't have a TS equivalent.
            if (!catExists) {
                NSLog(@"New gCal cal that doesn't have TS equivalent: %@", cal.title);
                TSCategory *newCategory = [self TSCategoryWithEKCalendar:cal];
                newCategory.level = 0;
                newCategory.path = ROOT_CATEGORY_PATH;
                [existingCategories addObject:newCategory];
                [self.allCategories addObject:newCategory];
            }
        }
    }

    NSLog(@"Existing categories (which are also in GCal are:");
    for (TSCategory *cat in existingCategories) {
        NSLog(@"%@", cat.title);
    }
    
        // Remove excess categories from allCategories.
        NSMutableArray *remove = [[NSMutableArray alloc] init];
        for (TSCategory *cat in self.allCategories) {
            if (![existingCategories containsObject:cat]) {
                NSLog(@"Removed object: %@", cat.title);
                [remove addObject:cat];
            }
        }
        [self.allCategories removeObjectsInArray:remove];
        NSLog(@"Finished syncing calendars");

    NSLog(@"UPDATED: Calendars from EKCal are:");
    for (EKCalendar *cal in calendars) {
        NSLog(@"%@", cal.title);
    }
    
    NSLog(@"UPDATED: Categories stored in phone are:");
    for (TSCategory *cat in self.allCategories) {
        NSLog(@"%@", cat.title);
    }
    NSLog(@"UPDATED: Active categories are:");
    for (TSCategory *cat in self.activeCalendars) {
        NSLog(@"%@", cat.title);
    }
    
//    });
}

- (void)importDefaultCategories {
    [self importDefaultCalendars];
    [self syncStoredDataWithGCalData];
    [self saveData];
}

- (void)importDefaultCalendars {
    NSArray *defaultCats = [[self getDefaultCalendars] copy];
    TSCategory *tempCat;
    BOOL catExistsAlready = FALSE;
    // Check that the category doesn't already exist in our application.
    for (TSCategory *defCat in defaultCats) {
        for (TSCategory *stoCat in self.allCategories) {
            catExistsAlready = FALSE;
            if ([defCat.title isEqualToString:stoCat.title] || [defCat.calendar.title isEqualToString:stoCat.calendar.title] || [defCat.calendar.calendarIdentifier isEqualToString:stoCat.calendar.calendarIdentifier]) {
                // The calendar already exists in our store
                catExistsAlready = TRUE;
                defCat.calendar = stoCat.calendar;
                // Make stoCat an active calendar.
                NSMutableSet *tempSet = [self.activeCalendars mutableCopy];
                [tempSet addObject:stoCat.calendar];
                self.activeCalendars = tempSet;
                break;
            }
        }
        if (!catExistsAlready) {
            // The addNewCalendar: function takes care of adding newCat to self.allCategories.
            tempCat = [self addNewCalendar:defCat];
        }
    }
}
- (NSMutableArray *)getDefaultCalendars {
    NSMutableArray *catArray = [[NSMutableArray alloc] init];
    
    TSCategory *sleep = [[TSCategory alloc] init];
    sleep.title = @"Sleep";
    sleep.color = [UIColor colorFromHexString:@"414750"];
    sleep.path = ROOT_CATEGORY_PATH;
    [sleep addSubcategory:@"Sleep"];
    [sleep addSubcategory:@"Nap"];

    TSCategory * class = [[TSCategory alloc]init];
    class.title = @"Classes";
    class.color = [UIColor flatBlueColor];
    class.path = ROOT_CATEGORY_PATH;
    [class addSubcategory:@"Physics"];
    
    TSCategory * school = [[TSCategory alloc]init];
    school.title = @"Study";
    school.color = [UIColor flatYellowColor];
    school.path = ROOT_CATEGORY_PATH;
    [school addSubcategory:@"Class"];
    [school addSubcategory:@"Studying"];
    [school addSubcategory:@"Extra Curriculars"];
    
    TSCategory *social = [[TSCategory alloc] init];
    social.title = @"Social";
    social.color = [UIColor flatOrangeColor];
    social.path = ROOT_CATEGORY_PATH;
    [social addSubcategory:@"Hanging Out"];
    [social addSubcategory:@"Partying"];
    
    TSCategory *food = [[TSCategory alloc] init];
    food.title = @"Food";
    food.color = [UIColor colorFromHexString:@"a78143"];
    food.path = ROOT_CATEGORY_PATH;
    [food addSubcategory:@"Breakfast"];
    [food addSubcategory:@"Lunch"];
    [food addSubcategory:@"Dinner"];
    [food addSubcategory:@"Snacks"];
    
    TSCategory *travel = [[TSCategory alloc] init];
    travel.title = @"Travel";
    travel.color = [UIColor colorFromHexString:@"2f3876"];
    travel.path = ROOT_CATEGORY_PATH;
    [travel addSubcategory:@"Walking"];
    [travel addSubcategory:@"To Class"];
    [travel addSubcategory:@"Biking"];
    [travel addSubcategory:@"Back Home :)"];
    
    TSCategory * sport = [[TSCategory alloc]init];
    sport.title = @"Fitness";
    sport.color = [UIColor colorFromHexString:@"6ba743"];
    sport.path = ROOT_CATEGORY_PATH;
    [sport addSubcategory:@"Gym"];
    [sport addSubcategory:@"Sport"];
    [sport addSubcategory:@"Running"];
    
    TSCategory * procras = [[TSCategory alloc]init];
    procras.title = @"Wasted Time";
    procras.color = [UIColor colorFromHexString:@"722f76"];
    procras.path = ROOT_CATEGORY_PATH;
    [procras addSubcategory:@"Internet"];
    [procras addSubcategory:@"Tired"];
    
    TSCategory *misc = [[TSCategory alloc] init];
    misc.path = ROOT_CATEGORY_PATH;
    misc.title = @"Miscellaneous";
    misc.color = [UIColor colorFromHexString:@"4a80b9"];
    [procras addSubcategory:@"Internet"];
    
    catArray = [NSMutableArray arrayWithObjects:procras, travel,misc, sport, food, social, school, class, sleep, nil];
//    catArray = [NSMutableArray arrayWithObjects:sport,procras, misc, nil];

    return catArray;
}

#pragma mark - database methods
- (NSArray *)dataForPath:(NSString *)path {
    TSCategory *category = [self categoryForPath:path andCategory:nil];
    NSArray *array = [[NSArray alloc] init];;
    if (category == nil) {
        array = self.categoryArray;
    } else {
        array = category.subCategories;
    }
    return array;
}
- (TSCategory *)categoryForPath:(NSString *)path {
    TSCategory *category = [[TSCategory alloc] init];
    if (![path isEqualToString:ROOT_CATEGORY_PATH]) {
        category = [self categoryForPath:path andCategory:nil];
        return category;
    }
    return nil;
}
// Recursively goes in and locates the category specified by the path.
// If it returns nil, then we are at the ROOT level.
- (TSCategory *)categoryForPath:(NSString *)path andCategory:(TSCategory *)category {
    if (category == nil) {
        category = [[TSCategory alloc] init];
        category.subCategories = self.allCategories;
    }
    if ([path isEqualToString:ROOT_CATEGORY_PATH]) {
        NSLog(@"This is the ROOT path");
        return nil;
    }
    
    NSMutableArray *pathElements = [[path componentsSeparatedByString:@":"] mutableCopy];
    [pathElements removeObjectAtIndex:0];
    NSString *newPath = [pathElements componentsJoinedByString:@":"];
    
    if ([newPath length] == 0) {
        return category;
    }
    
    NSString *element = [pathElements objectAtIndex:0];
    for (TSCategory *cat in category.subCategories) {
        if ([cat.title isEqualToString:element]) {
            return [self categoryForPath:newPath andCategory:cat];
        }
    }
    
    NSLog(@"Error: The specified path (%@) doesn't exist", path);
    return nil;
}
- (void)addSubcategory:(NSString *)name AtPathLevel:(NSString *)path {
    NSLog(@"Searching for path: %@", path);
    if ([name isEqualToString:@""]) return;
    TSCategory *category = [self categoryForPath:path andCategory:nil];
    if ([path isEqualToString:ROOT_CATEGORY_PATH]) {
        NSLog(@"Need to add a 'calendar' level category");
        TSCategory *newCat = [[TSCategory alloc] init];
        
        newCat.title = name;
        newCat.color = [UIColor randomFlatColor];
        // For some reason it's not seeing that I have a UIColor category, so the below is done manually.
        float h, s, b, a;
        [newCat.color getHue:&h saturation:&s brightness:&b alpha:&a];
        newCat.color = [UIColor colorWithHue:h saturation:MIN(s, 0.6) brightness:b alpha:a];
        [self addNewCalendar:newCat];
    } else {
        // Do some validation checks. Ensure that the category doesn't already exist.
        [category addSubcategory:name];
    }
    [self saveData];    
}
- (void)exchangeCategoryAtIndex:(NSInteger)ind1 withIndex:(NSInteger)ind2 forPath:(NSString *)path {
    dispatch_async(backgroundQueue, ^{
        TSCategory *category = [self categoryForPath:path andCategory:nil];
        if (category == nil) {
            TSCategory *cat1 = [self.categoryArray objectAtIndex:ind1];
            TSCategory *cat2 = [self.categoryArray objectAtIndex:ind2];
            
            //        [self.categoryArray exchangeObjectAtIndex:ind1 withObjectAtIndex:ind2];
            
            NSInteger newInd1 = [self.allCategories indexOfObject:cat1];
            NSInteger newInd2 = [self.allCategories indexOfObject:cat2];
            
            [self.allCategories exchangeObjectAtIndex:newInd1 withObjectAtIndex:newInd2];
        } else {
            [category.subCategories exchangeObjectAtIndex:ind1 withObjectAtIndex:ind2];
        }
        
        [self saveData];
    });
}
- (void)deleteCategory:(TSCategory *)category atPath:(NSString *)path {
    dispatch_async(backgroundQueue, ^{
        if ([path isEqualToString:ROOT_CATEGORY_PATH]) {
            // Have to 'hide' an entire calendar. We don't yet have this functionality.
            for (EKCalendar *cal in self.activeCalendars) {
                if ([cal.calendarIdentifier isEqualToString:category.calendar.calendarIdentifier]) {
                    NSMutableArray *tempArray = [self.activeCalendars mutableCopy];
                    [tempArray removeObject:cal];
                    self.activeCalendars = [tempArray copy];
                    break;
                }
            }
        } else {
            TSCategory *storedCat = [self categoryForPath:path andCategory:nil];
            for (TSCategory *cat in storedCat.subCategories) {
                if ([cat isEqual:category]) {
                    // remove category.
                    [storedCat.subCategories removeObject:cat];
                    break;
                }
            }
        }
        
        [self saveData];    
    });
}

- (TSCategory *)addNewCalendar:(TSCategory *)category {
    // This should be changed to match user's preferences.
    BOOL useICloudStorage = YES;
    
    // Find " source for new calendar
    EKSource* localSource=nil;
    for (EKSource* source in self.store.sources) {
//        if (useICloudStorage) {
        if(source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
            localSource = source;
            break;
            }
        else if (source.sourceType == EKSourceTypeCalDAV) {
            localSource = source;
            break;
            }
        else {
            if (source.sourceType == EKSourceTypeLocal) {
                localSource = source;
            }
        }
    }
    
    // Check that the calendar doesn't already exist.
    for (EKCalendar *cal in [self.store calendarsForEntityType:EKEntityTypeEvent]) {
        if ([cal.title isEqualToString:category.title]) {
            return nil;
            NSLog(@"FAILED: Trying to create a calendar with a name that already exists");
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
        return nil;
    } else {
        NSLog(@"Successfully created new calendar:%@", calendar);
    }
    
    // Update level of calendar.
    TSCategory *cat = [self TSCategoryWithEKCalendar:calendar];
    cat.level = 0;
    cat.path = ROOT_CATEGORY_PATH;
    
    // Let the database know.
    [self.allCategories insertObject:cat atIndex:0];
    // Make calendar active
    NSMutableSet *temp = [self.activeCalendars mutableCopy];
    [temp addObject:calendar];
    self.activeCalendars = temp;
    
    return cat;
}

#pragma mark Persistence Methods
-(void)saveData
{
    dispatch_async(backgroundQueue, ^{
        if (saveToFile) {
            NSLog(@"Save data method called");
            NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask, YES) objectAtIndex:0];
            NSString *savePath = [rootPath stringByAppendingPathComponent:@"TSCategoryData"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSMutableData *saveData = [[NSMutableData alloc] init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:saveData];
            [archiver encodeObject:self.allCategories forKey:@"categories"];
            [archiver finishEncoding];
            
            [fileManager createFileAtPath:savePath contents:saveData attributes:nil];
        }    
    });
}

-(void)loadData
{
//    dispatch_async(backgroundQueue, ^{
        NSLog(@"Load data method called");
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        NSString *savePath = [rootPath stringByAppendingPathComponent:@"TSCategoryData"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:savePath])
        {
            NSData *data = [fileManager contentsAtPath:savePath];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            self.allCategories = [unarchiver decodeObjectForKey:@"categories"];
        }
//    });
}
#pragma mark Utility Methods
- (TSCategory *)TSCategoryWithEKCalendar:(EKCalendar *)calendar {
    TSCategory *category = [[TSCategory alloc] init];
    
    category.title = calendar.title;
    category.color = [UIColor colorWithCGColor:calendar.CGColor];
    float h, s, b, a;
    [category.color getHue:&h saturation:&s brightness:&b alpha:&a];
    category.color = [UIColor colorWithHue:h saturation:MIN(s, 0.6) brightness:b alpha:a];
    category.calendar = calendar;
    
    return category;
}

@end

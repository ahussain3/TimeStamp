//
//  TSMenuObjectStore.m
//  TimeStamp-Homepage
//
//  Created by Timothy Chong on 3/15/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "TSMenuObjectStore.h"
#import "HomePageCalObj.h"
#import "UIColor+CalendarPalette.h"

@implementation TSMenuObjectStore


#pragma mark - Singleton Methods

-(id)initStore
{
    self = [super init];
    if (self) {
        HomePageCalObj *sleep = [[HomePageCalObj alloc] init];
        sleep.title = @"Sleep";
        sleep.color = [UIColor colorFromHexString:@"9e9e9e"];
        sleep.recentEvents = [NSMutableArray arrayWithObjects:@"Sleep",@"Nap",@"Resting",nil];

        HomePageCalObj *work = [[HomePageCalObj alloc] init];
        work.title = @"Work";
        work.color = [UIColor colorFromHexString:@"91565e"];
        work.recentEvents = [NSMutableArray arrayWithObjects:@"Physics", @"Philosophy", @"Econometrics", nil];

        HomePageCalObj * school = [[HomePageCalObj alloc]init];
        school.title = @"School";
        school.color = [UIColor colorFromHexString:@"C5B46f"];
        school.recentEvents = [NSMutableArray arrayWithObjects:@"Biology",@"Chemistry",@"Physics", nil];
        
        HomePageCalObj *survival = [[HomePageCalObj alloc]init];
        survival.title = @"Survival";
        survival.color = [UIColor colorFromHexString:@"A07B64"];
        survival.recentEvents =[NSMutableArray arrayWithObjects:@"Eat",@"Drink",@"bathroom",@"breathe", nil];
        
        HomePageCalObj * sport = [[HomePageCalObj alloc]init];
        sport.title = @"Sports";
        sport.color = [UIColor colorFromHexString:@"6C9B5C"];
        sport.recentEvents = [NSMutableArray arrayWithObjects:@"Gym",@"jogging",@"Bowling",@"Golf", nil];
        
        HomePageCalObj * procras = [[HomePageCalObj alloc]init];
        procras.title = @"Procrastination";
        procras.color = [UIColor colorFromHexString:@"8F6A77"];
        procras.recentEvents = [NSMutableArray arrayWithObjects:@"Hang out",@"Facebook", @"Youtube", nil];
        
        self.calendars = [NSMutableArray arrayWithObjects:sleep, work,school,survival,sport,procras, nil];
        
    }
    return self;
}

-(void) addElement:(NSString*)str toCaldendarWithIndex:(float)f
{
    [((HomePageCalObj*)[self.calendars objectAtIndex:f]).recentEvents insertObject:str atIndex:0];
}

-(void)deleteElemetWithCaldendarIndex:(float)f1 elementIndex:(float)f2
{
    [((HomePageCalObj*)[self.calendars objectAtIndex:f1]).recentEvents removeObjectAtIndex:f2];
}


+ (TSMenuObjectStore *) defaultStore
{
    // Persistent instance.
    static TSMenuObjectStore *_default = nil;
    
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
                      _default = [[TSMenuObjectStore alloc] initStore];
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
            _default = [[TSMenuObjectStore alloc] initStore];
        }
    }
#endif
    return _default;
}

@end

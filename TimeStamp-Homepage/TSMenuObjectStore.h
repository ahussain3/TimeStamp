//
//  TSMenuObjectStore.h
//  TimeStamp-Homepage
//
//  Created by Timothy Chong on 3/15/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSMenuObjectStore : NSObject

// [TSMenuObjectStore defaultStore] to access singleton
+ (TSMenuObjectStore *) defaultStore;

// This contains an array of HomePageCalObj
@property (nonatomic) NSArray *calendars;

//Called when need to modify the Storages
-(void) addElement:(NSString*)str toCaldendarWithIndex:(float)f;
-(void)deleteElemetWithCaldendarIndex:(float)f1 elementIndex:(float)f2;
@end

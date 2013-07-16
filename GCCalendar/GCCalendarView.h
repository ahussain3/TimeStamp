//
//  GCCalendarView.h
//  iBeautify
//
//  Created by Caleb Davenport on 2/27/10.
//  Copyright 2010 GUI Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCCalendarProtocols.h"

@interface GCCalendarView : UIViewController {
	// data source
	id<GCCalendarDataSource> __weak dataSource;
	
	// delegate
	id<GCCalendarDelegate> __weak delegate;
}

@property (nonatomic, weak) id<GCCalendarDataSource> dataSource;
@property (nonatomic, weak) id<GCCalendarDelegate> delegate;

@end

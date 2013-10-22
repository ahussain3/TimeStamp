//
//  TotalHourCell.h
//  CalendarTracker
//
//  Created by Awais Hussain on 1/26/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilityMethods.h"

@interface TotalHourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *totalHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfEventsLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@end

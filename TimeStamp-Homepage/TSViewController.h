//
//  TSViewController.h
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 3/1/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCalBoxesContainer.h"
#import "HomePageCalObj.h"

@interface TSViewController : UIViewController

@property (weak, nonatomic) IBOutlet TSCalBoxesContainer *calContainer;

@end

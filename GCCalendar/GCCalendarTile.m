//
//  GCCalendarTile.m
//  GCCalendar
//
//	GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 1/23/10.
//  Copyright GUI Cocoa Software 2010. All rights reserved.
//

#import "GCCalendarTile.h"
#import "GCCalendarEvent.h"
#import "GCCalendar.h"
#import "UIColor+CalendarPalette.h"
#import <QuartzCore/QuartzCore.h>

#define tDragAreaHeight 50

@interface GCCalendarTile () {
}

@end

@implementation GCCalendarTile

@synthesize event = _event;
@synthesize selected = _selected;

- (id)initWithEvent:(GCCalendarEvent *)event {
	if (self = [super init]) {
        self.event = event;
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = event.color;
        
        self.selectedView = [[UIView alloc] init];
        self.selectedView.backgroundColor = [UIColor colorFromHexString:@"#dddddd"];
        
        self.startTimeDragView = [[UIView alloc] init];
        self.startTimeDragView.backgroundColor = [UIColor redColor];
        self.startTimeDragView.hidden = YES;
        self.endTimeDragView = [[UIView alloc] init];
        self.endTimeDragView.backgroundColor = [UIColor redColor];
        self.endTimeDragView.hidden = YES;

        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:12.0f];
        titleLabel.text = event.eventName;

        descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        descriptionLabel.font = [UIFont fontWithName:@"Verdana" size:10.0f];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.text = event.eventDescription;

        [self addSubview:self.selectedView];
        [self addSubview:self.contentView];
        [self addSubview:self.startTimeDragView];
        [self addSubview:self.endTimeDragView];
		[self addSubview:titleLabel];
		[self addSubview:descriptionLabel];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTapped:)];
        [self addGestureRecognizer:tap];
	}
	
	return self;
}
- (void)dealloc {
	self.event = nil;
}
-(void)setSelected:(BOOL)selected {
    if (selected != _selected) {
        // Guaranteed to be toggling between selected / unselected, so frame calculations are valid
        _selected = selected;
        
        if (_selected) {
            self.contentView.hidden = YES;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = NO;
            self.endTimeDragView.hidden = NO;
            titleLabel.textColor = self.event.color;
            descriptionLabel.textColor = self.event.color;
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y - tDragAreaHeight,
                                    self.frame.size.width,
                                    self.frame.size.height + 2 * tDragAreaHeight);
        } else {
            self.contentView.hidden = NO;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = YES;
            self.endTimeDragView.hidden = YES;
            titleLabel.textColor = [UIColor colorFromHexString:@"#eeeeee"];
            descriptionLabel.textColor = [UIColor colorFromHexString:@"eeeeee"];
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y + tDragAreaHeight,
                                    self.frame.size.width,
                                    self.frame.size.height - 2 * tDragAreaHeight);
        }
        [self setNeedsDisplay];
    }
}
- (void)layoutSubviews {
	CGRect myBounds = self.bounds;
    self.selectedView.frame = self.bounds;
    self.selectedView.layer.borderColor = self.event.color.CGColor;
    self.selectedView.layer.borderWidth = 4.0;
    
    self.contentView.frame = self.bounds;
    
    CGRect startRect = CGRectMake(0, -tDragAreaHeight, self.bounds.size.width, tDragAreaHeight);
    self.startTimeDragView.frame = startRect;
    
    CGRect endRect = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, tDragAreaHeight);
    self.endTimeDragView.frame = endRect;
    
	CGSize stringSize = [titleLabel.text sizeWithFont:titleLabel.font];
	titleLabel.frame = CGRectMake(10,
								  3,
								  myBounds.size.width - 16,
								  stringSize.height);
	
	if (self.event.allDayEvent) {
		descriptionLabel.frame = CGRectZero;
	}
	else {
		descriptionLabel.frame = CGRectMake(14,
											titleLabel.frame.size.height + 3,
											myBounds.size.width - 20,
											myBounds.size.height - 14 - titleLabel.frame.size.height);
	}
}

#pragma mark Respond to gestures
- (void)tileTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"tap internal pressed");
    if (!self.selected) {
        [self.delegate deselectAllTiles];
        [self.delegate setSelectedTile:self];
        self.selected = TRUE;
    } else {
        self.selected = FALSE;
    }
}

//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef contextRef = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(contextRef, 4);
//    CGContextSetStrokeColorWithColor(contextRef, [self.event.color CGColor]);
//    CGContextStrokeRect(contextRef, rect);
//}

@end

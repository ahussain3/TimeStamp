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
@property (nonatomic) CGRect extendedFrame;

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

#pragma mark Setters and Getters
- (void)setNaturalFrame:(CGRect)naturalFrame {
    if (!CGRectEqualToRect(_naturalFrame, naturalFrame)) {
        _naturalFrame = naturalFrame;
        self.frame = _naturalFrame;
    }
//    self.selected = NO;
}
- (CGRect)extendedFrame {
    CGRect frame = CGRectMake(self.naturalFrame.origin.x,
                              self.naturalFrame.origin.y - tDragAreaHeight,
                              self.naturalFrame.size.width,
                              self.naturalFrame.size.height + 2 *tDragAreaHeight);
    return frame;
}
- (void)setSelected:(BOOL)selected {
    if (selected != _selected) {
        // Guaranteed to be toggling between selected / unselected, so frame calculations are valid
        _selected = selected;
        
        NSLog(@"Set selected to: %i", _selected);
        NSLog(@"self.frame (pre - sel): (%f,%f,%f,%f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        NSLog(@"natural frame (sel): (%f,%f,%f,%f)", self.naturalFrame.origin.x, self.naturalFrame.origin.y, self.naturalFrame.size.width, self.naturalFrame.size.height);
        NSLog(@"extended frame (sel): (%f,%f,%f,%f)", self.extendedFrame.origin.x, self.extendedFrame.origin.y, self.extendedFrame.size.width, self.extendedFrame.size.height);
        
        if (_selected) {
            self.frame = self.extendedFrame;
            self.contentView.hidden = YES;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = NO;
            self.endTimeDragView.hidden = NO;
            titleLabel.textColor = self.event.color;
            descriptionLabel.textColor = self.event.color;
        } else {
            self.frame = self.naturalFrame;
            self.contentView.hidden = NO;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = YES;
            self.endTimeDragView.hidden = YES;
            titleLabel.textColor = [UIColor colorFromHexString:@"#eeeeee"];
            descriptionLabel.textColor = [UIColor colorFromHexString:@"eeeeee"];
        }
        
        NSLog(@"self.frame (post - sel): (%f,%f,%f,%f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);

        [self setNeedsDisplay];
    }
}
- (void)layoutSubviews {
    if (self.selected) {
        contentFrame = CGRectMake(0, tDragAreaHeight, self.naturalFrame.size.width, self.naturalFrame.size.height);
    } else {
        contentFrame = CGRectMake(0, 0, self.naturalFrame.size.width, self.naturalFrame.size.height);
    }
    
    self.selectedView.frame = contentFrame;
    self.selectedView.layer.borderColor = self.event.color.CGColor;
    self.selectedView.layer.borderWidth = 4.0;
    
    self.contentView.frame = contentFrame;
    
    CGRect startRect = CGRectMake(0, 0, contentFrame.size.width, tDragAreaHeight);
    self.startTimeDragView.frame = startRect;
    
//    NSLog(@"Start drag frame (layout): (%f,%f,%f,%f)", self.startTimeDragView.frame.origin.x, self.startTimeDragView.frame.origin.y, self.startTimeDragView.frame.size.width, self.startTimeDragView.frame.size.height);
//    NSLog(@"self.frame (layout): (%f,%f,%f,%f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//    NSLog(@"self.bounds (layout): (%f,%f,%f,%f)", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    
    CGRect endRect = CGRectMake(0, contentFrame.origin.y + contentFrame.size.height, contentFrame.size.width, tDragAreaHeight);
    self.endTimeDragView.frame = endRect;
    
	CGSize stringSize = [titleLabel.text sizeWithFont:titleLabel.font];
	titleLabel.frame = CGRectMake(10,
								  contentFrame.origin.y + 3,
								  contentFrame.size.width - 16,
								  stringSize.height);
	
	if (self.event.allDayEvent) {
		descriptionLabel.frame = CGRectZero;
	}
	else {
		descriptionLabel.frame = CGRectMake(14,
											titleLabel.frame.size.height + 3,
											contentFrame.size.width - 20,
											contentFrame.size.height - 14 - titleLabel.frame.size.height);
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

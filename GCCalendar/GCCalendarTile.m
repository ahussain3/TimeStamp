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
@synthesize naturalFrame = _naturalFrame;

- (id)initWithEvent:(GCCalendarEvent *)event {
	if (self = [super init]) {
        self.event = event;
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = event.color;
        
        self.selectedView = [[UIView alloc] init];
        self.selectedView.backgroundColor = [UIColor colorFromHexString:@"#dddddd"];
        self.selectedView.layer.borderColor = self.event.color.CGColor;
        self.selectedView.layer.borderWidth = 4.0;
        
        [self configureDraggableAreas];

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
		[self addSubview:titleLabel];
		[self addSubview:descriptionLabel];
        
        [self addGestureRecognizers];
	}
	
	return self;
}
- (void)dealloc {
	self.event = nil;
}
- (void)configureDraggableAreas {
    self.startTimeDragView = [[UIView alloc] init];
    self.startTimeDragView.backgroundColor = [UIColor redColor];
    self.startTimeDragView.hidden = YES;
    
    self.endTimeDragView = [[UIView alloc] init];
    self.endTimeDragView.backgroundColor = [UIColor redColor];
    self.endTimeDragView.hidden = YES;
    
    [self addSubview:self.startTimeDragView];
    [self addSubview:self.endTimeDragView];
}
- (void)addGestureRecognizers {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTapped:)];
    [self addGestureRecognizer:tap];
}
#pragma mark Setters and Getters
- (void)setNaturalFrame:(CGRect)naturalFrame {
    if (!CGRectEqualToRect(_naturalFrame, naturalFrame)) {
        _naturalFrame = naturalFrame;
        [self layoutSubviews];
    }
}
//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    if (self.selected) {
//        _naturalFrame = CGRectMake(frame.origin.x, frame.origin.y + tDragAreaHeight, frame.size.width, frame.size.height + 2 * tDragAreaHeight);
//    } else {
//        _naturalFrame = frame;
//    }
//}
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
        
        if (_selected) {
            self.contentView.hidden = YES;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = NO;
            self.endTimeDragView.hidden = NO;
            titleLabel.textColor = self.event.color;
            descriptionLabel.textColor = self.event.color;
        } else {
            self.contentView.hidden = NO;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = YES;
            self.endTimeDragView.hidden = YES;
            titleLabel.textColor = [UIColor colorFromHexString:@"#eeeeee"];
            descriptionLabel.textColor = [UIColor colorFromHexString:@"eeeeee"];
        }
        
//        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}
- (void)layoutSubviews {
    if (self.selected) {
        self.frame = self.extendedFrame;
        contentFrame = CGRectMake(0, tDragAreaHeight, self.naturalFrame.size.width, self.naturalFrame.size.height);
    } else {
        self.frame = self.naturalFrame;
        contentFrame = CGRectMake(0, 0, self.naturalFrame.size.width, self.naturalFrame.size.height);
    }
    
    self.selectedView.frame = contentFrame;    
    self.contentView.frame = contentFrame;
    
    CGRect startRect = CGRectMake(0, 0, contentFrame.size.width, tDragAreaHeight);
    self.startTimeDragView.frame = startRect;
    
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

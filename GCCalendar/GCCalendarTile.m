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

@interface GCCalendarTile () {
    BOOL shouldRasterize;
}
@property (nonatomic) CGRect extendedFrame;

@end

@implementation GCCalendarTile

@synthesize event = _event;
@synthesize selected = _selected;
@synthesize naturalFrame = _naturalFrame;

- (id)initWithEvent:(GCCalendarEvent *)event {
	if (self = [super init]) {
        shouldRasterize = YES;
        self.event = event;
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = event.color;
        self.contentView.clipsToBounds = YES;

        
        self.selectedView = [[UIView alloc] init];
        self.selectedView.backgroundColor = [UIColor colorFromHexString:@"#dddddd"];
        self.selectedView.layer.borderColor = self.event.color.CGColor;
        self.selectedView.layer.borderWidth = 4.0;
        
        [self configureDraggableAreas];

        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:12.0f];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.text = event.eventName;

//        descriptionLabel = [[UILabel alloc] init];
//        descriptionLabel.backgroundColor = [UIColor clearColor];
//        descriptionLabel.textColor = [UIColor whiteColor];
//        descriptionLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
//        descriptionLabel.font = [UIFont fontWithName:@"Verdana" size:10.0f];
//        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        descriptionLabel.numberOfLines = 0;
//        descriptionLabel.text = event.eventDescription;

        [self addSubview:self.selectedView];
        [self addSubview:self.contentView];
		[self addSubview:titleLabel];
//		[self addSubview:descriptionLabel];
        
        [self addGestureRecognizers];
	}
	
	return self;
}
- (void)dealloc {
	self.event = nil;
}
- (void)configureDraggableAreas {
    self.startTimeDragView = [[UIView alloc] init];
    self.startTimeDragView.backgroundColor = [UIColor grayColor];
    self.startTimeDragView.alpha = 0.8f;
    self.startTimeDragView.hidden = YES;
    upArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up_arrow"]];
    [self.startTimeDragView addSubview:upArrowView];
    
    self.endTimeDragView = [[UIView alloc] init];
    self.endTimeDragView.backgroundColor = [UIColor grayColor];
    self.endTimeDragView.alpha = 0.8f;
    self.endTimeDragView.hidden = YES;
    downArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_arrow"]];
    [self.endTimeDragView addSubview:downArrowView];
    
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
//            descriptionLabel.textColor = self.event.color;
        } else {
            self.contentView.hidden = NO;
            self.selectedView.hidden = NO;
            self.startTimeDragView.hidden = YES;
            self.endTimeDragView.hidden = YES;
            titleLabel.textColor = [UIColor colorFromHexString:@"#eeeeee"];
//            descriptionLabel.textColor = [UIColor colorFromHexString:@"eeeeee"];
        }
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
    
    self.contentView.frame = contentFrame;
    self.selectedView.frame = contentFrame;
    self.contentView.layer.cornerRadius = CORNER_RADIUS;
    self.selectedView.layer.cornerRadius = CORNER_RADIUS;
    self.contentView.layer.masksToBounds = NO;
    self.selectedView.layer.masksToBounds = NO;
    self.contentView.layer.shouldRasterize = shouldRasterize;
    self.selectedView.layer.shouldRasterize = shouldRasterize;
    
    CGRect startRect = CGRectMake(0, 0, contentFrame.size.width, tDragAreaHeight + CORNER_RADIUS * 2);
    self.startTimeDragView.frame = startRect;
    self.startTimeDragView.layer.cornerRadius = CORNER_RADIUS;
    self.startTimeDragView.layer.masksToBounds = NO;
    self.startTimeDragView.layer.shouldRasterize = shouldRasterize;
    
    upArrowView.center = CGPointMake(self.startTimeDragView.bounds.size.width / 2, self.startTimeDragView.bounds.size.height / 2 - CORNER_RADIUS);
    upArrowView.bounds = CGRectMake(0, 0, 30, 30);
    
    CGRect endRect = CGRectMake(0, contentFrame.origin.y + contentFrame.size.height - CORNER_RADIUS * 2, contentFrame.size.width, tDragAreaHeight + CORNER_RADIUS * 2);
    self.endTimeDragView.frame = endRect;
    self.endTimeDragView.layer.cornerRadius = CORNER_RADIUS;
    self.endTimeDragView.layer.masksToBounds = NO;
    self.endTimeDragView.layer.shouldRasterize = shouldRasterize;
    
    downArrowView.center = CGPointMake(self.endTimeDragView.bounds.size.width / 2, self.endTimeDragView.bounds.size.height / 2 + CORNER_RADIUS);
    downArrowView.bounds = CGRectMake(0, 0, 30, 30);

    CGSize maxSize = CGSizeMake(contentFrame.size.width - 2*CORNER_RADIUS,
                                contentFrame.size.height - 6);
    CGSize stringSize = [titleLabel.text sizeWithFont:titleLabel.font
                                   constrainedToSize:maxSize
                                       lineBreakMode:titleLabel.lineBreakMode];
    
	titleLabel.frame = CGRectMake(CORNER_RADIUS,
								  contentFrame.origin.y + 3,
                                  stringSize.width, stringSize.height);
    
	if (self.event.allDayEvent) {
//		descriptionLabel.frame = CGRectZero;
	}
	else {
//		descriptionLabel.frame = CGRectMake(14,
//											titleLabel.frame.size.height + 3,
//											contentFrame.size.width - 20,
//											contentFrame.size.height - 14 - titleLabel.frame.size.height);
	}
}

#pragma mark Respond to gestures
- (void)tileTapped:(UITapGestureRecognizer *)sender {
//    NSLog(@"tap internal pressed");
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

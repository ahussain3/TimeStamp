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

#define tDragAreaHeight 50

@interface GCCalendarTile () {
}

@end

@implementation GCCalendarTile

@synthesize event;
@synthesize color = _color;
@synthesize selected = _selected;

- (id)init {
	if (self = [super init]) {
		self.clipsToBounds = NO;
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        
		titleLabel = [[UILabel alloc] init];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:12.0f];
		
		descriptionLabel = [[UILabel alloc] init];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor whiteColor];
		descriptionLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
		descriptionLabel.font = [UIFont fontWithName:@"Verdana" size:10.0f];
		descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
		descriptionLabel.numberOfLines = 0;
		
		[self addSubview:titleLabel];
		[self addSubview:descriptionLabel];
	}
	
	return self;
}
- (void)dealloc {
	self.event = nil;
}
- (void)setEvent:(GCCalendarEvent *)e {
	event = e;
	
	// set title
	titleLabel.text = event.eventName;
	descriptionLabel.text = event.eventDescription;
//    self.color = e.color;
	
	[self setNeedsDisplay];
}
-(void)setColor:(UIColor *)c {
    _color = c;
    if (self.selected) {
        self.backgroundColor = [_color colorWithAlphaComponent:0.8f];
    } else {
        self.backgroundColor = [_color colorWithAlphaComponent:0.5f];
    }
    [self setNeedsDisplay];
}
-(void)setSelected:(BOOL)s {
    if (s != _selected) {
        _selected = s;
        [self setColor:self.color];
        _selected ? [self drawDraggableAreas] : [self removeDraggableAreas];
        [self setNeedsDisplay];
    }
}
-(void)removeDraggableAreas {
    if (!self.selected) {
        // remove any left over drag regions
        if (self.endTimeDrag) {
            [self.endTimeDrag removeFromSuperview];
            self.endTimeDrag = nil;
        }
//        CGRect newFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height - self.endTimeDrag.bounds.size.height);
//        self.frame = newFrame;
        NSLog(@"(remove) New tile height is: %f", self.bounds.size.height);
    }
}
-(void)drawDraggableAreas {
    if (self.selected) {
        // create the dragging UIViews
//        CGRect startDrag = CGRectMake(self.bounds.origin.x, self.bounds.origin.y - tDragAreaHeight, self.bounds.size.width, tDragAreaHeight);
//        UIView *dragArea = [[UIView alloc] initWithFrame:startDrag];
//        dragArea.backgroundColor = [UIColor clearColor];
//        self.startTimeDrag = dragArea;
//        [self addSubview:self.startTimeDrag];
        
        CGRect endDrag = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height, self.bounds.size.width, tDragAreaHeight);
        UIView *endDragArea = [[UIView alloc]initWithFrame:endDrag];
        endDragArea.backgroundColor = [UIColor greenColor];
        self.endTimeDrag = endDragArea;
        [self addSubview:self.endTimeDrag];
        
        CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height + self.endTimeDrag.bounds.size.height);
        self.frame = newFrame;
        
        NSLog(@"(draw) New tile height is: %f", self.bounds.size.height);
    }
}
- (void)layoutSubviews {
	CGRect myBounds = self.bounds;
		
	CGSize stringSize = [titleLabel.text sizeWithFont:titleLabel.font];
	titleLabel.frame = CGRectMake(6,
								  4,
								  myBounds.size.width - 12,
								  stringSize.height);
	
	if (event.allDayEvent) {
		descriptionLabel.frame = CGRectZero;
	}
	else {
		descriptionLabel.frame = CGRectMake(10,
											titleLabel.frame.size.height + 2,
											myBounds.size.width - 20,
											myBounds.size.height - 14 - titleLabel.frame.size.height);
	}
    
//    [self drawDraggableAreas];
}

#pragma mark touch handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-began state
    [[self nextResponder] touchesBegan:touches withEvent:e];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)e {
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)e {
    
//	UITouch *touch = [touches anyObject];
//	
//	if ([self pointInside:[touch locationInView:self] withEvent:nil]) {
//		[self touchesCancelled:touches withEvent:e];
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:__GCCalendarTileTouchNotification
//															object:self];
//	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-end state
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef, 4);
    CGContextSetStrokeColorWithColor(contextRef, [self.color CGColor]);
    CGContextStrokeRect(contextRef, rect);
}


@end

//
//  UIColor+CalendarPalette.m
//  TimeStamp-Homepage
//
//  Created by Awais Hussain on 6/15/13.
//  Copyright (c) 2013 Awais Hussain. All rights reserved.
//

#import "UIColor+CalendarPalette.h"

@implementation UIColor (CalendarPalette)
+ (UIColor *) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *) prettyColorFromHexString:(NSString *)hexString {
    UIColor *color = [self colorFromHexString:hexString];
    
    float h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h saturation:MIN(s, 0.6) brightness:b alpha:a];
    }
    return nil;
}
- (UIColor *)prettyColor {
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h saturation:MIN(s, 0.6) brightness:b alpha:a];
    }
    return nil;
}

@end

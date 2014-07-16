//
//  DrawView.m
//  quartz2D
//
//  Created by lijian on 14-6-9.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import "DrawView.h"

void *data;

@implementation DrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    CGContextRef myContext = UIGraphicsGetCurrentContext();
//    
//    CGContextSetRGBFillColor(myContext, 1, 0, 0, 1);
//    CGContextFillRect(myContext, CGRectMake(0, 0, 200, 100));
//
//    CGContextSetRGBFillColor(myContext, 0, 0, 1, 0.5);
//    CGContextFillRect(myContext, CGRectMake(0, 0, 100, 200));
}

CGContextRef myCreateBitmapContext(int pixelWidth, int pixelHeight)
{
    CGContextRef contextRef = NULL;
    
    size_t bytesPerRow = pixelWidth * 4;
    
    data = malloc(bytesPerRow * pixelHeight);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
    
    contextRef = CGBitmapContextCreate(data, pixelWidth, pixelHeight, 8, bytesPerRow, space, bitmapInfo);
    
    CGColorSpaceRelease(space);
    
    return contextRef;
}

- (void)drawImage {
    CGRect rect = CGRectMake(0, 0, 300, 300);
    CGContextRef bitmapContext = myCreateBitmapContext(rect.size.width, rect.size.height);
    
    CGContextSetRGBFillColor(bitmapContext, 1, 0, 0, 1);
    CGContextFillRect(bitmapContext, CGRectMake(0, 0, 200, 100));
    
    CGContextSetRGBFillColor(bitmapContext, 0, 0, 1, 0.5);
    CGContextFillRect(bitmapContext, CGRectMake(0, 0, 100, 200));
    
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    
//    [self print];
    
    CGContextRelease(bitmapContext);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    [self addSubview:[[UIImageView alloc] initWithImage:image]];
    
}

- (void)print {
    for (int i = 0 ; i < 300 * 4 * 300; i++) {
        NSLog(@"%f", data + i);
    }
}

@end

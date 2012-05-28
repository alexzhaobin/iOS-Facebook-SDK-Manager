//
//  MultilineTextView.m
//  LocationTrackingGPS2
//
//  Created by Bin Zhao on 26/02/11.
//  Copyright 2011 DBSys. All rights reserved.
//

#import "MultilineTextView.h"


@implementation MultilineTextView

- (void)initialize {
	backgroundLayer = [[MultilineTextViewBackgroundLayer alloc] init];
	backgroundLayer.frame = CGRectMake(0., 0., self.contentSize.width, self.contentSize.height);
	backgroundLayer.lineHeight = self.font.lineHeight;
	backgroundLayer.needsDisplayOnBoundsChange = YES;
	[self.layer insertSublayer:backgroundLayer atIndex:0];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder])) {
        [self initialize];
	}
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
	CGFloat height = self.contentSize.height > self.frame.size.height ? self.contentSize.height : self.frame.size.height;
	backgroundLayer.frame = CGRectMake(0., 0., self.contentSize.width, height);
    backgroundLayer.lineHeight = self.font.lineHeight;
    [backgroundLayer setNeedsDisplay];
}

@end

@implementation MultilineTextViewBackgroundLayer
@synthesize lineHeight;

- (void)drawInContext:(CGContextRef)ctx {
	// Drawing code.
	CGMutablePathRef underscorePath = CGPathCreateMutable();
	CGPathMoveToPoint(underscorePath, NULL, 0., 0.);	
	CGPathAddLineToPoint(underscorePath, NULL, self.bounds.size.width, 0.);
	
	for (CGFloat height = lineHeight + lineHeight * 0.5; height < self.bounds.size.height; height += lineHeight) {
		CGContextSaveGState(ctx);
		CGContextTranslateCTM(ctx, 0., height);
		CGContextAddPath(ctx, underscorePath);
		CGContextSetLineWidth(ctx, 1.0);
		CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.6 alpha:0.5].CGColor);
		CGContextStrokePath(ctx);
		CGContextRestoreGState(ctx);
	}
	
	CFRelease(underscorePath);
}

@end

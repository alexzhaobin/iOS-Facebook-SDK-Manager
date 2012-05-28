//
//  CustomTableViewCell.m
//  HummbeeHunt
//
//  Created by Alex Zhao Bin on 16/01/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import "CustomTableViewCell.h"

#define kDefaultMargin (6.0)

@interface CustomTableViewCellBackgroundView : UIView
{
    BOOL highlighted;
	CustomTableViewCellBackgroundViewPosition position;
}

@property(nonatomic, assign) BOOL highlighted;
@property(nonatomic, assign) CustomTableViewCellBackgroundViewPosition position;

@end

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight)
{
	float fw, fh;
	
	if (ovalWidth == 0 || ovalHeight == 0)
	{// 1
		CGContextAddRect(context, rect);
		return;
	}
	
	CGContextSaveGState(context);// 2
	
	CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
                           CGRectGetMinY(rect));
	CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
	fw = CGRectGetWidth (rect) / ovalWidth;// 5
	fh = CGRectGetHeight (rect) / ovalHeight;// 6
	
	CGContextMoveToPoint(context, fw, fh/2); // 7
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
	CGContextClosePath(context);// 12
	
	CGContextRestoreGState(context);// 13
}

@implementation CustomTableViewCell
@synthesize detailButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        CustomTableViewCellBackgroundView *backgroundView = [[CustomTableViewCellBackgroundView alloc] initWithFrame:CGRectZero];
        backgroundView.highlighted = NO;
		self.backgroundView = backgroundView;
        
        CustomTableViewCellBackgroundView *selectedBackgroundView = [[CustomTableViewCellBackgroundView alloc] initWithFrame:CGRectZero];
        selectedBackgroundView.highlighted = YES;
		self.selectedBackgroundView = selectedBackgroundView;
	}
	return self;
}

- (CustomTableViewCellBackgroundViewPosition)position
{
	return 	((CustomTableViewCellBackgroundView *)self.backgroundView).position;
}

- (void)setPosition:(CustomTableViewCellBackgroundViewPosition)newPosition
{	
	[(CustomTableViewCellBackgroundView *)self.backgroundView setPosition:newPosition];
	[(CustomTableViewCellBackgroundView *)self.selectedBackgroundView setPosition:newPosition];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.textLabel.textColor = [UIColor blackColor];
    }
}

@end


@implementation CustomTableViewCellBackgroundView

@synthesize highlighted;
@synthesize position;

- (BOOL)isOpaque
{
	return NO;
}

-(void)drawRect:(CGRect)aRect
{
	/*BOOL highlighted = ((UITableViewCell *)self.superview).highlighted || ((UITableViewCell *)self.superview).selected;
	if ([self.superview isKindOfClass:[UITableViewCell class]] && ((UITableViewCell *)self.superview).selectionStyle == UITableViewCellSelectionStyleNone)
	{
		highlighted = NO;
	}*/
	CGContextRef c = UIGraphicsGetCurrentContext();	
	
	int lineWidth = 1 * (int) [UIScreen mainScreen].scale;
	
	CGRect rect = [self bounds];	
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	miny -= 1;
	
	CGFloat locations[2] = { 0.0, 1.0 };
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef myGradient = nil;
	CGFloat components[8] = 
    { 
		0.89, 0.89, 0.89, 1.0,
		0.84, 0.84, 0.84, 1.0
    };
	CGFloat componentsHighlighted[8] =
	{
		0.29, 0.29, 0.29, 1.0,
		0.1, 0.1, 0.1, 1.0
	};
	CGContextSetAllowsAntialiasing(c, YES);
	CGContextSetShouldAntialias(c, YES);
	
    CGMutablePathRef path = CGPathCreateMutable();
    
	if (position == CustomTableViewCellBackgroundViewPositionTop)
	{
		miny += 1;
		
		CGPathMoveToPoint(path, NULL, minx, maxy);
		CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
		CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, kDefaultMargin);
		CGPathAddLineToPoint(path, NULL, maxx, maxy);
		CGPathAddLineToPoint(path, NULL, minx, maxy);
		CGPathCloseSubpath(path);
	}
	else if (position == CustomTableViewCellBackgroundViewPositionBottom)
	{
		CGPathMoveToPoint(path, NULL, minx, miny);
		CGPathAddArcToPoint(path, NULL, minx, maxy, midx, maxy, kDefaultMargin);
		CGPathAddArcToPoint(path, NULL, maxx, maxy, maxx, miny, kDefaultMargin);
		CGPathAddLineToPoint(path, NULL, maxx, miny);
		CGPathAddLineToPoint(path, NULL, minx, miny);
		CGPathCloseSubpath(path);
	}
	else if (position == CustomTableViewCellBackgroundViewPositionMiddle)
	{
		CGPathMoveToPoint(path, NULL, minx, miny);
		CGPathAddLineToPoint(path, NULL, maxx, miny);
		CGPathAddLineToPoint(path, NULL, maxx, maxy);
		CGPathAddLineToPoint(path, NULL, minx, maxy);
		CGPathAddLineToPoint(path, NULL, minx, miny);
		CGPathCloseSubpath(path);
	}
	else if (position == CustomTableViewCellBackgroundViewPositionSingle)
	{
		miny += 1;
        
		CGPathMoveToPoint(path, NULL, minx, midy);
		CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
		CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, kDefaultMargin);
		CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, kDefaultMargin);
		CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, kDefaultMargin);
		CGPathCloseSubpath(path);
	}
    
    // Fill and stroke the path
    CGContextSaveGState(c);
    CGContextAddPath(c, path);
    CGContextClip(c);
    
    myGradient = CGGradientCreateWithColorComponents(myColorspace, (highlighted ? componentsHighlighted : components), locations, 2);
    CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
    
    CGContextAddPath(c, path);
    CGPathRelease(path);
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:1.0 alpha:0.5] CGColor]);
	CGContextSetLineWidth(c, lineWidth);
    CGContextStrokePath(c);
    CGContextRestoreGState(c);	
	
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
    
    if (!highlighted && (position == CustomTableViewCellBackgroundViewPositionBottom | position == CustomTableViewCellBackgroundViewPositionMiddle)) {
        CGMutablePathRef headLinePath = CGPathCreateMutable();
		CGPathMoveToPoint(headLinePath, NULL, minx, miny + 1.5);
		CGPathAddLineToPoint(headLinePath, NULL, maxx, miny + 1.5);
        CGContextAddPath(c, headLinePath);
        CGContextSetStrokeColorWithColor(c, [UIColor colorWithWhite:99.0/255.0 alpha:1.0].CGColor);
        CGContextSetLineWidth(c, 0.5);
        CGContextStrokePath(c);
        CGPathRelease(headLinePath);
    }
    
    /*if (!highlighted) {
        CGMutablePathRef bottomLinePath = CGPathCreateMutable();
		CGPathMoveToPoint(bottomLinePath, NULL, minx, maxy - 0.5);
		CGPathAddLineToPoint(bottomLinePath, NULL, maxx, maxy - 0.5);
        CGContextAddPath(c, bottomLinePath);
        CGContextSetStrokeColorWithColor(c, [UIColor colorWithWhite:0.72 alpha:1.0].CGColor);
        CGContextSetLineWidth(c, 0.5);
        CGContextStrokePath(c);
        CGPathRelease(bottomLinePath);
    }*/
    
	return;
}

- (void)setPosition:(CustomTableViewCellBackgroundViewPosition)newPosition
{
	if (position != newPosition)
	{
		position = newPosition;
		[self setNeedsDisplay];
	}
}

@end

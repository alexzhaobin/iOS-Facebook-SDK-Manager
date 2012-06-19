//
//  UIPlaceHolderTextView.m
//  CrownWestend
//
//  Created by Admin on 31/05/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import "UIPlaceHolderTextView.h"

@implementation UIPlaceHolderTextView

@synthesize placeholder;
@synthesize placeholderColor;
@synthesize placeholderLabel;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if(self.text.length == 0)
    {
        [self viewWithTag:999].alpha = 1;
    }
    else 
    {
        [self viewWithTag:999].alpha = 0;
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if(self.placeholder.length > 0)
    {
        if(placeholderLabel == nil)
        {
            placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.bounds.size.width - 16, 0)];
            placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            placeholderLabel.lineBreakMode = UILineBreakModeWordWrap;
            placeholderLabel.numberOfLines = 0;
            placeholderLabel.font = self.font;
            placeholderLabel.backgroundColor = [UIColor clearColor];
            placeholderLabel.textColor = self.placeholderColor;
            placeholderLabel.alpha = 0;
            placeholderLabel.tag = 999;
            [self addSubview:placeholderLabel];
        }
        
        placeholderLabel.text = self.placeholder;
        [placeholderLabel sizeToFit];
        [self sendSubviewToBack:placeholderLabel];
        
        if(self.text.length == 0 && self.placeholder.length > 0)
        {
            [[self viewWithTag:999] setAlpha:1];
        }
        
        [super drawRect:rect];
    }
}

@end

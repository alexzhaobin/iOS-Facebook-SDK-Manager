//
//  UIPlaceHolderTextView.h
//  CrownWestend
//
//  Created by Admin on 31/05/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
    
    @private
    UILabel *placeholderLabel;
}

@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end

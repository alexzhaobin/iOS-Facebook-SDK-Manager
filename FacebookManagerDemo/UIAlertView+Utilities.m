//
//  UIAlertView+Utilities.m
//  HummbeeHunt
//
//  Created by Alex Zhao Bin on 17/01/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import "UIAlertView+Utilities.h"

@implementation UIAlertView(Utilities)

+ (void)showAlert:(NSString *)text
{
	[self showAlert:text title:@""];
}

+ (void)showAlert:(NSString *)text title:(NSString *)title
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
	[alert show];
}

@end

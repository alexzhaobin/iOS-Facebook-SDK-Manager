//
//  AppDelegate.h
//  FacebookManagerDemo
//
//  Created by Alex Zhao Bin on 29/05/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, readonly) NSString *imagesCacheDirectory;

@end

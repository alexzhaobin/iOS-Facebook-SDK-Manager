//
//  PrizeImageLoader.h
//  HummbeeHunt
//
//  Created by Alex Zhao Bin on 17/01/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemWideImageLoader : NSObject

+ (void)loadImageForFacebookObject:(NSString *)facebookObjectId withCompletionHandler:(void (^)(UIImage *prizeImage))completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;

@end

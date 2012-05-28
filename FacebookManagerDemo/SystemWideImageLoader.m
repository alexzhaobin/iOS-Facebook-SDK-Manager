//
//  PrizeImageLoader.m
//  HummbeeHunt
//
//  Created by Alex Zhao Bin on 17/01/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#import "SystemWideImageLoader.h"
#import "AppDelegate.h"
#import "FacebookManager.h"

@implementation SystemWideImageLoader

static NSMutableArray *facebookObjectIds = nil;
//static NSMutableArray *imageCacheArray = nil;
//static NSMutableDictionary *imageCacheDictionary = nil;

+ (void)loadImageForFacebookObject:(NSString *)facebookObjectId withCompletionHandler:(void (^)(UIImage *facebookImage))completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    // To avoid loading same image simutaneously 
    if (!facebookObjectIds) {
        facebookObjectIds = [[NSMutableArray alloc] init];
    }
    // In memory cache to improve performance further
    /*if (!imageCacheArray) {
        imageCacheArray = [[NSMutableArray alloc] init];
    }
    if (!imageCacheDictionary) {
        imageCacheDictionary = [[NSMutableDictionary alloc] init];
    }*/
    
    if (facebookObjectId) {
        /*if ([imageCacheDictionary objectForKey:facebookObjectId]) {
            completionHandler([imageCacheDictionary objectForKey:facebookObjectId]);
            return;
        }
        
        @synchronized (imageCacheDictionary) {
            if (imageCacheArray.count > 12) {
                id firstFacebookId = [imageCacheArray objectAtIndex:0];
                [imageCacheDictionary removeObjectForKey:firstFacebookId];
                [imageCacheArray removeObject:firstFacebookId];
            }
        }*/
        
        if ([facebookObjectIds indexOfObject:facebookObjectId] == NSNotFound) {
            [facebookObjectIds addObject:facebookObjectId];
            
            AppDelegate *_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:_appDelegate.imagesCacheDirectory]) {
                if(![[NSFileManager defaultManager] createDirectoryAtPath:_appDelegate.imagesCacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL]) {
                    return;
                }
            }
            
            NSString *imageFilePath = [_appDelegate.imagesCacheDirectory stringByAppendingPathComponent:facebookObjectId];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
                
                [FacebookManager pictureForObject:facebookObjectId withCompletionHandler:^(NSData *resultData) {
                    
                    if (![[NSFileManager defaultManager] createFileAtPath:imageFilePath contents:resultData attributes:nil]) {
                        NSLog(@"Image Write Operation Failed");
                        failureHandler(nil);
                    }
                    
                    UIImage *facebookImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFilePath]];
                    //[imageCacheArray addObject:facebookObjectId];
                    //[imageCacheDictionary setObject:facebookImage forKey:facebookObjectId];
                    [facebookObjectIds removeObject:facebookObjectId];
                    completionHandler(facebookImage);
                    
                }];
                
            } else {
                UIImage *facebookImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFilePath]];
                //[imageCacheArray addObject:facebookObjectId];
                //[imageCacheDictionary setObject:facebookImage forKey:facebookObjectId];
                [facebookObjectIds removeObject:facebookObjectId];
                completionHandler(facebookImage);
            }
        }
    }
}

@end

//
//  FacebookManager.h
//  LocationTrackingGPS2
//
//  Created by Bin Zhao on 7/03/11.
//  Copyright 2011 DBSys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FBConnect.h"

typedef enum {
    FacebookCallBackModeJSON = 0,
    FacebookCallBackModeRawData = 1
} FacebookCallBackMode;

typedef void (^FacebookCallBack)(id results);

@interface FacebookManager : NSObject<FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {

}

+ (BOOL)handleOpenURL:(NSURL *)url;
+ (void)postToWallUseFacebookInterface:(NSMutableDictionary *)parameters;
+ (void)login;
+ (void)logout;
+ (BOOL)isSessionValid;

// Graph API
+ (void)friends:(FacebookCallBack)completionHandler;
+ (void)searchPlaceById:(NSString *)placeId withCompletionHandler:(FacebookCallBack)completionHandler;
+ (void)pictureForObject:(NSString *)objectId withCompletionHandler:(FacebookCallBack)completionHandler;
+ (void)searchPlaceByCoordinate:(CLLocationCoordinate2D)coordinate withCompletionHandler:(FacebookCallBack)completionHandler;
+ (void)checkInToPlace:(NSString *)placeId atCoordinate:(CLLocationCoordinate2D)coordinate message:(NSString *)message photoURL:(NSString *)photoURL withCompletionHandler:(FacebookCallBack)completionHandler;
+ (void)uploadPhoto:(UIImage *)photo message:(NSString *)message withCompletionHandler:(FacebookCallBack)completionHandler;

@end

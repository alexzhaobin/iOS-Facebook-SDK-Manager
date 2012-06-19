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

#define NOTIFICATION_FACEBOOK_SIGNED_IN @"FacebookSignedIn"

typedef enum {
    FacebookCallBackModeJSON = 0,
    FacebookCallBackModeRawData = 1
} FacebookCallBackMode;

typedef void (^FacebookCallBack)(id results);
typedef void (^FacebookFailHandler)(NSError *error);

@interface FacebookManager : NSObject<FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {

}

+ (BOOL)handleOpenURL:(NSURL *)url;
+ (void)postToWallUseFacebookInterface:(NSMutableDictionary *)parameters;
+ (void)login;
+ (void)logout;
+ (BOOL)isSessionValid;

// Graph API
+ (void)me:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)friends:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)postToWall:(NSString *)message link:(NSString *)link picture:(NSString *)picture withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)searchPlaceById:(NSString *)placeId withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)pictureForObject:(NSString *)objectId withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)searchPlaceByCoordinate:(CLLocationCoordinate2D)coordinate withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)checkInToPlace:(NSString *)placeId atCoordinate:(CLLocationCoordinate2D)coordinate message:(NSString *)message photoURL:(NSString *)photoURL withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;
+ (void)uploadPhoto:(UIImage *)photo message:(NSString *)message withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler;

@end

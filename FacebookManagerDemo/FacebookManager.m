//
//  FacebookManager.m
//  LocationTrackingGPS2
//
//  Created by Bin Zhao on 7/03/11.
//  Copyright 2011 DBSys. All rights reserved.
//

#import "FacebookManager.h"
#import "AppDelegate.h"
#import "JSON.h"

@interface FacebookManager () {
    
}

@property (retain, nonatomic) NSMutableArray *activeRequests;

+ (FacebookManager *)sharedManager;
+ (Facebook *)facebook;

@end

@interface FBRequestHelper : NSObject

@property (retain, nonatomic) NSString *path;
@property (assign, nonatomic) FacebookCallBackMode callBackMode;
@property (retain, nonatomic) NSMutableDictionary *params;
@property (copy, nonatomic) FacebookCallBack callbackBlock;
@property (copy, nonatomic) FacebookFailHandler errorBlock;
@property (assign, nonatomic) NSString *httpMethod;
@property (assign, nonatomic) BOOL requestSent;
@property (retain, nonatomic) FBRequest *request;

- (void)sendRequest;

@end

@implementation FBRequestHelper
@synthesize path;
@synthesize callBackMode;
@synthesize params;
@synthesize callbackBlock;
@synthesize errorBlock;
@synthesize httpMethod;
@synthesize requestSent;
@synthesize request;

- (id)init {
    if ((self = [super init])) {
        // Initialization code
        requestSent = NO;
    }
    return self;
}

- (void)sendRequest {
    if (!requestSent) {
#if DEBUG
        NSLog(@"Facebook Graph API Path: %@", self.path);
        if (params) {
            NSLog(@"Using Parameters: %@", self.params);
        }
#endif
        
        if (params) {
            self.request = [[FacebookManager facebook] requestWithGraphPath:self.path andParams:self.params andHttpMethod:self.httpMethod andDelegate:[FacebookManager sharedManager]];
        } else {
            self.request = [[FacebookManager facebook] requestWithGraphPath:self.path andDelegate:[FacebookManager sharedManager]];
        }
    }
    requestSent = YES;
}

@end

@implementation FacebookManager
@synthesize activeRequests;

- (id)init {
    if ((self = [super init])) {
        // Initialization code
        self.activeRequests = [NSMutableArray array];
    }
    return self;
}

+ (FacebookManager *)sharedManager {
    static FacebookManager *facebookManager = nil;
    if (facebookManager == nil) {
        facebookManager = [[FacebookManager alloc] init];
    }
    return facebookManager;
}

// The actual facebook object
+ (Facebook *)facebook {
	static Facebook *facebook = nil;
	if (facebook == nil) {
		facebook = [[Facebook alloc] initWithAppId:@"269620349802751" andDelegate:[FacebookManager sharedManager]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
	}
	return facebook;
}

#pragma -
#pragma FBSessionDelegate Delegate Methods

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[FacebookManager facebook] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[FacebookManager facebook] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    [UIAlertView showAlert:@"Unable to login to facebook"];
}

- (void)fbDidLogout {
    //[UIAlertView showAlert:@"Your facebook session is ended"];
    NSLog(@"Facebook session is ended");
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    
}

- (void)fbSessionInvalidated {
    
}

#pragma -
#pragma FBDialogDelegate Delegate Methods

- (void)dialogDidComplete:(FBDialog *)dialog {
    
}

- (void) dialogDidNotComplete:(FBDialog *)dialog {
    
}

- (void)dialogCompleteWithUrl:(NSURL *)url {
    
}

- (void) dialogDidNotCompleteWithUrl:(NSURL *)url {
    
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
    return NO;
}

#pragma -
#pragma Facebook Login/out Methods
/**
 * Show the authorization dialog.
 */
+ (void)login {
	[[FacebookManager facebook] authorize:[NSArray arrayWithObjects:
                                           @"user_checkins", //read the user's checkins.
                                           @"friends_checkins", //read the user's friend's checkins.
                                           @"publish_checkins", //publish checkin on user's behavior
                                           @"publish_stream", // post to wall
                                           @"user_photos", // upload photo
                                           @"user_likes", // Create like
                                           @"read_stream", // Read post I guess
                                           @"email", // yes, email
                                           nil]];
}

/**
 * Invalidate the access token and clear the cookie.
 */
+ (void)logout {
	[[FacebookManager facebook] logout:[FacebookManager sharedManager]];
}

+ (BOOL)isSessionValid {
    return [[FacebookManager facebook] isSessionValid];
}

#pragma -
#pragma Actual API Calls
// The actual class send request
+ (void)sendGraphAPIRequest:(NSString *)path params:(NSMutableDictionary *)params mode:(FacebookCallBackMode)callbackMode httpMethod:(NSString *)httpMethod withCompletionBlock:(FacebookCallBack)completionHandler  withFailureHandler:(void (^)(NSError *error))failureHandler {
    FBRequestHelper *requestHelper = [[FBRequestHelper alloc] init];
    requestHelper.path = path;
    requestHelper.params = params;
    requestHelper.callbackBlock = completionHandler;
    requestHelper.errorBlock = failureHandler;
    requestHelper.callBackMode = callbackMode;
    requestHelper.httpMethod = httpMethod;
    [[FacebookManager sharedManager].activeRequests addObject:requestHelper];
    
    if(![[FacebookManager facebook] isSessionValid])
    {
        [FacebookManager login];
        return;
    } else {
        [requestHelper sendRequest];
    }
}

+ (void)searchPlaceById:(NSString *)placeId withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    [FacebookManager sendGraphAPIRequest:placeId params:nil mode:FacebookCallBackModeJSON httpMethod:@"GET" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

+ (void)me:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    [FacebookManager sendGraphAPIRequest:@"me" params:nil mode:FacebookCallBackModeJSON httpMethod:@"GET" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

+ (void)friends:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    [FacebookManager sendGraphAPIRequest:@"me/friends" params:nil mode:FacebookCallBackModeJSON httpMethod:@"GET" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

+ (void)postToWall:(NSString *)message link:(NSString *)link picture:(NSString *)picture withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (message) {
        [params setObject:message forKey:@"message"];
    }
    if (link) {
        [params setObject:link forKey:@"link"];
    }
    if (picture) {
        [params setObject:picture forKey:@"picture"];
    }
    [FacebookManager sendGraphAPIRequest:@"me/feed" params:params mode:FacebookCallBackModeJSON httpMethod:@"POST" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

+ (void)pictureForObject:(NSString *)objectId withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    [FacebookManager sendGraphAPIRequest:[NSString stringWithFormat:@"%@/picture", objectId] params:nil mode:FacebookCallBackModeRawData httpMethod:@"GET" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

+ (void)searchPlaceByCoordinate:(CLLocationCoordinate2D)coordinate withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"place", @"type",
                                   [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude], @"center",
                                   @"300", @"distance",
                                   nil];
    [FacebookManager sendGraphAPIRequest:@"search" params:params mode:FacebookCallBackModeJSON httpMethod:@"GET" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

#define kMinimumNoticeableFloatValue (0.000000001)
+ (void)checkInToPlace:(NSString *)placeId atCoordinate:(CLLocationCoordinate2D)coordinate message:(NSString *)message photoURL:(NSString *)photoURL withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    if (fabs(coordinate.latitude) > kMinimumNoticeableFloatValue && fabs(coordinate.longitude) > kMinimumNoticeableFloatValue) {
        SBJSON *jsonWriter = [SBJSON new];
        NSMutableDictionary *coordinatesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%f", coordinate.latitude], @"latitude",
                                                      [NSString stringWithFormat:@"%f", coordinate.longitude], @"longitude",
                                                      nil];
        NSString *coordinates = [jsonWriter stringWithObject:coordinatesDictionary];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       placeId, @"place",
                                       coordinates, @"coordinates",
                                       nil];
        if (message) {
            [params setObject:message forKey:@"message"];
        }
        if (photoURL) {
            [params setObject:photoURL forKey:@"picture"];
        }
        [FacebookManager sendGraphAPIRequest:@"me/checkins" params:params mode:FacebookCallBackModeJSON httpMethod:@"POST" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
    } else {
        [UIAlertView showAlert:@"Invalid current location" title:@"Unable to check in"];
    }
}

+ (void)uploadPhoto:(UIImage *)photo message:(NSString *)message withCompletionHandler:(FacebookCallBack)completionHandler withFailureHandler:(void (^)(NSError *error))failureHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   photo, @"source",
                                   message, @"message", 
                                   nil];
    [FacebookManager sendGraphAPIRequest:@"me/photos" params:params mode:FacebookCallBackModeJSON httpMethod:@"POST" withCompletionBlock:completionHandler withFailureHandler:failureHandler];
}

#pragma -
#pragma FBRequestDelegate Delegate Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
#if DEBUG
    NSLog(@"Facebook Response: %@", result);
#endif
    FBRequestHelper *matchedRequestHelper = nil;
    for (FBRequestHelper *requestHelper in [FacebookManager sharedManager].activeRequests) {
        if (requestHelper.request == request) {
            matchedRequestHelper = requestHelper;
        }
    }
    if (matchedRequestHelper && matchedRequestHelper.callBackMode == FacebookCallBackModeJSON) {
        matchedRequestHelper.callbackBlock(result);
        [[FacebookManager sharedManager].activeRequests removeObject:matchedRequestHelper];
    }
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    FBRequestHelper *matchedRequestHelper = nil;
    for (FBRequestHelper *requestHelper in [FacebookManager sharedManager].activeRequests) {
        if (requestHelper.request == request) {
            matchedRequestHelper = requestHelper;
        }
    }
    if (matchedRequestHelper && matchedRequestHelper.callBackMode == FacebookCallBackModeRawData) {
        matchedRequestHelper.callbackBlock(data);
        [[FacebookManager sharedManager].activeRequests removeObject:matchedRequestHelper];
    }
}

- (void)requestLoading:(FBRequest *)request {
    
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    FBRequestHelper *matchedRequestHelper = nil;
    for (FBRequestHelper *requestHelper in [FacebookManager sharedManager].activeRequests) {
        if (requestHelper.request == request) {
            matchedRequestHelper = requestHelper;
        }
    }
    if (matchedRequestHelper) {
        matchedRequestHelper.errorBlock(error);
        [[FacebookManager sharedManager].activeRequests removeObject:matchedRequestHelper];
    }
    
#if DEBUG
    NSLog(@"Facebook Request Failed: %@ %@ %@ %@", [request url], [error description], [error localizedDescription], [error localizedFailureReason]);
#endif
    
    if (error) {
        NSDictionary *userInfo = [error userInfo];
        if (userInfo && [userInfo objectForKey:@"error"]) {
            NSDictionary *errorDict = [userInfo objectForKey:@"error"];
            if (userInfo && [errorDict objectForKey:@"message"]) {
                [UIAlertView showAlert:[NSString stringWithFormat:@"Facebook: %@", [errorDict objectForKey:@"message"]]];
            }
        }
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url {
	BOOL returnValue = [[FacebookManager facebook] handleOpenURL:url];
    
    //Perform the original action of the user before they were thrown out (if they authorised us)
    if (returnValue) {
        for (FBRequestHelper *requestHelper in [FacebookManager sharedManager].activeRequests) {
            if (!requestHelper.requestSent) {
                [requestHelper sendRequest];
            }
        }
    }
    
    return returnValue;
}

+ (void)postToWallUseFacebookInterface:(NSMutableDictionary *)parameters {
    [[FacebookManager facebook] dialog:@"feed" andParams:parameters andDelegate:[FacebookManager sharedManager]];
}

@end

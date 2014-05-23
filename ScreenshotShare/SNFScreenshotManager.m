//
//  SNFScreenshotManager.m
//  ScreenshotShare
//
//  Created by Seth Friedman on 5/22/14.
//  Copyright (c) 2014 Seth Friedman. All rights reserved.
//

#import "SNFScreenshotManager.h"

@import AssetsLibrary;

@interface SNFScreenshotManager () <UIAlertViewDelegate>

@end

@implementation SNFScreenshotManager

#pragma mark - Designated Initializer

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(askForPhotosPermission)Sha
                                                     name:UIApplicationUserDidTakeScreenshotNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static SNFScreenshotManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SNFScreenshotManager alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - Custom Getter

- (NSString *)photosPermissionMessage {
    if (!_photosPermissionMessage) {
        NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
        
        _photosPermissionMessage = [NSString stringWithFormat:@"%@ allows you to quickly do things with your screenshots, like message them to a friend. To allow this, please give the app permission to access your photos when the next alert pops up.", appName];
    }
    
    return _photosPermissionMessage;
}

- (void)latestPhotoWithCompletionBlock:(void (^)(UIImage *photo))completionBlock {
    UIImage * __block latestPhoto;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                               
                               [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
                                                          if (result) {
                                                              CGImageRef fullResolutionImageRef = [[result defaultRepresentation] fullResolutionImage];
                                                              latestPhoto = [UIImage imageWithCGImage:fullResolutionImageRef];
                                                              
                                                              *innerStop = YES;
                                                              *stop = YES;
                                                              
                                                              completionBlock(latestPhoto);
                                                          }
                                                      }];
                           } failureBlock:^(NSError *error) {
                               NSLog([error description]);
                           }];
}

- (void)askForPhotosPermission {
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    
    if (self.enabled) {
        if (authorizationStatus != ALAuthorizationStatusDenied && authorizationStatus != ALAuthorizationStatusRestricted) {
            if (authorizationStatus == ALAuthorizationStatusNotDetermined) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Needed"
                                                                    message:self.photosPermissionMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                
                alertView.delegate = self;
                
                [alertView show];
            }
        }
    }
}

- (void)displayActivityViewController {
    [self latestPhotoWithCompletionBlock:^(UIImage *photo) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[photo]
                                                                                             applicationActivities:nil];
        
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = currentWindow.rootViewController;
        
        UIViewController *visibleViewController;
        
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            visibleViewController = ((UINavigationController *)rootViewController).visibleViewController;
        } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
            visibleViewController = ((UITabBarController *)rootViewController).selectedViewController;
        } else {
            visibleViewController = rootViewController;
        }
        
        [visibleViewController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
    }];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self displayActivityViewController];
}

@end

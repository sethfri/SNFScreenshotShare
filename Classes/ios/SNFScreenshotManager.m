//
//  SNFScreenshotManager.m
//  ScreenshotShare
//
//  Created by Seth Friedman on 5/22/14.
//  Copyright (c) 2014 Seth Friedman. All rights reserved.
//

#import "SNFScreenshotManager.h"

@import AssetsLibrary;

@interface SNFScreenshotManager () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) UIViewController *visibleViewController;

@end

@implementation SNFScreenshotManager

#pragma mark - Designated Initializer

- (id)init {
    self = [super init];
    
    if (self) {
        _enabled = NO;
    }
    
    return self;
}

- (void)dealloc {
    if (self.enabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static SNFScreenshotManager *_sharedManager;
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

- (NSArray *)excludedActivityTypes {
    if (!_excludedActivityTypes) {
        _excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
    }
    
    return _excludedActivityTypes;
}

#pragma mark - Custom Setter

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        
        if (_enabled) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(displayActionSheet)
                                                         name:UIApplicationUserDidTakeScreenshotNotification
                                                       object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
}

#pragma mark - Instance Methods

/**
 *  Displays a `UIActionSheet` in the `visibleViewController` that gives the user
 *  the option to share the screenshot that they just took.
 */
- (void)displayActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Screenshot"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Share", nil];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = currentWindow.rootViewController;
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        self.visibleViewController = ((UINavigationController *)rootViewController).visibleViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        self.visibleViewController = ((UITabBarController *)rootViewController).selectedViewController;
    } else {
        self.visibleViewController = rootViewController;
    }
    
    [actionSheet showInView:self.visibleViewController.view];
}

/**
 *  Calls `shareScreenshot` if the user has given permission to access the
 *  Camera Roll. If the user has not yet been asked for permission, the user is
 *  prompted for permission using Cluster's method. The method is a no-op if the
 *  user has denied or restricted permission.
 */
- (void)shareScreenshotIfPermitted {
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    
    if (authorizationStatus != ALAuthorizationStatusDenied && authorizationStatus != ALAuthorizationStatusRestricted) {
        // Check if the user has been asked for permission yet
        if (authorizationStatus == ALAuthorizationStatusNotDetermined) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Needed"
                                                                message:self.photosPermissionMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            alertView.delegate = self;
            
            [alertView show];
        } else {
            [self shareScreenshot];
        }
    }
}

/**
 *  Fetches the screenshot just taken and displays a `UIActivityViewController`
 *  for the user to do something with that screenshot.
 */
- (void)shareScreenshot {
    [self latestPhotoWithCompletionBlock:^(UIImage *photo, NSError *error) {
        if (photo) {
            [self displayActivityViewControllerInViewController:self.visibleViewController
                                              withActivityItems:@[photo]];
        } else {
            NSLog(@"Photo Error: %@", [error description]);
        }
    }];
}

/**
 *  Fetches, at full resolution, the latest photo taken on the device.
 *
 *  @param completionBlock The block to be executed upon fetching the `UIImage`
 *                         object, with an `NSError` if necessary.
 */
- (void)latestPhotoWithCompletionBlock:(void (^)(UIImage *photo, NSError *error))completionBlock {
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
                                                              
                                                              completionBlock(latestPhoto, nil);
                                                          }
                                                      }];
                           } failureBlock:^(NSError *error) {
                               completionBlock(nil, error);
                           }];
}

/**
 *  Creates and presents a simple `UIActivityViewController` using
 *  `applicationActivities` and `excludedActivityTypes`.
 *
 *  @param viewController The view controller that should present the
 *                        `UIAcitivityViewController`.
 *  @param activityItems  The array of data objects on which to perform the
 *                        activity. See the `UIActivityViewController`
 *                        documentation for more information.
 */
- (void)displayActivityViewControllerInViewController:(UIViewController *)viewController withActivityItems:(NSArray *)activityItems {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:self.applicationActivities];
    activityViewController.excludedActivityTypes = self.excludedActivityTypes;
    
    [viewController presentViewController:activityViewController
                                 animated:YES
                               completion:nil];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self shareScreenshot];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // Share
            [self shareScreenshotIfPermitted];
            break;
            
        default: // Cancel
            break;
    }
}

@end

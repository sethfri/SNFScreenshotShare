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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(displayActionSheet)
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
                               NSLog(@"Photo Error: %@", [error description]);
                           }];
}

- (void)askForPhotosPermission {
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    
    if (self.enabled) {
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
                [self displayActivityViewControllerInViewController:self.visibleViewController];
            }
        }
    }
}

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

- (void)displayActivityViewControllerInViewController:(UIViewController *)viewController {
    [self latestPhotoWithCompletionBlock:^(UIImage *photo) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[photo]
                                                                                             applicationActivities:self.applicationActivities];
        activityViewController.excludedActivityTypes = self.excludedActivityTypes;
        
        [viewController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
    }];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self displayActivityViewControllerInViewController:self.visibleViewController];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // Share
            [self askForPhotosPermission];
            break;
            
        default: // Cancel
            break;
    }
}

@end

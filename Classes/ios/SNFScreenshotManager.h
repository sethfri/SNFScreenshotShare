//
//  SNFScreenshotManager.h
//  ScreenshotShare
//
//  Created by Seth Friedman on 5/22/14.
//  Copyright (c) 2014 Seth Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  `SNFScreenshotManager` keeps track of when a user takes a screenshot of the
 *  current application. When enabled, it will listen for notifications
 *  indicating that a user has taken a screenshot, and then display a
 *  `UIActivityViewController` so that the user can do something with their
 *  screenshot. The manager also takes care of asking the user for permission to
 *  access their photos, using Cluster's method: https://medium.com/on-startups/96fa4eb54f2c
 *
 *  You should enable the shared instance of `SNFScreenshotManager` when your
 *  application finishes launching. In
 *  `AppDelegate application:didFinishLaunchingWithOptions:` you can do so with
 *  the following code:
 *
 *      `[[SNFScreenshotManager sharedManager].enabled = YES;`
 */
@interface SNFScreenshotManager : NSObject

/**
 *  A Boolean value indicating whether the manager is enabled.
 *
 *  If `YES`, the manager will register for screenshot notifications and prompt
 *  the user to share their screenshots when the notifications are received. The
 *  default value is `NO`.
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

/**
 *  The message that the manager will display when explaining to the user why it
 *  needs access to their photos.
 *
 *  The default text is "[APP NAME] allows you to quickly do things with your
 *  screenshots, like message them to a friend. To allow this, please give the
 *  app permission to access your photos when the next alert pops up."
 *
 *  The app name comes from the `CFBundleName` value in the app's Info.plist.
 */
@property (nonatomic, copy) NSString *photosPermissionMessage;

/**
 *  The list of services that should not be displayed in the
 *  `UIActivityViewController`.
 *
 *  By default, `UIActivityTypeSaveToCameraRoll` is the only excluded type, as
 *  the screenshot is already saved to the camera roll when the user takes it. It
 *  is recommended that you keep this type excluded to avoid confusing the user.
 *
 *  For more information on the types of services that can be excluded, refer to
 *  the `UIActivity` documentation.
 */
@property (nonatomic, copy) NSArray *excludedActivityTypes;

/**
 *  An array of `UIActivity` objects representing the custom services that your
 *  application supports.
 *
 *  The default value is `nil`. For more information, refer to the
 *  `UIActivityViewController` documentation.
 */
@property (nonatomic, copy) NSArray *applicationActivities;

/**
 *  Returns the shared screenshot manager object for the app.
 *
 *  @return The shared screenshot manager.
 */
+ (instancetype)sharedManager;

@end

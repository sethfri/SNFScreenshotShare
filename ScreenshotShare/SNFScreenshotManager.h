//
//  SNFScreenshotManager.h
//  ScreenshotShare
//
//  Created by Seth Friedman on 5/22/14.
//  Copyright (c) 2014 Seth Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFScreenshotManager : NSObject

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) NSString *photosPermissionMessage;

+ (instancetype)sharedManager;

@end

SNFScreenshotShare
==================

[![Version](http://cocoapod-badges.herokuapp.com/v/SNFScreenshotShare/badge.png)](http://cocoadocs.org/docsets/SNFScreenshotShare)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SNFScreenshotShare/badge.png)](http://cocoadocs.org/docsets/SNFScreenshotShare)

A small iOS library for helping users do things with their screenshots.

## Usage

SNFScreenshotShare is very simple to incorporate into your existing project. In your app delegate's `application:didFinishLaunchingWithOptions:`, just add one line:

```objc
[SNFScreenshotManager sharedManager].enabled = YES;
```

The library will then manage all of your users' screenshotsfor you.

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

SNFScreenshotShare requires iOS 7.0 and above, and it requires ARC.

## Installation

SNFScreenshotShare is available through [CocoaPods](http://cocoapods.org). To install
it simply add the following line to your Podfile:

    pod "SNFScreenshotShare"

## Author

Seth Friedman, sethfri@gmail.com

## License

SNFScreenshotShare is available under the MIT license. See the LICENSE file for more info.


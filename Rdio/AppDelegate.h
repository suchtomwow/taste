//
//  AppDelegate.h
//  Taste
//
//  Created by Thomas Carey on 2/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, RdioDelegate>
{
    Rdio * rdio;
}


@property (readonly) Rdio *rdio;
@property (strong, nonatomic) UIWindow *window;

+ (Rdio*)rdioInstance;

@end

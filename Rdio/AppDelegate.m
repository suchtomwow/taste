//
//  AppDelegate.m
//  Taste
//
//  Created by Thomas Carey on 2/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "MWFSlideNavigationViewController.h"
#import "DeveloperCredentials.h"
#import "LastFm.h"

@implementation AppDelegate

@synthesize rdio;

+ (Rdio*)rdioInstance {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] rdio];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Initialize global rdio object with key and secret
    NSString *developerKey = RDIO_KEY;
    NSString *developerSecret = RDIO_SECRET;
    
    /**
     * Create an instance of the Rdio class with our Rdio API key and secret.
     */  
    rdio = [[Rdio alloc] initWithConsumerKey:developerKey andSecret:developerSecret delegate:nil];
    
    // Setup LastFm class
    [LastFm sharedInstance].apiKey = LASTFM_KEY;
    [LastFm sharedInstance].apiSecret = LASTFM_SECRET;
    
    
//    UIViewController *mainCtl;
//        
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        if( [[Settings settings] userKey] == nil ) {
//            mainCtl = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPhone" bundle:nil];
//        }
//        else {
////            mainCtl = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
////            self.viewController = mainCtl;
//        }
//    } else {
//        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
//    }

//    MWFSlideNavigationViewController *slideCtl = [[MWFSlideNavigationViewController alloc] initWithRootViewController:mainCtl];
//    
//    
//    self.window.rootViewController = slideCtl;
    
        [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

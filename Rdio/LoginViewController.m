//
//  LoginViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "LoginViewController.h"
#import "Settings.h"
#import "SeedViewController.h"
#import "NotUnlimitedViewController.h"

//@interface LoginViewController ()
//
//@end

@implementation LoginViewController

@synthesize accessToken = _accessToken;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    [[self navigationController] setNavigationBarHidden:YES]; 
    
    /**
     * Make sure we are sent delegate messages.
     */
    Rdio *rdio = [AppDelegate rdioInstance];
    [rdio setDelegate:self];  
}

- (void)viewWillAppear:(BOOL)animated {
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;

}

-(void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPress:(id)sender {
    [self presentLoginModal];
}

- (void)presentLoginModal {
    [[AppDelegate rdioInstance] authorizeFromController:self];
}


#pragma mark - RdioDelegate
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    
    [[Settings settings] setAccessToken:accessToken];

    if( [[Settings settings] user] ) {
        [self performSegueWithIdentifier:@"LoginToSeedSegue" sender:nil];
    } else {
        self.accessToken = accessToken;
    
        NSDictionary *params = @{@"keys": user[@"key"], @"extras": @"isUnlimited"};
        [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:params delegate:self];    
    }
}

/**
 * Authentication failed so we should alert the user.
 */
- (void)rdioAuthorizationFailed:(NSString *)message {
    NSLog(@"Rdio authorization failed: %@", message);
}

- (void)rdioAuthorizationCancelled {
    
}

-(void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    NSDictionary *user = [data allObjects][0];
    
    BOOL isUnlimited = [user[@"isUnlimited"] boolValue];
    
    if( (BOOL)isUnlimited ) { 
        
        [[Settings settings] setUser:[NSString stringWithFormat:@"%@ %@", [user valueForKey:@"firstName"], [user valueForKey:@"lastName"]]];
        [[Settings settings] setUserKey:user[@"key"]];
        [[Settings settings] setAccessToken:self.accessToken];
        [[Settings settings] setIcon:user[@"icon"]];

        [[Settings settings] save];
        
        [self performSegueWithIdentifier:@"LoginToSeedSegue" sender:nil];
    }
    else {
        // Load the "Unlimited Account Necessary" view controller
        
        [[Settings settings] reset];
        [[Settings settings] save];
        [self performSegueWithIdentifier:@"LoginToNotUnlimitedSegue" sender:nil];
    }
}
-(void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error {
}

@end

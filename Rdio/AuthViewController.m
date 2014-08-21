//
//  AuthViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/23/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "AuthViewController.h"
#import "Settings.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

@synthesize indicator;
@synthesize label;

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
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [label setHidden:YES];
    [indicator setHidden:YES];
    [indicator setHidesWhenStopped:YES];
    
    /**
     * Make sure we are sent delegate messages.
     */
    Rdio *rdio = [AppDelegate rdioInstance];
    [rdio setDelegate:self];  
    
    NSString *accessToken = [[Settings settings] accessToken];
    if( accessToken ) {
        
        [indicator setHidden:NO];
        [label setHidden:NO];
        [indicator startAnimating];
        
        [rdio authorizeUsingAccessToken:[[Settings settings] accessToken] fromController:self];
    }
    else {
        [self performSegueWithIdentifier:@"AuthToLoginSegue" sender:nil];
    }
}

-(void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    
    [indicator stopAnimating];
    
    [self performSegueWithIdentifier:@"AuthToSeedSegue" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  LoginViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController <RdioDelegate, RDAPIRequestDelegate>

@property (strong, nonatomic) NSString * accessToken;
- (IBAction)loginPress:(id)sender;
- (void)presentLoginModal;
@end

//
//  AuthViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/23/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface AuthViewController : UIViewController <RdioDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

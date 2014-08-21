//
//  NotUnlimitedViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/23/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "NotUnlimitedViewController.h"

@interface NotUnlimitedViewController ()

@end

@implementation NotUnlimitedViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continuePress:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end

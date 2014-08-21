//
//  MWFRootViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "MWFViewController.h"
#import "ViewController.h"

@implementation MWFViewController

@synthesize viewCtl = _viewCtl;

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
    [self setRootViewController:self.viewCtl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

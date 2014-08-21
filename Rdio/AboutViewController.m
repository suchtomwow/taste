//
//  AboutViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/29/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

@synthesize label;
@synthesize label2;
@synthesize label3;

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
    // Do any additional setup after loading the view from its nib.
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label3.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *string = @"Taste uses the Last.fm and Rdio API to pull down fresh content based on 'Liked' songs. It uses Last.fm to find the music, and Rdio® to play it.";
    NSString *string2 = @"Taste was developed by Thomas Carey as a senior capstone project at Washburn University.";
    NSString *string3 = @"This product uses the Rdio API but is not endorsed, certified or otherwise approved in any way by Rdio®.";

    label.text = string;
    label2.text = string2;
    label3.text = string3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  iPhoneMenuViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/29/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "iPhoneMenuViewController.h"
#import "TastesViewController.h"
#import "ViewController.h"
#import "Settings.h"
#import "SeedViewController.h"
#import "AboutViewController.h"

@interface iPhoneMenuViewController ()

@end

@implementation iPhoneMenuViewController

@synthesize table;

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
    self.items = [[NSMutableArray alloc] initWithObjects:@"Change Seed", @"Tastes", @"About", @"Logout", nil];    
    [table reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self items][indexPath.row];    
    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        
        // Stop playing music
        [self.viewCtl stop];
        [[Settings settings] reset];
        [[Settings settings] save];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        //        LoginViewController *loginCtl = (LoginViewController *) [self.tasteStoryboard instantiateViewControllerWithIdentifier:@"Login"];
        //        [self.tasteNavCtl popToViewController:loginCtl animated:YES];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 ) 
    {
//        SeedViewController *seedCtl = [myStoryboard instantiateViewControllerWithIdentifier:@"SeedViewCtl"];
//        [self.navigationController popToViewController:seedCtl animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController setNavigationBarHidden:NO];
    } 
    else if( indexPath.row == 1 ) 
    {
        TastesViewController *tastesCtl;
        tastesCtl = [[TastesViewController alloc] initWithNibName:@"TastesViewController_iPhone" bundle:nil];
        [self.navigationController pushViewController:tastesCtl animated:YES];
        [self.navigationController setNavigationBarHidden:NO];
    } 
    else if( indexPath.row == 2 )
    {
        AboutViewController *aboutCtl = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        [self.navigationController pushViewController:aboutCtl animated:YES];
        [self.navigationController setNavigationBarHidden:NO];
    }
    else if( indexPath.row == 3 ) 
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Logout of Rdio?" 
                                                     message:@"" 
                                                    delegate:self 
                                           cancelButtonTitle:@"No Thanks" 
                                           otherButtonTitles:@"Logout", nil];
        [av show];
    }
}

@end

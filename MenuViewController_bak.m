//
//  MenuViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/21/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "MenuViewController.h"
#import "SeedViewController.h"
#import "LoginViewController.h"
#import "Settings.h"
#import "ViewController.h"
#import "MWFViewController.h"
#import "TastesViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize tasteStoryboard = _tasteStoryboard;
@synthesize viewCtl = _viewCtl;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    cell.textLabel.text = [[self items] objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == 0 ) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if( indexPath.row == 1 ) {
        TastesViewController *tastesCtl = [[TastesViewController alloc] initWithNibName:@"TastesViewController_iPhone" bundle:nil];
        [self.navigationController pushViewController:tastesCtl animated:YES];
        [tastesCtl.navigationController setNavigationBarHidden:NO];
    } else if( indexPath.row == 2 ) {
    } else if( indexPath.row == 3 ) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Logout of Rdio?" 
                                                     message:@"" 
                                                    delegate:self 
                                           cancelButtonTitle:@"No Thanks" 
                                           otherButtonTitles:@"Logout", nil];
        [av show];
    }
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


@end

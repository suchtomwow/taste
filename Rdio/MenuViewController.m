//
//  MenuViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/27/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewController.h"
#import "Settings.h"
#import "TastesViewController.h"
#import "SeedViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize tasteStoryboard = _tasteStoryboard;
@synthesize viewCtl = _viewCtl;
@synthesize table;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.items = [[NSMutableArray alloc] initWithObjects:@"Change Seed", @"Tastes", @"About", @"Logout", nil];
    
    [table reloadData];

    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 ) 
    {
        SeedViewController *seedCtl = [self.storyboard instantiateViewControllerWithIdentifier:@"SeedViewCtl"];
        [self.navigationController popToViewController:seedCtl animated:YES];
    } 
    else if( indexPath.row == 1 ) 
    {
        TastesViewController *tastesCtl;
        tastesCtl = [[TastesViewController alloc] initWithNibName:@"TastesViewController_iPhone" bundle:nil];
        [self.navigationController pushViewController:tastesCtl animated:YES];
    } 
    else if( indexPath.row == 2 ) 
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

//
//  TastesViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/26/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "TastesViewController.h"
#import "Tastes.h"

@interface TastesViewController ()

@end

@implementation TastesViewController

@synthesize table = _table;

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
    
    [self.navigationController setTitle:@"Tastes"];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Tastes tastes] objectAtIndex:section] count];;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0 ) return @"Liked";
    else if( section == 1 ) return @"Disliked";
    
    return @"Hi";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSArray *list = [NSArray arrayWithArray:[[Tastes tastes] objectAtIndex:indexPath.section]];
    NSDictionary *track = list[indexPath.row];
    
    cell.textLabel.text = track[@"name"];
    cell.detailTextLabel.text = track[@"artist"];
    
    return cell;
}

@end

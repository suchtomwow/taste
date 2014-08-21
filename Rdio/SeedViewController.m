//
//  SeedViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "SeedViewController.h"
#import "Constants.h"
#import "MWFViewController.h"
#import "ViewController.h"
#import "QueueViewController.h"
#import "iPhoneMenuViewController.h"
#import "Tastes.h"
#import "LoginViewController.h"
#import "NowPlayingViewController.h"
#import "QueueCell.h"

@interface SeedViewController ()

@end

@class LoginViewController;
@implementation SeedViewController

@synthesize searchBar = _searchBar;
@synthesize suggestions = _suggestions;

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
    /**
     * Make sure we are sent delegate messages.
     */
    Rdio * rdio = [AppDelegate rdioInstance];
    [rdio setDelegate:self];
    
    self.searchBar.delegate = self;
    
    self.suggestions = [[NSMutableArray alloc] init];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    if( [[self.navigationController parentViewController] isKindOfClass:[LoginViewController class]] == NO )
    {
        self.navigationItem.hidesBackButton = YES;
    }
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
//    {
//        NSString *myIdentifier = @"Cell";
//        [self.suggestionsTable registerNib:[UINib nibWithNibName:@"QueueCell" bundle:nil] forCellReuseIdentifier:myIdentifier];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    [[Tastes tastes] reset];
//    [[Tastes tastes] save];
    
    NSDictionary *selection = (self.suggestions)[self.suggestionsTable.indexPathForSelectedRow.row];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        MWFViewController *rootCtl = segue.destinationViewController;
        ViewController *viewCtl = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        viewCtl.menuCtl.tasteStoryboard = [self storyboard];
        rootCtl.viewCtl = viewCtl;
        viewCtl.selection = selection;
        [viewCtl.queueCtl.trackQueue addObject:selection];
        viewCtl.queueCtl.currentTrack = selection;
        viewCtl.queueCtl.viewCtl = viewCtl;
        
        [viewCtl setInfo];
            
        [viewCtl playButtonPress:nil];
        [viewCtl thumbsUpButtonPress:nil];
    }
    else
    {
        NowPlayingViewController *npCtl = segue.destinationViewController;
        npCtl.selection = selection;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.items.count;
    if( self.suggestions ) {
        return self.suggestions.count;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *suggestion = (self.suggestions)[indexPath.row];
    
    cell.textLabel.text = suggestion[@"name"];
    cell.detailTextLabel.text = suggestion[@"albumArtist"];
    //    cell.imageView.image = nil;
    
    return cell;
}

#pragma mark - RDAPIRequestDelegate

-(void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    for (NSDictionary *result in data) {
        if( result[@"albumArtist"] != nil ) {
            [self.suggestions addObject:result];
        }
    }
    //    self.suggestions = data;
    
    [self.suggestionsTable reloadData];    
}

-(void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error {
    NSLog( @"Request failed with error %@", error );
}

#pragma mark - UISearchBar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if( searchText.length == 0 ) {
        [self.suggestions removeAllObjects];
        [self.suggestionsTable reloadData];
        return;
    }
    //    if( searchBar.text.length > 2 ) {
        [self.suggestions removeAllObjects];
        NSDictionary *params = @{@"query": searchBar.text, @"types": TYPE_TRACK};
        [[AppDelegate rdioInstance] callAPIMethod:@"searchSuggestions" withParameters:params delegate:self];
    //    }
}

@end

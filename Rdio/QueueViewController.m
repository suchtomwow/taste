//
//  QueueViewController.m
//  Taste
//
//  Created by Thomas Carey on 2/27/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "QueueViewController.h"
#import "ViewController.h"
#import "NowPlayingViewController.h"
#import "QueueCell.h"

@implementation QueueViewController

@synthesize queueTable;
@synthesize songLabel;
@synthesize artistLabel;
@synthesize albumLabel;
@synthesize currentTrack = _currentTrack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        queueTable.delegate = self;
        queueTable.dataSource = self;
        
        self.trackQueue = [NSMutableArray array];
        self.currentTrack = @{};
        self.keyQueue = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        NSString *myIdentifier = @"Cell";
        [self.queueTable registerNib:[UINib nibWithNibName:@"QueueCell" bundle:nil] forCellReuseIdentifier:myIdentifier];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateNowPlaying];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateNowPlaying
{
    if( self.currentTrack )
    {
        songLabel.text = (self.currentTrack)[@"name"];
        artistLabel.text = (self.currentTrack)[@"artist"];
        albumLabel.text = (self.currentTrack)[@"album"];   
        
        if( self.npCtl )
        {
            self.npCtl.currentTrack = self.currentTrack;
            [self.npCtl setInfo];
            [self.npCtl refreshView];
        }
    }
    
    [self.queueTable reloadData];
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
    return self.trackQueue.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Queue";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    QueueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[QueueCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if( self.trackQueue.count )
    {
        NSDictionary *track = [self trackQueue][indexPath.row];
        
        cell.textLabel.text = track[@"name"];
        cell.detailTextLabel.text = track[@"artist"];
        if( self.viewCtl )
        {
            if( [self.viewCtl.player currentTrackIndex] != indexPath.row)
            {
                [cell.imageView setHidden:YES];
            }
            else
            {
                [cell.imageView setHidden:NO];
            }
        }
        else
        {
            if( [self.npCtl.player currentTrackIndex] != indexPath.row)
            {
                [cell.imageView setHidden:YES];
            }
            else
            {
                [cell.imageView setHidden:NO];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.viewCtl )
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.viewCtl.player currentTrackIndex] inSection:0];
        [[[self tableView:tableView cellForRowAtIndexPath:path] imageView] setHidden:YES];
        
        [[[self tableView:tableView cellForRowAtIndexPath:indexPath] imageView] setHidden:NO];
        self.currentTrack = (self.trackQueue)[indexPath.row];
        [self.viewCtl.player skipToIndex:indexPath.row];
        [self updateNowPlaying];    
    }
    else
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.npCtl.player currentTrackIndex] inSection:0];
        [[[self tableView:tableView cellForRowAtIndexPath:path] imageView] setHidden:YES];
        
        [[[self tableView:tableView cellForRowAtIndexPath:indexPath] imageView] setHidden:NO];
        self.currentTrack = (self.trackQueue)[indexPath.row];
        [self.npCtl.player skipToIndex:indexPath.row];
        [self updateNowPlaying];            
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{    
    
//    [self.keyQueue removeAllObjects];
//    NSDictionary *track = [self.trackQueue objectAtIndex:indexPath.row + 1];
    
//    [[self.mainViewController player] playSource:[track objectForKey:@"key"]];
//    
//    NSMutableArray *queue = [[NSMutableArray alloc] initWithCapacity:(self.trackQueue.count-(indexPath.row+1))];
//    for( int Ix = (indexPath.row+1); Ix < self.trackQueue.count; Ix++ )
//    {
//        NSDictionary *dict = [self.trackQueue objectAtIndex:Ix];
//        [queue addObject:dict];
//        [self.keyQueue addObject:[dict objectForKey:@"key"]];
//        
//    }
}



@end

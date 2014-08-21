//
//  NowPlayingViewController.m
//  Taste
//
//  Created by Thomas Carey on 4/27/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "QueueViewController.h"
#import "LastFm.h"
#import "Tastes.h"
#import "Constants.h"
#import "MenuViewController.h"
#import "Settings.h"

@interface NowPlayingViewController ()

@end

@implementation NowPlayingViewController
@synthesize artistLabel;
@synthesize songLabel;
@synthesize albumCover;
@synthesize playButton;
@synthesize player = _player;
@synthesize key = _key;
@synthesize songName = _songName;
@synthesize artistName = _artistName;
@synthesize albumName = _albumName;
@synthesize albumKey = _albumKey;
@synthesize artwork = _artwork;
@synthesize lastLikedTrack = _lastLikedTrack;
@synthesize selection = _selection;
@synthesize iconURL = _iconURL;

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
    
    /**
     * Make sure we are sent delegate messages.
     */
    Rdio * rdio = [AppDelegate rdioInstance];
    [rdio setDelegate:self];
    [[rdio player] setDelegate:self];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.currentTrack = @{};
    self.trackQueue = [NSMutableArray array];
    self.keyQueue = [NSMutableArray array];
    
    self.currentTrack = self.selection;
    [self.trackQueue addObject:self.currentTrack];
    [self.keyQueue addObject:(self.currentTrack)[@"key"]];

}

-(void)viewWillAppear:(BOOL)animated
{
    [self setInfo];

    if( [self.player state] != RDPlayerStatePlaying )
    {
        //        [self playButtonPress:nil];
        [self playButtonPress:nil];
        [self thumbsUpButtonPress:nil];
    }
    
    [self refreshView];

    [self.player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"NowPlayingToQueueSegue"] )
    {
        QueueViewController *queueCtl = segue.destinationViewController;
        queueCtl.npCtl = self;
        queueCtl.currentTrack = self.currentTrack;
        queueCtl.trackQueue = self.trackQueue;
        queueCtl.keyQueue = self.keyQueue;        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context {
    
    self.currentTrack = (self.trackQueue)[[self.player currentTrackIndex]];
    [self setInfo];
    [self refreshView];

    if( (self.trackQueue.count == self.player.currentTrackIndex+1) &&
       (self.trackQueue.count > 1)) {
        [self getSimilarTracks];
    }
}

-(RDPlayer*)getPlayer
{
    if (self.player == nil) {
        self.player = [AppDelegate rdioInstance].player;
    }
    return self.player;
}

-(void)setInfo {
    self.artistName = (self.currentTrack)[@"albumArtist"];
    self.songName = (self.currentTrack)[@"name"];
    self.albumName = (self.currentTrack)[@"album"];
    self.albumKey = (self.currentTrack)[@"albumKey"];
    self.iconURL = (self.currentTrack)[@"bigIcon"];
    self.key = (self.currentTrack)[@"key"];    
}

-(void)refreshView {
    self.artistLabel.text = self.artistName;
    self.songLabel.text = self.songName;    
    [self setAlbumArtForUrl:self.iconURL];
}

- (void)getAlbumArtFromKey:(NSString *)key
{
    // see if the image exists on disk
    NSString *albumArtCachedName = [NSString stringWithFormat:@"%@.png", key];
    NSString *albumArtCachedFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                                        stringByAppendingPathComponent:albumArtCachedName];
    UIImage *image = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:albumArtCachedFullPath]) {
        image = [UIImage imageWithContentsOfFile:albumArtCachedFullPath];
        
        [albumCover setImage:image];
    }
    else {
        NSDictionary *params = @{@"keys": key, @"extras": @"bigIcon"};
        [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:params delegate:self];
    }
}

- (void)setAlbumArtForUrl:(NSString*)Url
{
    if( [Url isEqualToString:@""] )
    {
        NSDictionary *params = @{@"keys": self.albumKey, @"extras": @"bigIcon"};
        [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:params delegate:self];
    }
    NSString *albumArtCachedName = [NSString stringWithFormat:@"%@.png", self.albumKey];
    NSString *albumArtCachedFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                                        stringByAppendingPathComponent:albumArtCachedName];
    UIImage *image = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:albumArtCachedFullPath]) 
    {
        image = [UIImage imageWithContentsOfFile:albumArtCachedFullPath];
        
        [albumCover setImage:image];
    }
    else 
    {
        self.artwork = [UIImage imageWithData: 
                        [NSData dataWithContentsOfURL: 
                         [NSURL URLWithString:Url]]];
    
        [albumCover setImage:self.artwork];
    
        // save it to disk
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.artwork)];
        NSString *albumArtCachedName = [NSString stringWithFormat:@"%@.png", self.albumKey];
        NSString *albumArtCachedFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:albumArtCachedName];
        [imageData writeToFile:albumArtCachedFullPath atomically:YES];
    }
}

- (void)getSimilarTracks
{
    NSDictionary *nowPlaying = self.currentTrack;
    [self getSimilarTracksForTrack:nowPlaying[@"name"] 
                            artist:nowPlaying[@"albumArtist"]];
}

- (void)getSimilarTracksForTrack:(NSString *)title artist:(NSString *)artist
{
    // Make calls to LastFm
    [[LastFm sharedInstance] getSimilarTracks:title 
                                       artist:artist
                               successHandler:^(NSArray *result) {
                                   
           NSLog( @"Last.fm result: %@", result );
           
           /* Stub: Randomize result set here */
           
           NSMutableArray *randResult = [[NSMutableArray alloc] initWithArray:result];
           randResult = [self randomize:randResult];
           
           for (NSDictionary *item in randResult) {
               [NSThread sleepForTimeInterval:.1];
               [self getKeyForTrackName:item[@"name"] artist:item[@"artist"]];            
           }
                                   
       } failureHandler:^(NSError *error) {
           NSLog( @"Last.fm error: %@", error );
       }];
    
}

- (NSMutableArray*)randomize:(NSMutableArray*)array
{
    NSInteger nItems = [array count];
    for(int i = 0; i < nItems; i++) {
        [array exchangeObjectAtIndex:i withObjectAtIndex:arc4random() % nItems];
    }
    
    return array;
}


- (void)getKeyForTrackName:(NSString *)name artist:(NSString *)artist
{
    NSString *query = [NSString stringWithFormat:@"%@ %@", artist, name];
    
    NSDictionary *params = @{@"query": query, @"types": @"track", @"extras": @"bigIcon"};
    [[AppDelegate rdioInstance] callAPIMethod:@"search" withParameters:params delegate:self];
}

-(void)stop {
    [self.player stop];
}

#pragma mark - Button Actions

- (IBAction)playButtonPress:(id)sender 
{
    if (!playing) {
        [[self getPlayer] playSources:self.keyQueue];
    } else {
        [[self getPlayer] togglePause];
    }
}

- (IBAction)prevButtonPress:(id)sender 
{
    if( [self.player position] < 3 )
    {
        [self.player previous];
        
        [self refreshView];
    }
    else
    {
        [self.player seekToPosition:0.00];    
    }
}

- (IBAction)nextButtonPress:(id)sender 
{
    [self.player next];
    
    [self refreshView];
}

- (IBAction)thumbsDownButtonPress:(id)sender 
{
    [[Tastes tastes] dislikeTrack:self.currentTrack];
    [self.player next];
}

- (IBAction)thumbsUpButtonPress:(id)sender 
{
    if( self.lastLikedTrack == self.currentTrack )
    {
        return;
    }
    
    self.lastLikedTrack = self.currentTrack;
    [[Tastes tastes] likeTrack:self.currentTrack];
    [self.keyQueue removeAllObjects];  
    [self.keyQueue addObject:self.key];
    [self.trackQueue removeAllObjects];
    [self.trackQueue addObject:self.currentTrack];
    [self.player updateQueue:self.keyQueue withCurrentTrackIndex:0];

    
    // Get similar tracks
    [self performSelectorInBackground:@selector(getSimilarTracks) withObject:nil];
    //    [self getSimilarTracks]; 
}

- (IBAction)logoutPress:(id)sender {
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Logout of Rdio?" 
                                                 message:@"" 
                                                delegate:self 
                                       cancelButtonTitle:@"No Thanks" 
                                       otherButtonTitles:@"Logout", nil];
    [av show];
}

- (IBAction)changeSeedPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RDAPIRequestDelegate
/**
 * Our API call has returned successfully.
 * the data parameter can be an NSDictionary, NSArray, or NSData 
 * depending on the call we made.
 *
 * Here we will inspect the parameters property of the returned RDAPIRequest
 * to see what method has returned.
 */
- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
    NSString *method = (request.parameters)[@"method"];
    
    if([method isEqualToString:@"get"]) 
    {
        NSDictionary *dictionary = [data allObjects][0];
        
        if( [dictionary[@"type"] isEqualToString:TYPE_ALBUM] )
        {
            [self setAlbumArtForUrl:dictionary[@"bigIcon"]];                
        }
    }
    else if( [method isEqualToString:@"search"] )
    {
        NSArray *array = data[@"results"];
        NSDictionary *newTrack = array[0];
        
        [self.trackQueue addObject:newTrack];
        
        [self.keyQueue addObject:newTrack[@"key"]];
        
        [self.player updateQueue:self.keyQueue withCurrentTrackIndex:[self.player currentTrackIndex]];
        
        NSLog(@"Queued source: %@, %@, %@", newTrack[@"key"], 
              newTrack[@"artist"], 
              newTrack[@"name"]);
    }
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error 
{
    NSLog( @"Rdio error: %@", error );
}

#pragma mark - RDPlayerDelegate

- (void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState
{
    playing = (newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped);
    paused = (newState == RDPlayerStatePaused);
    
    if (paused || !playing) 
    {
        [playButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    } 
    else 
    {
        [playButton setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
    }
    
    NSLog(@"*** Player changed from state: %d toState: %d", oldState, newState);
}

- (BOOL)rdioIsPlayingElsewhere {
    return NO; // Returning NO lets the SDK handle it
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        
        // Stop playing music
        [self stop];
        [[Settings settings] reset];
        [[Settings settings] save];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end

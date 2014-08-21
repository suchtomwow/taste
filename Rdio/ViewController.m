//
//  RootViewController.m
//  Taste
//
//  Created by Thomas Carey on 2/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "ViewController.h"
#import "iPhoneMenuViewController.h"
#import "QueueViewController.h"
#import "Settings.h"
#import "Constants.h"
#import "LastFm.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Tastes.h"
#import "AFImageRequestOperation.h"

@implementation ViewController

@synthesize artistLabel;
@synthesize songLabel;
@synthesize albumCover;
@synthesize playButton;
@synthesize menuCtl = _menuCtl;
@synthesize queueCtl = _queueCtl;
@synthesize player = _player;
@synthesize key = _key;
@synthesize songName = _songName;
@synthesize artistName = _artistName;
@synthesize albumName = _albumName;
@synthesize albumKey = _albumKey;
@synthesize artwork = _artwork;
@synthesize lastLikedTrack = _lastLikedTrack;
@synthesize songInfo = _songInfo;

#pragma mark - Methods -
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.queueCtl = [[QueueViewController alloc] initWithNibName:@"QueueViewController_iPhone" bundle:nil];
            self.menuCtl = [[iPhoneMenuViewController alloc] initWithNibName:@"iPhoneMenuViewController" bundle:nil];
            self.menuCtl.viewCtl = self;
        }
    }        
    return self;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    self.artwork = [[UIImage alloc] init];

    self.slideNavigationViewController.delegate = self;
    self.slideNavigationViewController.dataSource = self;
            
    /**
     * Make sure we are sent delegate messages.
     */
    Rdio * rdio = [AppDelegate rdioInstance];
    [rdio setDelegate:self];
    [[rdio player] setDelegate:self];
    
    [self.player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
    
    self.songInfo = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
  
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self refreshView];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [self resignFirstResponder];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self togglePlayPause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self previous];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self next];
                break;
                
            default:
                break;
        }
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
    
    self.queueCtl.currentTrack = (self.queueCtl.trackQueue)[[self.player currentTrackIndex]];
    [self setInfo];
    [self refreshView];
    [self.queueCtl updateNowPlaying];
    
    if((self.queueCtl.trackQueue.count == self.player.currentTrackIndex+1) &&
       (self.queueCtl.trackQueue.count > 1)) {
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

- (void)presentLoginModal
{
    [[AppDelegate rdioInstance] authorizeFromController:self];
}

-(void)setInfo {
    self.artistName = (self.queueCtl.currentTrack)[@"albumArtist"];
    self.songName = (self.queueCtl.currentTrack)[@"name"];
    self.albumName = (self.queueCtl.currentTrack)[@"album"];
    self.albumKey = (self.queueCtl.currentTrack)[@"albumKey"];
    self.key = (self.queueCtl.currentTrack)[@"key"];    
}

-(void)refreshView {
 
    self.artistLabel.text = self.artistName;
    self.songLabel.text = self.songName;
    [self getAlbumArtFromKey:(self.queueCtl.currentTrack)[@"albumKey"]];
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        

        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:self.artwork];
        
        [self.songInfo setObject:self.songName forKey:MPMediaItemPropertyTitle];
        [self.songInfo setObject:self.artistName forKey:MPMediaItemPropertyArtist];
        [self.songInfo setObject:self.albumName forKey:MPMediaItemPropertyAlbumTitle];
        [self.songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.songInfo];
    }
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
    self.artwork = [UIImage imageWithData: 
                        [NSData dataWithContentsOfURL: 
                         [NSURL URLWithString:Url]]];
    
    
//    AFImageRequestOperation *imageOperation;
//    imageOperation = [AFImageRequestOperation
//                      imageRequestOperationWithRequest:imageRequest
//                      imageProcessingBlock:nil
//                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                          [[weakSelf currentAlbum] setCachedImage:image];
//                          MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
//                          [self.songInfo setValue:artwork forKey:MPMediaItemPropertyArtwork];
//                          [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.songInfo];
//                      } failure:nil];
//    [imageOperation start];
    
    [albumCover setImage:self.artwork];

    // save it to disk
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.artwork)];
    NSString *albumArtCachedName = [NSString stringWithFormat:@"%@.png", self.albumKey];
    NSString *albumArtCachedFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:albumArtCachedName];
    [imageData writeToFile:albumArtCachedFullPath atomically:YES];
}

- (void)getSimilarTracks
{
    NSDictionary *nowPlaying = self.queueCtl.currentTrack;
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
        //        [self playAlbum];
    }];

}

-(void)playAlbum
{
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:self.albumKey, @"get", @"bigIcon", @"extras", nil];
//    [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:params delegate:self];
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

-(void)next {
    [self.player next];
}

-(void)previous {
  
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

#pragma mark - Button Actions

- (void) slideLeft:(id)sender {
    [self _slide:MWFSlideDirectionLeft];
}
- (void) slideRight:(id)sender {
    [self _slide:MWFSlideDirectionRight];
}
- (void) close:(id)sender {
    [self _slide:MWFSlideDirectionNone];
}

- (IBAction)menuButtonPress:(id)sender
{
    [self slideRight:sender];
}

- (IBAction)queueButtonPress:(id)sender
{
    [self slideLeft:sender];
}

- (IBAction)playButtonPress:(id)sender 
{
    if (!playing) {
        [[self getPlayer] playSource:self.key];
    } else {
        [[self getPlayer] togglePause];
    }
}

-(void)togglePlayPause {
    [self.player togglePause];
}

- (IBAction)prevButtonPress:(id)sender {
    [self previous];
}

- (IBAction)nextButtonPress:(id)sender {
    [self next];
}

- (IBAction)thumbsDownButtonPress:(id)sender {
    [[Tastes tastes] dislikeTrack:self.queueCtl.currentTrack];
    [self.player next];
}

- (IBAction)thumbsUpButtonPress:(id)sender {
    
    if( self.lastLikedTrack == self.queueCtl.currentTrack )
    {
        return;
    }
    
    self.lastLikedTrack = self.queueCtl.currentTrack;
    [[Tastes tastes] likeTrack:self.queueCtl.currentTrack];
    [self.queueCtl.keyQueue removeAllObjects];  
    [self.queueCtl.keyQueue addObject:self.key];
    [self.queueCtl.trackQueue removeAllObjects];
    [self.queueCtl.trackQueue addObject:self.queueCtl.currentTrack];
    [self.player updateQueue:self.queueCtl.keyQueue withCurrentTrackIndex:0];
    
    // Get similar tracks
    [self performSelectorInBackground:@selector(getSimilarTracks) withObject:nil];
    //    [self getSimilarTracks]; 
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
        
        [self.queueCtl.trackQueue addObject:newTrack];
        
        [self.queueCtl.keyQueue addObject:newTrack[@"key"]];
        
        [self.player updateQueue:self.queueCtl.keyQueue withCurrentTrackIndex:[self.player currentTrackIndex]];
        
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

#pragma mark - MWFSlideNavigationViewControllerDelegate
#define VIEWTAG_OVERLAY 1100
- (void) slideNavigationViewController:(MWFSlideNavigationViewController *)controller willPerformSlideFor:(UIViewController *)targetController withSlideDirection:(MWFSlideDirection)slideDirection distance:(CGFloat)distance orientation:(UIInterfaceOrientation)orientation {
    
    if (slideDirection == MWFSlideDirectionNone) 
    {
        UIView * overlay = [self.view viewWithTag:VIEWTAG_OVERLAY];
        [overlay removeFromSuperview];
        
    } 
    else 
    {
        UIView * overlay = [[UIView alloc] initWithFrame:self.view.bounds];
        overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        overlay.tag = VIEWTAG_OVERLAY;
        UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        [overlay addGestureRecognizer:gr];
        overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:overlay];
    }
}

- (void) slideNavigationViewController:(MWFSlideNavigationViewController *)controller animateSlideFor:(UIViewController *)targetController withSlideDirection:(MWFSlideDirection)slideDirection distance:(CGFloat)distance orientation:(UIInterfaceOrientation)orientation
{
    UIView * overlay = [self.view viewWithTag:VIEWTAG_OVERLAY];
    if (slideDirection == MWFSlideDirectionNone)
    {
        overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    else
    {
        overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
}

- (NSInteger) slideNavigationViewController:(MWFSlideNavigationViewController *)controller distanceForSlideDirecton:(MWFSlideDirection)direction portraitOrientation:(BOOL)portraitOrientation
{
    if (portraitOrientation)
    {
        if( direction == MWFSlideDirectionRight )
        {    
            return 180;
        }
        else if( direction == MWFSlideDirectionLeft )
        {
            return 250;
        }
    }
    else
    {
        return 100;
    }
    
    return 0;
}

#pragma mark - MWFSlideNavigationViewControllerDataSource

- (UIViewController *) slideNavigationViewController:(MWFSlideNavigationViewController *)controller 
                      viewControllerForSlideDirecton:(MWFSlideDirection)direction
{
    if( direction == MWFSlideDirectionLeft )
    {
        return self.queueCtl;
    }
    else if( direction == MWFSlideDirectionRight )
    {
        return self.menuCtl;
    }
    else if( direction == MWFSlideDirectionNone )
    {
        return self;
    }
    
    return nil;
}

- (void) _slide:(MWFSlideDirection)direction {
    
    [self.slideNavigationViewController slideWithDirection:direction];
    
}

@end

//
//  RootViewController.h
//  Taste
//
//  Created by Thomas Carey on 2/20/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFSlideNavigationViewController.h"
#import "AppDelegate.h"

@class iPhoneMenuViewController;
@class QueueViewController;

@interface ViewController : UIViewController <RdioDelegate, RDAPIRequestDelegate, RDPlayerDelegate, MWFSlideNavigationViewControllerDelegate, MWFSlideNavigationViewControllerDataSource>
{
    BOOL playing;
    BOOL paused;
//    RDPlayer* player;
//    NSMutableDictionary *currentTrack;
//    NSMutableArray *trackQueue;
//    NSMutableArray *keyQueue;
}
- (void)presentLoginModal;
- (void)setInfo;
- (void)refreshView;
//- (void)setNowPlaying;
//- (void)setNowPlaying:(NSDictionary*)track;
//- (void)setNowPlayingSong:(NSString*)song artist:(NSString*)artist key:(NSString*)tKey albumKey:(NSString *)aKey;
- (void)getAlbumArtFromKey:(NSString *)key;
- (void)setAlbumArtForUrl:(NSString*)Url;
- (void)getSimilarTracks;
- (void)getSimilarTracksForTrack:(NSString *)title artist:(NSString *)artist;
- (NSMutableArray*)randomize:(NSMutableArray*)array;
- (void)getKeyForTrackName:(NSString *)name artist:(NSString *)artist;
- (void)stop;
- (void)togglePlayPause;
- (void)next;
- (void)previous;

- (IBAction)menuButtonPress:(id)sender;
- (IBAction)queueButtonPress:(id)sender;
- (IBAction)playButtonPress:(id)sender;
- (IBAction)prevButtonPress:(id)sender;
- (IBAction)nextButtonPress:(id)sender;
- (IBAction)thumbsDownButtonPress:(id)sender;
- (IBAction)thumbsUpButtonPress:(id)sender;

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *songName;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *albumKey;
@property (strong, nonatomic) UIImage *artwork;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumCover;
@property (strong, nonatomic) iPhoneMenuViewController *menuCtl;
@property (nonatomic, strong) QueueViewController *queueCtl;
@property (strong, nonatomic) RDPlayer *player;
@property (strong, nonatomic) NSDictionary *selection;
@property (strong, nonatomic) NSDictionary *lastLikedTrack;
@property (strong, nonatomic) NSMutableDictionary *songInfo;

@end

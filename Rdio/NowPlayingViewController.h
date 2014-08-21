//
//  NowPlayingViewController.h
//  Taste
//
//  Created by Thomas Carey on 4/27/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NowPlayingViewController : UIViewController <RdioDelegate, RDAPIRequestDelegate, RDPlayerDelegate, UIAlertViewDelegate>
{
    BOOL playing;
    BOOL paused;
}
- (void)setInfo;
- (void)refreshView;
- (void)getAlbumArtFromKey:(NSString *)key;
- (void)setAlbumArtForUrl:(NSString*)Url;
- (void)getSimilarTracks;
- (void)getSimilarTracksForTrack:(NSString *)title artist:(NSString *)artist;
- (NSMutableArray*)randomize:(NSMutableArray*)array;
- (void)getKeyForTrackName:(NSString *)name artist:(NSString *)artist;
- (void)stop;

- (IBAction)playButtonPress:(id)sender;
- (IBAction)prevButtonPress:(id)sender;
- (IBAction)nextButtonPress:(id)sender;
- (IBAction)thumbsDownButtonPress:(id)sender;
- (IBAction)thumbsUpButtonPress:(id)sender;
- (IBAction)logoutPress:(id)sender;
- (IBAction)changeSeedPress:(id)sender;

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *songName;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *albumKey;
@property (strong, nonatomic) NSString *iconURL;
@property (strong, nonatomic) UIImage *artwork;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumCover;
@property (strong, nonatomic) RDPlayer *player;
@property (strong, nonatomic) NSDictionary *selection;
@property (strong, nonatomic) NSDictionary *lastLikedTrack;
@property (retain, nonatomic) NSMutableArray *trackQueue;
@property (retain, nonatomic) NSDictionary *currentTrack;
@property (retain, nonatomic) NSMutableArray *keyQueue;


@end

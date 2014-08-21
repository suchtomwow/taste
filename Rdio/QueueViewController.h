//
//  QueueViewController.h
//  Taste
//
//  Created by Thomas Carey on 2/27/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class NowPlayingViewController;

@interface QueueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (void) updateNowPlaying;

@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;

@property (strong, nonatomic) IBOutlet UITableView *queueTable;
@property (retain, nonatomic) NSMutableArray *trackQueue;
@property (retain, nonatomic) NSDictionary *currentTrack;
@property (retain, nonatomic) NSMutableArray *keyQueue;
@property (strong, nonatomic) ViewController *viewCtl;
@property (strong, nonatomic) NowPlayingViewController *npCtl;

@end

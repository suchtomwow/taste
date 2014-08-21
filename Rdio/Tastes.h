//
//  Tastes.h
//  Taste
//
//  Created by Thomas Carey on 4/25/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tastes : NSObject
{
    NSArray *tastes_;
    NSString *filePath_;
}

+(Tastes *)tastes;
@property (retain) NSMutableArray *liked;
@property (retain) NSMutableArray *disliked;

-(void)likeTrack:track;
-(void)dislikeTrack:track;
-(void)removePreviousTrackFrom:(NSMutableArray *)array matching:(NSString *)artist title:(NSString *)title;
-(NSMutableArray *)objectAtIndex:(NSInteger)index;
-(void)save;
-(void)reset;

@end

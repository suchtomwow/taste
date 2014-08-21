//
//  Tastes.m
//  Taste
//
//  Created by Thomas Carey on 4/25/13.
//  Copyright (c) 2013 Thomas J. Carey. All rights reserved.
//

#import "Tastes.h"

@implementation Tastes

@synthesize liked = _liked;
@synthesize disliked = _disliked;

-(void)likeTrack:(id)track
{
    [self removePreviousTrackFrom:self.liked matching:track[@"artist"] title:track[@"name"]];
    
    [self.liked addObject:track];
    [self save];
}

-(void)dislikeTrack:track
{
    [self removePreviousTrackFrom:self.liked matching:track[@"artist"] title:track[@"name"]];
    
    [self.disliked addObject:track];
    [self save];
}

-(void)removePreviousTrackFrom:(NSMutableArray *)array matching:(NSString *)artist title:(NSString *)title
{
    for( int Ix = 0; Ix < array.count; Ix++ )
    {
        NSDictionary *track = array[Ix];

        BOOL artistMatch = [track[@"artist"]  isEqualToString:artist] || [track[@"albumArtist"] isEqualToString:artist];
        BOOL titleMatch = [track[@"name"] isEqualToString:title];
        BOOL match = artistMatch && titleMatch;
        
        if( match )
        {
            [array removeObject:track];
            Ix--;
            NSLog( @"Removed track: %@, %@", artist, title );
        }
    }
}

-(NSMutableArray *)objectAtIndex:(NSInteger)index
{
    return tastes_[index];
}

+ (Tastes*)tastes 
{
    static Tastes *tastes_;
    
    if (tastes_) {
        return tastes_;
    }
    
    @synchronized(self) {
        if (!tastes_){
            tastes_ = [[self alloc] init];
        }
    }
    
    return tastes_;
}

- (NSString*)filePath 
{
    if (filePath_ == nil) {
        filePath_ = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                     stringByAppendingPathComponent:@"taste.tastes"];
    }
    return filePath_;
}

- (id)init 
{
    if (self = [super init]) 
    {
        @try
        {
            tastes_ = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
            if([tastes_ count])
            {
                self.liked = tastes_[0];
                self.disliked = tastes_[1];
            }
            else
            {
                self.liked = [[NSMutableArray alloc] initWithCapacity:1];
                self.disliked = [[NSMutableArray alloc] initWithCapacity:1];
            }
        }
        @catch (NSException *exception) 
        {
            NSLog(@"Exception loading tastes. %@, %@", exception.name, exception.reason);
        }
        if (tastes_ == nil) 
        {
            self.liked = [[NSMutableArray alloc] initWithCapacity:1];
            self.disliked = [[NSMutableArray alloc] initWithCapacity:1];
            tastes_ = @[self.liked, self.disliked];
        }
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)save {
    NSArray *array = @[self.liked, self.disliked];
    [NSKeyedArchiver archiveRootObject:array
                                toFile:[self filePath]];
    NSLog(@"Tastes saved.");
}

- (void)reset {
    for (NSMutableArray *array in tastes_) {
        [array removeAllObjects];
    }
}

@end

//
//  LastFm.m
//  lastfmlocalplayback
//
//  Created by Kevin Renskers on 17-08-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "LastFm.h"
#import "DDXML.h"
#include <CommonCrypto/CommonDigest.h>

#define API_URL @"http://ws.audioscrobbler.com/2.0/"

@interface DDXMLNode (objectAtXPath)
- (id)objectAtXPath:(NSString *)XPath;
@end

@implementation DDXMLNode (objectAtXPath)

- (id)objectAtXPath:(NSString *)XPath {
    NSError *err;
    NSArray *nodes = [self nodesForXPath:XPath error:&err];

    if ([nodes count]) {
        NSMutableArray *strings = [[NSMutableArray alloc] init];
        for (DDXMLNode *node in nodes) {
            if ([node stringValue]) {
                [strings addObject:[[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
        if ([strings count] == 1) {
            NSString *output = [NSString stringWithString:strings[0]];
            return output;
        } else if ([strings count] > 1) {
            return strings;
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}

@end


@interface LastFm ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end


@implementation LastFm

+ (LastFm *)sharedInstance {
    static dispatch_once_t pred;
    static LastFm *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.apiKey = @"";
        self.apiSecret = @"";
        self.queue = [[NSOperationQueue alloc] init];
        self.maxConcurrentOperationCount = 4;
        self.timeoutInterval = 10;
    }
    return self;
}

- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount {
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
}

+ (NSDateFormatter *)dateFormatter {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = dictionary[@"LFMDateFormatter"];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
        dictionary[@"LFMDateFormatter"] = formatter;
    }
    return formatter;
}

+ (NSNumberFormatter *)numberFormatter {
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSNumberFormatter *formatter = dictionary[@"LFMNumberFormatter"];
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        dictionary[@"LFMNumberFormatter"] = formatter;
    }
    return formatter;
}

#pragma mark - Private methods

- (NSString *)md5sumFromString:(NSString *)string {
	unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
	CC_MD5([string UTF8String], [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
	NSMutableString *ms = [NSMutableString string];
	for (i=0;i<CC_MD5_DIGEST_LENGTH;i++) {
		[ms appendFormat: @"%02x", (int)(digest[i])];
	}
	return [ms copy];
}

- (NSString*)urlEscapeString:(id)unencodedString {
    if ([unencodedString isKindOfClass:[NSString class]]) {
        NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef)unencodedString,
            NULL,
            (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
            kCFStringEncodingUTF8
        );
        return s;
    }
    return unencodedString;
}

- (id)transformValue:(id)value intoClass:(NSString *)targetClass {
    if ([value isKindOfClass:NSClassFromString(targetClass)]) {
        return value;
    }

    if ([targetClass isEqualToString:@"NSNumber"]) {
        if ([value isKindOfClass:[NSString class]] && [value length]) {
            return [[LastFm numberFormatter] numberFromString:value];
        }
        return @0;
    }

    if ([targetClass isEqualToString:@"NSURL"]) {
        if ([value isKindOfClass:[NSString class]] && [value length]) {
            return [NSURL URLWithString:value];
        }
        return nil;
    }

    if ([targetClass isEqualToString:@"NSDate"]) {
        return [[LastFm dateFormatter] dateFromString:value];
    }

    if ([targetClass isEqualToString:@"NSArray"]) {
        if ([value isKindOfClass:[NSString class]] && [value length]) {
            return @[value];
        }
        return @[];
    }

    NSLog(@"Invalid targetClass (%@)", targetClass);
    return value;
}

- (NSString *)forceString:(NSString *)value {
    if (!value) return @"";
    return value;
}

- (NSOperation *)performApiCallForMethod:(NSString*)method
                              withParams:(NSDictionary *)params
                               rootXpath:(NSString *)rootXpath
                        returnDictionary:(BOOL)returnDictionary
                           mappingObject:(NSDictionary *)mappingObject
                          successHandler:(LastFmReturnBlockWithObject)successHandler
                          failureHandler:(LastFmReturnBlockWithError)failureHandler {

    return [self performApiCallForMethod:method
                                useCache:YES
                              withParams:params
                               rootXpath:rootXpath
                        returnDictionary:returnDictionary
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)performApiCallForMethod:(NSString*)method
                                useCache:(BOOL)useCache
                              withParams:(NSDictionary *)params
                               rootXpath:(NSString *)rootXpath
                        returnDictionary:(BOOL)returnDictionary
                           mappingObject:(NSDictionary *)mappingObject
                          successHandler:(LastFmReturnBlockWithObject)successHandler
                          failureHandler:(LastFmReturnBlockWithError)failureHandler {

    NSMutableDictionary *newParams = [params mutableCopy];
    newParams[@"method"] = method;
    newParams[@"api_key"] = self.apiKey;

    if (self.session) {
        newParams[@"sk"] = self.session;
    }

    if (self.username && !params[@"username"]) {
        newParams[@"username"] = self.username;
    }

    // Create signature by sorting all the parameters
    NSArray *sortedParamKeys = [[newParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *signature = [[NSMutableString alloc] init];
    for (NSString *key in sortedParamKeys) {
        [signature appendString:[NSString stringWithFormat:@"%@%@", key, newParams[key]]];
    }
    [signature appendString:self.apiSecret];

    // Check if we have the object in cache
    NSString *cacheKey = [self md5sumFromString:signature];
    NSArray *cachedArray = nil;

    if (useCache && self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(cachedArrayForKey:requestParams:)]) {
        cachedArray = [self.cacheDelegate cachedArrayForKey:cacheKey requestParams:newParams];
    } else if (useCache && self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(cachedArrayForKey:)]) {
        cachedArray = [self.cacheDelegate cachedArrayForKey:cacheKey];
    }

    if (cachedArray && cachedArray.count) {
        id returnObject;
        if (returnDictionary) {
            returnObject = cachedArray[0];
        } else {
            returnObject = cachedArray;
        }
        if (successHandler) {
            successHandler(returnObject);
        }

        if (self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(cacheExpiredForKey:)]) {
            BOOL expired = [self.cacheDelegate cacheExpiredForKey:cacheKey];
            if (!expired) {
                // Not expired? Then don't make the request to the server. Stop here.
                return nil;
            }
        } if (self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(cacheExpiredForKey:requestParams:)]) {
            BOOL expired = [self.cacheDelegate cacheExpiredForKey:cacheKey requestParams:newParams];
            if (!expired) {
                // Not expired? Then don't make the request to the server. Stop here.
                return nil;
            }
        } else {
            // No expiration delegate methods? Stop here.
            return nil;
        }
    }

    // We need to send all the params in a sorted fashion
    NSMutableArray *sortedParamsArray = [NSMutableArray array];
    for (NSString *key in sortedParamKeys) {
        [sortedParamsArray addObject:[NSString stringWithFormat:@"%@=%@", [self urlEscapeString:key], [self urlEscapeString:newParams[key]]]];
    }

    return [self _performApiCallForMethod:method useCache:useCache signature:cacheKey withSortedParamsArray:sortedParamsArray andOriginalParams:newParams rootXpath:rootXpath returnDictionary:returnDictionary mappingObject:mappingObject successHandler:successHandler failureHandler:failureHandler];
}

- (NSOperation *)_performApiCallForMethod:(NSString*)method
                                 useCache:(BOOL)useCache
                                signature:(NSString *)signature
                    withSortedParamsArray:(NSArray *)sortedParamsArray
                        andOriginalParams:(NSDictionary *)originalParams
                                rootXpath:(NSString *)rootXpath
                         returnDictionary:(BOOL)returnDictionary
                            mappingObject:(NSDictionary *)mappingObject
                           successHandler:(LastFmReturnBlockWithObject)successHandler
                           failureHandler:(LastFmReturnBlockWithError)failureHandler {

    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    __unsafe_unretained NSBlockOperation *weakOp = op;

    [op addExecutionBlock:^{
        if ([weakOp isCancelled]) {
            return;
        }

        // Do we need to POST or GET?
        BOOL doPost = YES;
        NSArray *methodParts = [method componentsSeparatedByString:@"."];
        if ([methodParts count] > 1) {
            NSString *secondPart = methodParts[1];
            if ([secondPart hasPrefix:@"get"]) {
                doPost = NO;
            }
        }

        NSMutableURLRequest *request;
        if (doPost) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_URL]];
            request.timeoutInterval = self.timeoutInterval;
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[[NSString stringWithFormat:@"%@&api_sig=%@", [sortedParamsArray componentsJoinedByString:@"&"], signature] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *paramsString = [NSString stringWithFormat:@"%@&api_sig=%@", [sortedParamsArray componentsJoinedByString:@"&"], signature];
            NSString *urlString = [NSString stringWithFormat:@"%@?%@", API_URL, paramsString];

            NSURLRequestCachePolicy policy = NSURLRequestUseProtocolCachePolicy;
            if (!useCache) {
                policy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            }
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:policy timeoutInterval:self.timeoutInterval];
        }

        NSHTTPURLResponse *response;
        NSError *error;

        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if ([weakOp isCancelled]) {
            return;
        }

        NSNumber *maxAgeNumber = (response.allHeaderFields)[@"Access-Control-Max-Age"];
        NSTimeInterval maxAge = [maxAgeNumber integerValue];

        // Check for NSURLConnection errors
        if (error) {
            if (failureHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureHandler(error);
                }];
            }
            return;
        }

        DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];

        // Check for XML parsing errors
        if (error) {
            if (failureHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureHandler(error);
                }];
            }
            return;
        }

        // Check for Last.fm errors
        if (![[[document rootElement] objectAtXPath:@"./@status"] isEqualToString:@"ok"]) {
            if (failureHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSError *lastfmError = [[NSError alloc] initWithDomain:LastFmServiceErrorDomain
                                                                      code:[[[document rootElement] objectAtXPath:@"./error/@code"] intValue]
                                                                  userInfo:@{NSLocalizedDescriptionKey: [[document rootElement] objectAtXPath:@"./error"], @"method": method}];

                    failureHandler(lastfmError);
                }];
            }
            return;
        }

        NSArray *output = [[document rootElement] nodesForXPath:rootXpath error:&error];
        NSMutableArray *returnArray = [NSMutableArray array];

        for (DDXMLNode *node in output) {
            if ([weakOp isCancelled]) {
                return;
            }

            // Convert this node to a dictionary using the mapping object (keys and xpaths)
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            result[@"_params"] = originalParams;

            for (NSString *key in mappingObject) {
                NSArray *mappingArray = mappingObject[key];
                NSString *xpath = mappingArray[0];
                NSString *targetClass = mappingArray[1];
                NSString *value = [node objectAtXPath:xpath];
                id correctValue = [self transformValue:value intoClass:targetClass];
                if (correctValue != nil) {
                    result[key] = correctValue;
                }
            }

            [returnArray addObject:result];
        }

        if (returnArray && returnArray.count) {
            // Add to cache
            if (!doPost && self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(cacheArray:requestParams:forKey:maxAge:)]) {
                [self.cacheDelegate cacheArray:returnArray requestParams:originalParams forKey:signature maxAge:maxAge];
            } else if (!doPost && self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(cacheArray:forKey:maxAge:)]) {
                [self.cacheDelegate cacheArray:returnArray forKey:signature maxAge:maxAge];
            }

            if (successHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (returnDictionary) {
                        successHandler(returnArray[0]);
                    } else {
                        successHandler(returnArray);
                    }
                }];
            }
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (failureHandler) {
                    failureHandler(error);
                }
            }];
        }
    }];
    
    [self.queue addOperation:op];
    return op;
}

#pragma mark -
#pragma mark Artist methods

- (NSOperation *)getInfoForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"bio": @[ @"./bio/content", @"NSString" ],
        @"summary": @[ @"./bio/summary", @"NSString" ],
        @"name": @[ @"./name", @"NSString" ],
        @"url": @[ @"./url", @"NSURL" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"listeners": @[ @"./stats/listeners", @"NSNumber" ],
        @"playcount": @[ @"./stats/playcount", @"NSNumber" ],
        @"userplaycount": @[ @"./stats/userplaycount", @"NSNumber" ],
        @"tags": @[ @"./tags/tag/name", @"NSArray" ],
        @"ontour": @[ @"./ontour", @"NSNumber" ],
    };

    return [self performApiCallForMethod:@"artist.getInfo"
                              withParams:@{ @"artist": [self forceString:artist] }
                               rootXpath:@"./artist"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getEventsForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"title": @[ @"./title", @"NSString" ],
        @"headliner": @[ @"./artists/headliner", @"NSString" ],
        @"attendance": @[ @"./attendance", @"NSNumber" ],
        @"description": @[ @"./description", @"NSString" ],
        @"startDate": @[ @"./startDate", @"NSDate" ],
        @"url": @[ @"./url", @"NSURL" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"venue": @[ @"./venue/name", @"NSString" ],
        @"city": @[ @"./venue/location/city", @"NSString" ],
        @"country": @[ @"./venue/location/country", @"NSString" ],
        @"venue_url": @[ @"./venue/website", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"artist.getEvents"
                              withParams:@{ @"artist": [self forceString:artist] }
                               rootXpath:@"./events/event"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopAlbumsForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"title": @[ @"./name", @"NSString" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"url": @[ @"./url", @"NSURL" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"artist.getTopAlbums"
                             withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                              rootXpath:@"./topalbums/album"
                       returnDictionary:NO
                          mappingObject:mappingObject
                         successHandler:successHandler
                         failureHandler:failureHandler];
}

- (NSOperation *)getTopTracksForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"artist.getTopTracks"
                             withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                              rootXpath:@"./toptracks/track"
                       returnDictionary:NO
                          mappingObject:mappingObject
                         successHandler:successHandler
                         failureHandler:failureHandler];
}

- (NSOperation *)getImagesForArtist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"format": @[ @"format", @"NSString"],
        @"original": @[ @"./sizes/size[@name=\"original\"]", @"NSURL" ],
        @"original_width": @[ @"./sizes/size[@name=\"original\"]/@width", @"NSNumber" ],
        @"original_height": @[ @"./sizes/size[@name=\"original\"]/@height", @"NSNumber" ],
        @"extralarge": @[ @"./sizes/size[@name=\"extralarge\"]", @"NSURL" ],
        @"extralarge_width": @[ @"./sizes/size[@name=\"extralarge\"]/@width", @"NSNumber" ],
        @"extralarge_height": @[ @"./sizes/size[@name=\"extralarge\"]/@height", @"NSNumber" ],
        @"large": @[ @"./sizes/size[@name=\"large\"]", @"NSURL" ],
        @"large_width": @[ @"./sizes/size[@name=\"large\"]/@width", @"NSNumber" ],
        @"large_height": @[ @"./sizes/size[@name=\"large\"]/@height", @"NSNumber" ],
        @"largesquare": @[ @"./sizes/size[@name=\"largesquare\"]", @"NSURL" ],
        @"largesquare_width": @[ @"./sizes/size[@name=\"largesquare\"]/@width", @"NSNumber" ],
        @"largesquare_height": @[ @"./sizes/size[@name=\"largesquare\"]/@height", @"NSNumber" ],
        @"medium": @[ @"./sizes/size[@name=\"medium\"]", @"NSURL" ],
        @"medium_width": @[ @"./sizes/size[@name=\"medium\"]/@width", @"NSNumber" ],
        @"medium_height": @[ @"./sizes/size[@name=\"medium\"]/@height", @"NSNumber" ],
        @"small": @[ @"./sizes/size[@name=\"small\"]", @"NSURL" ],
        @"small_width": @[ @"./sizes/size[@name=\"small\"]/@width", @"NSNumber" ],
        @"small_height": @[ @"./sizes/size[@name=\"small\"]/@height", @"NSNumber" ],
        @"title": @[ @"title", @"NSString" ],
        @"url": @[ @"url", @"NSURL" ],
        @"owner": @[ @"./owner/name", @"NSString" ],
        @"thumbsup": @[ @"./votes/thumbsup", @"NSNumber" ],
        @"thumbsdown": @[ @"./votes/thumbsdown", @"NSNumber" ]
    };

    return [self performApiCallForMethod:@"artist.getImages"
                              withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                               rootXpath:@"./images/image"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSimilarArtistsTo:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"match": @[ @"./match", @"NSNumber" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"artist.getSimilar"
                              withParams:@{ @"artist": [self forceString:artist], @"limit": @"500" }
                               rootXpath:@"./similarartists/artist"
                        returnDictionary:NO
                           mappingObject:mappingObject
                         successHandler:successHandler
                         failureHandler:failureHandler];
}

#pragma mark Album methods

- (NSOperation *)getInfoForAlbum:(NSString *)album artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"artist": @[ @"./artist", @"NSString" ],
        @"name": @[ @"./name", @"NSString" ],
        @"listeners": @[ @"./listeners", @"NSNumber" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"url": @[ @"./url", @"NSURL" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"releasedate": @[ @"./releasedate", @"NSString" ],
        @"tags": @[ @"./toptags/tag/name", @"NSArray" ],
        @"userplaycount": @[ @"./userplaycount", @"NSNumber" ],
        @"summary": @[ @"./wiki/summary", @"NSString" ]
    };

    return [self performApiCallForMethod:@"album.getInfo"
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album] }
                               rootXpath:@"./album"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTracksForAlbum:(NSString *)album artist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"rank": @[ @"@rank", @"NSNumber" ],
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"name": @[ @"./name", @"NSString" ],
        @"duration": @[ @"./duration", @"NSNumber" ],
        @"url": @[ @"./url", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"album.getInfo"
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album], @"1": @"1" }
                               rootXpath:@"./album/tracks/track"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getBuyLinksForAlbum:(NSString *)album artist:(NSString *)artist country:(NSString *)country successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"url": @[ @"./buyLink", @"NSURL" ],
        @"price": @[ @"./price/amount", @"NSNumber" ],
        @"currency": @[ @"./price/currency", @"NSString" ],
        @"name": @[ @"./supplierName", @"NSString" ],
        @"icon": @[ @"./supplierIcon", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"album.getBuylinks"
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album], @"country": [self forceString:country] }
                               rootXpath:@"./affiliations/downloads/affiliation"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getTopTagsForAlbum:(NSString *)album artist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"count": @[ @"./count", @"NSNumber" ],
        @"url": @[ @"./url", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"album.getTopTags"
                              withParams:@{ @"artist": [self forceString:artist], @"album": [self forceString:album] }
                               rootXpath:@"./toptags/tag"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark Track methods

- (NSOperation *)getInfoForTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"listeners": @[ @"./listeners", @"NSNumber" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"tags": @[ @"./toptags/tag/name", @"NSArray" ],
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"album": @[ @"./album/title", @"NSString" ],
        @"image": @[ @"./album/image[@size=\"large\"]", @"NSURL" ],
        @"wiki": @[ @"./wiki/summary", @"NSString" ],
        @"duration": @[ @"./duration", @"NSNumber" ],
        @"userplaycount": @[ @"./userplaycount", @"NSNumber" ],
        @"userloved": @[ @"./userloved", @"NSNumber" ],
        @"url": @[ @"./url", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"track.getInfo"
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                               rootXpath:@"./track"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getInfoForTrack:(NSString *)musicBrainId successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"listeners": @[ @"./listeners", @"NSNumber" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"tags": @[ @"./toptags/tag/name", @"NSArray" ],
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"album": @[ @"./album/title", @"NSString" ],
        @"image": @[ @"./album/image[@size=\"large\"]", @"NSURL" ],
        @"wiki": @[ @"./wiki/summary", @"NSString" ],
        @"duration": @[ @"./duration", @"NSNumber" ],
        @"userplaycount": @[ @"./userplaycount", @"NSNumber" ],
        @"userloved": @[ @"./userloved", @"NSNumber" ],
        @"url": @[ @"./url", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"track.getInfo"
                             withParams:@{ @"mbid": [self forceString:musicBrainId] }
                              rootXpath:@"./track"
                       returnDictionary:YES
                          mappingObject:mappingObject
                         successHandler:successHandler
                         failureHandler:failureHandler];
}

- (NSOperation *)loveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.love"
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                               rootXpath:@"."
                        returnDictionary:YES
                           mappingObject:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)unloveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.unlove"
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                               rootXpath:@"."
                        returnDictionary:YES
                           mappingObject:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)banTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.ban"
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                               rootXpath:@"."
                        returnDictionary:YES
                           mappingObject:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)unbanTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    return [self performApiCallForMethod:@"track.unban"
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist] }
                               rootXpath:@"."
                        returnDictionary:YES
                           mappingObject:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getBuyLinksForTrack:(NSString *)title artist:(NSString *)artist country:(NSString *)country successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"url": @[ @"./buyLink", @"NSURL" ],
        @"price": @[ @"./price/amount", @"NSNumber" ],
        @"currency": @[ @"./price/currency", @"NSString" ],
        @"name": @[ @"./supplierName", @"NSString" ],
        @"icon": @[ @"./supplierIcon", @"NSURL" ]
    };

    return [self performApiCallForMethod:@"track.getBuylinks"
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist], @"country": [self forceString:country] }
                               rootXpath:@"./affiliations/downloads/affiliation"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSimilarTracks:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
                                    @"name": @[ @"./name", @"NSString" ],
                                    @"match": @[ @"./match", @"NSNumber" ],
                                    @"artist": @[ @"./artist/name", @"NSString" ]
                                    };
    
    return [self performApiCallForMethod:@"track.getSimilar"
                              withParams:@{ @"artist": [self forceString:artist], @"track": [self forceString:title], @"limit": @"25", @"autocorrect": @"1" }
                               rootXpath:@"./similartracks/track"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

#pragma mark User methods

// Please note: to use this method, your API key needs special permission
- (NSOperation *)createUserWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"url": @[ @"./url", @"NSURL" ],
    };

    NSDictionary *params = @{
        @"username": [self forceString:username],
        @"password": [self forceString:password],
        @"email": [self forceString:email],
    };

    return [self performApiCallForMethod:@"user.signUp"
                                useCache:NO
                              withParams:params
                               rootXpath:@"./user"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSessionForUser:(NSString *)username password:(NSString *)password successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    username = [self forceString:username];
    password = [self forceString:password];
    NSString *authToken = [self md5sumFromString:[NSString stringWithFormat:@"%@%@", [username lowercaseString], [self md5sumFromString:password]]];

    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"key": @[ @"./key", @"NSString" ],
        @"subscriber": @[ @"./subscriber", @"NSNumber" ]
    };

    return [self performApiCallForMethod:@"auth.getMobileSession"
                                useCache:NO
                              withParams:@{ @"username": [username lowercaseString], @"authToken": authToken }
                               rootXpath:@"./session"
                        returnDictionary:YES
                            mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getSessionInfoWithSuccessHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./session/name", @"NSString" ],
        @"subscriber": @[ @"./session/subscriber", @"NSNumber" ],
        @"country": @[ @"./country", @"NSString" ],
        @"radio_enabled": @[ @"./radioPermission/user[@type=\"you\"]/radio", @"NSNumber" ],
        @"trial_enabled": @[ @"./radioPermission/user[@type=\"you\"]/freetrial", @"NSNumber" ],
        @"trial_expired": @[ @"./radioPermission/user[@type=\"you\"]/trial/expired", @"NSNumber" ],
        @"trial_playsleft": @[ @"./radioPermission/user[@type=\"you\"]/trial/playsleft", @"NSNumber" ],
        @"trial_playselapsed": @[ @"./radioPermission/user[@type=\"you\"]/trial/playselapsed", @"NSNumber" ]
    };

    return [self performApiCallForMethod:@"auth.getSessionInfo"
                                useCache:NO
                              withParams:@{}
                               rootXpath:@"./application"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getInfoForUserOrNil:(NSString *)username successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./realname", @"NSString" ],
        @"username": @[ @"./name", @"NSString" ],
        @"gender": @[ @"./gender", @"NSString" ],
        @"age": @[ @"./age", @"NSNumber" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"country": @[ @"./country", @"NSString" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"url": @[ @"./url", @"NSURL" ]
    };

    NSDictionary *params = @{};
    if (username) {
        params = @{ @"user": [self forceString:username] };
    }

    return [self performApiCallForMethod:@"user.getInfo"
                              withParams:params
                               rootXpath:@"./user"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)sendNowPlayingTrack:(NSString *)track byArtist:(NSString *)artist onAlbum:(NSString *)album withDuration:(NSTimeInterval)duration successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *params = @{
        @"track": [self forceString:track],
        @"artist": [self forceString:artist],
        @"album": [self forceString:album],
        @"duration": @((int)duration)
    };

    return [self performApiCallForMethod:@"track.updateNowPlaying"
                              withParams:params
                               rootXpath:@"."
                        returnDictionary:YES
                           mappingObject:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)sendScrobbledTrack:(NSString *)track byArtist:(NSString *)artist onAlbum:(NSString *)album withDuration:(NSTimeInterval)duration atTimestamp:(NSTimeInterval)timestamp successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *params = @{
        @"track": [self forceString:track],
        @"artist": [self forceString:artist],
        @"album": [self forceString:album],
        @"duration": @((int)duration),
        @"timestamp": @((int)timestamp)
    };

    return [self performApiCallForMethod:@"track.scrobble"
                              withParams:params
                               rootXpath:@"."
                        returnDictionary:YES
                           mappingObject:@{}
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getNewReleasesForUserBasedOnRecommendations:(BOOL)basedOnRecommendations successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"releasedate": @[ @"@releasedate", @"NSString" ]
    };

    NSDictionary *params = @{
        @"user": [self forceString:[self username]],
        @"userec": @(basedOnRecommendations)
    };

    return [self performApiCallForMethod:@"user.getNewReleases"
                              withParams:params
                               rootXpath:@"./albums/album"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getRecommendedAlbumsWithLimit:(NSInteger)limit successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"context": @[ @"./context/artist/name", @"NSArray" ],
    };

    return [self performApiCallForMethod:@"user.getRecommendedAlbums"
                              withParams:@{ @"limit": @(limit) }
                               rootXpath:@"./recommendations/album"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (void)logout {
    self.session = nil;
    self.username = nil;
}

#pragma mark Chart methods

- (NSOperation *)getTopTracksWithLimit:(NSInteger)limit page:(NSInteger)page successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"playcount": @[ @"./playcount", @"NSNumber" ],
        @"listeners": @[ @"./listeners", @"NSNumber" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"artist": @[ @"./artist/name", @"NSString" ]
    };

    return [self performApiCallForMethod:@"chart.getTopTracks"
                              withParams:@{ @"limit": @(limit), @"page": @(page) }
                               rootXpath:@"./tracks/track"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

- (NSOperation *)getHypedTracksWithLimit:(NSInteger)limit page:(NSInteger)page successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler {
    NSDictionary *mappingObject = @{
        @"name": @[ @"./name", @"NSString" ],
        @"image": @[ @"./image[@size=\"large\"]", @"NSURL" ],
        @"artist": @[ @"./artist/name", @"NSString" ],
        @"percentagechange": @[ @"./percentagechange", @"NSNumber" ]
    };

    return [self performApiCallForMethod:@"chart.getHypedTracks"
                              withParams:@{ @"limit": @(limit), @"page": @(page) }
                               rootXpath:@"./tracks/track"
                        returnDictionary:NO
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

@end

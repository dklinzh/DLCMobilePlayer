//
//  DLCBaseVideoView+Snapshot.m
//  DLCMobilePlayer
//
//  Created by Linzh on 11/10/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCBaseVideoView+Snapshot.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface DLCBaseVideoView ()

@end

@implementation DLCBaseVideoView (Snapshot)
#pragma mark - Public
- (UIImage *)takeVideoSnapshotImage {
    return [self takeVideoSnapshotImageForKey:[DLCBaseVideoView defaultKey]];
}

- (UIImage *)takeVideoSnapshotImageForKey:(NSString *)key {
    NSString *path = [self takeVideoSnapshotPathForKey:key];
    if (!path) {
        return nil;
    }
    
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)takeVideoSnapshotPath {
    return [self takeVideoSnapshotPathForKey:[DLCBaseVideoView defaultKey]];
}

- (NSString *)takeVideoSnapshotPathForKey:(NSString *)key {
    if (!self.isVideoPlayed || !key) {
        return nil;
    }
    NSError *error = nil;
    NSString *directoryPath = [DLCBaseVideoView defaultDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        return nil;
    }
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:key];
    VLCMediaPlayer *mediaPlayer = [self valueForKey:@"mediaPlayer"];
    @try {
        [mediaPlayer saveVideoSnapshotAt:filePath withWidth:0 andHeight:0];
    } @catch (NSException *e) {
        NSLog(@"DLCMobilePlayer -error: %@", e);
        return nil;
    }
    NSLog(@"DLCMobilePlayer -snapshot: %@", filePath);
    return filePath;
}

- (NSString *)takeVideoSnapshotUrlForKey:(NSString *)key {
    NSString *path = [self takeVideoSnapshotPathForKey:key];
    if (!path) {
        return nil;
    }
    
    return [[NSURL fileURLWithPath:path] absoluteString];
}

- (NSString *)takeVideoSnapshotUrl {
    return [self takeVideoSnapshotUrlForKey:[DLCBaseVideoView defaultKey]];
}

+ (UIImage *)videoSnapshotImageForKey:(NSString *)key {
    NSString *path = [self videoSnapshotPathForKey:key];
    if (!path) {
        return nil;
    }
    
    return [UIImage imageWithContentsOfFile:path];
}

+ (NSString *)videoSnapshotPathForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    
    NSString *path = [[self defaultDirectory] stringByAppendingPathComponent:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return nil;
}

+ (NSString *)videoSnapshotUrlForKey:(NSString *)key {
    NSString *path = [self videoSnapshotPathForKey:key];
    if (!path) {
        return nil;
    }
    
    return [[NSURL fileURLWithPath:path] absoluteString];
}

#pragma mark - Private
+ (NSString *)defaultKey {
    return [NSString stringWithFormat:@"%ld", (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000)];
}

+ (NSString *)defaultDirectory {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"dlc_snapshot"];
}
@end

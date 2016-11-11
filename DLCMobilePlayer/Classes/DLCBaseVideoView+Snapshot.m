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
    return [self takeVideoSnapshotImageForKey:[self defaultKey]];
}

- (UIImage *)takeVideoSnapshotImageForKey:(NSString *)key {
    NSString *filePath = [self takeVideoSnapshotPathForKey:key];
    if (!filePath) {
        return nil;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}

- (NSString *)takeVideoSnapshotPath {
    return [self takeVideoSnapshotPathForKey:[self defaultKey]];
}

- (NSString *)takeVideoSnapshotPathForKey:(NSString *)key {
    if (!self.isVideoPlayed) {
        return nil;
    }
    NSError *error = nil;
    NSString *directoryPath = [self defaultDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        return nil;
    }
    NSString *filePath = [directoryPath stringByAppendingPathComponent:key];
    VLCMediaPlayer *mediaPlayer = [self valueForKey:@"mediaPlayer"];
    [mediaPlayer saveVideoSnapshotAt:filePath withWidth:0 andHeight:0];
    return filePath;
}

- (UIImage *)videoSnapshotImageForKey:(NSString *)key {
    NSString *path = [self videoSnapshotImageForKey:key];
    if (!path) {
        return nil;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (NSString *)videoSnapshotPathForKey:(NSString *)key {
    NSString *path = [[self defaultDirectory] stringByAppendingPathComponent:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return nil;
}

#pragma mark - Private
- (NSString *)defaultKey {
    return [NSString stringWithFormat:@"%ld", (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000)];
}

- (NSString *)defaultDirectory {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"dlc_snapshot"];
}
@end

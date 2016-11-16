//
//  DLCBaseVideoView+Snapshot.h
//  DLCMobilePlayer
//
//  Created by Linzh on 11/10/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <DLCMobilePlayer/DLCBaseVideoView.h>

@interface DLCBaseVideoView (Snapshot)

- (UIImage *)takeVideoSnapshotImage;

- (NSString *)takeVideoSnapshotPath;

- (NSString *)takeVideoSnapshotUrl;

- (UIImage *)takeVideoSnapshotImageForKey:(NSString *)key;

- (NSString *)takeVideoSnapshotPathForKey:(NSString *)key;

- (NSString *)takeVideoSnapshotUrlForKey:(NSString *)key;

+ (UIImage *)videoSnapshotImageForKey:(NSString *)key;

+ (NSString *)videoSnapshotPathForKey:(NSString *)key;

+ (NSString *)videoSnapshotUrlForKey:(NSString *)key;
@end

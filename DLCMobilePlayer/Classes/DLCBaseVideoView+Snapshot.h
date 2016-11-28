//
//  DLCBaseVideoView+Snapshot.h
//  DLCMobilePlayer
//
//  Created by Linzh on 11/10/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <DLCMobilePlayer/DLCBaseVideoView.h>

@interface DLCBaseVideoView (Snapshot)

/**
 Take and save a snapshot of the video with a default key.

 @return The image object of the snapshot saved.
 */
- (UIImage *)takeVideoSnapshotImage;

/**
 Take and save a snapshot of the video with a default key.

 @return The file path of the snapshot saved.
 */
- (NSString *)takeVideoSnapshotPath;

/**
 Take and save a snapshot of the video with a default key.

 @return The file url string of the snapshot saved.
 */
- (NSString *)takeVideoSnapshotUrl;

/**
 Take and save a snapshot of the video with a specified key used in reading cache later.
 
 @return The image object of the snapshot saved.
 */
- (UIImage *)takeVideoSnapshotImageForKey:(NSString *)key;

/**
 Take and save a snapshot of the video with a specified key used in reading cache later.
 
 @return The file path of the snapshot saved.
 */
- (NSString *)takeVideoSnapshotPathForKey:(NSString *)key;

/**
 Take and save a snapshot of the video with a specified key used in reading cache later.
 
 @return The file url string of the snapshot saved.
 */
- (NSString *)takeVideoSnapshotUrlForKey:(NSString *)key;

/**
 Get the image object of video snapshot by a specified key.

 @param key A specified key for getting the video snapshot saved before.
 @return The image object of video snapshot.
 */
+ (UIImage *)videoSnapshotImageForKey:(NSString *)key;

/**
 Get the file path of video snapshot by a specified key.

 @param key A specified key for getting the video snapshot saved before.
 @return The file path of video snapshot.
 */
+ (NSString *)videoSnapshotPathForKey:(NSString *)key;

/**
 Get the file url of video snapshot by a specified key.

 @param key A specified key for getting the video snapshot saved before.
 @return The file url of video snapshot.
 */
+ (NSString *)videoSnapshotUrlForKey:(NSString *)key;
@end

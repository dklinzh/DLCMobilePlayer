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

- (UIImage *)takeVideoSnapshotImageForKey:(NSString *)key;

- (NSString *)takeVideoSnapshotPath;

- (NSString *)takeVideoSnapshotPathForKey:(NSString *)key;

- (UIImage *)videoSnapshotImageForKey:(NSString *)key;

- (NSString *)videoSnapshotPathForKey:(NSString *)key;
@end

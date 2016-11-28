//
//  DLCLiveVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 11/2/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <DLCMobilePlayer/DLCBaseVideoView.h>

/**
 A player view for the live video.
 */
@interface DLCLiveVideoView : DLCBaseVideoView <UIAlertViewDelegate>

/**
 Determine whether the player should be allowed to play on the WWAN network.
 */
@property (nonatomic, assign) BOOL allowPlayingViaWWAN;

/**
 Play the live video.
 */
- (void)playLiveVideo;

/**
 Pause the live video.
 */
- (void)pauseLiveVideo;

/**
 Stop the live video.
 */
- (void)stopLiveVideo;
@end

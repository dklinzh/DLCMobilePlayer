//
//  DLCLiveVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 11/2/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCBaseVideoView.h"

@interface DLCLiveVideoView : DLCBaseVideoView
@property (nonatomic, assign) BOOL allowPlayingViaWWAN;

- (void)playLiveVideo;

- (void)pauseLiveVideo;

- (void)stopLiveVideo;
@end

//
//  DLCBaseVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLCVideoActionDelegate <NSObject>

- (void)dlc_videoWillPlay;
- (void)dlc_videoWillStop;

@end

typedef void(^DLCVideoVisibleBlock)(BOOL visible);

@interface DLCBaseVideoView : UIView <DLCVideoActionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *visibleBarButton;

@property (nonatomic, strong) NSString *mediaURL;
@property (nonatomic, assign) IBInspectable BOOL shouldAutoPlay;
@property (nonatomic, assign) IBInspectable BOOL shouldPauseInBackground;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly, getter=isMuted) BOOL muted;
@property (nonatomic, assign, readonly, getter=isBuffering) BOOL buffering;
@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, copy) DLCVideoVisibleBlock videoVisibleBlock;

- (void)playVideo;

- (void)pauseVideo;

- (void)stopVideo;

- (UIImage *)takeVideoSnapshot;
@end

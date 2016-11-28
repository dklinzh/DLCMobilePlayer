//
//  DLCBaseVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Animation styles for the hidden transition of player tool bar.

 - DLCHiddenAnimationNone: Hiding view with none animation.
 - DLCHiddenAnimationFade: Hiding view with the faded animation.
 - DLCHiddenAnimationSlide: Hiding view with the sliding animation.
 - DLCHiddenAnimationFadeSlide: Hiding view with the combination of both faded animation and sliding animation.
 */
typedef NS_ENUM(NSInteger, DLCHiddenAnimation) {
    DLCHiddenAnimationNone = 0,
    DLCHiddenAnimationFade = 1,
    DLCHiddenAnimationSlide = 1 << 1,
    DLCHiddenAnimationFadeSlide = DLCHiddenAnimationFade | DLCHiddenAnimationSlide,
};


/**
 The delegate of video player control action.
 */
@protocol DLCVideoActionDelegate <NSObject>

@optional

/**
 Video will be played.
 */
- (void)dlc_videoWillPlay;

/**
 Video will be stoped.
 */
- (void)dlc_videoWillStop;

/**
 The full screen mode of player is changed.

 @param isFullScreen Indicate whether the player is in full screen mode.
 */
- (void)dlc_videoFullScreenChanged:(BOOL)isFullScreen;

/**
 The player is active with waking up by user's interaction

 @param isActive Indicate whether the player is in active state.
 */
- (void)dlc_playerControlActive:(BOOL)isActive;
@end

@interface DLCBaseVideoView : UIView <DLCVideoActionDelegate>

/**
 The main play button in the center of player screen.
 */
@property (weak, nonatomic, readonly) IBOutlet UIButton *videoPlayButton;

/**
 The tool bar for the player control.
 */
@property (weak, nonatomic, readonly) IBOutlet UIView *toolbarView;

/**
 The label for the hint of player status.
 */
@property (weak, nonatomic, readonly) IBOutlet UILabel *hintLabel;

/**
 Indicate whether the player is playing.
 */
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

/**
 Indicate whether the current video has been played.
 */
@property (nonatomic, assign, readonly, getter=isVideoPlayed) BOOL videoPlayed;

/**
 Indicate whether the player is muted.
 */
@property (nonatomic, assign, readonly, getter=isMuted) BOOL muted;

/**
 Indicate whether the video stream is in buffering.
 */
@property (nonatomic, assign, readonly, getter=isBuffering) BOOL buffering;

/**
 Indicate whether the player is in full screen mode.
 */
@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;

/**
 Indicate whether the player control is in active state.
 */
@property (nonatomic, assign, readonly, getter=isControlActive) BOOL controlActive;

/**
 Get/Set the local or remote url string of the media resource.
 */
@property (nonatomic, strong) NSString *mediaURL;

/**
 Get/Set the text of hint lable for player status.
 */
@property (nonatomic, strong) IBInspectable NSString *hintText;

/**
 Determine whether the player should be played automactically when it is available and displayed, or media resource changed.
 */
@property (nonatomic, assign) IBInspectable BOOL shouldAutoPlay;

/**
 Determine whether the player should be paused when the app enter background or its super view controller disappears.
 */
@property (nonatomic, assign) IBInspectable BOOL shouldPauseInBackground;

/**
 Determine the layer of player control should be hidden automactically after a specified time interval.
 */
@property (nonatomic, assign) IBInspectable BOOL shouldControlAutoHidden;

/**
 Get/Set the time interval of player control hiding. Default value is 5s.
 */
@property (nonatomic, assign) NSTimeInterval hiddenInterval;

/**
 Get/Set the duration of player control hidden animation. Default value is 0.6s.
 */
@property (nonatomic, assign) NSTimeInterval hiddenDuration;

/**
 Get/Set the animation styles for the hidden transition of player tool bar. Default value is DLCHiddenAnimationFadeSlide.
 */
@property (nonatomic, assign) DLCHiddenAnimation hiddenAnimation;

/**
 Get/Set the other additional buttons on the player tool bar.
 */
@property (nonatomic, strong) NSArray<UIButton *> *otherToolBarButtons;

/**
 Play the video.
 */
- (void)playVideo;

/**
 Pause the video.
 */
- (void)pauseVideo;

/**
 Stop the video.
 */
- (void)stopVideo;

@end

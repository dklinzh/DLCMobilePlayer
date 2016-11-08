//
//  DLCBaseVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DLCVideoActionDelegate <NSObject>

@optional
- (void)dlc_videoWillPlay;
- (void)dlc_videoWillStop;
- (void)dlc_videoFullScreenChanged:(BOOL)isFullScreen;
@end

@interface DLCBaseVideoView : UIView <DLCVideoActionDelegate>
@property (weak, nonatomic, readonly) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic, readonly) IBOutlet UIView *toolbarView;
@property (weak, nonatomic, readonly) IBOutlet UILabel *hintLabel;

@property (nonatomic, strong) NSString *mediaURL;
@property (nonatomic, assign) IBInspectable BOOL shouldAutoPlay;
@property (nonatomic, assign) IBInspectable BOOL shouldPauseInBackground;
@property (nonatomic, strong) IBInspectable NSString *hintText;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly, getter=isMuted) BOOL muted;
@property (nonatomic, assign, readonly, getter=isBuffering) BOOL buffering;
@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;
@property (nonatomic, strong) NSArray<UIButton *> *otherToolBarButtons;

- (void)playVideo;

- (void)pauseVideo;

- (void)stopVideo;

- (UIImage *)takeVideoSnapshot;
@end

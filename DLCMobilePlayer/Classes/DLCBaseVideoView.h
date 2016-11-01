//
//  DLCBaseVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DLCVideoVisibleBlock)(BOOL visible);

@interface DLCBaseVideoView : UIView
@property (weak, nonatomic) IBOutlet UIButton *visibleBarButton;

@property (nonatomic, strong) NSString *mediaURL;
@property (nonatomic, assign) BOOL shouldAutoPlay;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, getter=isMuted) BOOL muted;
@property (nonatomic, assign, getter=isBuffering) BOOL buffering;
@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, copy) DLCVideoVisibleBlock videoVisibleBlock;

- (void)playVideo;

- (void)pauseVideo;

- (void)stopVideo;

- (UIImage *)takeVideoSnapshot;
@end

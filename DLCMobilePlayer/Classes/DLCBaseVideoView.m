//
//  DLCBaseVideoView.m
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCBaseVideoView.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "UIView+DLCAnimation.h"
#import "UIDevice+DLCOrientation.h"
#import "Aspects.h"

static NSString *const kContentViewNibName = @"DLCBaseVideoContentView";

@interface DLCBaseVideoView () <VLCMediaPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *playBarButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceBarButton;

@property (weak, nonatomic) IBOutlet UIButton *fullScreenBarButton;
@property (weak, nonatomic) IBOutlet UIView *videoDrawableView;
@property (weak, nonatomic) IBOutlet UIImageView *videoBufferingView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, weak) id<AspectToken> aspectToken;
@property (nonatomic, weak) id<DLCVideoActionDelegate> videoActionDelegate;
@end

IB_DESIGNABLE
@implementation DLCBaseVideoView
#pragma mark - Public
- (void)playVideo {
    if (!self.isPlaying) {
        if (!self.mediaURL) {
            NSLog(@"DLCMobilePlayer -Error: mediaURL is null.");
            return;
        }
        self.playing = YES;
        if (self.mediaPlayer.isPlaying) {
            [self.mediaPlayer pause];
        }
        [self.mediaPlayer play];
    }
}

- (void)pauseVideo {
    if (self.isPlaying) {
        self.playing = NO;
        [self.mediaPlayer pause];
    }
}

- (void)stopVideo {
    self.playing = NO;
    [self.mediaPlayer stop];
}

- (UIImage *)takeVideoSnapshot {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"snapshot_%f", [[NSDate date] timeIntervalSince1970]]];
    [self.mediaPlayer saveVideoSnapshotAt:path withWidth:0 andHeight:0];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

#pragma mark - Override
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
        self.videoActionDelegate = self;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
        
        self.videoActionDelegate = self;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.shouldAutoPlay) {
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
            [self.videoActionDelegate dlc_videoWillPlay];
        }
    }
}

#pragma mark - Event
- (IBAction)videoPlayAction:(id)sender {
    if (self.playing) {
        self.playing = NO;
        [self.mediaPlayer pause];
    } else {
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
            [self.videoActionDelegate dlc_videoWillPlay];
        }
    }
}

- (IBAction)videoVoiceAction:(UIButton *)sender {
    if ((self.muted = !self.isMuted)) {
        self.mediaPlayer.audio.muted = YES;
    } else {
        self.mediaPlayer.audio.muted = NO;
    }
}

- (IBAction)videoVisibleAction:(UIButton *)sender {
    self.visible = !self.isVisible;
    
    if (self.videoVisibleBlock) {
        self.videoVisibleBlock(self.isVisible);
    }
}

- (IBAction)videoFullScreenAction:(UIButton *)sender {
    self.fullScreen = !self.isFullScreen;
}

#pragma mark - DLCVideoActionDelegate
- (void)dlc_videoWillPlay {
    [self playVideo];
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    NSLog(@"mediaPlayerStateChanged: %ld", (long)self.mediaPlayer.state);
 
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateError:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStatePaused:
            self.playing = NO;
            break;
        case VLCMediaPlayerStateBuffering:
            self.buffering = YES;
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    self.buffering = NO;
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    
}

#pragma mark - Private
- (void)setupView {
    NSBundle *bundle = [NSBundle bundleForClass:[DLCBaseVideoView class]];
    self.contentView = [bundle loadNibNamed:kContentViewNibName owner:self options:nil].firstObject;
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    //    [self.videoToolbar setBackgroundImage:[UIImage imageNamed:@"bg_toolbar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //    self.videoToolbar.clipsToBounds = YES;
    //    self.toolbarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_toolbar"]];
    
}

- (void)enterFullScreen {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    UIInterfaceOrientationMask defaultOrientationMask = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:window];
    Class delegateClass = [[UIApplication sharedApplication].delegate class];
    self.aspectToken = [delegateClass aspect_hookSelector:@selector(application:supportedInterfaceOrientationsForWindow:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, UIApplication *application, UIWindow *window) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscapeRight;
        [invocation setReturnValue:&orientationMask];
    } error:nil];
    
    [UIDevice dlc_setOrientation:UIInterfaceOrientationLandscapeRight];
    [self.contentView removeFromSuperview];
    self.contentView.frame = window.bounds;
    [window addSubview:self.contentView];
}

- (void)exitFullScreen {
    [self.aspectToken remove];
    
    [UIDevice dlc_setOrientation:UIInterfaceOrientationPortrait];
    [self.contentView removeFromSuperview];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    [self sendSubviewToBack:self.contentView];
}

- (void)videoVisible {
    if (self.isFullScreen) {
        [self.visibleBarButton setImage:DLCImageNamed(@"btn_full_visible") forState:UIControlStateNormal];
    } else {
        [self.visibleBarButton setImage:DLCImageNamed(@"btn_toolbar_visible") forState:UIControlStateNormal];
    }
}

- (void)videoInvisible {
    if (self.isFullScreen) {
        [self.visibleBarButton setImage:DLCImageNamed(@"btn_full_invisible") forState:UIControlStateNormal];
    } else {
        [self.visibleBarButton setImage:DLCImageNamed(@"btn_toolbar_invisible") forState:UIControlStateNormal];
    }
}

- (void)mutedOn {
    if (self.isFullScreen) {
        [self.voiceBarButton setImage:DLCImageNamed(@"btn_full_voice_mute") forState:UIControlStateNormal];
    } else {
        [self.voiceBarButton setImage:DLCImageNamed(@"btn_toolbar_voice_mute") forState:UIControlStateNormal];
    }
}

- (void)mutedOff {
    if (self.isFullScreen) {
        [self.voiceBarButton setImage:DLCImageNamed(@"btn_full_voice") forState:UIControlStateNormal];
    } else {
        [self.voiceBarButton setImage:DLCImageNamed(@"btn_toolbar_voice") forState:UIControlStateNormal];
    }
}

- (void)videoPalyed {
    self.videoPlayButton.hidden = YES;
    if (self.isFullScreen) {
        [self.playBarButton setImage:DLCImageNamed(@"btn_full_pause") forState:UIControlStateNormal];
    } else {
        [self.playBarButton setImage:DLCImageNamed(@"btn_toolbar_pause") forState:UIControlStateNormal];
    }
}

- (void)videoStoped {
    self.buffering = NO;
    self.videoPlayButton.hidden = NO;
    if (self.isFullScreen) {
        [self.playBarButton setImage:DLCImageNamed(@"btn_full_play") forState:UIControlStateNormal];
    } else {
        [self.playBarButton setImage:DLCImageNamed(@"btn_toolbar_play") forState:UIControlStateNormal];
    }
}

- (void)startBuffering {
    if (self.isPlaying) {
        self.videoBufferingView.hidden = NO;
        [self.videoBufferingView dlc_startRotateAnimationInDuration:2 repeatCout:HUGE_VALF];
    }
}

- (void)stopBuffering {
    [self.videoBufferingView dlc_stopRotateAnimation];
    self.videoBufferingView.hidden = YES;
}

#pragma mark - G/S
- (VLCMediaPlayer *)mediaPlayer {
    if (_mediaPlayer) {
        return _mediaPlayer;
    }
    _mediaPlayer = [[VLCMediaPlayer alloc] init];
    _mediaPlayer.delegate = self;
    _mediaPlayer.drawable = self.videoDrawableView;
    return _mediaPlayer;
}

- (void)setMediaURL:(NSString *)mediaURL {
    if (mediaURL && ![mediaURL isEqualToString:_mediaURL]) {
        [self stopVideo];
        
        _mediaURL = mediaURL;
        self.mediaPlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:mediaURL]];
        
        if (self.shouldAutoPlay && self.window) {
            [self playVideo];
        }
    }
}

- (void)setPlaying:(BOOL)playing {
    if (_playing != playing) {
        _playing = playing;
        if (_playing) {
            [self videoPalyed];
        } else {
            [self videoStoped];
        }
    }
}

- (void)setMuted:(BOOL)muted {
    if (_muted != muted) {
        _muted = muted;
        if (_muted) {
            [self mutedOn];
        } else {
            [self mutedOff];
        }
    }
}

- (void)setBuffering:(BOOL)buffering {
    if (_buffering != buffering) {
        _buffering = buffering;
        if (_buffering) {
            [self startBuffering];
        } else {
            [self stopBuffering];
        }
    }
}

- (void)setFullScreen:(BOOL)fullScreen {
    if (_fullScreen != fullScreen) {
        _fullScreen = fullScreen;
        if (_fullScreen) {
            [self enterFullScreen];
            [self.fullScreenBarButton setImage:DLCImageNamed(@"btn_full_exit") forState:UIControlStateNormal];
            [self.videoPlayButton setImage:DLCImageNamed(@"btn_full_play_def") forState:UIControlStateNormal];
            [self.videoPlayButton setImage:DLCImageNamed(@"btn_full_play_hl") forState:UIControlStateHighlighted];
        } else {
            [self exitFullScreen];
            [self.fullScreenBarButton setImage:DLCImageNamed(@"btn_toolbar_full_screen") forState:UIControlStateNormal];
            [self.videoPlayButton setImage:DLCImageNamed(@"btn_video_play_def") forState:UIControlStateNormal];
            [self.videoPlayButton setImage:DLCImageNamed(@"btn_video_play_hl") forState:UIControlStateHighlighted];
        }
        if (self.isPlaying) {
            [self videoPalyed];
        } else {
            [self videoStoped];
        }
        if (self.isMuted) {
            [self mutedOn];
        } else {
            [self mutedOff];
        }
        if (self.isVisible) {
            [self videoVisible];
        } else {
            [self videoInvisible];
        }
    }
}

- (void)setVisible:(BOOL)visible {
    _visible = visible;
    if (_visible) {
        [self videoVisible];
    } else {
        [self videoInvisible];
    }
}
@end

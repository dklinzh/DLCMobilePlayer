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
static BOOL const kDefaultShouldPauseInBackground = YES;

@interface DLCBaseVideoView () <VLCMediaPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playBarButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceBarButton;

@property (weak, nonatomic) IBOutlet UIButton *fullScreenBarButton;
@property (weak, nonatomic) IBOutlet UIView *videoDrawableView;
@property (weak, nonatomic) IBOutlet UIImageView *videoBufferingView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, weak) id<AspectToken> aspectToken;
@property (nonatomic, weak) id<DLCVideoActionDelegate> videoActionDelegate;
@property (nonatomic, assign) BOOL shouldResumeInActive;
@property (nonatomic, assign, getter=isVideoPlayed) BOOL videoPlayed;
@end

IB_DESIGNABLE
@implementation DLCBaseVideoView

#pragma mark - Public
- (void)playVideo {
    if (!self.isPlaying) {
        [self play];
        
        [self addObserverForPauseInBackground];
    }
}

- (void)pauseVideo {
    if (self.isPlaying) {
        [self pause];
        
        [self removeObserverForPauseInBackground];
    }
}

- (void)stopVideo {
    [self stop];
    
    [self removeObserverForPauseInBackground];
}

- (UIImage *)takeVideoSnapshot {
    if (!self.isVideoPlayed) {
        return nil;
    }
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
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
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

- (void)dealloc {
//    [self stopVideo];
    self.shouldPauseInBackground = NO;
}



#pragma mark - Event
- (IBAction)videoPlayAction:(id)sender {
    if (self.playing) {
        [self pauseVideo];
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

- (IBAction)videoFullScreenAction:(UIButton *)sender {
    if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoFullScreenChanged:)]) {
        [self.videoActionDelegate dlc_videoFullScreenChanged:!self.isFullScreen];
    }
}

#pragma mark - DLCVideoActionDelegate
- (void)dlc_videoWillPlay {
    [self playVideo];
}

- (void)dlc_videoWillStop {
    [self stopVideo];
}

- (void)dlc_videoFullScreenChanged:(BOOL)isFullScreen {
    self.fullScreen = isFullScreen;
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    NSLog(@"mediaPlayerStateChanged: %ld", (long)self.mediaPlayer.state);
 
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateError:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateEnded:
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
                [self.videoActionDelegate dlc_videoWillStop];
            }
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
    self.videoPlayed = YES;
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    
}

#pragma mark - Private
- (void)setup {
    [self setupView];
    
    self.videoActionDelegate = self;
    self.shouldPauseInBackground = kDefaultShouldPauseInBackground;
}

- (void)setupView {
    NSBundle *bundle = [NSBundle bundleForClass:[DLCBaseVideoView class]];
    self.contentView = [bundle loadNibNamed:kContentViewNibName owner:self options:nil].firstObject;
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    //    [self.videoToolbar setBackgroundImage:[UIImage imageNamed:@"bg_toolbar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //    self.videoToolbar.clipsToBounds = YES;
    //    self.toolbarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_toolbar"]];
}

- (void)addObserverForPauseInBackground {
    if (self.shouldPauseInBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeInActive)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseInBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

- (void)removeObserverForPauseInBackground {
    self.shouldResumeInActive = NO;
    if (self.shouldPauseInBackground) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

- (void)pauseInBackground {
    if (self.isPlaying) {
        self.shouldResumeInActive = YES;
        [self pause];
    }
}

- (void)resumeInActive {
    if (self.shouldResumeInActive) {
        self.shouldResumeInActive = NO;
        [self play];
    }
}

- (void)play {
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

- (void)pause {
    self.playing = NO;
    [self.mediaPlayer pause];
}

- (void)stop {
    self.playing = NO;
    [self.mediaPlayer stop];
    self.videoPlayed = NO;
}

- (void)enterFullScreen {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    UIInterfaceOrientationMask defaultOrientationMask = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:window];
    Class delegateClass = [[UIApplication sharedApplication].delegate class];
    self.aspectToken = [delegateClass aspect_hookSelector:@selector(application:supportedInterfaceOrientationsForWindow:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, UIApplication *application, UIWindow *window) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscape;
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
    if (mediaURL) {
        if (![mediaURL isEqualToString:_mediaURL]) {
            _mediaURL = mediaURL;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.mediaPlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:mediaURL]];
            });
            
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
                [self.videoActionDelegate dlc_videoWillStop];
            }
            
            if (self.shouldAutoPlay && self.window) {
                if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
                    [self.videoActionDelegate dlc_videoWillPlay];
                }
            }
        }
    } else {
        _mediaURL = mediaURL;
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
            [self.videoActionDelegate dlc_videoWillStop];
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
    }
}

- (void)setShouldPauseInBackground:(BOOL)shouldPauseInBackground {
    if (_shouldPauseInBackground != shouldPauseInBackground) {
        _shouldPauseInBackground = shouldPauseInBackground;
        if (!_shouldPauseInBackground) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidBecomeActiveNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    }
}

- (void)setOtherToolBarButtons:(NSArray<UIButton *> *)otherToolBarButtons {
    _otherToolBarButtons = otherToolBarButtons;
    if (_otherToolBarButtons) {
        NSUInteger count = _otherToolBarButtons.count;
        if (count > 0) {
            int margin = 18;
            NSDictionary *metrics = @{ @"margin": @(margin) };
            NSMutableString *Hvfl = [NSMutableString stringWithString:@"H:[btn_base]"];
            NSMutableDictionary *views = [NSMutableDictionary dictionaryWithDictionary:@{ @"btn_base": self.voiceBarButton }];
            for (int i = 0; i < count; i++) {
                UIButton *btn = _otherToolBarButtons[i];
                btn.translatesAutoresizingMaskIntoConstraints = NO;
                [self.toolbarView addSubview:btn];
                
                [Hvfl appendFormat:@"-margin-[btn_%d]", i];
                [views setValue:btn forKey:[NSString stringWithFormat:@"btn_%d", i]];
            }
            NSArray *Hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:Hvfl options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
            [self.toolbarView addConstraints:Hconstraints];
        }
    }
}

#pragma mark - IBInspectable
- (void)setHintText:(NSString *)hintText {
    _hintText = hintText;
    self.hintLabel.text = _hintText;
}

@end

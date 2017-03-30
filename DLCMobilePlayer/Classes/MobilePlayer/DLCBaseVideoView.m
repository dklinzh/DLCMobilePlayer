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
#import "MSWeakTimer.h"

NSString *const kDLCNotificationVideoDidPlay = @"kDLCNotificationVideoDidPlay";

static NSString *const kContentViewNibName = @"DLCBaseVideoContentView";
static NSTimeInterval const kDefaultHiddenDuration = 0.6;
static NSTimeInterval const kDefaultHiddenInterval = 5;

@interface DLCBaseVideoView () <VLCMediaPlayerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoDrawableView;

@property (nonatomic, weak) UIViewController *superViewController;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, weak) id<AspectToken> orientationAspectToken;
@property (nonatomic, weak) id<AspectToken> viewAppearAspectToken;
@property (nonatomic, weak) id<AspectToken> viewDisappearAspectToken;
@property (nonatomic, weak) id<DLCVideoActionDelegate> videoActionDelegate;
@property (nonatomic, assign) BOOL shouldResumeInActive;
@property (nonatomic, assign) BOOL videoPlayed;
@property (nonatomic, assign, getter=isToolBarHidden) BOOL toolBarHidden;
@property (nonatomic, strong) dispatch_queue_t playerControlQueue;
@property (nonatomic, strong) MSWeakTimer *toolbarHiddenTimer;
@property (nonatomic, assign) UIInterfaceOrientation originalOrientation;
@property (nonatomic, assign) BOOL observerForPauseInBackgroundAdded;
@property (nonatomic, assign) BOOL controlActive;
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

#pragma mark - Override
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        if (!self.isVideoPlayed && self.shouldAutoPlay && self.mediaURL) {
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
                [self.videoActionDelegate dlc_videoWillPlay];
            }
        }
        [self resetToolBarHiddenTimer];
    }
}

- (void)dealloc {
    _videoActionDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [_mediaPlayer stop];
    _mediaPlayer = nil;
    
    [_toolbarHiddenTimer invalidate];
    self.shouldPauseInBackground = NO;
    _superViewController = nil;
    
    if (_fullScreen) {
        [_orientationAspectToken remove];
        [UIDevice dlc_setOrientation:_originalOrientation];
    }
    
    [_contentView removeFromSuperview];
    _contentView = nil;
}

#pragma mark - Init
- (void)setup {
    [self setupView];
    
    self.videoActionDelegate = self;
    self.playerControlQueue = dispatch_queue_create("com.dklinzh.DLCMobilePlayer.controlQueue", DISPATCH_QUEUE_CONCURRENT);
    self.hiddenAnimation = -1;
    self.shouldPauseInBackground = YES;
    self.shouldControlAutoHidden = YES;
    
    [self initGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)setupView {
    NSBundle *bundle = [NSBundle bundleForClass:[DLCBaseVideoView class]];
    self.contentView = [bundle loadNibNamed:kContentViewNibName owner:self options:nil].firstObject;
    self.contentView.frame = self.bounds;
    self.contentView.clipsToBounds = YES;
    [self addSubview:self.contentView];
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

- (void)dlc_playerControlActive:(BOOL)isActive {
    if (self.controlActive = isActive) {
        [self showToolBarView];
        [self resetToolBarHiddenTimer];
    } else {
        [self hideToolBarView];
    }
}

#pragma mark - Gesture
- (void)initGesture {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] init];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:singleTap];
//    self.contentView.userInteractionEnabled = YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_playerControlActive:)]) {
            [self.videoActionDelegate dlc_playerControlActive:YES];
        }
    }
    return YES;
}

#pragma mark - Orientation
- (void)orientationDidChange {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }
    
    if (self.isToolBarHidden) {
        self.toolBarHidden = NO;
        [self hideToolBarView];
    }
}

#pragma mark - ToolBar
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

- (void)hideToolBarView {
    if (!self.isToolBarHidden) {
        self.toolBarHidden = YES;
        switch (self.hiddenAnimation) {
            case DLCHiddenAnimationFade:
                [self.toolbarView dlc_fadeOutAnimationWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationSlide:
                [self.toolbarView dlc_slideOutFromBottomWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationFadeSlide:
                [self.toolbarView dlc_fadeOutAnimationWithDuration:self.hiddenDuration/2.0];
                [self.toolbarView dlc_slideOutFromBottomWithDuration:self.hiddenDuration];
                break;
            default:
                self.toolbarView.hidden = YES;
                break;
        }
    }
}

- (void)showToolBarView {
    if (self.isToolBarHidden) {
        self.toolBarHidden = NO;
        switch (self.hiddenAnimation) {
            case DLCHiddenAnimationFade:
                [self.toolbarView dlc_fadeInAnimationWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationSlide:
                [self.toolbarView dlc_slideIntoBottomWithDuration:self.hiddenDuration];
                break;
            case DLCHiddenAnimationFadeSlide:
                [self.toolbarView dlc_slideIntoBottomWithDuration:self.hiddenDuration/2.0];
                [self.toolbarView dlc_fadeInAnimationWithDuration:self.hiddenDuration];
                break;
            default:
                self.toolbarView.hidden = NO;
                break;
        }
    }
}

- (void)resetToolBarHiddenTimer {
    if (self.shouldControlAutoHidden) {
        [self.toolbarHiddenTimer invalidate];
        self.toolbarHiddenTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.hiddenInterval target:self.videoActionDelegate selector:@selector(playerControlResign) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    }
}

- (void)playerControlResign {
    if ([self.videoActionDelegate respondsToSelector:@selector(dlc_playerControlActive:)]) {
        [self.videoActionDelegate dlc_playerControlActive:NO];
    }
}

- (NSTimeInterval)hiddenDuration {
    if (_hiddenDuration > 0) {
        return _hiddenDuration;
    }
    return kDefaultHiddenDuration;
}

- (NSTimeInterval)hiddenInterval {
    if (_hiddenInterval > 0) {
        return _hiddenInterval;
    }
    return kDefaultHiddenInterval;
}

- (DLCHiddenAnimation)hiddenAnimation {
    if (_hiddenAnimation >= 0) {
        return _hiddenAnimation;
    }
    return DLCHiddenAnimationFadeSlide;
}

#pragma mark - Background
- (UIViewController *)superViewController {
    if (_superViewController) {
        return _superViewController;
    }
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return _superViewController = (UIViewController *)responder;
        }
    }
    return nil;
}

- (void)addObserverForPauseInBackground {
    if (self.shouldPauseInBackground && !self.observerForPauseInBackgroundAdded) {
        self.observerForPauseInBackgroundAdded = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeInActive)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseInBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        if (self.superViewController) {
            __weak __typeof(self)weakSelf = self;
            self.viewAppearAspectToken = [self.superViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf resumeInActive];
            } error:nil];
            self.viewDisappearAspectToken = [self.superViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf pauseInBackground];
            } error:nil];
        }
    }
}

- (void)removeObserverForPauseInBackground {
    self.shouldResumeInActive = NO;
    if (self.shouldPauseInBackground && self.observerForPauseInBackgroundAdded) {
        self.observerForPauseInBackgroundAdded = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self.viewAppearAspectToken remove];
        [self.viewDisappearAspectToken remove];
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

- (void)setShouldPauseInBackground:(BOOL)shouldPauseInBackground {
    if (_shouldPauseInBackground != shouldPauseInBackground) {
        _shouldPauseInBackground = shouldPauseInBackground;
        if (!_shouldPauseInBackground && self.observerForPauseInBackgroundAdded) {
            self.observerForPauseInBackgroundAdded = NO;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationWillEnterForegroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidEnterBackgroundNotification object:nil];
            
            [self.viewAppearAspectToken remove];
            [self.viewDisappearAspectToken remove];
        }
    }
}

#pragma mark - PlayControl
- (IBAction)videoPlayAction:(id)sender {
    if (self.playing) {
        [self pauseVideo];
    } else {
        if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
            [self.videoActionDelegate dlc_videoWillPlay];
        }
    }
}

- (void)play {
    if (!self.mediaURL) {
        NSLog(@"DLCMobilePlayer -warn: mediaURL is null.");
        return;
    }
    self.playing = YES;
    dispatch_async(self.playerControlQueue, ^{
        if (self.mediaPlayer.isPlaying) {
            [self.mediaPlayer pause];
        }
        [self.mediaPlayer play];
    });
}

- (void)pause {
    self.playing = NO;
    dispatch_barrier_async(self.playerControlQueue, ^{
        [self.mediaPlayer pause];
    });
}

- (void)stop {
    self.playing = NO;
    dispatch_barrier_async(self.playerControlQueue, ^{
        self.videoPlayed = NO;
        [self.mediaPlayer stop];
    });
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

#pragma mark - FullScreen
- (IBAction)videoFullScreenAction:(UIButton *)sender {
    if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoFullScreenChanged:)]) {
        [self.videoActionDelegate dlc_videoFullScreenChanged:!self.isFullScreen];
    }
}

- (void)enterFullScreen {
    self.originalOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    Class delegateClass = [[UIApplication sharedApplication].delegate class];
    self.orientationAspectToken = [delegateClass aspect_hookSelector:@selector(application:supportedInterfaceOrientationsForWindow:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, UIApplication *application, UIWindow *window) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscape;
        [invocation setReturnValue:&orientationMask];
    } error:nil];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.originalOrientation != UIInterfaceOrientationLandscapeLeft && self.originalOrientation != UIInterfaceOrientationLandscapeRight) {
            [UIDevice dlc_setOrientation:UIInterfaceOrientationLandscapeRight];
        }
        [self.contentView removeFromSuperview];
        self.contentView.frame = window.bounds;
        [window addSubview:self.contentView];
    }];
}

- (void)exitFullScreen {
    [self.orientationAspectToken remove];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.contentView removeFromSuperview];
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        [self sendSubviewToBack:self.contentView];
        [UIDevice dlc_setOrientation:self.originalOrientation];
    } completion:nil];
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

#pragma mark - Audio
- (IBAction)videoVoiceAction:(UIButton *)sender {
    if ((self.muted = !self.isMuted)) {
        self.mediaPlayer.audio.muted = YES;
    } else {
        self.mediaPlayer.audio.muted = NO;
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

#pragma mark - Buffer
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

#pragma mark - VLCMediaPlayer
- (VLCMediaPlayer *)mediaPlayer {
    if (_mediaPlayer) {
        return _mediaPlayer;
    }
    _mediaPlayer = [[VLCMediaPlayer alloc] init];
    //    _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:@[@"-vvvv"]];
    _mediaPlayer.delegate = self;
    _mediaPlayer.drawable = self.videoDrawableView;
    return _mediaPlayer;
}

// Autoplay if necessary while mediaURL was changed.
- (void)setMediaURL:(NSString *)mediaURL {
    if (mediaURL) {
        mediaURL = [mediaURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (![mediaURL isEqualToString:_mediaURL]) {
            _mediaURL = mediaURL;
            dispatch_async(self.playerControlQueue, ^{
                self.mediaPlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:_mediaURL]];
                //                [self.mediaPlayer.media addOptions:@{@"network-caching": @"500"}];
            });
            
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)]) {
                [self.videoActionDelegate dlc_videoWillStop];
            }
            
            if (self.shouldAutoPlay && self.window) {
                if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillPlay)]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.videoActionDelegate dlc_videoWillPlay];
                    });
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

#pragma mark - VLCMediaPlayerDelegate

/**
 VLCMediaPlayerStateStopped,        //<0 Player has stopped
 VLCMediaPlayerStateOpening,        //<1 Stream is opening
 VLCMediaPlayerStateBuffering,      //<2 Stream is buffering
 VLCMediaPlayerStateEnded,          //<3 Stream has ended
 VLCMediaPlayerStateError,          //<4 Player has generated an error
 VLCMediaPlayerStatePlaying,        //<5 Stream is playing
 VLCMediaPlayerStatePaused          //<6 Stream is paused
 
 @param aNotification <#aNotification description#>
 */
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    NSLog(@"DLCMobilePlayer -mediaPlayerStateChanged: %ld", (long)self.mediaPlayer.state);
    
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateError:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateEnded:
            if ([self.videoActionDelegate respondsToSelector:@selector(dlc_videoWillStop)] && (self.isVideoPlayed || self.isBuffering)) {
                [self.videoActionDelegate dlc_videoWillStop];
            }
        case VLCMediaPlayerStatePaused:
            self.playing = NO;
            break;
        case VLCMediaPlayerStateBuffering:
            self.buffering = YES;
            break;
        case VLCMediaPlayerStatePlaying:
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    if (self.mediaPlayer.audio.isMuted != self.isMuted) {
        self.mediaPlayer.audio.muted = self.isMuted;
    }
    
    self.buffering = NO;
    if (!self.videoPlayed) {
        self.videoPlayed = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDLCNotificationVideoDidPlay object:self];
    }
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    
}

#pragma mark - IBInspectable
- (void)setHintText:(NSString *)hintText {
    _hintText = hintText;
    self.hintLabel.text = _hintText;
}

@end

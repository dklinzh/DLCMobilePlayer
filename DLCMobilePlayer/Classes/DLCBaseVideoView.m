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

@interface DLCBaseVideoView () <VLCMediaPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *playBarButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceBarButton;
@property (weak, nonatomic) IBOutlet UIButton *visibleBarButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBarButton;
@property (weak, nonatomic) IBOutlet UIView *videoDrawableView;
@property (weak, nonatomic) IBOutlet UIImageView *videoBufferingView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isMuted;
@property (nonatomic, assign) BOOL isBuffering;
@property (nonatomic, assign) BOOL isFullScreen;
@end

IB_DESIGNABLE
@implementation DLCBaseVideoView
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
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

#pragma mark - Event
- (IBAction)videoPlayAction:(id)sender {
    if ((self.isPlaying = !self.isPlaying)) {
        if (self.mediaPlayer.isPlaying) {
            [self.mediaPlayer pause];
        }
        [self.mediaPlayer play];
        [self videoPalyed];
    } else {
        [self.mediaPlayer pause];
        [self videoStoped];
    }
}

- (IBAction)videoVoiceAction:(UIButton *)sender {
    if ((self.isMuted = !self.isMuted)) {
        self.mediaPlayer.audio.muted = YES;
        
        [self.voiceBarButton setImage:[UIImage imageNamed:@"btn_toolbar_voice_mute"] forState:UIControlStateNormal];
    } else {
        self.mediaPlayer.audio.muted = NO;
        
        [self.voiceBarButton setImage:[UIImage imageNamed:@"btn_toolbar_voice"] forState:UIControlStateNormal];
    }
}

- (IBAction)videoVisibleAction:(UIButton *)sender {
}

- (IBAction)videoFullScreenAction:(UIButton *)sender {
    if ((self.isFullScreen = !self.isFullScreen)) { //Enter full screen mode
        [UIDevice dlc_setOrientation:UIInterfaceOrientationLandscapeRight];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [self.contentView removeFromSuperview];
        self.contentView.frame = window.bounds;
        [self.fullScreenBarButton setImage:[UIImage imageNamed:@"btn_full_exit"] forState:UIControlStateNormal];
        [window addSubview:self.contentView];
    } else { //Exit full screen mode
        [UIDevice dlc_setOrientation:UIInterfaceOrientationPortrait];
        [self.contentView removeFromSuperview];
        self.contentView.frame = self.bounds;
        [self.fullScreenBarButton setImage:[UIImage imageNamed:@"btn_toolbar_full_screen"] forState:UIControlStateNormal];
        [self addSubview:self.contentView];
    }
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    NSLog(@"mediaPlayerStateChanged: %ld", (long)self.mediaPlayer.state);
 
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateError:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStatePaused:
            self.isPlaying = NO;
            [self videoStoped];
            break;
        case VLCMediaPlayerStateBuffering:
            [self startBuffering];
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    [self stopBuffering];
}

- (void)mediaPlayerTitleChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerChapterChanged:(NSNotification *)aNotification {
    
}

- (void)mediaPlayerSnapshot:(NSNotification *)aNotification {
    
}

#pragma mark - Public
- (UIImage *)takeVideoSnapshot {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"snapshot_%f", [[NSDate date] timeIntervalSince1970]]];
    [self.mediaPlayer saveVideoSnapshotAt:path withWidth:0 andHeight:0];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

#pragma mark - Private
- (void)videoPalyed {
    self.videoPlayButton.hidden = YES;
    [self.playBarButton setImage:[UIImage imageNamed:@"btn_toolbar_pause"] forState:UIControlStateNormal];
}

- (void)videoStoped {
    [self stopBuffering];
    self.videoPlayButton.hidden = NO;
    [self.playBarButton setImage:[UIImage imageNamed:@"btn_toolbar_play"] forState:UIControlStateNormal];
}

- (void)startBuffering {
    if (!self.isBuffering) {
        self.isBuffering = YES;
        self.videoBufferingView.hidden = NO;
        [self.videoBufferingView dlc_startRotateAnimationInDuration:2 repeatCout:HUGE_VALF];
    }
}

- (void)stopBuffering {
    if (self.isBuffering) {
        self.isBuffering = NO;
        [self.videoBufferingView dlc_stopRotateAnimation];
        self.videoBufferingView.hidden = YES;
    }
}

- (void)setupView {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.contentView = [bundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
//    [self.videoToolbar setBackgroundImage:[UIImage imageNamed:@"bg_toolbar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
//    self.videoToolbar.clipsToBounds = YES;
    UIImage *image = [UIImage imageNamed:@"bg_toolbar"];
    self.toolbarView.layer.contents = (__bridge id _Nullable)(image.CGImage);
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
    _mediaURL = mediaURL;
    self.mediaPlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:mediaURL]];
}
@end

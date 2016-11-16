//
//  DLCLiveVideoView.m
//  DLCMobilePlayer
//
//  Created by Linzh on 11/2/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCLiveVideoView.h"
#import "DLCNetworkCenter.h"

static NSInteger const kNetworkErrorAlertTag = -1010101;

IB_DESIGNABLE
@implementation DLCLiveVideoView
@synthesize hintText = _hintText;

#pragma mark - Public
- (void)playLiveVideo {
    if (!self.mediaURL) {
        NSLog(@"DLCMobilePlayer -warn: mediaURL is null.");
        return;
    }
    [[DLCNetworkCenter sharedInstance] startReachNotifierOnReachable:^(DLCNetworkStatus status) {
        [self hideHintNetworkError];
    } onUnreachable:^(DLCNetworkStatus status) {
        [self showHintNetworkError];
    }];
    
    switch ([DLCNetworkCenter sharedInstance].currentNetworkStatus) {
        case DLCNotReachable:
            [self showHintNetworkError];
            break;
        case DLCReachableViaWWAN:
            [self hideHintNetworkError];
            if (self.allowPlayingViaWWAN) {
                [self playVideo];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络视频将使用移动数据流量，是否继续？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                alertView.tag = kNetworkErrorAlertTag;
                [alertView show];
            }
            break;
        case DLCReachableViaWiFi:
            [self hideHintNetworkError];
            [self playVideo];
            break;
    }
}

- (void)pauseLiveVideo {
    [self pauseVideo];
}

- (void)stopLiveVideo {
    [self stopVideo];
    [[DLCNetworkCenter sharedInstance] stopReachNotifier];
}

#pragma mark - Override
- (void)dlc_videoWillPlay {
    [self playLiveVideo];
}

- (void)dlc_videoWillStop {
    [self stopLiveVideo];
}

- (void)dealloc {
    [[DLCNetworkCenter sharedInstance] stopReachNotifier];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kNetworkErrorAlertTag && buttonIndex == 1) {
        self.allowPlayingViaWWAN = YES;
        [self playLiveVideo];
    }
}

#pragma mark - Private
- (void)showHintNetworkError {
    self.hintLabel.text = self.hintText;
    self.hintLabel.hidden = NO;
}

- (void)hideHintNetworkError {
    self.hintLabel.text = nil;
    self.hintLabel.hidden = YES;
}

- (void)showAlertWithNetworkUnreachable {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络不可用。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (NSString *)hintText {
    if (_hintText) {
        return _hintText;
    }
    return @"无法加载视频，请检查设备或网络后重试。";
}
@end

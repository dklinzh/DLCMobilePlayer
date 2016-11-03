//
//  DLCLiveVideoView.m
//  DLCMobilePlayer
//
//  Created by Linzh on 11/2/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCLiveVideoView.h"
#import "DLCNetworkCenter.h"

@interface DLCLiveVideoView () <UIAlertViewDelegate>

@end

IB_DESIGNABLE
@implementation DLCLiveVideoView
#pragma mark - Public
- (void)playLiveVideo {
    [[DLCNetworkCenter sharedInstance] startReachNotifierOnReachable:^(DLCNetworkStatus status) {
        
    } onUnreachable:^(DLCNetworkStatus status) {
        [self showAlertWithNetworkUnreachable];
    }];
    
    switch ([DLCNetworkCenter sharedInstance].currentNetworkStatus) {
        case DLCNotReachable:
            [self showAlertWithNetworkUnreachable];
            break;
        case DLCReachableViaWWAN:
            if (self.allowPlayingViaWWAN) {
                [self playVideo];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络视频将使用移动数据流量，是否继续？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                [alertView show];
            }
            break;
        case DLCReachableViaWiFi:
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
    if (buttonIndex == 1) {
        self.allowPlayingViaWWAN = YES;
        [self playLiveVideo];
    }
}

#pragma mark - Private
- (void)showAlertWithNetworkUnreachable {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络不可用。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}
@end

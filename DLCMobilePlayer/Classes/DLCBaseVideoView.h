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
@property (nonatomic, strong) NSString *mediaURL;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, copy) DLCVideoVisibleBlock videoVisibleBlock;

- (void)playVideo;

- (void)pauseVideo;

- (void)stopVideo;

- (UIImage *)takeVideoSnapshot;
@end

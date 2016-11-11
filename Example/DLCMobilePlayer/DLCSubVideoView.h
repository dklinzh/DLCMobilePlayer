//
//  DLCSubVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 11/1/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <DLCMobilePlayer/DLCMobilePlayer.h>

@interface DLCSubVideoView : DLCLiveVideoView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *visibleBarButton;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@end

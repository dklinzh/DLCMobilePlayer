//
//  DLCSubVideoView.m
//  DLCMobilePlayer
//
//  Created by Linzh on 11/1/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCSubVideoView.h"

IB_DESIGNABLE
@implementation DLCSubVideoView
#pragma mark - Override
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubView];
    }
    return self;
}

#pragma mark - DLCVideoActionDelegate
- (void)dlc_videoFullScreenChanged:(BOOL)isFullScreen {
    [super dlc_videoFullScreenChanged:isFullScreen];
    if (self.isVisible) {
        [self videoVisible];
    } else {
        [self videoInvisible];
    }
}

#pragma mark - Private
- (void)setupSubView {
    self.visibleBarButton = [[UIButton alloc] init];
    [self.visibleBarButton addTarget:self action:@selector(videoVisibleAction:) forControlEvents:UIControlEventTouchUpInside];
    self.visible = NO;
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"More" forState:UIControlStateNormal];
    self.otherToolBarButtons = @[self.visibleBarButton, button];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectZero;
    self.titleLabel.text = @"DLCMobilePlayer";
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.titleLabel];
}

- (void)videoVisibleAction:(UIButton *)sender {
    self.visible = !self.isVisible;
    
}

- (void)videoVisible {
    if (self.isFullScreen) {
        [self.visibleBarButton setImage:[UIImage imageNamed:@"btn_full_visible"] forState:UIControlStateNormal];
    } else {
        [self.visibleBarButton setImage:[UIImage imageNamed:@"btn_toolbar_visible"] forState:UIControlStateNormal];
    }
}

- (void)videoInvisible {
    if (self.isFullScreen) {
        [self.visibleBarButton setImage:[UIImage imageNamed:@"btn_full_invisible"] forState:UIControlStateNormal];
    } else {
        [self.visibleBarButton setImage:[UIImage imageNamed:@"btn_toolbar_invisible"] forState:UIControlStateNormal];
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

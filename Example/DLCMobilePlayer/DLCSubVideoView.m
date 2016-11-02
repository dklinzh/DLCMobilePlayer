//
//  DLCSubVideoView.m
//  DLCMobilePlayer
//
//  Created by Linzh on 11/1/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCSubVideoView.h"

@implementation DLCSubVideoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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

- (void)setupSubView {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectZero;
    self.titleLabel.text = @"DLCMobilePlayer";
    [self.titleLabel sizeToFit];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.titleLabel];
}

@end

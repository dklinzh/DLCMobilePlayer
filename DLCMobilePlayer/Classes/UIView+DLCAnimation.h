//
//  UIView+DLCAnimation.h
//  DLCMobilePlayer
//
//  Created by Linzh on 10/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DLCAnimation)

- (void)dlc_startRotateAnimationInDuration:(double)duration repeatCout:(float)count;

- (void)dlc_stopRotateAnimation;
@end

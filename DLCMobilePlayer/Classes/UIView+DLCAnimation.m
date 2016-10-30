//
//  UIView+DLCAnimation.m
//  DLCMobilePlayer
//
//  Created by Linzh on 10/27/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "UIView+DLCAnimation.h"

static NSString *const kRotateAnimationKey = @"kRotateAnimationKey";

@implementation UIView (DLCAnimation)
- (void)dlc_startRotateAnimationInDuration:(double)duration repeatCout:(float)count {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    rotateAnimation.duration = duration;
    rotateAnimation.cumulative = YES;
    rotateAnimation.repeatCount = count;
//    rotateAnimation.removedOnCompletion = NO;
//    rotateAnimation.delegate = self;
//    [rotateAnimation setValue:kRotateAnimationKey forKey:@"AnimType"];
    [self.layer addAnimation:rotateAnimation forKey:kRotateAnimationKey];
}

- (void)dlc_stopRotateAnimation {
    [self.layer removeAnimationForKey:kRotateAnimationKey];
}
@end

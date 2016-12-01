//
//  UIDevice+DLCOrientation.m
//  DLCMobilePlayer
//
//  Created by Linzh on 10/30/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "UIDevice+DLCOrientation.h"

@implementation UIDevice (DLCOrientation)
+ (void)dlc_setOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == [UIApplication sharedApplication].statusBarOrientation) {
        return;
    }
//    if ([[self currentDevice] valueForKey:@"orientation"]) {
//        [[self currentDevice] setValue:@(UIInterfaceOrientationUnknown) forKey:@"orientation"];
//        [[self currentDevice] setValue:@(orientation) forKey:@"orientation"];
//    }
    [self _setOrientation:UIInterfaceOrientationUnknown];
    [self _setOrientation:orientation];
}

+ (void)_setOrientation:(UIInterfaceOrientation)orientation {
    if ([[self currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[self currentDevice]];
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}
@end

//
//  DLCNetworkCenter.m
//  DLCMobilePlayer
//
//  Created by Linzh on 11/2/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "DLCNetworkCenter.h"
#import <Reachability/Reachability.h>

@interface DLCNetworkCenter ()
@property (nonatomic, strong) Reachability* reach;
@property (nonatomic, copy) DLCNetworkReachable reachableBlock;
@property (nonatomic, copy) DLCNetworkUnreachable unreachableBlock;
@end

@implementation DLCNetworkCenter
static DLCNetworkCenter *sharedInstance = nil;

#pragma mark - Override
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.reach = [Reachability reachabilityForInternetConnection];
        self.reach.reachableBlock = ^(Reachability *reach) {
            if (self.reachableBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.reachableBlock([reach currentReachabilityStatus]);
                });
            }
        };
        self.reach.unreachableBlock = ^(Reachability *reach) {
            if (self.unreachableBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.unreachableBlock([reach currentReachabilityStatus]);
                });
            }
        };
    }
    return self;
}

- (void)dealloc {
    [self stopReachNotifier];
    self.reach = nil;
    self.reachableBlock = nil;
    self.unreachableBlock = nil;
}

#pragma mark - Public
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startReachNotifierOnReachable:(DLCNetworkReachable)reachableBlock onUnreachable:(DLCNetworkUnreachable)unreachableBlock {
    self.reachableBlock = reachableBlock;
    self.unreachableBlock = unreachableBlock;
    
    [self.reach startNotifier];
}

- (void)stopReachNotifier {
    [self.reach stopNotifier];
}

#pragma mark - Private
- (DLCNetworkStatus)currentNetworkStatus {
    return [self.reach currentReachabilityStatus];
}
@end

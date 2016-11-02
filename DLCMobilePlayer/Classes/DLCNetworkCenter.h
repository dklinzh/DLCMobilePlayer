//
//  DLCNetworkCenter.h
//  DLCMobilePlayer
//
//  Created by Linzh on 11/2/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DLCNetworkStatus) {
    DLCNotReachable = 0,
    DLCReachableViaWWAN = 1,
    DLCReachableViaWiFi = 2,
};

typedef void(^DLCNetworkReachable)(DLCNetworkStatus status);
typedef void(^DLCNetworkUnreachable)(DLCNetworkStatus status);

@interface DLCNetworkCenter : NSObject
@property (nonatomic, assign, readonly) DLCNetworkStatus currentNetworkStatus;

+ (instancetype)sharedInstance;

- (void)startReachNotifierOnReachable:(DLCNetworkReachable)reachableBlock onUnreachable:(DLCNetworkUnreachable)unreachableBlock;

- (void)stopReachNotifier;
@end

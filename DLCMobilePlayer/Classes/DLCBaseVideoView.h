//
//  DLCBaseVideoView.h
//  DLCMobilePlayer
//
//  Created by Linzh on 10/26/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLCBaseVideoView : UIView
@property (nonatomic, strong) NSString *mediaURL;

- (UIImage *)takeVideoSnapshot;
@end

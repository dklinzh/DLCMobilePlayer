//
//  DLCViewController.m
//  DLCMobilePlayer
//
//  Created by Daniel on 10/30/2016.
//  Copyright (c) 2016 Daniel. All rights reserved.
//

#import "DLCViewController.h"
#import "DLCSubVideoView.h"

@interface DLCViewController ()
@property (weak, nonatomic) IBOutlet DLCSubVideoView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
@property (nonatomic, strong) NSArray<NSString *> *mediaURLs;
@end

@implementation DLCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.videoView.mediaURL = self.mediaURLs[0];
    self.videoView.shouldAutoPlay = YES;
//    self.videoView.allowPlayingViaWWAN = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event
- (IBAction)videoSnapshotAction:(UIButton *)sender {
    NSString *key = [NSString stringWithFormat:@"%ld", (NSInteger)([[NSDate date] timeIntervalSince1970]*1000)];
    
    self.snapshotImageView.image = [self.videoView takeVideoSnapshotImageForKey:key];
    NSLog(@"video snapshot path: %@", [self.videoView videoSnapshotPathForKey:key]);
}

- (IBAction)nextMediaAction:(UIButton *)sender {
    sender.tag++;
    NSUInteger count = self.mediaURLs.count;
    NSUInteger index = sender.tag % count;
    self.videoView.mediaURL = self.mediaURLs[index];
}

- (NSArray<NSString *> *)mediaURLs {
    if (_mediaURLs) {
        return _mediaURLs;
    }
    return _mediaURLs = @[@"rtsp://218.204.223.237:554/live/1/66251FC11353191F/e7ooqwcfbqjoo80j.sdp",
                          @"rtmp://live.hkstv.hk.lxdns.com/live/hks",
//                          @"http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8",
//                          @"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8"
                          ];
}
@end

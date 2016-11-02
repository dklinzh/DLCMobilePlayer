//
//  DLCViewController.m
//  DLCMobilePlayer
//
//  Created by Daniel on 10/30/2016.
//  Copyright (c) 2016 Daniel. All rights reserved.
//

#import "DLCViewController.h"
#import <DLCmobilePlayer/DLCBaseVideoView.h>

@interface DLCViewController ()
@property (weak, nonatomic) IBOutlet DLCBaseVideoView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
@end

@implementation DLCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.videoView.mediaURL =
    @"rtsp://admin:12345@bs.cqtianwang.com:554/_sdk_/hik/admin/12345/192.168.110.100/8000/14/sub";
//    @"http://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4";
    self.videoView.shouldAutoPlay = YES;
}

//- (BOOL)shouldAutorotate {
//    return NO;
//}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event
- (IBAction)videoSnapshotAction:(UIButton *)sender {
    self.snapshotImageView.image = [self.videoView takeVideoSnapshot];
}
@end

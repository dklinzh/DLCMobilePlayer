//
//  DLCViewController.m
//  DLCMobilePlayer
//
//  Created by Daniel on 10/30/2016.
//  Copyright (c) 2016 Daniel. All rights reserved.
//

#import "DLCViewController.h"
#import "DLCBaseVideoView.h"

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
    
    @"http://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4";
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

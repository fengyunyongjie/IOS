//
//  MusicPlayerViewController.h
//  MusicPlayer
//
//  Created by wanghb on 12-10-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MusicPlayerViewController : NSObject<AVAudioPlayerDelegate>
{
    AVAudioPlayer *newPlayer;
    AVAudioSession *session;
}

- (void)viewDidLoad;

@end

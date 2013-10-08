//
//  MusicPlayerViewController.m
//  MusicPlayer
//
//  Created by wanghb on 12-10-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MusicPlayerViewController ()

@end

@implementation MusicPlayerViewController

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Registers this class as the delegate of the audio session.
    if(newPlayer == nil)
    {
        session = [AVAudioSession sharedInstance];
        
    [session setCategory: AVAudioSessionCategoryPlayback error: nil];
        [session setMode:@"" error:nil];
        
    UInt32 doSetProperty = true;
    //The C Style function call
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideCategoryMixWithOthers,
                             sizeof (doSetProperty),
                             &doSetProperty
                             );
    
    // Activates the audio session.
    NSError *activationError = nil;
    [session setActive: YES error: &activationError];
    
    //alloc a new player, zhizh.mp3 is the name of file, need you change
    NSString* path= [[NSBundle mainBundle] pathForResource: @"nothing" ofType:@"mp3"];
    NSLog(@"path = %@",path);
    
    NSURL* url = [NSURL fileURLWithPath:path];
    NSLog(@"url = %@",url);
    
    newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:nil];
    
    //prepare and set delegate
    [newPlayer prepareToPlay];

    [newPlayer setDelegate:self];
    
    //play audio
    [newPlayer play];
    
    
    }    
    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"finished:继续播放------------------------------------------------");
    //prepare and set delegate
    [newPlayer prepareToPlay];
    [newPlayer setDelegate:self];
    //play audio
    [newPlayer play];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Decode error");
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    NSLog(@"begin interruption");
}

@end

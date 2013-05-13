//
//  PhotoImageButton.h
//  NetDisk
//
//  Created by Yangsl on 13-5-8.
//
//

#import <UIKit/UIKit.h>
#import "PhohoDemo.h"

@interface PhotoImageButton : UIButton
{
    NSString *timeLine;
    NSInteger timeIndex;
    PhohoDemo *demo;
    BOOL isShowImage;
}

@property(nonatomic,retain) NSString *timeLine;
@property(nonatomic,assign) NSInteger timeIndex;
@property(nonatomic,retain) PhohoDemo *demo;
@property(nonatomic,assign) BOOL isShowImage;

@end

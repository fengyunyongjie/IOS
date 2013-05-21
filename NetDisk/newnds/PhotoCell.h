//
//  PhotoCell.h
//  NetDisk
//
//  Created by Yangsl on 13-5-13.
//
//

#import <UIKit/UIKit.h>
#import "PhotoImageButton.h"
#import "DownImage.h"

@interface PhotoCell : UITableViewCell <DownloaderDelegate>
{
    PhotoImageButton *imageViewButton1;     //点击按钮
    PhotoImageButton *imageViewButton2;
    PhotoImageButton *imageViewButton3;
    PhotoImageButton *imageViewButton4;
    
    UIImageView *bg1;   //图片背景
    UIImageView *bg2;
    UIImageView *bg3;
    UIImageView *bg4;
    
    UIButton *selected1; 
    UIButton *selected2;
    UIButton *selected3;
    UIButton *selected4;
}

@property(nonatomic,retain) PhotoImageButton *imageViewButton1;
@property(nonatomic,retain) PhotoImageButton *imageViewButton2;
@property(nonatomic,retain) PhotoImageButton *imageViewButton3;
@property(nonatomic,retain) PhotoImageButton *imageViewButton4;

@property(nonatomic,retain) UIImageView *bg1;
@property(nonatomic,retain) UIImageView *bg2;
@property(nonatomic,retain) UIImageView *bg3;
@property(nonatomic,retain) UIImageView *bg4;

@property(nonatomic,retain) UIButton *selected1;
@property(nonatomic,retain) UIButton *selected2;
@property(nonatomic,retain) UIButton *selected3;
@property(nonatomic,retain) UIButton *selected4;

-(void)array:(NSArray *)array index:(int)index timeLine:(NSString *)timeLine nunber:(int)number;
-(void)downImage;

@end

//
//  CustomSelectButton.h
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSelectButtonDelegate <NSObject>

-(void)isSelectedLeft:(BOOL)bl;

@end


@interface CustomSelectButton : UIButton
@property(strong,nonatomic)UIImageView *left_backimage;
@property(strong,nonatomic)UIButton *left_button;
@property(strong,nonatomic)UIImageView *left_botton_image;
@property(strong,nonatomic)UIImageView *right_backimage;
@property(strong,nonatomic)UIButton *right_button;
@property(strong,nonatomic)UIImageView *right_botton_image;
@property(strong,nonatomic)id<CustomSelectButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame leftText:(NSString *)left_title rightText:(NSString *)right_title isShowLeft:(BOOL)bl;
//是否显示左边视图
-(void)showLeftWithIsSelected:(BOOL)bl;

@end

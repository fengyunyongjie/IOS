//
//  PhotoDetailView.h
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol BackDelegate
- (void)backImageView:(id)detailView;
@end
@interface PhotoDetailView : UIScrollView<UIScrollViewDelegate>
{
    UIImageView *bgImageView;
    UIButton *clickButton;
    UILabel *addressLabel;
    UILabel *weatherLabel;
    UILabel *dayTimeLabel;
    UIImageView *lineImageView;
    UILabel *dateTimeLabel;
    UILabel *clientLabel;
    UIView *bottonView;
    UIButton *leftButton;
    UIButton *centerButton;
    UIButton *rightButton;
    UIActivityIndicatorView *activity_indicator;
    id<BackDelegate> back_Delegate;
}

@property(nonatomic,retain) UIImageView *bgImageView;
@property(nonatomic,retain) UIButton *clickButton;
@property(nonatomic,retain) UILabel *addressLabel;
@property(nonatomic,retain) UILabel *weatherLabel;
@property(nonatomic,retain) UILabel *dayTimeLabel;
@property(nonatomic,retain) UIImageView *lineImageView;
@property(nonatomic,retain) UILabel *dateTimeLabel;
@property(nonatomic,retain) UILabel *clientLabel;
@property(nonatomic,retain) UIView *bottonView;
@property(nonatomic,retain) UIButton *leftButton;
@property(nonatomic,retain) UIButton *centerButton;
@property(nonatomic,retain) UIButton *rightButton;
@property(nonatomic,retain) UIActivityIndicatorView *activity_indicator;
@property(nonatomic,retain) id<BackDelegate> back_Delegate;

#pragma mark 隐藏信息
-(void)hiddenNewview;

#pragma mark 显示信息
-(void)showNewview;

-(void)initImageView;

@end


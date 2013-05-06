//
//  PhotoDetailView.h
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import <UIKit/UIKit.h>

@interface PhotoDetailView : UIView
{
    UIImageView *bgImageView;
    UIView *topView;
    UIButton *topButton;
    UILabel *pagLabel;
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
}

@property(nonatomic,retain) UIImageView *bgImageView;
@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) UIButton *topButton;
@property(nonatomic,retain) UILabel *pagLabel;
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

@end

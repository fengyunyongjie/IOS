//
//  UICustomTabController.h
//  CustomTab
//
//  Created by user on 12-2-7.
//  Copyright (c) 2012年 ITMG zhaoxiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum
{
//仅文本
    UItabbarControllerShowStyleOnlyText=0,
//仅图标
    UItabbarControllerShowStyleOnlyIcon,
//图标在上，文本在下，与官方的布局一样，只是更换了背景和选中时的图片
    UItabbarControllerShowStyleIconAndText,
/*仅开放前三条*/
//图标在左，文本在右
    UItabbarControllerShowStyleIconLeftAndTextRigth,
//图标在右，文本在左
    UItabbarControllerShowStyleIconRightAndTextLeft,
}UItabbarControllerShowStyle;

//横竖排布
typedef enum
{
    UItabbarControllerHorizontal = 0,
    UItabbarControllerVertical,
}UItabbarControllerHorizontalVertical;


@protocol UICustomTabControllerDelegate <NSObject>

- (void)custom_tabbar_view_by_delegate:(UIView*)custom_view;

@end

@interface UICustomTabController : UITabBarController
{
    NSMutableArray *view_manager;
//button背景图片
	NSMutableArray *normal_image;
//选中时的图片
	NSMutableArray *select_image;
//背景图片
	UIImage *tab_bar_bg;

	NSMutableArray *tab_btn;
//故名思义，tabbar的个数
    int tab_num;
//这个很重要，是否需要自定义
    BOOL need_to_custom;
//风格,默认为UItabbarControllerShowStyleOnlyText
    UItabbarControllerShowStyle show_style;
//横竖
    UItabbarControllerHorizontalVertical show_way;
//坐标
    CGRect show_rect;
//默认选中索引,调用- (void)setSelectedIndex:(int)index进行设置
    int default_selected_index;
//字体大小和颜色
    UIColor *font_color;
    UIFont *font;
    UIColor *hilighted_color;
    BOOL is_did_load;
//当前选中的tabbar视图
    int current_selected_tab_index;
    BOOL delegate_custom;
    id <UICustomTabControllerDelegate> tab_delegate;
    
    BOOL IsTabBarHidden;
    
    UIView *custom_view;
}

@property (nonatomic,assign) BOOL delegate_custom;
@property (nonatomic,assign) id <UICustomTabControllerDelegate> tab_delegate;
@property (nonatomic,retain) NSMutableArray *normal_image;

@property (nonatomic,retain) NSMutableArray *select_image;

//如果要实现自定义，这里必须调用此方法，否则为官方的布局
@property (nonatomic,assign) BOOL need_to_custom;

@property (nonatomic,assign) int current_selected_tab_index;
- (void)setNeed_to_custom:(BOOL)flag style:(int)style;

@property (nonatomic,assign) UItabbarControllerShowStyle show_style;

- (void)setShow_way:(UItabbarControllerHorizontalVertical)index Rect:(CGRect)Rect;

@property (nonatomic,retain) UIImage *tab_bar_bg;

@property (nonatomic,retain) UIColor *font_color;

@property (nonatomic,retain) UIFont *font;

@property (nonatomic,retain) UIColor *hilighted_color;
- (void) show_custom_view_layer;

- (void) add_custom_view_layer;

- (void) when_tabbar_is_selected:(int)tabID;

@property(nonatomic) BOOL hidesBottomBarWhenPushed;
- (void)setHidesBottomBarWhenPushed:(BOOL)flag;

- (void)setSelectedIndex:(int)index;

- (void)rechange_the_selected_index:(int)index;

- (void)setHidesTabBarWithAnimate:(BOOL)hide;

- (BOOL)IsTabBarHiden;

- (void)NeedToHiddenSpecialView:(int)view_index;
@end


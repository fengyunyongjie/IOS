//
//  FirstLoadViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-2.
//
//

#import <UIKit/UIKit.h>
@protocol FirstLoadDelegate <NSObject>
-(void)uploadFinish;
@end

@interface FirstLoadViewController : UIViewController<UIScrollViewDelegate>
{
    id<FirstLoadDelegate> delegate;
    UIScrollView *scroll_view;
    UIPageControl *page_controller;
}

@property(nonatomic,retain) id<FirstLoadDelegate> delegate;
@property(nonatomic,retain) UIScrollView *scroll_view;
@property(nonatomic,retain) UIPageControl *page_controller;
@end

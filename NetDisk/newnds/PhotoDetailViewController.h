//
//  PhotoDetailViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import <UIKit/UIKit.h>

@interface PhotoDetailViewController : UIViewController
{
    UIScrollView *scrollView;
}

@property(nonatomic,retain) UIScrollView *scrollView;

#pragma mark 加载所有数据
-(void)loadAllDiction:(NSArray *)allArray currtimeIdexTag:(int)indexTag;

@end

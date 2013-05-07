//
//  PhotoDetailViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import <UIKit/UIKit.h>
#import "DownImage.h"

@interface PhotoDetailViewController : UIViewController<DownloaderDelegate>
{
    UIScrollView *scrollView;
    float allHeight;
}

@property(nonatomic,retain) UIScrollView *scrollView;

#pragma mark 加载所有数据
-(void)loadAllDiction:(NSArray *)allArray currtimeIdexTag:(int)indexTag;

@end

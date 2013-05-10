//
//  ImageBrowserViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-10.
//
//

#import <UIKit/UIKit.h>

@interface ImageBrowserViewController : UIViewController
{
    
}
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) NSArray *listArray;
@property (assign,nonatomic) int index;
@property (strong,nonatomic) NSMutableDictionary *fileDownloaders;

-(void)fileDidDownload:(int)index;
-(void)updateProgress:(long)size index:(int)index;
@end

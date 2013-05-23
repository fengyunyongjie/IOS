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
    
    BOOL isSelected;
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

@property(nonatomic,assign) BOOL isSelected;

-(void)array:(NSArray *)array index:(int)index timeLine:(NSString *)timeLine nunber:(int)number;
-(void)downImage;
-(void)loadImageView:(UIImage *)image button:(UIImageView *)image_button number:(int)number;
- (NSString*)get_image_save_file_path:(NSString*)image_path;
- (BOOL)image_exists_at_file_path:(NSString *)image_path;


//
//-(void)loadViewData:(NSDictionary *)demoDic keyArray:(NSArray *)keyArray timeLine:(NSString *)timelineString
//{
//    CGRect titleRect = CGRectMake(0, scrollview_heigth, 320, 25);
//    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:titleRect];
//    CGRect titleLabelRect = CGRectMake(0, 2, 320, 25);
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
//    [titleLabel setText:timelineString];
//    [titleLabel setBackgroundColor:[UIColor clearColor]];
//    [titleImage addSubview:titleLabel];
//    [titleLabel release];
//    [titleImage setImage:[UIImage imageNamed:@"title_bg.png"]];
//    [scroll_view addSubview:titleImage];
//    [titleImage release];
//    scrollview_heigth += 29;
//    for(int j=0;j<[keyArray count];j++)
//    {
//        PhohoDemo *demo = [demoDic objectForKey:[keyArray objectAtIndex:j]];
//        if(j%4==0&&j!=0)
//        {
//            scrollview_heigth += 79;
//        }
//        CGRect imageButtonRect = CGRectMake((j%4)*79+4, scrollview_heigth+4, 75, 75);
//        PhotoImageButton *imageButton = [[[PhotoImageButton alloc] initWithFrame:imageButtonRect] autorelease];
//        [imageButton addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
//        [imageButton setDemo:demo];
//        [imageButton setTag:demo.f_id];
//        [imageButton setTimeLine:timelineString];
//        [imageButton setTimeIndex:j];
//        NSString *path = [self get_image_save_file_path:demo.f_name];
//        if([self image_exists_at_file_path:path])
//        {
//            UIImage *imageDemo = [UIImage imageWithContentsOfFile:path];
//            [imageButton setBackgroundImage:imageDemo forState:UIControlStateNormal];
//        }
//        else
//        {
//            UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
//            [imageButton setBackgroundImage:imageDemo forState:UIControlStateNormal];
//        }
//        [scroll_view addSubview:imageButton];
//        [demo setIsSelected:NO];
//    }
//    scrollview_heigth += 79+4;
//    [scroll_view setContentSize:CGSizeMake(320, scrollview_heigth+10)];
//}
@end

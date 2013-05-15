//
//  PhotoImageButton.m
//  NetDisk
//
//  Created by Yangsl on 13-5-8.
//
//

#import "PhotoImageButton.h"

@implementation PhotoImageButton
@synthesize timeLine,timeIndex,demo,isShowImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)loadImage:(PhohoDemo *)demos
{
    [self setDemo:demos];
    NSString *path = [self get_image_save_file_path:demo.f_name];
    if([self image_exists_at_file_path:path])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"icon_Folder.png"];
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
}

//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}

-(void)dealloc
{
    [timeLine release];
    [demo release];
    [super dealloc];
}

@end

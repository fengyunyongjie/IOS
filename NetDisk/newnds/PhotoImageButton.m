//
//  PhotoImageButton.m
//  NetDisk
//
//  Created by Yangsl on 13-5-8.
//
//

#import "PhotoImageButton.h"
#import "YNFunctions.h"

@implementation PhotoImageButton
@synthesize timeLine,timeIndex,demo,bgImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [bgImageView setImage:[UIImage imageNamed:@"interestSelected.png"]];
        [bgImageView setHidden:YES];
        [self addSubview:bgImageView];
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
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}

-(void)dealloc
{
    [timeLine release];
    [demo release];
    [bgImageView release];
    [super dealloc];
}

@end

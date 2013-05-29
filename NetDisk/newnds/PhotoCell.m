//
//  PhotoCell.m
//  NetDisk
//
//  Created by Yangsl on 13-5-13.
//
//

#import "PhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "YNFunctions.h"

@implementation PhotoCell
@synthesize imageViewButton1,imageViewButton2,imageViewButton3,imageViewButton4;
@synthesize bg1,bg2,bg3,bg4;
@synthesize selected1,selected2,selected3,selected4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect backRect = CGRectMake(4, 4, 75, 75);
        UIColor *bg_color = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1];
        bg1 = [[UIImageView alloc] initWithFrame:backRect];
        [self addSubview:bg1];
        imageViewButton1 = [[PhotoImageButton alloc] initWithFrame:backRect];
        [imageViewButton1.layer setBorderColor:[bg_color CGColor]];
        [imageViewButton1.layer setBorderWidth:1];
        [self addSubview:imageViewButton1];
        
        backRect.origin.x += 79;
        bg2 = [[UIImageView alloc] initWithFrame:backRect];
        [self addSubview:bg2];
        imageViewButton2 = [PhotoImageButton buttonWithType:UIButtonTypeCustom];
        [imageViewButton2 setFrame:backRect];
        [imageViewButton2.layer setBorderColor:[bg_color CGColor]];
        [imageViewButton2.layer setBorderWidth:1];
        [self addSubview:imageViewButton2];
        
        backRect.origin.x += 79;
        bg3 = [[UIImageView alloc] initWithFrame:backRect];
        [self addSubview:bg3];
        imageViewButton3 = [PhotoImageButton buttonWithType:UIButtonTypeCustom];
        [imageViewButton3 setFrame:backRect];
        [imageViewButton3.layer setBorderColor:[bg_color CGColor]];
        [imageViewButton3.layer setBorderWidth:1];
        [self addSubview:imageViewButton3];
        
        backRect.origin.x += 79;
        bg4 = [[UIImageView alloc] initWithFrame:backRect];
        [self addSubview:bg4];
        imageViewButton4 = [PhotoImageButton buttonWithType:UIButtonTypeCustom];
        [imageViewButton4 setFrame:backRect];
        [imageViewButton4.layer setBorderColor:[bg_color CGColor]];
        [imageViewButton4.layer setBorderWidth:1];
        [self addSubview:imageViewButton4];
    }
    return self;
}

-(void)array:(NSArray *)array index:(int)index timeLine:(NSString *)timeLine nunber:(int)number
{
    int tag = 0;
    for(int i=index;i<[array count];i++)
    {
        tag++;
        if(tag == number+1)
        {
            break;
        }
        PhohoDemo *demo = (PhohoDemo *)[array objectAtIndex:i];
        if(i%4==0)
        {
            [imageViewButton1 setDemo:demo];
            [imageViewButton1 setTimeIndex:i];
            [imageViewButton1 setTimeLine:timeLine];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [bg1 setImage:imageDemo];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadImageView:imageDemo button:bg1 number:1];
            }
            if(isSelected && demo.isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
                [imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
            }
            else if(isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
            }
            else
            {
                [imageViewButton1 setAlpha:1.0];
                [imageViewButton1 setBackgroundImage:nil forState:UIControlStateNormal];
                [demo setIsSelected:NO];
            }
        }
        else if(i%4==1)
        {
            [imageViewButton2 setDemo:demo];
            [imageViewButton2 setTimeIndex:i];
            [imageViewButton2 setTimeLine:timeLine];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [bg2 setImage:imageDemo];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadImageView:imageDemo button:bg2 number:2];
            }
            if(isSelected && demo.isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
                [imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
            }
            else if(isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
            }
            else
            {
                [imageViewButton1 setAlpha:1.0];
                [imageViewButton1 setBackgroundImage:nil forState:UIControlStateNormal];
                [demo setIsSelected:NO];
            }
        }
        else if(i%4==2)
        {
            [imageViewButton3 setDemo:demo];
            [imageViewButton3 setTimeIndex:i];
            [imageViewButton3 setTimeLine:timeLine];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [bg3 setImage:imageDemo];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadImageView:imageDemo button:bg3 number:3];
            }
            if(isSelected && demo.isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
                [imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
            }
            else if(isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
            }
            else
            {
                [imageViewButton1 setAlpha:1.0];
                [imageViewButton1 setBackgroundImage:nil forState:UIControlStateNormal];
                [demo setIsSelected:NO];
            }
        }
        else if(i%4==3)
        {
            [imageViewButton4 setDemo:demo];
            [imageViewButton4 setTimeIndex:i];
            [imageViewButton4 setTimeLine:timeLine];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [bg4 setImage:imageDemo];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadImageView:imageDemo button:bg4 number:4];
            }
            if(isSelected && demo.isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
                [imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
            }
            else if(isSelected)
            {
                [imageViewButton1 setAlpha:0.5];
            }
            else
            {
                [imageViewButton1 setAlpha:1.0];
                [imageViewButton1 setBackgroundImage:nil forState:UIControlStateNormal];
                [demo setIsSelected:NO];
            }
        }
    }
}

-(void)loadImageView:(UIImage *)image button:(UIImageView *)image_button number:(int)number
{
    UIImage *image1 = (UIImage *)image;
    CGSize imageS = image1.size;
    if(imageS.width == imageS.height)
    {
        if(imageS.width>=75)
        {
            imageS.height = 75;
            imageS.width = 75;
            image = [self scaleFromImage:image toSize:imageS];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            [image_button setImage:image];
        }
        else
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = 79*(number-1)+4+(75-imageS.width)/2;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setImage:image];
        }
    }
    else if(imageS.width < imageS.height)
    {
        if(imageS.width>=75)
        {
            imageS.height = 75*imageS.height/imageS.width;
            image = [self scaleFromImage:image toSize:CGSizeMake(75, imageS.height)];
            
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = 75;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake(0, (imageS.height-75)/2, 75, 75)];
            [image_button setImage:endImage];
        }
        else if(imageS.height<75)
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4+(75-imageS.width)/2;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setImage:image];
        }
        else
        {
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((75-imageS.width)/2, (imageS.height-75)/2, imageS.width, 75)];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = 75;
            imageRect.origin.x = (number-1)*79+4+(75-imageS.width)/2;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            [image_button setImage:endImage];
        }
    }
    else
    {
        if(imageS.height>=75)
        {
            imageS.width = 75*imageS.width/imageS.height;
            image = [self scaleFromImage:image toSize:CGSizeMake(imageS.width, 75)];
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((imageS.width-75)/2, 0, 75, 75)];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = 75;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            [image_button setImage:endImage];
        }
        else if(imageS.width<75)
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4+(75-imageS.width)/2;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setImage:image];
        }
        else
        {
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((imageS.width-75)/2, (75-imageS.height)/2, 75, imageS.height)];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setImage:endImage];
        }
    }
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	return newImage;
}


-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [imageViewButton1 release];
    [imageViewButton2 release];
    [imageViewButton3 release];
    [imageViewButton4 release];
    
    [bg1 release];
    [bg2 release];
    [bg3 release];
    [bg4 release];
    
    [selected1 release];
    [selected2 release];
    [selected3 release];
    [selected4 release];
    
    [super dealloc];
}

-(void)downImage
{
    PhohoDemo *demo = imageViewButton1.demo;
    if(demo)
    {
        if(!demo.isShowImage)
        {
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setIndex:1];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
    demo = imageViewButton2.demo;
    if(demo)
    {
        if(!demo.isShowImage)
        {
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setIndex:2];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
    
    demo = imageViewButton3.demo;
    if(demo)
    {
        if(!demo.isShowImage)
        {
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setIndex:3];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
    
    demo = imageViewButton4.demo;
    if(demo)
    {
        if(!demo.isShowImage)
        {
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setIndex:4];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
}

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index
{
    if(index == 1)
    {
        [self loadImageView:image button:bg1 number:index];
    }
    if(index == 2)
    {
        [self loadImageView:image button:bg2 number:index];
    }
    if(index == 3)
    {
        [self loadImageView:image button:bg3 number:index];
    }
    if(index == 4)
    {
        [self loadImageView:image button:bg4 number:index];
    }
}

@end

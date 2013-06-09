//
//  operation.m
//  NetDisk
//
//  Created by Yangsl on 13-6-9.
//
//

#import "operation.h"
#import "YNFunctions.h"

@implementation operation
@synthesize imageArray,cellArray;

- (void)main{
    [NSThread sleepForTimeInterval:0.5];
    for(int j=0;j<[cellArray count];j++)
    {
        CellTag *cellTag = [cellArray objectAtIndex:j];
        UIImageView *image_view = [imageArray objectAtIndex:j];
        if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
        {
            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
            UIImage *imageV = [UIImage imageWithContentsOfFile:path];
            CGSize newImageSize;
            if(imageV.size.width>=imageV.size.height && imageV.size.height>200)
            {
                newImageSize.height = 200;
                newImageSize.width = 200*imageV.size.width/imageV.size.height;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                if(!image_view || !imageS || ![image_view isKindOfClass:[UIImageView class]])
                {
                    return;
                }
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else if(imageV.size.width<=imageV.size.height && imageV.size.width>200)
            {
                newImageSize.width = 200;
                newImageSize.height = 200*imageV.size.height/imageV.size.width;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                if(!image_view || !imageS || ![image_view isKindOfClass:[UIImageView class]])
                {
                    return;
                }
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
        }
    }
}

-(void)cellArray:(NSMutableArray *)cellAr imagev:(NSMutableArray *)imageV
{
    imageArray = [imageV retain];
    cellArray = [cellAr retain];
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


//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
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

-(void)dealloc
{
    [cellArray release];
    [imageArray release];
    [super dealloc];
}

@end

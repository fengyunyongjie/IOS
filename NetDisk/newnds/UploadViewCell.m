//
//  UploadViewCell.m
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#import "UploadViewCell.h"

@implementation UploadViewCell
@synthesize demo,button_dele_button,imageView,contentView,label_name;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect image_rect = CGRectMake(5, 5, 40, 40);
        self.imageView = [[UIImageView alloc] initWithFrame:image_rect];
        [self addSubview:self.imageView];
        
        CGRect label_rect = CGRectMake(60, 2, 200, 20);
        self.label_name = [[UILabel alloc] initWithFrame:label_rect];
        [self.label_name setTextColor:[UIColor blackColor]];
        [self.label_name setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.label_name];
        
        CGRect progress_rect = CGRectMake(60, 30, 200, 3);
        self.jinDuView = [[CustomJinDu alloc] initWithFrame:progress_rect];
        [self addSubview:self.jinDuView];
//        self.progressView = [[UIProgressView alloc] initWithFrame:progress_rect];
//        [self addSubview:self.progressView];
        
        CGRect button_rect = CGRectMake(270, 0, 50, 50);
        self.button_dele_button = [[UIButton alloc] initWithFrame:button_rect];
        [self.button_dele_button setBackgroundImage:[UIImage imageNamed:@"Bt_Cancle.png"] forState:UIControlStateNormal];
        [self.button_dele_button addTarget:self action:@selector(deleteSelf) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button_dele_button];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)setUploadDemo:(TaskDemo *)demo_
{
    self.demo = demo_;
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:nil] waitUntilDone:YES];
    if(self.demo.f_state == 1)
    {
        [self.jinDuView showText:@"完成"];
    }
    else if(self.demo.state == 1)
    {
        [self.jinDuView setCurrFloat:demo.proess];
    }
    else if(self.demo.state == 0)
    {
        [self.jinDuView showText:@"等待中..."];
    }
    [self.label_name setText:self.demo.f_base_name];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if(self.demo.result==nil && self.demo.f_data==nil)
        {
            return;
        }
        UIImage *imageV = [UIImage imageWithData:self.demo.f_data];
        if(imageV.size.width>=imageV.size.height)
        {
            if(imageV.size.height<=88)
            {
                CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.height = 88;
                newImageSize.width = 88*imageV.size.width/imageV.size.height;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake((newImageSize.width-88)/2, 0, 88, 88);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
        else if(imageV.size.width<=imageV.size.height)
        {
            if(imageV.size.width<=88)
            {
                CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.width = 88;
                newImageSize.height = 88*imageV.size.height/imageV.size.width;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake(0, (newImageSize.height-88)/2, 88, 88);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
    });
    
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(void)showStartButton
{
    
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)deleteSelf
{
    [delegate deletCell:self.demo];
}

@end

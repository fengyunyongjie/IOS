//
//  UploadViewCell.m
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#import "UploadViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"

@implementation UploadViewCell
@synthesize demo,button_dele_button,imageView,contentView,label_name;
@synthesize delegate,button_start_button,jinDuView;

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
        
        CGRect button_rect = CGRectMake(270, 0, 50, 50);
        self.button_dele_button = [[UIButton alloc] initWithFrame:button_rect];
        [self.button_dele_button setBackgroundImage:[UIImage imageNamed:@"Bt_Cancle.png"] forState:UIControlStateNormal];
        [self.button_dele_button addTarget:self action:@selector(deleteSelf) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button_dele_button];
        
        CGRect start_rect = CGRectMake(270, 15, 40, 30);
        self.button_start_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.button_start_button setFrame:start_rect];
        [self.button_start_button setBackgroundColor:[UIColor clearColor]];
        [self.button_start_button setTitle:@"暂停" forState:UIControlStateNormal];
        [self.button_start_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.button_start_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.button_start_button addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.button_start_button];
        [self.button_start_button setHidden:YES];
    }
    return self;
}

-(void)start
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([self.button_start_button.titleLabel.text isEqualToString:@"暂停"])
    {
        NSLog(@"self.button_start_button.titleLabel.text 0");
        [self.button_start_button setTitle:@"继续" forState:UIControlStateNormal];
        [app_delegate.autoUpload stopUpload];
    }
    else
    {
        NSLog(@"self.button_start_button.titleLabel.text 1");
        [self.button_start_button setTitle:@"暂停" forState:UIControlStateNormal];
        [app_delegate.autoUpload goOnUpload];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)setUploadDemo:(UpLoadList *)list
{
    upload_list = list;
    if(list.t_state == 1)
    {
        [self.jinDuView showDate:list.t_date];
    }
    else if(list.t_state == 0)
    {
        float f = (float)list.upload_size / (float)list.t_lenght;
        [self.jinDuView setCurrFloat:f];
    }
    else if(list.t_state == 2)
    {
        [self.jinDuView showText:@"暂停"];
    }
    else if(list.t_state == 3)
    {
        [self.jinDuView showText:@"等待WiFi"];
    }
    if(![self.label_name.text isEqualToString:list.t_name])
    {
        ALAssetsLibrary *libary = [[[ALAssetsLibrary alloc] init] autorelease];
        [libary assetForURL:[NSURL URLWithString:list.t_fileUrl] resultBlock:^(ALAsset *result){
            UIImage *imageV = [UIImage imageWithCGImage:[result thumbnail]];
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
        } failureBlock:^(NSError *error){}];
        
    }
    [self.label_name setText:list.t_name];
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(void)showTopBar
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
    [delegate deletCell:upload_list];
}

@end

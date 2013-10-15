//
//  NSString+Format.m
//  NetDisk
//
//  Created by Yangsl on 13-9-22.
//
//

#import "NSString+Format.h"
#import "YNFunctions.h"

@implementation NSString (Format)

+(NSString *)formatNSStringForChar:(const char *)temp
{
    NSString *string;
    if(temp!=NULL)
    {
        string = [NSString stringWithUTF8String:temp];
    }
    else
    {
        string = @"";
    }
    return string;
}

+(NSString *)formatNSStringForOjbect:(NSObject *)object
{
    if([object isEqual:@"<null>"] || [object isEqual:@"<NULL>"] )
    {
        object = @"";
    }
    NSString *string = [NSString stringWithFormat:@"%@",object];
    return string;
}

//这个路径下是否存在此图片
+ (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}
//获取图片路径
+ (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

@end

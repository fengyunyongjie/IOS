//
//  NSString+Format.h
//  NetDisk
//
//  Created by Yangsl on 13-9-22.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Format)

+(NSString *)formatNSStringForChar:(const char *)temp;
+(NSString *)formatNSStringForOjbect:(NSObject *)object;
//这个路径下是否存在此图片
+ (BOOL)image_exists_at_file_path:(NSString *)image_path;
//获取图片路径
+ (NSString*)get_image_save_file_path:(NSString*)image_path;
+ (BOOL)image_exists_FM_file_path:(NSString *)image_path;
+ (NSString*)get_image_FM_file_path:(NSString*)image_path;
+(void)CreatePath:(NSString *)urlPath;
@end

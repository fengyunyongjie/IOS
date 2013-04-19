//
//  SCBPhotoManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>

@interface SCBPhotoManager : NSObject
//获取时间分组/photo/timeline
//获取按年或月查询的概要照片/photo/general
//获取按日查询的照片/photo/detail
//获取最新标签/photo/tag/recent
//获取指定文件相关标签/photo/tag/file_tags
//根据标签集查询文件列表/photo/tag/tag_files
//给指定文件集标注指定的标签集/photo/tag/file_add
//给指定文件集删除指定文件标签集/photo/tag/file_del
//创建标签/photo/tag/create
//删除标签/photo/tag/del
@end

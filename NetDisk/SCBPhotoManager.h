//
//  SCBPhotoManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>

@protocol SCBPhotoDelegate <NSObject>

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary;

-(void)getPhotoGeneral:(NSDictionary *)dictionary;

-(void)getPhotoDetail:(NSDictionary *)dictionary;

@end

@interface SCBPhotoManager : NSObject
{
    id<SCBPhotoDelegate> photoDelegate;
    NSString *url_string;
    int timeLineTotalNumber;
    int timeLineNowNumber;
    NSArray *timeLineAllArray;
    NSMutableDictionary *timeDictionary;
    NSMutableData *matableData;
}

@property(nonatomic,retain) id<SCBPhotoDelegate> photoDelegate;

//获取时间分组/photo/timeline
-(void)getPhotoTimeLine;
//获取所有时间轴上的照片信息
-(void)getAllPhotoGeneral:(NSArray *)timeLineArray;
//获取按年或月查询的概要照片/photo/general
-(void)getPhotoGeneral;
//获取按日查询的照片/photo/detail
//获取最新标签/photo/tag/recent
//获取指定文件相关标签/photo/tag/file_tags
//根据标签集查询文件列表/photo/tag/tag_files
//给指定文件集标注指定的标签集/photo/tag/file_add
//给指定文件集删除指定文件标签集/photo/tag/file_del
//创建标签/photo/tag/create
//删除标签/photo/tag/del

//得到月份天数
-(int)theDaysInYear:(int)year inMonth:(int)month;
#pragma mark 获取当月过了多少天
-(int)getNowMonthToManyDay;
#pragma mark 获取本年过了多少天
-(int)getNowYearToManyDay;

@end

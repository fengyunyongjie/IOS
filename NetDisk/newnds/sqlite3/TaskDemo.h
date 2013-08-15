//
//  TaskDemo.h
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//

#import <Foundation/Foundation.h>
#import "DBSqlite3.h"
#import "ALAsset+AGIPC.h"

#define InsertTaskTable @"INSERT INTO TASKTABLE(F_ID,F_STATE,F_BASE_NAME,F_LENGHT,F_DATA,DEVICE_NAME,SPACE_ID,P_ID,IS_AUTOMIC_UPLOAD) VALUES (?,?,?,?,?,?,?,?,?)"
#define DeleteTskTable @"DELETE FROM TASKTABLE WHERE F_BASE_NAME=?"
#define DeleteALLTskTable @"DELETE FROM TASKTABLE"
#define UpdateTaskTable @"UPDATE TASKTABLE SET F_ID=?,F_STATE=?,F_BASE_NAME=?,F_LENGHT=? WHERE T_ID=?"
#define UpdateTaskTableForName @"UPDATE TASKTABLE SET F_ID=?,F_STATE=?,F_BASE_NAME=?,F_LENGHT=?,F_DATA=?,P_ID=?,IS_AUTOMIC_UPLOAD=? WHERE F_BASE_NAME=?"
#define SelectAllTaskTable @"SELECT * FROM TASKTABLE where F_STATE=0 and IS_AUTOMIC_UPLOAD=0"
#define SelectMoreTaskTable @"SELECT * FROM TASKTABLE WHERE F_STATE=0"
#define SelectFinishTaskTable @"SELECT * FROM TASKTABLE WHERE F_STATE=1"
#define SelectOneTaskTableForTID @"SELECT * FROM TASKTABLE WHERE T_ID=?"
#define SelectOneTaskTableForFID @"SELECT * FROM TASKTABLE WHERE F_ID=?"
#define SelectOneTaskTableOneceForFNAME @"SELECT * FROM TASKTABLE WHERE F_BASE_NAME=?"
#define SelectOneTaskTableForFNAME @"SELECT * FROM TASKTABLE WHERE F_BASE_NAME=? AND F_STATE=1"
#define DeleteUploadTskTable @"DELETE FROM TASKTABLE WHERE F_STATE=0"
#define DeleteFinishTskTable @"DELETE FROM TASKTABLE WHERE F_STATE=1"

@interface TaskDemo : DBSqlite3
{
    NSInteger t_id;
    NSInteger f_id;
    NSData *f_data;
    NSInteger f_state;
    NSString *f_base_name;
    NSInteger f_lenght;
    ALAsset *result;
    CGFloat proess;
    int index_id;
    int state;
    //to
    NSString *deviceName;
    NSString *space_id;
    NSString *p_id;
    NSInteger is_automic_upload;
}

@property(nonatomic,assign) NSInteger t_id;
@property(nonatomic,assign) NSInteger f_id;
@property(nonatomic,retain)  NSData *f_data;
@property(nonatomic,assign) NSInteger f_state;
@property(nonatomic,retain) NSString *f_base_name;
@property(nonatomic,assign) NSInteger f_lenght;
@property(nonatomic,retain) ALAsset *result;
@property(nonatomic,assign) CGFloat proess;
@property(nonatomic,assign) int index_id;
@property(nonatomic,assign) int state;
@property(nonatomic,retain) NSString *deviceName;
@property(nonatomic,retain) NSString *space_id;
@property(nonatomic,retain) NSString *p_id;
@property(nonatomic,assign) NSInteger is_automic_upload;

-(id)init;

#pragma mark 添加任务表数据
-(BOOL)insertTaskTable;
#pragma mark 删除单个数据
-(BOOL)deleteTaskTable;
#pragma mark 删除所有数据
-(BOOL)deleteAllTaskTable;

#pragma mark 修改任务表
-(void)updateTaskTable;
-(void)updateTaskTableFName;

#pragma mark 查询任务表所有数据
-(NSMutableArray *)selectAllTaskTable;

//查询所有完成的纪录
-(NSMutableArray *)selectFinishTaskTable;

#pragma mark 查询任务表所有数据
-(NSArray *)selectAllTaskTableForFNAME;

#pragma mark 判断图片是否存在
-(BOOL)isPhotoExist;
#pragma mark 判断图片是否唯一
-(BOOL)isExistOneImage;
#pragma mark 删除上传记录
-(BOOL)deleteUploadTaskTable;
#pragma mark 删除历史记录
-(BOOL)deleteFinishTaskTable;

@end

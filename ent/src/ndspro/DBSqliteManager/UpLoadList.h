//
//  UpLoadList.h
//  NetDisk
//
//  Created by Yangsl on 13-9-25.
//
//  新代码

#import <Foundation/Foundation.h>
#import "DBSqlite3.h"
#define InsertUploadList @"INSERT INTO UploadList(t_name,t_lenght,t_date,t_state,t_fileUrl,t_url_pid,t_url_name,t_file_type,User_id,File_id,Upload_size,Is_autoUpload,Is_share,Space_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
#define DeleteUploadList @"DELETE FROM UploadList WHERE t_id=? and User_id=?"
#define DeleteAutoUploadListAllAndNotUpload @"DELETE FROM UploadList WHERE Is_autoUpload=1 and t_state <>1 and User_id=?"
#define DeleteMoveUploadListAllAndNotUpload @"DELETE FROM UploadList WHERE Is_autoUpload=0 and t_state <>1 and User_id=?"
#define DeleteUploadListAndUpload @"DELETE FROM UploadList WHERE t_state=1 and User_id=?"
#define SelectUploadListIsHaveName @"SELECT * FROM UploadList WHERE t_name=? and User_id=? and Is_autoUpload=?"
#define UpdateUploadListForName @"UPDATE UploadList SET File_id=?,Upload_size=?,t_date=?,t_state=? WHERE t_name=? and User_id=?"

#define SelectAutoUploadListAllAndNotUpload @"SELECT * FROM UploadList WHERE Is_autoUpload=1 and t_state=0 and t_id>? and User_id=?"
#define SelectMoveUploadListAllAndNotUpload @"SELECT * FROM UploadList WHERE Is_autoUpload=0 and t_state=0 and t_id>? and User_id=?"
#define SelectUploadListAllAndUploaded @"SELECT * FROM UploadList WHERE t_state=1 and User_id=? and t_id>? ORDER BY t_id desc"

@interface UpLoadList : DBSqlite3

@property(nonatomic,assign) NSInteger t_id;
@property(nonatomic,retain) NSString *t_name;
@property(nonatomic,assign) NSInteger t_lenght;
@property(nonatomic,retain) NSString *t_date;
@property(nonatomic,assign) NSInteger t_state;
@property(nonatomic,retain) NSString *t_fileUrl;
@property(nonatomic,retain) NSString *t_url_pid;
@property(nonatomic,retain) NSString *t_url_name;
@property(nonatomic,assign) NSInteger t_file_type;
@property(nonatomic,retain) NSString *user_id;
@property(nonatomic,retain) NSString *file_id;
@property(nonatomic,assign) NSInteger upload_size;
@property(nonatomic,assign) BOOL is_autoUpload;
@property(nonatomic,assign) BOOL is_share;
@property(nonatomic,retain) NSString *spaceId;
@property(nonatomic,assign) NSInteger sudu;

//添加数据
-(BOOL)insertUploadList;
//根据文件名称删除一条记录
-(BOOL)deleteUploadList;
//删除自动上传的所有未完成的上传记录
-(BOOL)deleteAutoUploadListAllAndNotUpload;
//删除手动上传的所有未完成的上传记录
-(BOOL)deleteMoveUploadListAllAndNotUpload;
//删除所有上传完成的历史记录
-(BOOL)deleteUploadListAllAndUploaded;
//根据文件名称更新数据
-(BOOL)updateUploadList;
//查询文件是否存在
-(BOOL)selectUploadListIsHave;
//查询所有自动上传没有完成的记录
-(NSMutableArray *)selectAutoUploadListAllAndNotUpload;
//查询所有手动上传没有完成的记录
-(NSMutableArray *)selectMoveUploadListAllAndNotUpload;
//查询所有上传完成的历史记录
-(NSMutableArray *)selectUploadListAllAndUploaded;

-(void)updateList:(UpLoadList *)demo;

@end

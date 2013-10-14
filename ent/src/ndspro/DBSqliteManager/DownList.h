//
//  DownList.h
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DBSqlite3.h"

#define InsertDownList @"INSERT INTO DownList(d_name,d_state,d_thumbUrl,d_baseUrl,d_file_id,d_downSize,d_datetime,d_ure_id) VALUES (?,?,?,?,?,?,?,?)"
#define DeleteDownList @"DELETE FROM DownList WHERE d_id=? and d_ure_id=?"
#define DeleteDowningAll @"DELETE FROM DownList WHERE d_state<>1 and d_ure_id=?"
#define DeleteDownedAll @"DELETE FROM DownList WHERE d_state=1 and d_ure_id=?"
#define SelectDownListIsHaveName @"SELECT * FROM DownList WHERE d_name=? and d_ure_id=? and d_state=?"
#define UpdateDownListForUserId @"UPDATE DownList SET d_state=?,d_baseUrl=?,d_file_id=?,d_downSize=?,d_datetime=? WHERE d_id=? and d_ure_id=?"

#define SelectDowningAll @"SELECT * FROM DownList WHERE d_state<>1 and d_id>? and d_ure_id=?"
#define SelectDownedAll @"SELECT * FROM DownList WHERE d_state=1 and d_id>? and d_ure_id=?"

@interface DownList : DBSqlite3

@property(assign,nonatomic) NSInteger d_id;
@property(strong,nonatomic) NSString *d_name;
@property(assign,nonatomic) NSInteger d_state;
@property(strong,nonatomic) NSString *d_thumbUrl;
@property(strong,nonatomic) NSString *d_baseUrl;
@property(strong,nonatomic) NSString *d_file_id;
@property(assign,nonatomic) NSInteger d_downSize;
@property(strong,nonatomic) NSString *d_datetime;
@property(strong,nonatomic) NSString *d_ure_id;
@property(assign,nonatomic) NSInteger curr_size;
@property(nonatomic,assign) NSInteger sudu;

//添加数据
-(BOOL)insertDownList;
//根据文件id删除一条记录
-(BOOL)deleteDownList;
//删除所有未完成的下载记录
-(BOOL)deleteDowningAll;
//删除所有完成的下载记录
-(BOOL)deleteUploadedAll;
//查询文件是否存在
-(BOOL)selectUploadListIsHave;
//根据用户id更新数据
-(BOOL)updateDownListForUserId;
//查询所有没有完成的记录
-(NSMutableArray *)selectDowningAll;
//查询所有上传完成的历史记录
-(NSMutableArray *)selectDownedAll;

@end

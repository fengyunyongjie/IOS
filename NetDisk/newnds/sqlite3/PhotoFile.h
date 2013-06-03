//
//  PhotoFile.h
//  NetDisk
//
//  Created by Yangsl on 13-5-31.
//
//

#import <Foundation/Foundation.h>
#import "DBSqlite3.h"
#define CreatePhotoFileTable @"CREATE TABLE IF NOT EXISTS PhotoFile(F_ID INTEGER PRIMARY KEY,F_DATE TEXT,F_TIME double)"

#define InsertPhotoFileTable @"INSERT INTO PhotoFile(F_ID,F_DATE,F_TIME) VALUES (?,?,?)"
#define DeletePhotoFileTable @"DELETE FROM PhotoFile WHERE F_ID=?"
#define DeleteAllPhotoFileTable @"DELETE FROM PhotoFile"
#define UpdatePhotoFileTable @"UPDATE PhotoFile SET F_DATE=?,F_TIME=? WHERE F_ID=?"
#define SelectAllTaskTable @"SELECT * FROM PhotoFile"
#define SelectMorePhotoFileTable @"SELECT * FROM PhotoFile WHERE F_TIME>? and F_TIME<=?"
#define SelectCountPhotoFileTable @"SELECT COUNT(*) FROM PhotoFile"

@interface PhotoFile : DBSqlite3
{
    int f_id;
    NSString *f_date;
    double f_time;
}

-(id)init;

@property(nonatomic,assign) int f_id;
@property(nonatomic,retain) NSString *f_date;
@property(nonatomic,assign) double f_time;

#pragma mark 添加任务表数据
-(BOOL)insertPhotoFileTable;
#pragma mark 删除任务表
-(void)deletePhotoFileTable;
#pragma mark 删除任务表中所有数据
-(void)deleteAllPhotoFileTable;
#pragma mark 修改任务表
-(void)updatePhotoFileTable;
#pragma mark 查询任务表所有数据
-(NSArray *)selectAllTaskTable;
#pragma mark 查询时间轴的数据
-(NSArray *)selectMoreTaskTable:(NSString *)sDate eDate:(NSString *)eDate;
#pragma mark 查询时间轴的个数
-(NSInteger)selectCountTaskTable;

@end

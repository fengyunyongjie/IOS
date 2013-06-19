//
//  FavoritesDBController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-30.
//
//
#import <Foundation/Foundation.h>
#import "DBSqlite3.h"
#define CreateFavoritesTable @"create  table if not exists favorites(t_id integer primary key autoincrement,f_id text,f_name text,f_mime text,f_size text,compressaddr text,owner text,f_time text default CURRENT_TIMESTAMP)"
#define InsertTaskTable @"insert into favorites(f_id,f_name,f_mime,f_size,compressaddr,owner,f_time) values(?,?,?,?,?,?,datetime('now','localtime'))"
#define DeleteTskTable @"delete from favorites where f_id=? and owner=?"
#define SelectAllTaskTable @"select * from favorites where owner=? ORDER BY t_id DESC"
#define SelectOneTaskTableForFID @"select * from favorites where f_id=? and owner=?"


@interface FavoritesDBController : NSObject
{
    sqlite3 *contactDB;
}
@property (strong,nonatomic) NSString *databasePath;
-(id)init;
//增加数据
-(int)insertDic:(NSDictionary *)dic;
//删除数据
-(int)deleteWithF_ID:(NSString *)f_id;
//数据是否存在
-(BOOL)isExistsWithF_ID:(NSString *)f_id;
//查询数据
-(NSArray *)getAllDatas;
@end

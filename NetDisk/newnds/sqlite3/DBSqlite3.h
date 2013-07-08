//
//  DBSqlite3.h
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//
#define CreateTaskTable @"CREATE TABLE IF NOT EXISTS TASKTABLE(T_ID INTEGER PRIMARY KEY AUTOINCREMENT,F_ID INTEGER,F_DATA BLOB,F_STATE INTEGER,F_BASE_NAME TEXT,F_LENGHT INTEGER)"

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DBSqlite3 : NSObject
{
    sqlite3 *contactDB;
    
    NSString *databasePath;
}

-(id)init;
+(void)cleanSql;

@end

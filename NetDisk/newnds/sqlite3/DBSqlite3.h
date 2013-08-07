//
//  DBSqlite3.h
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//
#define CreateTaskTable @"CREATE TABLE IF NOT EXISTS TASKTABLE(T_ID INTEGER PRIMARY KEY AUTOINCREMENT,F_ID INTEGER,F_DATA BLOB,F_STATE INTEGER,F_BASE_NAME TEXT,F_LENGHT INTEGER,DEVICE_NAME TEXT,SPACE_ID TEXT)"
#define CreatePhotoFileTable @"CREATE TABLE IF NOT EXISTS PhotoFile(F_ID INTEGER PRIMARY KEY,F_DATE TEXT,F_TIME double)"
#define CreateUserinfoTable @"CREATE TABLE IF NOT EXISTS Userinfo(U_ID INTEGER PRIMARY KEY AUTOINCREMENT,ISTRUE INTEGER,KEY TEXT)"
#define CreateWebDataTable @"CREATE TABLE IF NOT EXISTS WebData(WEB_ID INTEGER PRIMARY KEY AUTOINCREMENT,PHOTO_NAME TEXT,PHOTO_ID TEXT)"

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DBSqlite3 : NSObject
{
    sqlite3 *contactDB;
    
    NSString *databasePath;
}

@property(strong,retain) NSString *databasePath;

-(id)init;
+(void)cleanSql;

@end

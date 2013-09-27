//
//  DBSqlite3.h
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//
#define CreateTaskTable @"CREATE TABLE IF NOT EXISTS TASKTABLE(T_ID INTEGER PRIMARY KEY AUTOINCREMENT,F_ID INTEGER,F_DATA BLOB,F_STATE INTEGER,F_BASE_NAME TEXT,F_LENGHT INTEGER,DEVICE_NAME TEXT,SPACE_ID TEXT,P_ID TEXT,IS_AUTOMIC_UPLOAD INTEGER)"
#define CreatePhotoFileTable @"CREATE TABLE IF NOT EXISTS PhotoFile(F_ID INTEGER PRIMARY KEY,F_DATE TEXT,F_TIME double)"
#define CreateUserinfoTable @"CREATE TABLE IF NOT EXISTS Userinfo(U_ID INTEGER PRIMARY KEY AUTOINCREMENT,ISTRUE INTEGER,KEY TEXT,DESCRIPT TEXT,F_ID INTEGER,Space_id TEXT)"
#define CreateWebDataTable @"CREATE TABLE IF NOT EXISTS WebData(WEB_ID INTEGER PRIMARY KEY AUTOINCREMENT,PHOTO_NAME TEXT,PHOTO_ID TEXT,P_ID TEXT)"
//新代码
#define CreateUploadList @"CREATE TABLE IF NOT EXISTS UploadList(t_id INTEGER PRIMARY KEY AUTOINCREMENT,t_name TEXT,t_lenght INTEGER,t_date TEXT,t_state INTEGER,t_fileUrl TEXT,t_url_pid TEXT,t_url_name TEXT,t_file_type INTEGER,User_id TEXT,File_id TEXT,Upload_size INTEGER,Is_autoUpload BLOB,Is_share BLOB,Space_id TEXT)"
#define CreateAutoUploadList @"CREATE TABLE IF NOT EXISTS AutoUploadList(a_id INTEGER PRIMARY KEY AUTOINCREMENT,a_name TEXT,a_user_id TEXT,a_state INTEGER)"

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

//
//  DBSqlite3.h
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//


#define CreateTaskTable @"CREATE TABLE IF NOT EXISTS TASKTABLE(T_ID INTEGER PRIMARY KEY AUTOINCREMENT,F_ID INTEGER,F_DATA BLOB,F_STATE INTEGER,F_BASE_NAME TEXT,F_LENGHT INTEGER,DEVICE_NAME TEXT,SPACE_ID TEXT,P_ID TEXT,IS_AUTOMIC_UPLOAD INTEGER)"
#define CreatePhotoFileTable @"CREATE TABLE IF NOT EXISTS PhotoFile(F_ID INTEGER PRIMARY KEY,F_DATE TEXT,F_TIME double)"
#define CreateUserinfoTable @"CREATE TABLE IF NOT EXISTS Userinfo(U_ID INTEGER PRIMARY KEY AUTOINCREMENT,Auto_url TEXT,User_name TEXT,F_ID INTEGER,Space_id TEXT,Is_autoUpload BLOB,IS_OneWiFi BLOB)"
//新代码
#define CreateUploadList @"CREATE TABLE IF NOT EXISTS UploadList(t_id INTEGER PRIMARY KEY AUTOINCREMENT,t_name TEXT,t_lenght INTEGER,t_date TEXT,t_state INTEGER,t_fileUrl TEXT,t_url_pid TEXT,t_url_name TEXT,t_file_type INTEGER,User_id TEXT,File_id TEXT,Upload_size INTEGER,Is_autoUpload BLOB,Is_share BLOB,Space_id TEXT,Is_Onece BLOB)"
#define CreateAutoUploadList @"CREATE TABLE IF NOT EXISTS AutoUploadList(a_id INTEGER PRIMARY KEY AUTOINCREMENT,a_name TEXT,a_user_id TEXT,a_state INTEGER)"
#define SelectTableIsHave @"SELECT COUNT(*)  as CNT FROM sqlite_master where type='table' and name=?"
//商业版新代码
#define CreateDownList @"CREATE TABLE IF NOT EXISTS DownList(d_id INTEGER PRIMARY KEY AUTOINCREMENT,d_name TEXT,d_state INTEGER,d_thumbUrl TEXT,d_baseUrl TEXT,d_file_id TEXT,d_downSize INTEGER,d_datetime TEXT,D_ure_id TEXT)"

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DBSqlite3 : NSObject
{
    sqlite3 *contactDB;
    
    NSString *databasePath;
}

@property(strong,retain) NSString *databasePath;

-(void)updateVersion;
-(id)init;
-(void)cleanSql;
-(BOOL)isHaveTable:(NSString *)name;

@end

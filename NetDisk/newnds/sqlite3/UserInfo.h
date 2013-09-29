//
//  UserInfo.h
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "DBSqlite3.h"
#define InsertUserinfoTable @"INSERT INTO Userinfo(Auto_url,User_name,F_ID,Space_id,Is_autoUpload,IS_OneWiFi) VALUES (?,?,?,?,?,?)"
#define UpdateUserinfoForName @"UPDATE Userinfo SET Auto_url=?,F_ID=?,Space_id=?,Is_autoUpload=?,IS_OneWiFi=? WHERE User_name=?"
#define SelectAllKey @"SELECT * FROM Userinfo WHERE User_name=?"
@interface UserInfo : DBSqlite3
{
    NSInteger u_id;
    NSString *auto_url;
    NSString *user_name;
    NSInteger f_id;
    NSString *space_id;
    BOOL is_autoUpload;
    BOOL is_oneWiFi;
}

@property(nonatomic,assign) NSInteger u_id;
@property(nonatomic,retain) NSString *auto_url;
@property(nonatomic,retain) NSString *user_name;
@property(nonatomic,assign) NSInteger f_id;
@property(nonatomic,retain) NSString *space_id;
@property(nonatomic,assign) BOOL is_autoUpload;
@property(nonatomic,assign) BOOL is_oneWiFi;

//添加数据
-(BOOL)insertUserinfo;

//修改数据
-(BOOL)updateUserinfo;

//查询数据列表
-(NSMutableArray *)selectAllUserinfo;

@end

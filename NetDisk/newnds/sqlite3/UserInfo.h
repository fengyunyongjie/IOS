//
//  UserInfo.h
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "DBSqlite3.h"
#define InsertUserinfoTable @"INSERT INTO Userinfo(ISTRUE,KEY) VALUES (?,?)"
#define UpdateUserinfoForName @"UPDATE Userinfo SET ISTRUE=? WHERE KEY=?"
#define SelectForKey @"SELECT ISTRUE FROM Userinfo WHERE KEY=?"

@interface UserInfo : DBSqlite3
{
    BOOL isTrue;
    NSString *keyString;
}

@property(nonatomic,assign) BOOL isTrue;
@property(nonatomic,retain) NSString *keyString;

//添加数据
-(BOOL)insertUserinfo;

//修改数据
-(BOOL)updateUserinfo;

//查询数据
-(BOOL)selectIsTrueForKey;

@end

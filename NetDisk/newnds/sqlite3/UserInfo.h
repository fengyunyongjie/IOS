//
//  UserInfo.h
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "DBSqlite3.h"
#define InsertUserinfoTable @"INSERT INTO Userinfo(ISTRUE,KEY,DESCRIPT,F_ID) VALUES (?,?,?,?)"
#define UpdateUserinfoForName @"UPDATE Userinfo SET ISTRUE=?,DESCRIPT=?,F_ID=? WHERE KEY=?"
#define SelectForKey @"SELECT ISTRUE FROM Userinfo WHERE KEY=?"
#define SelectAllKey @"SELECT * FROM Userinfo WHERE KEY=?"

@interface UserInfo : DBSqlite3
{
    BOOL isTrue;
    NSString *keyString;
    NSString *descript;
    int f_id;
}

@property(nonatomic,assign) BOOL isTrue;
@property(nonatomic,retain) NSString *keyString;
@property(nonatomic,retain) NSString *descript;
@property(nonatomic,assign) int f_id;

//添加数据
-(BOOL)insertUserinfo;

//修改数据
-(BOOL)updateUserinfo;

//查询数据
-(BOOL)selectIsTrueForKey;

//查询数据列表
-(NSMutableArray *)selectAllUserinfo;

@end

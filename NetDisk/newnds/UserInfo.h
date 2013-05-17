//
//  UserInfo.h
//  NetDisk
//  用户信息表
//  Created by Yangsl on 13-5-15.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface UserInfo : NSObject
{
    NSString *user_name;  //用户登录名
    NSString *user_password;    //用户秘密
    int client_tag;     //用户终端类型
    BOOL on_line;       //是否已经是登录状态
    NSString *user_id;      //用户临时ID
    NSString *user_token;   //用户token
    FMDatabase *database;   //数据库管理
}

@property(nonatomic,retain) NSString *user_name;
@property(nonatomic,retain) NSString *user_password;
@property(nonatomic,assign) int client_tag;
@property(nonatomic,assign) BOOL on_line;
@property(nonatomic,retain) NSString *user_id;
@property(nonatomic,retain) NSString *user_token;
@property(nonatomic,retain) FMDatabase *database;

#pragma mark 添加
-(BOOL)insertUserinfo;

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table;

#pragma mark 清除
-(BOOL)cleanUserinfo;

#pragma mark 修改
-(BOOL)updatetUserinfo;

#pragma mark 查询是否有这条数据
-(BOOL)isHaveUserinfo;

@end

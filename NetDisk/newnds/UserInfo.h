//
//  UserInfo.h
//  NetDisk
//
//  Created by Yangsl on 13-5-15.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface UserInfo : NSObject
{
    NSString *user_name;
    NSString *user_password;
    int client_tag;
    BOOL on_line;
    NSString *user_id;
    NSString *user_token;
    FMDatabase *database;
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

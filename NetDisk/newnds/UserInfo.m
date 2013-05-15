//
//  UserInfo.m
//  NetDisk
//
//  Created by Yangsl on 13-5-15.
//
//

#import "UserInfo.h"
#import "AppDelegate.h"

@implementation UserInfo
@synthesize user_name,client_tag,on_line,user_id,user_password,user_token;
@synthesize database;

#pragma mark 添加
-(BOOL)insertUserinfo
{
    BOOL bl = FALSE;
    [database executeUpdate:[self SQL:@"INSERT INTO %@ (USER_NAME, USER_PASSWORD) VALUES (?,?)" inTable:@"Userinfo"], self.user_name, self.user_password];
	if (![database hadError]) {
		bl = TRUE;
	}
    else
    {
        NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
    }
    return bl;
}

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table {
	return [NSString stringWithFormat:sql, table];
}

#pragma mark 清除
-(BOOL)cleanUserinfo
{
    BOOL bl = FALSE;
    [database executeUpdate:[self SQL:@"DELETE FROM %@ WHERE = ?" inTable:@"Userinfo"], self.user_name];
	if (![database hadError]) {
		bl = TRUE;
	}
    return bl;
}

#pragma mark 修改
-(BOOL)updatetUserinfo
{
    BOOL bl = FALSE;
    [database executeUpdate:[self SQL:@"UPDATE %@ SET USER_PASSWORD=? WHERE USER_NAME= ?" inTable:@"Userinfo"],self.user_password,self.user_name];
	if (![database hadError]) {
		bl = TRUE;
	}
    return bl;
}

#pragma mark 查询是否有这条数据
-(BOOL)isHaveUserinfo
{
    BOOL bl = FALSE;
    FMResultSet *rs = [database executeQuery:[self SQL:@"SELECT * FROM %@ WHERE USER_NAME=?" inTable:@"Userinfo"],self.user_name];
	while ([rs next]) {
        bl = TRUE;
	}
	[rs close];
    return bl;
}



-(void)dealloc
{
    [user_token release];
    [user_name release];
    [user_password release];
    [user_id release];
    [super dealloc];
}

@end

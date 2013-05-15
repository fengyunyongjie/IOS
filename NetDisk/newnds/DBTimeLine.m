//
//  DBTimeLine.m
//  NetDisk
//
//  Created by Yangsl on 13-5-15.
//
//

#import "DBTimeLine.h"

@implementation DBTimeLine
@synthesize user_name,user_linedictionary,database;

-(void)dealloc
{
    [user_name release];
    [user_linedictionary release];
    [super dealloc];
}

#pragma mark 添加
-(BOOL)insertUserinfo
{
    BOOL bl = FALSE;
    [database executeUpdate:[self SQL:@"INSERT INTO %@ (USER_NAME, USER_LINEDICTIONARY) VALUES (?,?)" inTable:@"ALLTIMELINE"], self.user_name, self.user_linedictionary];
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
    [database executeUpdate:[self SQL:@"DELETE FROM %@ WHERE = ?" inTable:@"ALLTIMELINE"], self.user_name];
	if (![database hadError]) {
		bl = TRUE;
	}
    return bl;
}

#pragma mark 修改
-(BOOL)updatetUserinfo
{
    BOOL bl = FALSE;
    [database executeUpdate:[self SQL:@"UPDATE %@ SET USER_LINEDICTIONARY=? WHERE USER_NAME= ?" inTable:@"ALLTIMELINE"],self.user_linedictionary,self.user_name];
	if (![database hadError]) {
		bl = TRUE;
	}
    return bl;
}

#pragma mark 查询是否有这条数据
-(NSData *)isHaveUserinfo
{
    NSData *tionary = nil;
    FMResultSet *rs = [database executeQuery:[self SQL:@"SELECT * FROM %@ WHERE USER_NAME=?" inTable:@"ALLTIMELINE"],self.user_name];
	while ([rs next]) {
        tionary = [rs dataForColumn:@"USER_LINEDICTIONARY"];
	}
	[rs close];
    return tionary;
}

@end

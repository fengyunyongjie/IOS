//
//  UserInfo.m
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "UserInfo.h"
#import "NSString+Format.h"

@implementation UserInfo
@synthesize u_id,auto_url,user_name,f_id,space_id,is_autoUpload,is_oneWiFi;

//添加数据
-(BOOL)insertUserinfo
{
    sqlite3_stmt *statement;
    NSMutableArray *array = [self selectAllUserinfo];
    if([array count]>0)
    {
        [self updateUserinfo];
        return YES;
    }
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertUserinfoTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [auto_url UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [user_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, f_id);
        sqlite3_bind_text(statement, 4, [space_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 5, is_autoUpload);
        sqlite3_bind_int(statement, 6, is_oneWiFi);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        DDLogCInfo(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//修改数据
-(BOOL)updateUserinfo
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateUserinfoForName UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [auto_url UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, f_id);
        sqlite3_bind_text(statement, 3, [space_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, is_autoUpload);
        sqlite3_bind_int(statement, 5, is_oneWiFi);
        sqlite3_bind_text(statement, 6, [user_name UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        DDLogCInfo(@"updateUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//查询数据列表
-(NSMutableArray *)selectAllUserinfo
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllKey UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [user_name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UserInfo *info = [[UserInfo alloc] init];
            info.u_id = sqlite3_column_int(statement, 0);
            const char *url = (const char *)sqlite3_column_text(statement, 1);
            info.auto_url = [NSString formatNSStringForChar:url];
            const char *name = (const char *)sqlite3_column_text(statement, 2);
            info.user_name = [NSString formatNSStringForChar:name];
            info.f_id = sqlite3_column_int(statement, 3);
            const char *space = (const char *)sqlite3_column_text(statement, 4);
            info.space_id = [NSString formatNSStringForChar:space];
            info.is_autoUpload = sqlite3_column_int(statement, 5);
            info.is_oneWiFi = sqlite3_column_int(statement, 6);
            [tableArray addObject:info];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}

//查询数据是否存在
-(NSMutableArray *)selectIsHaveUser
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectIsHave UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [user_name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UserInfo *info = [[UserInfo alloc] init];
            info.u_id = sqlite3_column_int(statement, 0);
            const char *url = (const char *)sqlite3_column_text(statement, 1);
            info.auto_url = [NSString formatNSStringForChar:url];
            const char *name = (const char *)sqlite3_column_text(statement, 2);
            info.user_name = [NSString formatNSStringForChar:name];
            info.f_id = sqlite3_column_int(statement, 3);
            const char *space = (const char *)sqlite3_column_text(statement, 4);
            info.space_id = [NSString formatNSStringForChar:space];
            info.is_autoUpload = sqlite3_column_int(statement, 5);
            info.is_oneWiFi = sqlite3_column_int(statement, 6);
            [tableArray addObject:info];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}


@end

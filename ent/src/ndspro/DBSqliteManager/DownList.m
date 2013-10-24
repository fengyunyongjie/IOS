//
//  DownList.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DownList.h"
#import "NSString+Format.h"
#import "YNFunctions.h"

@implementation DownList
@synthesize d_thumbUrl,d_baseUrl,d_datetime,d_downSize,d_id,d_name,d_state,d_file_id,d_ure_id,curr_size,sudu;

//添加数据
-(BOOL)insertDownList
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertDownList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [d_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, d_state);
        sqlite3_bind_text(statement, 3, [d_thumbUrl UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [d_baseUrl UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [d_file_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 6, d_downSize);
        sqlite3_bind_text(statement, 7, [d_datetime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR || success != 101) {
            bl = FALSE;
        }
        
        DDLogCInfo(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

//根据文件id删除一条记录
-(BOOL)deleteDownList
{
    
    if([self.d_baseUrl isEqualToString:@"(null)"] || [self.d_baseUrl length]==0)
    {
        
    }
    else
    {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if([filemgr fileExistsAtPath:self.d_baseUrl])
        {
            BOOL isDelete = [filemgr removeItemAtPath:self.d_baseUrl error:nil];
            DDLogCInfo(@"删除文件是否成功：%i",isDelete);
        }
    }
    
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteDownList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, d_id);
        sqlite3_bind_text(statement, 2, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
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

//删除所有未完成的下载记录
-(BOOL)deleteDowningAll
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteDowningAll UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
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

//删除所有完成的下载记录
-(BOOL)deleteUploadedAll
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteDownedAll UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
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
//查询文件是否存在
-(BOOL)selectUploadListIsHave
{
    sqlite3_stmt *statement;
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectDownListIsHaveName UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [d_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, d_state);
        if (sqlite3_step(statement)==SQLITE_ROW) {
            bl = TRUE;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}
//根据用户id更新数据
-(BOOL)updateDownListForUserId
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateDownListForUserId UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, d_state);
        
        sqlite3_bind_text(statement, 2, [d_baseUrl UTF8String], -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_text(statement, 3, [d_file_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, d_downSize);
        sqlite3_bind_text(statement, 5, [d_datetime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 6, d_id);
        sqlite3_bind_text(statement, 7, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        
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
//查询所有没有完成的记录
-(NSMutableArray *)selectDowningAll
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectDowningAll UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, d_id);
        sqlite3_bind_text(statement, 2, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            DownList *list = [[DownList alloc] init];
            list.d_id = sqlite3_column_int(statement, 0);
            list.d_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            list.d_state = sqlite3_column_int(statement, 2);
            list.d_thumbUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            list.d_baseUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            list.d_file_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            list.d_downSize = sqlite3_column_int(statement, 6);;
            list.d_datetime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            list.d_ure_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 8)];
            [tableArray addObject:list];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    DDLogCInfo(@"自动上传的个数:%i",[tableArray count]);
    return tableArray;
}
//查询所有上传完成的历史记录
-(NSMutableArray *)selectDownedAll
{
    sqlite3_stmt *statement;
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectDownedAll UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, d_id);
        sqlite3_bind_text(statement, 2, [d_ure_id UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            DownList *list = [[DownList alloc] init];
            list.d_id = sqlite3_column_int(statement, 0);
            list.d_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 1)];
            list.d_state = sqlite3_column_int(statement, 2);
            list.d_thumbUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 3)];
            list.d_baseUrl = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            list.d_file_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 5)];
            list.d_downSize = sqlite3_column_int(statement, 6);;
            list.d_datetime = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            list.d_ure_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 8)];
            [tableArray addObject:list];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    DDLogCInfo(@"自动上传的个数:%i",[tableArray count]);
    return tableArray;
}

@end
//
//  WebData.m
//  NetDisk
//
//  Created by Yangsl on 13-8-7.
//
//

#import "WebData.h"

@implementation WebData
@synthesize photo_id,photo_name,web_id,p_id;

#pragma mark 清空数据库
-(BOOL)clearTable
{
//    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
//    const char *dbpath = [self.databasePath UTF8String];
    
//    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
//        const char *insert_stmt = [DeleteALLTskTable UTF8String];
//        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
//        if (success != SQLITE_OK) {
//            bl = FALSE;
//        }
//        sqlite3_bind_int(statement, 1, f_id);
//        success = sqlite3_step(statement);
//        if (success == SQLITE_ERROR) {
//            bl = FALSE;
//        }
//        NSLog(@"insertTaskTable:%i",success);
//        sqlite3_finalize(statement);
//        sqlite3_close(contactDB);
//    }
    return bl;
}

#pragma mark ------- 添加数据

-(BOOL)insertWebData
{
    __block BOOL bl = TRUE;
    BOOL isHave = [self selectIsTrueForPhotoName];
    if(!isHave)
    {
        sqlite3_stmt *statement;
        
        const char *dbpath = [self.databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
            const char *insert_stmt = [InsertWebDataTable UTF8String];
            int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
            if (success != SQLITE_OK) {
                bl = FALSE;
            }
            NSLog(@"photo_name:%@",photo_name);
            NSLog(@"photo_id:%@",photo_id);
            NSLog(@"p_id:%@",p_id);
            sqlite3_bind_text(statement, 1, [photo_name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [photo_id UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [p_id UTF8String], -1, SQLITE_TRANSIENT);
            success = sqlite3_step(statement);
            if (success == SQLITE_ERROR) {
                bl = FALSE;
            }
            NSLog(@"insertWebData:%i",success);
            sqlite3_finalize(statement);
            sqlite3_close(contactDB);
        }
    }
    return bl;
}

#pragma mark ------- 修改数据
-(BOOL)updateWebData
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateWebDataForName UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [photo_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [photo_name UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"updateWebData:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark ------- 查询数据
-(BOOL)selectIsTrueForPhotoName
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    __block BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectForKey UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [photo_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [p_id UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            int i = sqlite3_column_int(statement, 0);
            if(i>=1)
            {
                bl = TRUE;
                break;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

@end

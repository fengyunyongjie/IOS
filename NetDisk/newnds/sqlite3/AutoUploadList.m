//
//  AutoUploadList.m
//  NetDisk
//
//  Created by Yangsl on 13-9-27.
//
//

#import "AutoUploadList.h"

@implementation AutoUploadList
@synthesize a_id,a_name,a_state,a_user_id;

//批量处理添加
-(BOOL)insertsAutoUploadList:(NSMutableArray *)tableArray
{
    __block BOOL bl = FALSE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        
        sqlite3_exec(contactDB,"BEGIN TRANSACTION",0,0,0);  //事务开始
        for (int i=0; i<tableArray.count; i++) {
            AutoUploadList *list = [tableArray objectAtIndex:i];
            NSString *format = [NSString stringWithFormat:InsertsAutoUploadList,list.a_name,list.a_user_id,list.a_state];
            NSString *s = [[NSString alloc] initWithUTF8String:[format UTF8String]];
            const char *insert_stmt = (char *) [s UTF8String];
            int success  = sqlite3_exec(contactDB, insert_stmt , 0, 0, 0 );
            if (success != SQLITE_OK) {
                bl = FALSE;
            }
        }
        int success = sqlite3_exec(contactDB,"COMMIT",0,0,0); //COMMIT
        
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        else
        {
            bl = TRUE;
        }
    }
    sqlite3_close(contactDB);
    return bl;
}

-(BOOL)insertAutoUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertAutoUploadList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [a_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [a_user_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, a_state);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR || success == 5) {
            bl = FALSE;
        }
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(BOOL)deleteAutoUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteAutoUploadList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [a_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [a_user_id UTF8String], -1, SQLITE_TRANSIENT);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(BOOL)deleteAllAutoUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteAllAutoUploadList UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(BOOL)updateAutoUploadList
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateAutoUploadListForName UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, a_state);
        sqlite3_bind_text(statement, 2, [a_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [a_user_id UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertUserinfo:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(BOOL)selectAutoUploadList
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    __block BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAutoUploadListForName UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [a_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [a_user_id UTF8String], -1, SQLITE_TRANSIENT);
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

-(NSInteger)SelectCountAutoUploadList
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    __block NSInteger count = 0;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectCountAutoUploadListForUserId UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [a_user_id UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement)==SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return count;
}

@end

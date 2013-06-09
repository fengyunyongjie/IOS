//
//  TaskDemo.m
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//

#import "TaskDemo.h"

@implementation TaskDemo
@synthesize f_id,f_base_name,f_data,f_state,t_id,f_lenght,result;

-(id)init
{
    return [super init];
}

#pragma mark 添加任务表数据
-(BOOL)insertTaskTable
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertTaskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, f_id);
        sqlite3_bind_int(statement, 2, f_state);
        sqlite3_bind_text(statement, 3, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, f_lenght);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"success:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 删除任务表
#pragma mark 修改任务表
-(void)updateTaskTable
{
    sqlite3_stmt *statement;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateTaskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        sqlite3_bind_int(statement, 1, f_id);
//        sqlite3_bind_blob(statement, 2, [f_data bytes], f_lenght, NULL);
        sqlite3_bind_int(statement, 2, f_state);
        sqlite3_bind_text(statement, 3, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, f_lenght);
        sqlite3_bind_int(statement, 5, t_id);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}

-(void)updateTaskTableFName
{
    sqlite3_stmt *statement;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateTaskTableForName UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        sqlite3_bind_int(statement, 1, f_id);
//        sqlite3_bind_blob(statement, 2, [f_data bytes], f_lenght, NULL);
        sqlite3_bind_int(statement, 2, f_state);
        sqlite3_bind_text(statement, 3, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, f_lenght);
        sqlite3_bind_text(statement, 5, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}


#pragma mark 查询任务表所有数据
-(NSArray *)selectAllTaskTable
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllTaskTable UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        
        while (sqlite3_step(statement)==SQLITE_ROW) {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.t_id = sqlite3_column_int(statement, 0);
            demo.f_id = sqlite3_column_int(statement, 1);
//            int bytes = sqlite3_column_bytes(statement, 2);
//            const void *value = sqlite3_column_blob(statement, 2);
//            if( value != NULL && bytes != 0 ){
//                NSData *data = [NSData dataWithBytes:value length:bytes];
//                demo.f_data = data;
//            }
            demo.f_state = sqlite3_column_int(statement, 3);
            demo.f_base_name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
            demo.f_lenght = sqlite3_column_int(statement, 5);
            [tableArray addObject:demo];
            [demo release];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return [tableArray autorelease];
}

#pragma mark 查询任务表所有数据
-(NSArray *)selectAllTaskTableForFNAME
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableForFNAME UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(statement, 2, [f_data bytes], f_lenght, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.t_id = sqlite3_column_int(statement, 0);
            demo.f_id = sqlite3_column_int(statement, 1);
//            int bytes = sqlite3_column_bytes(statement, 2);
//            const void *value = sqlite3_column_blob(statement, 2);
//            if( value != NULL && bytes != 0 ){
//                NSData *data = [NSData dataWithBytes:value length:bytes];
//                demo.f_data = data;
//            }
            demo.f_state = sqlite3_column_int(statement, 3);
            demo.f_base_name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
            demo.f_lenght = sqlite3_column_int(statement, 5);
            [tableArray addObject:demo];
            [demo release];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return [tableArray autorelease];
}

#pragma mark 查询任务表单个数据
#pragma mark 查询任务表单个数据
#pragma mark 查询任务表单个数据

#pragma mark 判断图片是否存在
-(BOOL)isPhotoExist
{
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableForFNAME UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
//            int bytes = sqlite3_column_bytes(statement, 2);
//            const void *value = sqlite3_column_blob(statement, 2);
//            if( value != NULL && bytes != 0 ){
//                NSData *data = [NSData dataWithBytes:value length:bytes];
//                if([f_data isEqualToData:data])
//                {
                    bl = TRUE;
                    break;
//                }
//            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 判断图片是否存在
-(BOOL)isExistOneImage
{
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableOneceForFNAME UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            //            int bytes = sqlite3_column_bytes(statement, 2);
            //            const void *value = sqlite3_column_blob(statement, 2);
            //            if( value != NULL && bytes != 0 ){
            //                NSData *data = [NSData dataWithBytes:value length:bytes];
            //                if([f_data isEqualToData:data])
            //                {
            bl = TRUE;
            break;
            //                }
            //            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(void)dealloc
{
    [f_base_name release];
    [f_data release];
    [result release];
    [super dealloc];
}

@end

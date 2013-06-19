//
//  FavoritesDBController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-30.
//
//

#import "FavoritesDBController.h"
#import "YNFunctions.h"

@implementation FavoritesDBController
-(id)init
{
    // Do any additional setup after loading the view, typically from a nib.
    
    /*根据路径创建数据库并创建一个表contact(id nametext addresstext phonetext)*/
    
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"favorites_db.sqlite"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:self.databasePath] == NO)
    {
        const char *dbpath = [self.databasePath UTF8String];
        if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK)
        {
            char *errMsg;
            if (sqlite3_exec(contactDB, (const char *)[CreateFavoritesTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
                NSLog(@"errMsg:%s",errMsg);
            }
        }
        else
        {
            NSLog(@"创建/打开数据库失败");
        }
    }
    return self;
}
//增加数据
-(int)insertDic:(NSDictionary *)dic
{
    sqlite3_stmt *statement;
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"favorites_db.sqlite"];
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertTaskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        NSString *f_id=[dic objectForKey:@"f_id"];
        NSString *f_name=[dic objectForKey:@"f_name"];
        NSString *f_mime=[dic objectForKey:@"f_mime"];
        NSString *f_size=[dic objectForKey:@"f_size"];
        NSString *compressaddr=[dic objectForKey:@"compressaddr"];
        NSString *owner=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
        
        f_id=[NSString stringWithFormat:@"%@",f_id];
        f_size=[NSString stringWithFormat:@"%@",f_size];
        sqlite3_bind_text(statement, 1, [f_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [f_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [f_mime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [f_size UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [compressaddr UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [owner UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return 0;
}
//删除数据
-(int)deleteWithF_ID:(NSString *)f_id
{
    sqlite3_stmt *statement;
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"favorites_db.sqlite"];
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteTskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        NSString *owner=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
        f_id=[NSString stringWithFormat:@"%@",f_id];
        sqlite3_bind_text(statement, 1, [f_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [owner UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return 0;
}
//数据是否存在
-(BOOL)isExistsWithF_ID:(NSString *)f_id
{
    sqlite3_stmt *statement;
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"favorites_db.sqlite"];
    const char *dbpath = [self.databasePath UTF8String];
    BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableForFID UTF8String];
        int success=sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:isExists");
        }
        NSString *owner=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
        f_id=[NSString stringWithFormat:@"%@",f_id];
        sqlite3_bind_text(statement, 1, [f_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [owner UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            bl = TRUE;
            break;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}
//查询数据
-(NSArray *)getAllDatas
{
    NSMutableArray *tableArray = [NSMutableArray array];
    sqlite3_stmt *statement;
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"favorites_db.sqlite"];
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllTaskTable UTF8String];
        int success=sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:getAllDatas");
        }
         NSString *owner=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
        sqlite3_bind_text(statement, 1, [owner UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            const char * value=(const char *)sqlite3_column_text(statement, 1);
            NSLog(@"%s",value);
            [dic setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)] forKey:@"f_id"];
            [dic setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 2)] forKey:@"f_name"];
            [dic setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 3)] forKey:@"f_mime"];
            [dic setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 4)] forKey:@"f_size"];
            const char * comp=(const char *)sqlite3_column_text(statement, 5);
            if (comp==NULL) {
                NSLog(@"compressaddr =NULL");
            }else
            {
                NSLog(@"%s",value);
                [dic setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 5)] forKey:@"compressaddr"];
            }
            const char * time=(const char*)sqlite3_column_text(statement, 7);
            if (time==NULL) {
                NSLog(@"f_time==NULL");
                [dic setObject:@"2013-06-19 12:17:17" forKey:@"f_time"];
            }else
            {
                NSLog(@"f_time = %s",time);
                [dic setObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 7)] forKey:@"f_time"];
            }
            [tableArray addObject:dic];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}
@end

//
//  DBSqlite3.m
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//

#import "DBSqlite3.h"
#import "YNFunctions.h"

@implementation DBSqlite3
@synthesize databasePath;

-(id)init
{
    // Do any additional setup after loading the view, typically from a nib.
    
    /*根据路径创建数据库并创建一个表contact(id nametext addresstext phonetext)*/
    
    self.databasePath=[YNFunctions getDBCachePath];
    self.databasePath=[self.databasePath stringByAppendingPathComponent:@"hongPan.sqlite"];
    
    if (sqlite3_open([self.databasePath fileSystemRepresentation], &contactDB)==SQLITE_OK)
    {
        char *errMsg;
        if (sqlite3_exec(contactDB, [CreateTaskTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        if (sqlite3_exec(contactDB, (const char *)[CreatePhotoFileTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        if (sqlite3_exec(contactDB, (const char *)[CreateUserinfoTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        //新代码
        if (sqlite3_exec(contactDB, (const char *)[CreateUploadList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        if (sqlite3_exec(contactDB, (const char *)[CreateAutoUploadList UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
            NSLog(@"errMsg:%s",errMsg);
        }
        sqlite3_close(contactDB);
    }
    else
    {
        NSLog(@"创建/打开数据库失败");
    }
    
    
    return self;
}

-(void)cleanSql
{
    BOOL bl = [self deleteUploadList:@"DELETE FROM PhotoFile"];
    NSLog(@"照片文件删除：%i",bl);
//    bl = [self deleteUploadList:@"DELETE FROM UploadList"];
//    NSLog(@"上传文件删除：%i",bl);
}

-(BOOL)deleteUploadList:(NSString *)sqlDelete
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [sqlDelete UTF8String];
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


@end

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
        if (sqlite3_exec(contactDB, (const char *)[CreateWebDataTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
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

+(void)cleanSql
{
    NSString *databasePaths=[YNFunctions getDBCachePath];
    databasePaths=[databasePaths stringByAppendingPathComponent:@"hongPan.sqlite"];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    BOOL bl = [filemgr removeItemAtPath:databasePaths error:nil];
    NSLog(@"bl:%i",bl);
}

@end

//
//  DBSqlite3.m
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//

#import "DBSqlite3.h"
#import "SCBSession.h"

@implementation DBSqlite3

-(id)init
{
    // Do any additional setup after loading the view, typically from a nib.
    
    /*根据路径创建数据库并创建一个表contact(id nametext addresstext phonetext)*/
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"hongPan.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK)
        {
            char *errMsg;
            if (sqlite3_exec(contactDB, (const char *)[CreateTaskTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
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

+(void)cleanSql
{
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"hongPan.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    BOOL bl = [filemgr removeItemAtPath:databasePath error:nil];
    NSLog(@"bl:%i",bl);
}

@end

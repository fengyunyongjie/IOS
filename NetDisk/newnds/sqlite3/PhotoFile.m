//
//  PhotoFile.m
//  NetDisk
//
//  Created by Yangsl on 13-5-31.
//
//

#import "PhotoFile.h"
#import "SCBSession.h"

@implementation PhotoFile
@synthesize f_id,f_date;
@synthesize f_time;

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
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@PhotoFile.sqlite",[[SCBSession sharedSession] userId]]]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK)
        {
            char *errMsg;
            if (sqlite3_exec(contactDB, (const char *)[CreatePhotoFileTable UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
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

#pragma mark 添加任务表数据
-(BOOL)insertPhotoFileTable
{
    BOOL bl = FALSE;
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertPhotoFileTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        sqlite3_bind_int(statement, 1, f_id);
        sqlite3_bind_text(statement, 2, [f_date UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 3, f_time);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        if(success == 101)
        {
            bl = TRUE;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 删除任务表
-(void)deletePhotoFileTable
{
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeletePhotoFileTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        sqlite3_bind_int(statement, 1, f_id);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        NSLog(@"success:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}


#pragma mark 修改任务表
-(void)updatePhotoFileTable
{
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdatePhotoFileTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
        sqlite3_bind_text(statement, 1, [f_date UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, f_time);
        sqlite3_bind_double(statement, 3, f_id);
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
            PhotoFile *demo = [[PhotoFile alloc] init];
            demo.f_id = sqlite3_column_int(statement, 0);
            demo.f_date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
            demo.f_time = sqlite3_column_double(statement, 2);
            [tableArray addObject:demo];
            [demo release];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return [tableArray autorelease];
}

#pragma mark 查询时间轴的数据
-(NSArray *)selectMoreTaskTable:(NSString *)sDate eDate:(NSString *)eDate
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    double sDoubel = [[dateFormatter dateFromString:sDate] timeIntervalSince1970];
    double eDoubel = [[dateFormatter dateFromString:eDate] timeIntervalSince1970];
    
    NSLog(@"SELECT * FROM PhotoFile WHERE F_TIME>%f and F_TIME<=%f",sDoubel,eDoubel);
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectMorePhotoFileTable UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_double(statement, 1, sDoubel);
        sqlite3_bind_double(statement, 2, eDoubel);
        
        while (sqlite3_step(statement)==SQLITE_ROW) {
            PhotoFile *demo = [[PhotoFile alloc] init];
            demo.f_id = sqlite3_column_int(statement, 0);
            demo.f_date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
            demo.f_time = sqlite3_column_double(statement, 2);
            [tableArray addObject:demo];
            [demo release];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return [tableArray autorelease];
}

-(void)dealloc
{
    [self.f_date release];
    [super dealloc];
}

@end

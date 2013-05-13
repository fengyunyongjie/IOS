//
//  PhohoDemo.m
//  NetDisk
//
//  Created by Yangsl on 13-5-3.
//
//

#import "PhohoDemo.h"

@implementation PhohoDemo
@synthesize compressaddr,date,f_id,f_mime,f_modify,f_name,f_ownerid,f_pid,f_size,img_create,total,f_create;
@synthesize date_type,key_string,oderByString,user_id,user_name;
@synthesize sqlite_path;

- (void)init_sqlite3_database
{
    NSFileManager *fm_manager = [NSFileManager defaultManager];
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [path_array objectAtIndex:0];
    NSString *path = [directory stringByAppendingPathComponent:@"SigmanoteDB.sqlite"];
    BOOL is_exists = [fm_manager fileExistsAtPath:path];
    NSError *error;
    if (!is_exists)
    {
        NSString *db_path = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"SigmanoteDB.sqlite"];
        BOOL success = [fm_manager copyItemAtPath:db_path toPath:path error:&error];
        if(!success)
		{
			NSLog(@"%@",[error localizedDescription]);
		}
    }
    [self setSqlite_path:sqlite_path];
}

-(void)dealloc
{
    [compressaddr release];
    [date release];
    [f_mime release];
    [f_modify release];
    [f_name release];
    [img_create release];
    [f_create release];
    [date_type release];
    [key_string release];
    [oderByString release];
    [user_id release];
    [user_name release];
    [sqlite_path release];
    [super dealloc];
}

@end

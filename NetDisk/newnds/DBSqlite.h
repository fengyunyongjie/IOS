//
//  DBSqlite.h
//  NetDisk
//
//  Created by Yangsl on 13-5-15.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBSqlite : NSObject
{
    FMDatabase *db;
}

- (BOOL)initDatabase;
- (void)closeDatabase;
- (FMDatabase *)getDatabase;

@end

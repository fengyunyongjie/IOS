//
//  AutoUploadList.h
//  NetDisk
//
//  Created by Yangsl on 13-9-27.
//
//

#import <Foundation/Foundation.h>
#import "DBSqlite3.h"

#define InsertAutoUploadList @"INSERT INTO AutoUploadList(a_name,a_user_id,a_state) VALUES (?,?,?)"
#define DeleteAutoUploadList @"DELETE FROM AutoUploadList WHERE t_id=?"
#define DeleteAllAutoUploadList @"DELETE FROM AutoUploadList WHERE a_state=0"
#define UpdateAutoUploadListForName @"UPDATE AutoUploadList SET a_state=? WHERE a_name=?"
#define SelectAutoUploadListForName @"SELECT * FROM AutoUploadList WHERE a_name=? and a_user_id=?"
#define SelectCountAutoUploadListForUserId @"SELECT Count(*) FROM AutoUploadList WHERE a_user_id=?"

@interface AutoUploadList : DBSqlite3

@property(nonatomic,assign) NSInteger a_id;
@property(nonatomic,retain) NSString *a_name;
@property(nonatomic,retain) NSString *a_user_id;
@property(nonatomic,assign) NSInteger a_state;

-(BOOL)insertAutoUploadList;

-(BOOL)deleteAutoUploadList;

-(BOOL)deleteAllAutoUploadList;

-(BOOL)updateAutoUploadList;

-(BOOL)selectAutoUploadList;

-(NSInteger)SelectCountAutoUploadList;

@end

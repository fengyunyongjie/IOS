//
//  WebData.h
//  NetDisk
//
//  Created by Yangsl on 13-8-7.
//
//

#import "DBSqlite3.h"
#define InsertWebDataTable @"INSERT INTO WebData(PHOTO_NAME,PHOTO_ID) VALUES (?,?)"
#define UpdateWebDataForName @"UPDATE WebData SET PHOTO_ID=? WHERE PHOTO_NAME=?"
#define SelectForKey @"SELECT * FROM WebData WHERE PHOTO_NAME=?"


@interface WebData : DBSqlite3
{
    NSInteger web_id;
    NSString *photo_name;
    NSString *photo_id;
}

@property(nonatomic,assign) NSInteger web_id;
@property(nonatomic,retain) NSString *photo_name;
@property(nonatomic,retain) NSString *photo_id;

//添加数据
-(BOOL)insertWebData;

//修改数据
-(BOOL)updateWebData;

//查询数据
-(BOOL)selectIsTrueForPhotoName;


@end

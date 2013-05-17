//
//  DBTimeLine.h
//  NetDisk
//  用户文件
//  Created by Yangsl on 13-5-15.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBTimeLine : NSObject
{
    NSString *user_name;
    NSData *user_linedictionary;
    FMDatabase *database;
}

@property(nonatomic,retain) NSString *user_name;
@property(nonatomic,retain) NSData *user_linedictionary;
@property(nonatomic,retain) FMDatabase *database;

#pragma mark 添加
-(BOOL)insertUserinfo;

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table;

#pragma mark 清除
-(BOOL)cleanUserinfo;

#pragma mark 修改
-(BOOL)updatetUserinfo;

#pragma mark 查询是否有这条数据
-(NSData *)isHaveUserinfo;

@end

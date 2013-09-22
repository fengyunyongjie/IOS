//
//  TaskDemo.m
//  NetDisk
//
//  Created by Yangsl on 13-5-27.
//
//

#import "TaskDemo.h"
#import "UploadFile.h"
#import "NSString+Format.h"

@implementation TaskDemo
@synthesize f_id,f_base_name,f_data,f_state,t_id,f_lenght,result,proess,index_id;
@synthesize deviceName,state;
@synthesize space_id;
@synthesize p_id;
@synthesize is_automic_upload;
@synthesize topImage;

-(id)init
{
    self = [super init];
    return self;
}

#pragma mark 添加任务表数据
-(BOOL)insertTaskTable
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    NSLog(@"insertTaskTable space_id:%@",space_id);
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [InsertTaskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        NSString *sapce_ = [NSString stringWithFormat:@"%@",space_id];
        NSString *p_id_ = [NSString stringWithFormat:@"%@",p_id];
        
        sqlite3_bind_int(statement, 1, f_id);
        sqlite3_bind_int(statement, 2, f_state);
        sqlite3_bind_text(statement, 3, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, f_lenght);
        sqlite3_bind_blob(statement, 5, [f_data bytes], [f_data length], NULL);
        sqlite3_bind_text(statement, 6, [deviceName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [sapce_ UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [p_id_ UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 9, is_automic_upload);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertTaskTable:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 删除任务表
#pragma mark 删除单个数据
-(BOOL)deleteTaskTable
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteTskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"deleteTaskTable:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 删除所有数据
-(BOOL)deleteAllTaskTable
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteALLTskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, f_id);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertTaskTable:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 删除上传记录
-(BOOL)deleteUploadTaskTable
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteUploadTskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, f_id);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertTaskTable:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 删除历史记录
-(BOOL)deleteFinishTaskTable
{
    sqlite3_stmt *statement;
    __block BOOL bl = TRUE;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [DeleteFinishTskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            bl = FALSE;
        }
        sqlite3_bind_int(statement, 1, f_id);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            bl = FALSE;
        }
        NSLog(@"insertTaskTable:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}
    
#pragma mark 修改任务表
-(void)updateTaskTable
{
    sqlite3_stmt *statement;
    
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateTaskTable UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert: updateTaskTable");
        }
        sqlite3_bind_int(statement, 1, f_id);
        //        sqlite3_bind_blob(statement, 2, [f_data bytes], f_lenght, NULL);
        sqlite3_bind_int(statement, 2, f_state);
        sqlite3_bind_text(statement, 3, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, f_lenght);
        sqlite3_bind_int(statement, 5, t_id);
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}

-(void)updateTaskTableFName
{
    sqlite3_stmt *statement;
    
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [UpdateTaskTableForName UTF8String];
        int success = sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to insert:TASKTable");
        }
//        NSString *sapce_ = [NSString stringWithFormat:@"%@",space_id];
        NSString *p_id_ = [NSString stringWithFormat:@"%@",p_id];
        f_lenght = [f_data length];
        sqlite3_bind_int(statement, 1, f_id);
        sqlite3_bind_int(statement, 2, f_state);
        sqlite3_bind_text(statement, 3, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, f_lenght);
        sqlite3_bind_blob(statement, 5, [f_data bytes], f_lenght, NULL);
        sqlite3_bind_text(statement, 6, [p_id_ UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 7, is_automic_upload);
        sqlite3_bind_text(statement, 8, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
        }
        NSLog(@"updateTaskTableFName:%i",success);
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
}


#pragma mark 查询任务表所有数据
-(NSMutableArray *)selectAllTaskTable
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectAllTaskTable UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        int i=0;
        while (sqlite3_step(statement)==SQLITE_ROW) {
            UploadFile *upload_file = [[UploadFile alloc] init];
            
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.t_id = sqlite3_column_int(statement, 0);
            demo.f_id = sqlite3_column_int(statement, 1);
            int bytes = sqlite3_column_bytes(statement, 2);
            const void *value = sqlite3_column_blob(statement, 2);
            if( value != NULL && bytes != 0 ){
                NSData *data = [NSData dataWithBytes:value length:bytes];
                demo.f_data = data;
            }
            demo.f_state = sqlite3_column_int(statement, 3);
            demo.f_base_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            demo.f_lenght = sqlite3_column_int(statement, 5);
            demo.deviceName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            demo.space_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            demo.p_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 8)];
            demo.is_automic_upload = sqlite3_column_int(statement, 9);
            demo.index_id = i;
            
            if([demo.f_data length]>1024*1024)
            {
                UIImage *data_image = [UIImage imageWithData:demo.f_data];
                UIImage *state_image = [self scaleFromImage:data_image toSize:CGSizeMake(data_image.size.width/4, data_image.size.height/4)];
                demo.topImage = state_image;
            }
            else
            {
                demo.topImage = [UIImage imageWithData:demo.f_data];
            }
            
            [upload_file setSpace_id:demo.space_id];
            [upload_file setF_id:demo.p_id];
            [upload_file setDemo:demo];
            [tableArray addObject:upload_file];
            [demo release];
            [upload_file release];
            i++;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}

//查询所有完成的纪录
-(NSMutableArray *)selectFinishTaskTable
{
    NSLog(@"tid:%i",t_id);
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectFinishTaskTable UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_int(statement, 1, t_id);
        int i=0;
        while (sqlite3_step(statement)==SQLITE_ROW) {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.t_id = sqlite3_column_int(statement, 0);
            demo.f_id = sqlite3_column_int(statement, 1);
            int bytes = sqlite3_column_bytes(statement, 2);
            const void *value = sqlite3_column_blob(statement, 2);
            if( value != NULL && bytes != 0 ){
                NSData *data = [NSData dataWithBytes:value length:bytes];
                demo.f_data = data;
            }
            demo.f_state = sqlite3_column_int(statement, 3);
            demo.f_base_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            demo.f_lenght = sqlite3_column_int(statement, 5);
            demo.deviceName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            demo.space_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            demo.p_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 8)];
            demo.is_automic_upload = sqlite3_column_int(statement, 9);
            demo.index_id = i;
            if([demo.f_data length]>1024*1024)
            {
                UIImage *data_image = [UIImage imageWithData:demo.f_data];
                UIImage *state_image = [self scaleFromImage:data_image toSize:CGSizeMake(data_image.size.width/4, data_image.size.height/4)];
                demo.topImage = state_image;
            }
            else
            {
                demo.topImage = [UIImage imageWithData:demo.f_data];
            }
            [tableArray addObject:demo];
            [demo release];
            i++;
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return tableArray;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark 查询任务表所有数据
-(NSArray *)selectAllTaskTableForFNAME
{
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableForFNAME UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(statement, 2, [f_data bytes], f_lenght, NULL);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.t_id = sqlite3_column_int(statement, 0);
            demo.f_id = sqlite3_column_int(statement, 1);
//            int bytes = sqlite3_column_bytes(statement, 2);
//            const void *value = sqlite3_column_blob(statement, 2);
//            if( value != NULL && bytes != 0 ){
//                NSData *data = [NSData dataWithBytes:value length:bytes];
//                demo.f_data = data;
//            }
            demo.f_state = sqlite3_column_int(statement, 3);
            demo.f_base_name = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 4)];
            demo.f_lenght = sqlite3_column_int(statement, 5);
            demo.deviceName = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 6)];
            demo.space_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 7)];
            demo.p_id = [NSString formatNSStringForChar:(const char *)sqlite3_column_text(statement, 8)];
            demo.is_automic_upload = sqlite3_column_int(statement, 9);
            [tableArray addObject:demo];
            [demo release];
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return [tableArray autorelease];
}

#pragma mark 查询任务表单个数据
#pragma mark 查询任务表单个数据
#pragma mark 查询任务表单个数据

#pragma mark 判断图片是否存在
-(BOOL)isPhotoExist
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableForFNAME UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            //            int bytes = sqlite3_column_bytes(statement, 2);
            //            const void *value = sqlite3_column_blob(statement, 2);
            //            if( value != NULL && bytes != 0 ){
            //                NSData *data = [NSData dataWithBytes:value length:bytes];
            //                if([f_data isEqualToData:data])
            //                {
            bl = TRUE;
            break;
            //                }
            //            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

#pragma mark 判断图片是否存在
-(BOOL)isExistOneImage
{
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    BOOL bl = FALSE;
    if (sqlite3_open(dbpath, &contactDB)==SQLITE_OK) {
        const char *insert_stmt = [SelectOneTaskTableOneceForFNAME UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [f_base_name UTF8String], -1, SQLITE_TRANSIENT);
        while (sqlite3_step(statement)==SQLITE_ROW) {
            //            int bytes = sqlite3_column_bytes(statement, 2);
            //            const void *value = sqlite3_column_blob(statement, 2);
            //            if( value != NULL && bytes != 0 ){
            //                NSData *data = [NSData dataWithBytes:value length:bytes];
            //                if([f_data isEqualToData:data])
            //                {
            bl = TRUE;
            break;
            //                }
            //            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    return bl;
}

-(void)dealloc
{
    NSLog(@"上传类死亡");
    if(f_base_name)
    {
        [f_base_name release];
    }
    if(f_data)
    {
        [f_data release];
    }
    if(result)
    {
        [result release];
    }
    if(deviceName)
    {
        [deviceName release];
    }
    [super dealloc];
}

@end

//
//  UploadFile.m
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#import "UploadFile.h"
//需要引用的类
#import <CommonCrypto/CommonDigest.h>

@implementation UploadFile
@synthesize demo;
@synthesize photoManger;
@synthesize uploderDemo;
@synthesize deviceName;
@synthesize delegate;
@synthesize finishName;

-(id)init
{
    self = [super init];
    if(self)
    {
        photoManger = [[SCBPhotoManager alloc] init];
        [photoManger setNewFoldDelegate:self];
        uploderDemo = [[SCBUploader alloc] init];
        [uploderDemo setUpLoadDelegate:self];
    }
    return self;
}

//上传暂停
-(void)upStop
{
    if(connection)
    {
        [connection cancel];
    }
}

//上传销毁
-(void)upClear
{
    if(connection)
    {
        [connection cancel];
    }
}

//上传开始
-(void)upload
{
    NSLog(@"1:打开文件目录");
    [photoManger openFinderWithID:@"1"];
    currTag = demo.f_id;
}

//请求认证
-(void)requestVerify
{
    if(demo.f_data == nil)
    {
        ALAsset *result = demo.result;
        NSError *error = nil;
        Byte *data = malloc(result.defaultRepresentation.size);
        //获得照片图像数据
        [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
        demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
    }
    NSLog(@"1:申请效验");
    uploadData = [[NSString alloc] initWithString:[self md5:demo.f_data]];
    [uploderDemo requestUploadVerify:f_id f_name:demo.f_base_name f_size:[NSString stringWithFormat:@"%i",[demo.f_data length]] f_md5:uploadData];
}

#pragma mark ----文件管理类的代理

-(void)newFold:(NSDictionary *)dictionary
{
    NSLog(@"newFold dictionary:%@",dictionary);
    BOOL bl = FALSE;
    if(f_pid > 0)
    {
        bl = TRUE;
    }
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        if(f_pid > 0)
        {
            f_id = [[dictionary objectForKey:@"f_id"] intValue];
            [self requestVerify];
        }
        else
        {
            f_pid = [[dictionary objectForKey:@"f_id"] intValue];
            [photoManger requestNewFold:deviceName FID:f_pid];
        }
    }
    else
    {
        if(bl && f_pid > 0)
        {
            [photoManger requestNewFold:deviceName FID:f_pid];
        }
        if(f_pid==0)
        {
            [photoManger requestNewFold:@"手机照片" FID:1];
        }
    }
}

-(void)openFile:(NSDictionary *)dictionary
{
    NSLog(@"打开成功 dictionary:%@ ",dictionary);
    BOOL bl = FALSE;
        if(f_pid>0)
        {
            bl = TRUE;
        }
        NSArray *array = [dictionary objectForKey:@"files"];
        for(int i=0;i<[array count];i++)
        {
            NSString *f_name = [[array objectAtIndex:i] objectForKey:@"f_name"];
            if([f_name isEqualToString:@"手机照片"])
            {
                f_pid = [[[array objectAtIndex:i] objectForKey:@"f_id"] intValue];
                [photoManger openFinderWithID:[NSString stringWithFormat:@"%i",f_pid]];
                break;
            }
            if([f_name isEqualToString:deviceName])
            {
                f_id = [[[array objectAtIndex:i] objectForKey:@"f_id"] intValue];
                [self requestVerify];
            }
        }
        if(f_pid==0)
        {
            [photoManger requestNewFold:@"手机照片" FID:1];
        }
        if(f_pid>0 && f_id==0 && bl)
        {
            [photoManger requestNewFold:deviceName FID:f_pid];
        }
}

-(void)didFailWithError
{
    
}

#pragma mark -----UpLoadDelegate
//上传效验
-(void)uploadVerify:(NSDictionary *)dictionary
{
    NSLog(@"upload:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0 )
    {
        [uploderDemo requestUploadState:demo.f_base_name];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 5 )
    {
        [uploadData release];
        demo.f_lenght = [demo.f_data length];
        [demo updateTaskTableFName];
        [delegate upFinish:currTag];
        [self dealloc];
    }
    else
    {
        [delegate upError:currTag];
        [self dealloc];
    }
    
}

//申请上传状态
-(void)requestUploadState:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        finishName = [dictionary objectForKey:@"sname"];
        if(demo.f_data == nil)
        {
            ALAsset *result = demo.result;
            NSError *error = nil;
            Byte *data = malloc(result.defaultRepresentation.size);
            //获得照片图像数据
            [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
            demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
        }
        NSLog(@"demo.f_data:%i",[demo.f_data length]);
        if([demo.f_data length]==0)
        {
            NSLog(@"验证失败");
            [delegate upError:currTag];
        }
        else
        {
            NSLog(@"3:开始上传：%@",finishName);
            connection = [uploderDemo requestUploadFile:[NSString stringWithFormat:@"%i",f_pid] f_name:demo.f_base_name s_name:finishName skip:[NSString stringWithFormat:@"%i",[demo f_lenght]] f_md5:[self md5:demo.f_data] Image:demo.f_data];
        }
    }
}

//上传文件完成
-(void)uploadFinish:(NSDictionary *)dictionary
{
    NSLog(@"uploadFinishdictionary:%@",dictionary);
    if(connection)
    {
        [connection cancel];
        connection = nil;
    }
        
    NSLog(@"uploadFinishdictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        [delegate upProess:1 fileTag:currTag];
        NSLog(@"4:提交上传表单:%@",finishName);
        [uploderDemo requestUploadCommit:[NSString stringWithFormat:@"%i",f_id] f_name:demo.f_base_name s_name:finishName device:@"" skip:@"" f_md5:uploadData img_createtime:@""];
    }
    else
    {
        NSLog(@"上传失败");
        [delegate upError:currTag];
    }
}

//查看上传记录
-(void)lookDescript:(NSDictionary *)dictionary
{

}

//上传文件流
-(void)uploadFiles:(int)proress
{
    float f = (float)proress / (float)[demo.f_data length];
    [demo setProess:f];
    [delegate upProess:f fileTag:currTag];
}

//上传提交
-(void)uploadCommit:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSLog(@"5:完成");
        
    if([[dictionary objectForKey:@"code"] intValue] == 0 || [[dictionary objectForKey:@"code"] intValue] == 5)
    {
        NSInteger fid = [[dictionary objectForKey:@"fid"] intValue];
        demo.f_id = fid;
        demo.f_state = 1;
        demo.f_lenght = [demo.f_data length];
        NSLog(@"Url-------:%@",demo.databasePath);
        [demo updateTaskTableFName];
        [delegate upFinish:currTag];
        [uploadData release];
    }
    [self dealloc];
}


#pragma mark  -----------常用方法

-(NSString *)md5:(NSData *)concat {
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    NSData* filedata = concat;
    CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

-(void)dealloc
{
    [photoManger release];
    [uploderDemo release];
    [finishName release];
    [super dealloc];
}

@end

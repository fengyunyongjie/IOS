//
//  PhohoDemo.h
//  NetDisk
//
//  Created by Yangsl on 13-5-3.
//
//

#import <Foundation/Foundation.h>

@interface PhohoDemo : NSObject
{
    //详细信息表
    NSString *f_mime;
    NSInteger f_size;
    NSString *f_name;
    NSInteger f_pid;
    NSString *img_create;
    NSString *f_create;
    NSInteger f_id;
    NSString *f_modify;
    NSString *compressaddr;
    NSInteger f_ownerid;
    NSString *date;
    NSInteger total;
    NSString *date_type; //时间轴的key
    NSString *user_name; //用户名
    NSString *f_owername;
    NSString *f_pids;
    //时间轴表
    NSString *user_id; //用户id
    NSString *key_string; //时间轴的key
    NSString *oderByString; //排序字符串
    BOOL isSelected;
    BOOL isShowImage;
    NSString *timeLine;
}
@property(nonatomic,retain) NSString *f_mime;
@property(nonatomic,assign) NSInteger f_size;
@property(nonatomic,retain) NSString *f_name;
@property(nonatomic,assign) NSInteger f_pid;
@property(nonatomic,retain) NSString *img_create;
@property(nonatomic,retain) NSString *f_create;
@property(nonatomic,assign) NSInteger f_id;
@property(nonatomic,retain) NSString *f_modify;
@property(nonatomic,retain) NSString *compressaddr;
@property(nonatomic,assign) NSInteger f_ownerid;
@property(nonatomic,retain) NSString *date;
@property(nonatomic,assign) NSInteger total;
@property(nonatomic,retain) NSString *date_type;
@property(nonatomic,retain) NSString *user_name;
@property(nonatomic,retain) NSString *f_owername;
@property(nonatomic,retain) NSString *f_pids;
@property(nonatomic,retain) NSString *user_id;
@property(nonatomic,retain) NSString *key_string;
@property(nonatomic,retain) NSString *oderByString;
@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,assign) BOOL isShowImage;
@property(nonatomic,retain) NSString *timeLine;

@end

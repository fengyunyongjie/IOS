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

@end

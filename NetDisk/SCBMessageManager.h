//
//  SCBMessageManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>

@protocol SCBMessageManagerDelegate <NSObject>

-(void)getSelectMessges:(NSDictionary *)dictioinary;

-(void)finishMessage:(NSDictionary *)dictioinary;

-(void)error;

@end

@interface SCBMessageManager : NSObject
{
    NSString *url_string;
    NSMutableData *matableData;
    id<SCBMessageManagerDelegate> delegate;
}

@property(nonatomic,retain) NSMutableData *matableData;
@property(nonatomic,retain) id<SCBMessageManagerDelegate> delegate;

//获取短消息列表/msgs
-(void)selectMessages:(int)msg_type cursor:(int)cursor offset:(int)offset unread:(int)unread;

//发送短消息/msg/send
-(void)sendMessage:(int)friend_id msg_content:(NSString *)msg_content;

//删除短消息/msg/del
-(void)deleteMessage:(NSArray *)array;

//删除所有短消息/msg/delall
-(void)deleteAllMessage:(int)msg_type;

@end

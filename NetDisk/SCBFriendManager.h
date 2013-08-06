//
//  SCBFriendManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>

@protocol SCBFriendManagerDelegate <NSObject>

//获取群组列表
-(void)getFriendshipsGroups:(NSDictionary *)dictionary;

//获取所有群组及好友列表/friendships/groups/deep
-(void)getFriendshipsGroupsDeep:(NSDictionary *)dictionary;

//创建群组/friendships/group/create
-(void)getFriendshipsGroupsCreate:(NSDictionary *)dictionary;

//修改群组/friendships/group/update
-(void)getFriendshipsGroupsUpdate:(NSDictionary *)dictionary;

//删除群组/friendships/group/del
-(void)getFriendshipsGroupDel:(NSDictionary *)dictionary;

//获取好友列表/friendships/friends
-(void)getFriendshipsFriends:(NSDictionary *)dictionary;

//添加好友/friendships/friend/create
-(void)getFriendshipsFriendsCreate:(NSDictionary *)dictionary;

//移动好友/friendships/friend/move
-(void)getFriendshipsFriendMove:(NSDictionary *)dictionary;

//修改好友备注/friendships/friend/remark/update
-(void)getFriendshipsFriendRemarkUpdate:(NSDictionary *)dictionary;

//删除好友/friendships/friend/del
-(void)getFriendshipsFriendDel:(NSDictionary *)dictionary;

-(void)error;

@end

@interface SCBFriendManager : NSObject
{
    NSString *url_string;
    NSMutableData *matableData;
    id<SCBFriendManagerDelegate> delegate;
}

@property(nonatomic,retain) NSMutableData *matableData;
@property(nonatomic,retain) id<SCBFriendManagerDelegate> delegate;

//获取群组列表
-(void)getFriendshipsGroups:(int)cursor offset:(int)offset;

//获取所有群组及好友列表/friendships/groups/deep
-(void)getFriendshipsGroupsDeep;

//创建群组/friendships/group/create
-(void)getFriendshipsGroupsCreate:(NSString *)group_name;

//修改群组/friendships/group/update
-(void)getFriendshipsGroupsUpdate:(int)group_id group_name:(NSString *)group_name;

//删除群组/friendships/group/del
-(void)getFriendshipsGroupDel:(int)isdeep group_id:(int)group_id;

//获取好友列表/friendships/friends
-(void)getFriendshipsFriends:(int)group_id cursor:(int)cursor offset:(int)offset;

//添加好友/friendships/friend/create
-(void)getFriendshipsFriendsCreate:(NSString *)friend_name group_id:(int)group_id friend_remark:(NSString *)friend_remark;

//移动好友/friendships/friend/move
-(void)getFriendshipsFriendMove:(int)group_id friend_id:(int)friend_id;

//修改好友备注/friendships/friend/remark/update
-(void)getFriendshipsFriendRemarkUpdate:(NSString *)friend_remark friend_id:(int)friend_id;

//删除好友/friendships/friend/del
-(void)getFriendshipsFriendDel:(int)friend_id;


@end

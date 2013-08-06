//
//  SCBFriendManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>

@interface SCBFriendManager : NSObject
{
    NSString *url_string;
    NSMutableData *matableData;
}

@property(nonatomic,retain) NSMutableData *matableData;

//获取群组列表
-(void)getFriendshipsGroups:(int)cursor offset:(int)offset;

//获取所有群组及好友列表/friendships/groups/deep
//创建群组/friendships/group/create
//修改群组/friendships/group/update
//删除群组/friendships/group/del
//获取好友列表/friendships/friends
//添加好友/friendships/friend/create
//移动好友/friendships/friend/move
//修改好友备注/friendships/friend/remark/update
//删除好友/friendships/friend/del



@end

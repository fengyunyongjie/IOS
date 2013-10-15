//
//  SqlliteManager.m
//  NetDisk
//
//  Created by Yangsl on 13-10-9.
//
//

#import "SqlliteManager.h"
#import "UserInfo.h"
#import "UpLoadList.h"

@implementation SqlliteManager
@synthesize demo;
@synthesize sqlIndex;

-(void)main
{
    if([demo isKindOfClass:[UserInfo class]])
    {
        UserInfo *info = (UserInfo *)demo;
        switch (sqlIndex) {
            case 1:
                [info insertUserinfo];
                break;
            case 2:
                [info updateUserinfo];
                break;
            default:
                break;
        }
    }
    else if([demo isKindOfClass:[UpLoadList class]])
    {
        UpLoadList *info = (UpLoadList *)demo;
        switch (sqlIndex) {
            case 1:
                [info insertUploadList];
                break;
            case 2:
                [info deleteUploadList];
                break;
            case 3:
                [info deleteAutoUploadListAllAndNotUpload];
                break;
            case 4:
                [info deleteMoveUploadListAllAndNotUpload];
                break;
            default:
                break;
        }
    }
}

@end

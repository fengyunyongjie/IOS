//
//  operation.h
//  NetDisk
//
//  Created by Yangsl on 13-6-9.
//
//

#import <Foundation/Foundation.h>
#import "PhotoViewController.h"
#import "DownImage.h"

@interface operation : NSOperation
{
    NSMutableArray *imageArray;
    NSMutableArray *cellArray;
}

@property(nonatomic,retain) NSMutableArray *imageArray;
@property(nonatomic,retain) NSMutableArray *cellArray;

-(void)cellArray:(NSMutableArray *)cellAr imagev:(NSMutableArray *)imageV;

@end

//
//  FMDBManager.m
//  testForCocopod
//
//  Created by lgh on 16/10/30.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import "FMDBManager.h"
#import <FMDB.h>

#define kLibraryPath [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"fmdb.sqlite"]

@implementation DeviceModel


@end


@interface FMDBManager ()

/** fmdb*/
@property (nonatomic, strong) FMDatabaseQueue *fmdb;


@end

static FMDBManager *manager = nil;

@implementation FMDBManager

+ (FMDBManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[FMDBManager alloc] init];
        }
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (manager == nil) {
        manager = [super allocWithZone:zone];
        
        [manager initMananger];
        
    }
    return manager;
}
// 初始化表
- (void)initMananger{
    
    NSLog(@"%@", kLibraryPath);
    
    self.fmdb = [FMDatabaseQueue databaseQueueWithPath:kLibraryPath];
    
    [self.fmdb inDatabase:^(FMDatabase *db) {
        
        BOOL ret = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SERVER (myId text PRIMARY KEY NOT NULL,port integer)"];
        if (ret) {
            NSLog(@"创建表成功");
        } else {
            NSLog(@"创建表失败");
        }
    }];
    
}

- (void)insertModel:(DeviceModel *)model
{
    [self.fmdb inDatabase:^(FMDatabase *db) {
       
        BOOL ret = [db executeUpdate:@"INSERT INTO SERVER (myId,port) VALUES (?,?)", model.ip, @(model.port)];
        if (ret == NO) {
            NSLog(@"添加数据失败");
        }
    }];
}

- (void)deleteAllData
{
    [self.fmdb inDatabase:^(FMDatabase *db) {
        
        BOOL ret = [db executeUpdate:@"delete from SERVER"];
        if (ret == NO) {
            NSLog(@"删除数据失败");
        }
    }];
}

- (DeviceModel *)selectModel
{
    DeviceModel *dm = [[DeviceModel alloc] init];
    [self.fmdb inDatabase:^(FMDatabase *db) {
       
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SERVER"];
        
        while ([result next]) {
            
            dm.ip = [result stringForColumn:@"myId"];
            dm.port = [result intForColumn:@"port"];
        }
    }];
    return dm;
}


@end
















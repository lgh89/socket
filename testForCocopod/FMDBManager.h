//
//  FMDBManager.h
//  testForCocopod
//
//  Created by lgh on 16/10/30.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

/** ip*/
@property (nonatomic, copy) NSString *ip;
/** port*/
@property (nonatomic, assign) NSInteger port;

@end

@interface FMDBManager : NSObject

+ (FMDBManager *)shareManager;

// 增
- (void)insertModel:(DeviceModel *)model;
// 删
- (void)deleteAllData;

// 查
- (DeviceModel *)selectModel;

// 改
- (void)replaceDataWithModel:(DeviceModel *)model;

@end

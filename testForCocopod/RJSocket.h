//
//  RJSocket.h
//  testForCocopod
//
//  Created by RJ_engel on 16/10/28.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJSocket : NSObject

+ (instancetype)defaultScoket;
/**
 * 初始化socket
 */
- (void)initSocket;

- (void)sendDict:(NSDictionary *)dict;

- (void)test;

@end

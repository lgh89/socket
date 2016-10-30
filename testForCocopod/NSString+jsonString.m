//
//  NSString+jsonString.m
//  testForCocopod
//
//  Created by RJ_engel on 16/10/28.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import "NSString+jsonString.h"

@implementation NSString (jsonString)

- (NSDictionary *)dictionaryFromJsonString
{
    if (self == nil) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"json解析错误:%@, %@", self, error);
        return nil;
    }
    return dict;
}

@end

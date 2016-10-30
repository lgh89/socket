//
//  NSDictionary+jsonData.m
//  testForCocopod
//
//  Created by RJ_engel on 16/10/28.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import "NSDictionary+jsonData.h"

@implementation NSDictionary (jsonData)

- (NSData *)posJsonData{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    json = [NSString stringWithFormat:@"\t\nLength:%d\r\n%@\r\n", (int)[json lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 2, json];
    NSLog(@"发送%@", json);
    return [json dataUsingEncoding:NSUTF8StringEncoding];
}

@end

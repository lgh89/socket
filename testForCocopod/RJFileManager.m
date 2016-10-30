//
//  RJFileManager.m
//  testForCocopod
//
//  Created by lgh on 16/10/30.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import "RJFileManager.h"

@implementation RJFileManager

+ (float)testForSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    float size =0;
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    NSLog(@"%@", array);
    
    NSLog(@"%f", [[fileManager attributesOfFileSystemForPath:path error:nil][NSFileSystemSize] floatValue] / 1024 / 1024 / 1024);
    
    
    return size;
}

@end

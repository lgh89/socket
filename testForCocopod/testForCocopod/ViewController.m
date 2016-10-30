//
//  ViewController.m
//  testForCocopod
//
//  Created by RJ_engel on 16/10/28.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "RJSocket.h"
#import "RJFileManager.h"
#import "FMDBManager.h"

@interface ViewController ()
/** RJs*/
@property (nonatomic, strong) RJSocket *Rj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.Rj = [RJSocket defaultScoket];
    
    [self.Rj initSocket];
}

@end

//
//  CacheModel.m
//  MemCacheDemo
//
//  Created by 李浩 on 2017/11/18.
//  Copyright © 2017年 com.GodL.github. All rights reserved.
//

#import "CacheModel.h"

@implementation CacheModel

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    NSLog(@" %d  %@",[[NSThread currentThread] isMainThread],self.name);
}

@end

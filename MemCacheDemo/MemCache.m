//
//  MemCache.m
//  MemCacheDemo
//
//  Created by imac on 2017/9/30.
//  Copyright © 2017年 com.GodL.github. All rights reserved.
//

#import "MemCache.h"
#import <FHLinkedList/fh_linked.h>
#import <UIKit/UIKit.h>

typedef struct Cache_item {
    void *key;
    void *value;
    NSUInteger cost;
} Cache_item;

@implementation MemCache {
    @private
    dispatch_queue_t _release_queue;
    linkList *_cache_list;
    CFMutableDictionaryRef _cache_hash;
}

- (void)_applicationDidReceiveMemoryWarning {
    
}

- (void)_applicationDidEnteringBackground {
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _release_queue = dispatch_queue_create("com.GodL.memcache", DISPATCH_QUEUE_SERIAL);
        _cache_list = linkListify(NULL);
        _cache_hash = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnteringBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

@end

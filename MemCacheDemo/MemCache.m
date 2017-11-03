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

#define NodeGetCacheItem(node) ((Cache_item *)((node)->value))

#define NodeGetCacheValue(node) (NodeGetCacheItem(node)->value)

#define NodeGetCacheCost(node) (NodeGetCacheItem(node)->cost)

typedef struct Cache_item {
    void *key;
    void *value;
    NSUInteger cost;
} Cache_item;

@implementation MemCache {
    @private
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    dispatch_queue_t _release_queue;
    dispatch_queue_t _trim_queue;
    dispatch_semaphore_t _lock;
    linkList *_cache_list;
    CFMutableDictionaryRef _cache_hash;
}

#pragma mark- private
- (id)_removeNode:(linkNode *)node {
    if (node->prev) node->prev->next = node->next;
    if (node->next) node->next->prev = node->prev;
    if (_cache_list->head == node) _cache_list->head = node->next;
    if (_cache_list->tail == node) _cache_list->tail =node->prev;
    _totalCost -= NodeGetCacheCost(node);
    id value = (__bridge id)NodeGetCacheValue(node);
    free(node);
    return value;
}

- (void)_applicationDidReceiveMemoryWarning {
    
}

- (void)_applicationDidEnteringBackground {
    
}


#pragma mark- public

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_attr_t release_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_BACKGROUND, 0);
        _release_queue = dispatch_queue_create("com.Release.MemCache", release_attr);
        dispatch_queue_attr_t trim_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0);
        _trim_queue = dispatch_queue_create("com.Trim.MemCache", trim_attr);
        _lock = dispatch_semaphore_create(1);
        _cache_list = linkListify(NULL);
        _cache_hash = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnteringBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (NSUInteger)totalCost {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSUInteger cost = _totalCost;
    dispatch_semaphore_signal(_lock);
    return cost;
}

- (NSUInteger)totalCount {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSUInteger count = _totalCount;
    dispatch_semaphore_signal(_lock);
    return count;
}

- (BOOL)containsObjectForKey:(id)key {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    BOOL contain = CFDictionaryContainsKey(_cache_hash, (__bridge const void *)(key));
    dispatch_semaphore_signal(_lock);
    return contain;
}

-(void)setObject:(id)obj forKey:(id)key {
    [self setObject:obj forKey:key cost:0];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost {
    if (!obj) {
        [self removeObjectWithKey:key];
        return;
    }
    
}

- (id)objectForKey:(id)key {
    return nil;
}

- (void)removeObjectWithKey:(id)key {
    if (!key) return;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    linkNode *node = (linkNode *)CFDictionaryGetValue(_cache_hash, (__bridge const void *)(key));
    if (node) {
        CFDictionaryRemoveValue(_cache_hash, (__bridge const void *)(key));
        id value = [self _removeNode:node];
        dispatch_async(_release_queue, ^{
            [value class];
        });
    }
    dispatch_semaphore_signal(_lock);
}

@end

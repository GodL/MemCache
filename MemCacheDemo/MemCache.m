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

#define NodeGetCacheKey(node) (NodeGetCacheItem(node)->key)

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
static inline Cache_item *CacheItemify(const void *key,const void *value, NSUInteger cost) {
    Cache_item *item = malloc(sizeof(Cache_item));
    item->key = (void *)key;
    item->value = (void *)value;
    item->cost = cost;
    return item;
}

static inline void CacheNodeRelease(void *ptr) {
    Cache_item *item = ptr;
    id value = (__bridge_transfer id)(item->value);
    value = nil;
    free(item);
    item = NULL;
}

static inline void CacheBringNodeToHeader(linkList *list,linkNode *node) {
    if (list->head == node) return;
    if (node->prev) node->prev->next = node->next;
    if (node->next) node->next->prev = node->prev;
    if (list->tail == node) list->tail = node->prev;
    list->head->prev = node;
    node->prev = NULL;
    node->next = list->head;
    list->head = node;
}

- (void)_removeNode:(linkNode *)node {
    CFDictionaryRemoveValue(_cache_hash, NodeGetCacheKey(node));
    if (node->prev) node->prev->next = node->next;
    if (node->next) node->next->prev = node->prev;
    if (_cache_list->head == node) _cache_list->head = node->next;
    if (_cache_list->tail == node) _cache_list->tail = node->prev;
    _totalCost -= NodeGetCacheCost(node);
    _totalCount -- ;
    _cache_list->len -- ;
    dispatch_async(_release_queue, ^{
        _cache_list->node_release(node->value);
        free(node);
    });
}

- (void)_removeTailNode {
    if (_totalCount == 0) return ;
    linkNode *node = _cache_list->tail;
    [self _removeNode:node];
}

- (void)_removeAllNode {
    CFDictionaryRef hash = _cache_hash;
    _cache_hash = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    linkList *set = _cache_list;
    struct linkListNodeCallback callback = {
        CacheNodeRelease,
        NULL
    };
    _cache_list = linkListify(&callback);
    _totalCount = 0;
    _totalCost = 0;
    dispatch_async(_release_queue, ^{
        CFRelease(hash);
        linkListRelease(set);
    });
}

- (void)_trimToCost:(NSUInteger)cost {

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
        struct linkListNodeCallback callback = {
            CacheNodeRelease,
            NULL
        };
        _cache_list = linkListify(&callback);
        _cache_hash = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, NULL);
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
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    linkNode *node = (linkNode *)CFDictionaryGetValue(_cache_hash, (__bridge const void *)(key));
    if (node) {
        Cache_item *item = NodeGetCacheItem(node);
        _totalCost -= NodeGetCacheItem(node)->cost;
        _totalCount += cost;
        item->cost = cost;
        item->value = (__bridge_retained void *)(obj);
        CacheBringNodeToHeader(_cache_list, node);
    }else {
        Cache_item *item = CacheItemify((__bridge const void *)(key), (__bridge_retained void *)(obj), cost);
        linkListAddHead(_cache_list, item);
        CFDictionarySetValue(_cache_hash, (__bridge const void *)(key), _cache_list->head);
        _totalCount ++;
        if (_totalCount > self.countLimit) {
            [self _removeTailNode];
        }
    }
    if (_totalCount > 1 &&_totalCost > _costLimit) {
        [self _removeTailNode];;
    }
    dispatch_semaphore_signal(_lock);
}

- (id)objectForKey:(id)key {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id value = nil;
    linkNode *node = (linkNode *)CFDictionaryGetValue(_cache_hash, (__bridge const void *)(key));
    if (node) {
        value = (__bridge_transfer id)(NodeGetCacheValue(node));
        CacheBringNodeToHeader(_cache_list, node);
    }
    dispatch_semaphore_signal(_lock);
    return value;
}

- (void)removeObjectWithKey:(id)key {
    if (!key) return;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    linkNode *node = (linkNode *)CFDictionaryGetValue(_cache_hash, (__bridge const void *)(key));
    if (node) {
        [self _removeNode:node];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)removeAllObjects {
    [self _removeAllNode];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    CFRelease(_cache_hash);
    linkList *list = _cache_list;
    _cache_list = NULL;
    dispatch_async(_release_queue, ^{
        linkListRelease(list);
    });
}

@end

//
//  MemCache.m
//  MemCacheDemo
//
//  Created by imac on 2017/9/30.
//  Copyright © 2017年 com.GodL.github. All rights reserved.
//

#import "MemCache.h"
#import <FHLinkedList/fh_linked.h>

typedef struct Cache_item {
    void *key;
    void *value;
    NSUInteger cost;
} Cache_item;

@implementation MemCache {
    @private
    linkList *cache_list;
    CFMutableDictionaryRef *
}



@end

//
//  fh_linked.h
//  LinkedListDemo
//
//  Created by imac on 2017/9/27.
//  Copyright © 2017年 com.GodL.github. All rights reserved.
//

#ifndef fh_linked_h
#define fh_linked_h

#include <stdio.h>
#include <stdbool.h>

typedef enum iterDirection {
    iterDirectionHead,
    iterDirectionTail
} iterDirection;

typedef struct linkListNodeCallback {
    void(*node_release)(void *ptr);
    int(*node_match)(void *pth,void *key);
} linkListNodeCallback;

typedef struct linkNode {
    struct linkNode *next;
    struct linkNode *prev;
    void *value;
} linkNode;

typedef struct linkIter {
    linkNode *next;
    iterDirection direction;
} linkIter;

typedef struct linkList {
    linkNode *head;
    linkNode *tail;
    void(*node_release)(void *ptr);
    int(*node_match)(void *pth,void *key);
    unsigned long len;
} linkList;

#pragma mark- linkNode

linkNode *linkNodeify(void *value);

void linkNodeRelease(linkNode *node);

#pragma mark- linkIter

linkIter *linkIterify(linkList *list,iterDirection dicection);

linkNode *linkIterNext(linkIter *iter);

#pragma mark- linkList

linkList *linkListify(linkListNodeCallback* callback);

linkList *linkListAddHead(linkList *list,void *value);

linkList *linkListAddTail(linkList *list,void *value);

linkNode *linkListQueryNode(linkList *list,unsigned long index);

void *linkListQueryValue(linkList *list,unsigned long index);

linkList *linkListInsert(linkList *list,void *value,unsigned long index);

linkList *linkListDelWithIndex(linkList *list,unsigned long index);

linkList *linkListDelWithValue(linkList *list,void *value);

linkList *linkListDelTTail(linkList *list);

linkList *linkListEmpty(linkList *list);

linkList *linkListHeadToTail(linkList *list);

linkList *linkListTailToHead(linkList *list);

void linkListRelease(linkList *list);

#endif /* fh_linked_h */

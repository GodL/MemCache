//
//  fh_linked.c
//  LinkedListDemo
//
//  Created by imac on 2017/9/27.
//  Copyright © 2017年 com.GodL.github. All rights reserved.
//

#include "fh_linked.h"
#include <stdlib.h>

linkNode *linkNodeify(void *value) {
    linkNode *node;
    if ((node = malloc(sizeof(*node))) == NULL) return NULL;
    node->value = value;
    node->next = node->prev = NULL;
    return node;
}

void linkNodeRelease(linkNode *node) {
    if (node == NULL) return;
    free(node);
    node = NULL;
}

linkIter *linkIterify(linkList *list,iterDirection dicection) {
    if (list == NULL) return NULL;
    linkIter *iter;
    if ((iter = malloc(sizeof(*iter))) == NULL) return NULL;
    iter->direction = dicection;
    iter->next = dicection == iterDirectionHead?list->head:list->tail;
    return iter;
}

linkNode *linkIterNext(linkIter *iter) {
    linkNode *current = iter->next;
    if (current == NULL) return NULL;
    if (iter->direction == iterDirectionHead)
        iter->next = current->next;
    else
        iter->next = current->prev;
    
    return current;
}

linkList *linkListify(linkListNodeCallback* callback) {
    linkList *list;
    if ((list = malloc(sizeof(*list))) == NULL) return NULL;
    list->head = list->tail = NULL;
    list->len = 0;
    if (callback) {
        list->node_release = (*callback).node_release;
        list->node_match = (*callback).node_match;
    }
    return list;
}

linkList *linkListAddHead(linkList *list,void *value) {
    if (list == NULL || value == NULL) return list;
    linkNode *new;
    if ((new = linkNodeify(value)) == NULL) return list;
    if (list->len == 0)
        list->head = list->tail = new;
    else {
        new->next = list->head;
        list->head->prev = new;
        list->head = new;
    }
    list->len++;
    return list;
}

linkList *linkListAddTail(linkList *list,void *value) {
    if (list == NULL || value == NULL) return list;
    linkNode *new;
    if ((new = linkNodeify(value)) == NULL) return list;
    if (list->len == 0)
        list->head = list->tail = new;
    else {
        new->prev = list->tail;
        list->tail->next = new;
        list->tail = new;
    }
    list->len++;
    return list;
}

linkNode *linkListQueryNode(linkList *list,unsigned long index) {
    if (list == NULL || index >= list->len) return NULL;
    linkNode *result = NULL;
    if (index < list->len/2) {
        result = list->head;
        while (index -- && result) result = result->next;
    }else {
        result = list->tail;
        while (index -- && result) result = result->prev;
    }
    return result;
}

void *linkListQueryValue(linkList *list,unsigned long index) {
    linkNode *result = linkListQueryNode(list, index);
    return result?result->value:NULL;
}

linkList *linkListInsert(linkList *list,void *value,unsigned long index) {
    if (list == NULL || value == NULL) return list;
    if (index >= list->len) index = list->len - 1;
    if (index == 0 && linkListAddHead(list, value)) return list;
    linkNode *new;
    if ((new = linkNodeify(value)) == NULL) return list;
    linkNode *indexNode = linkListQueryNode(list, index);
    new->next = indexNode;
    new->prev = indexNode->prev;
    indexNode->prev->next = new;
    indexNode->prev = new;
    list->len ++ ;
    return list;
}

linkList *linkListDelWithIndex(linkList *list,unsigned long index) {
    linkNode *indexNode = linkListQueryNode(list, index);
    if (indexNode == NULL) return list;
    if (index == 0) {
        list->head = indexNode->next;
        list->head->prev = NULL;
    } else if (index == list->len-1) {
        list->tail = indexNode->prev;
        list->tail->next = NULL;
    } else {
        indexNode->prev->next = indexNode->next;
        indexNode->next->prev = indexNode->prev;
    }
    if (list->node_release) list->node_release(indexNode->value);
    linkNodeRelease(indexNode);
    list->len--;
    return list;
}

linkList *linkListDelWithValue(linkList *list,void *value) {
    if (list == NULL || value == NULL) return list;
    linkNode *head = list->head;
    linkNode *result = NULL;
    while (head) {
        if (list->node_match && list->node_match(head->value,value)) {
            result = head;
        }else if (!(list->node_match)&&head->value == value) {
            result = head;
        }else
            head = head->next;
    }
    if (result == NULL) return list;
    if (result == list->head) {
        list->head = result->next;
        list->head->prev = NULL;
    } else if (result == list->tail) {
        list->tail = result->prev;
        list->tail->next = NULL;
    } else {
        result->prev->next = result->next;
        result->next->prev = result->prev;
    }
    if (list->node_release) list->node_release(result->value);
    linkNodeRelease(result);
    list->len--;
    return list;
}

linkList *linkListDelTTail(linkList *list) {
    if (list == NULL) return NULL;
    return linkListDelWithIndex(list, list->len-1);
}

linkList *linkListEmpty(linkList *list) {
    if (list == NULL) return NULL;
    unsigned long len = list->len;
    linkNode *current = list->head;
    linkNode *next = NULL;
    while (len --) {
        next = current->next;
        if (list->node_release) list->node_release(current->value);
        linkNodeRelease(current);
        current = next;
    }
    list->head = list->tail = NULL;
    list->len = 0;
    return list;
}

linkList *linkListHeadToTail(linkList *list) {
    if (list == NULL || list->len <= 1) return list;
    linkNode *head = list->head;
    list->head = head->next;
    list->head->prev = NULL;
    list->tail->next = head;
    head->prev = list->tail;
    list->tail = head;
    head->next = NULL;
    return list;
}

linkList *linkListTailToHead(linkList *list) {
    if (list == NULL || list->len <= 1) return list;
    linkNode *tail = list->tail;
    tail->prev->next = NULL;
    list->tail = tail->prev;
    list->head->prev = tail;
    tail->next = list->head;
    list->head = tail;
    return list;
}

void linkListRelease(linkList *list) {
    if (linkListEmpty(list) == NULL) return;
    free(list);
    list = NULL;
}

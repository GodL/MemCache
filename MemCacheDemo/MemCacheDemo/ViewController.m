//
//  ViewController.m
//  MemCacheDemo
//
//  Created by imac on 2017/9/27.
//  Copyright © 2017年 com.GodL.github. All rights reserved.
//

#import "ViewController.h"
#import "MemCache.h"
#import <YYCache/YYMemoryCache.h>
#import "CacheModel.h"

@interface ViewController ()

@end

@implementation ViewController {
    MemCache *_mine;
    YYMemoryCache *_yycache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mine = [MemCache new];
    _mine.countLimit = 20;
    _yycache = [YYMemoryCache new];
    _yycache.countLimit = 20;
    NSMutableArray *keys = [NSMutableArray new];
    NSMutableArray *values1 = [NSMutableArray array];
    NSMutableArray *values2 = [NSMutableArray array];
    int count = 100;
    for (int i = 0; i < count; i++) {
        NSObject *key;
        key = @(i); // avoid string compare
        //key = @(i).description; // it will slow down NSCache...
        //key = [NSUUID UUID].UUIDString;
        [keys addObject:key];
        CacheModel *model1 = [CacheModel new];
        CacheModel *model2 = [CacheModel new];
        model2.name = @"yycache";
        model1.name = @"mine";
        [values1 addObject:model1];
        [values2 addObject:model2];
    }
    
    NSTimeInterval begin, end, time;
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i=0; i<count; i++) {
            [_mine setObject:values1[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("mine:   %8.2f\n", time * 1000);
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i=0; i<count; i++) {
            [_yycache setObject:values2[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("yycache:    %8.2f\n", time * 1000);
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.backgroundColor = [UIColor redColor];
    button1.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:button1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(200, 300, 100, 100);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button1 addTarget:self action:@selector(buttonAction1:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buttonAction:(UIButton *)b{
    _yycache = nil;
}

- (void)buttonAction1:(UIButton*)b {
    _mine = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

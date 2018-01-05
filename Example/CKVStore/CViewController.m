//
//  CViewController.m
//  CKVStore
//
//  Created by nbyh100@sina.com on 01/05/2018.
//  Copyright (c) 2018 nbyh100@sina.com. All rights reserved.
//

#import "CViewController.h"
#import <CKVStore/CKVStore.h>

@interface CViewController ()

@end

@implementation CViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[CKVStore sharedStore] setObject:@"VALUE" forKey:@"foobar"];
    [[CKVStore sharedStore] asyncObjectForKey:@"foobar" complete:^(id<NSCoding> result) {
        NSLog(@"%@", result);
    }];
}

@end

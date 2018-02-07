//
//  CKVStoreTests.m
//  CKVStoreTests
//
//  Created by nbyh100@sina.com on 01/05/2018.
//  Copyright (c) 2018 nbyh100@sina.com. All rights reserved.
//

#import <CKVStore/CKVStore.h>

@interface CKVStore (Test)

+ (void)unsetStore;
+ (void)unsetStoreWithName:(NSString *)name;

@end

@interface MyObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString *one;
@property (nonatomic, strong) NSString *two;

@end

@implementation MyObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.one = [aDecoder decodeObjectForKey:@"one"];
        self.two = [aDecoder decodeObjectForKey:@"two"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.one forKey:@"one"];
    [aCoder encodeObject:self.two forKey:@"two"];
}

@end

@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];

    [[CKVStore store] clear];
}

- (void)testUnsetStore {
    CKVStore *store = [CKVStore store];
    [CKVStore unsetStore];
    XCTAssertTrue(store != [CKVStore store]);
}

- (void)testUnsetStoreWithName {
    CKVStore *store = [CKVStore storeWithName:@"mystore"];
    [CKVStore unsetStoreWithName:@"mystore"];
    XCTAssertTrue(store != [CKVStore storeWithName:@"mystore"]);
}

- (void)testDifferentStore {
    [[CKVStore storeWithName:@"store1"] setObject:@YES forKey:@"store1"];
    XCTAssertNil([[CKVStore store] objectForKey:@"store1"]);
    XCTAssertNotNil([[CKVStore storeWithName:@"store1"] objectForKey:@"store1"]);
}

- (void)testSetString {
    NSString *k = @"str";
    NSString *v = @"bar";
    [[CKVStore store] setObject:v forKey:k];
    [CKVStore unsetStore];

    NSString *foo = (NSString *)[[CKVStore store] objectForKey:k];
    XCTAssertTrue([foo isEqualToString:v]);
}

- (void)testSetDictionary {
    NSString *k = @"dic";
    NSDictionary *v = @{@"k":@"v"};
    [[CKVStore store] setObject:v forKey:k];
    [CKVStore unsetStore];

    NSDictionary *dic = (NSDictionary *)[[CKVStore store] objectForKey:k];
    XCTAssertTrue([dic isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue([dic[@"k"] isEqualToString:@"v"]);
}

- (void)testSetObject {
    NSString *k = @"obj";
    MyObject *obj = [MyObject new];
    obj.one = @"1";
    obj.two = @"2";
    [[CKVStore store] setObject:obj forKey:k];
    [CKVStore unsetStore];

    obj = (MyObject *)[[CKVStore store] objectForKey:k];
    XCTAssertTrue([obj isMemberOfClass:[MyObject class]]);
    XCTAssertTrue([obj.one isEqualToString:@"1"]);
    XCTAssertTrue([obj.two isEqualToString:@"2"]);
}

- (void)testSetNil {
    NSString *k = @"nil";
    id v = nil;
    [[CKVStore store] setObject:@"Not null" forKey:k];
    [[CKVStore store] setObject:v forKey:k];
    [CKVStore unsetStore];

    XCTAssertNil([[CKVStore store] objectForKey:k]);
}

- (void)testSetNSNULL {
    NSString *k = @"NSNULL";
    NSNull *v = [NSNull null];
    [[CKVStore store] setObject:@"Not null" forKey:k];
    [[CKVStore store] setObject:v forKey:k];
    [CKVStore unsetStore];

    XCTAssertNil([[CKVStore store] objectForKey:k]);
}

- (void)testDelete {
    [[CKVStore store] setObject:@"bar" forKey:@"del"];
    [[CKVStore store] deleteObjectForKey:@"del"];
    [CKVStore unsetStore];

    XCTAssertNil([[CKVStore store] objectForKey:@"del"]);
}

- (void)testClear {
    [[CKVStore store] setObject:@"1" forKey:@"one"];
    [[CKVStore store] setObject:@"2" forKey:@"two"];
    [[CKVStore store] clear];
    [CKVStore unsetStore];

    XCTAssertNil([[CKVStore store] objectForKey:@"one"]);
    XCTAssertNil([[CKVStore store] objectForKey:@"two"]);
}

@end


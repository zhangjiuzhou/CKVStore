//
//  CKVStore.h
//  CKVStore
//
//  Created by 张九州 on 2018/1/5.
//

#import <Foundation/Foundation.h>

@interface CKVStore : NSObject

+ (instancetype)store;
+ (instancetype)storeWithName:(NSString *)name;

- (id<NSCoding>)objectForKey:(NSString *)key;
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
- (void)deleteObjectForKey:(NSString *)key;
- (void)clear;

- (void)asyncObjectForKey:(NSString *)key complete:(void (^)(id<NSCoding> result))complete;
- (void)asyncSetObject:(id<NSCoding>)object forKey:(NSString *)key complete:(void (^)(void))complete;

@end

@interface CKVStore (Unavailable)

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

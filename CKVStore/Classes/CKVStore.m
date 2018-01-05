//
//  CKVStore.m
//  CKVStore
//
//  Created by 张九州 on 2018/1/5.
//

#import "CKVStore.h"
#import <FMDB/FMDB.h>

static FMDatabaseQueue *queue;
static dispatch_queue_t operationQueue;

@interface CKVStore ()

@property (nonatomic, strong) NSString *name;

@end

@implementation CKVStore

+ (instancetype)sharedStore {
    return [self storeWithName:@"tbl_default"];
}

+ (instancetype)storeWithName:(NSString *)name {
    static NSMutableDictionary *stores;

    @synchronized (self) {
        if (!stores) {
            stores = [NSMutableDictionary dictionary];
        }

        id store = stores[name];
        if (!store) {
            store = [[self alloc] initWithName:name];
            stores[name] = store;
        }

        return store;
    }
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        if (!queue) {
            NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *dbPath = [docPath stringByAppendingPathComponent:@"com.zjz.kvstore"];
            queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
            operationQueue = dispatch_queue_create("com.zjz.kvstore", DISPATCH_QUEUE_CONCURRENT);
        }

        self.name = name;
        [self _createTable:name];
    }
    return self;
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    static NSString *const sqlTemplate = @"SELECT data, createdTime from %@ where id = ? Limit 1";

    NSString *sql = [NSString stringWithFormat:sqlTemplate, self.name];
    __block NSData *objectData = nil;
    __block NSDate *createdTime = nil;
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql, key];
        if ([rs next]) {
            objectData = [rs dataForColumn:@"data"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];

    id object;
    if (objectData) {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:objectData];
        if ([object isKindOfClass:[NSNull class]]) {
            object = nil;
        }
    }
    return object;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    static NSString *const sqlTemplate = @"REPLACE INTO %@ (id, data, createdTime) values (?, ?, ?)";

    if (!object) {
        object = [NSNull null];
    }

    NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSDate *createdTime = [NSDate date];
    NSString *sql = [NSString stringWithFormat:sqlTemplate, self.name];
    __block BOOL result;
    [queue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, key, objectData, createdTime];
    }];

    if (!result) {
        NSLog(@"Store object for key %@ in %@ failed.", key, self.name);
    }
}

- (void)deleteObjectForKey:(NSString *)key {
    static NSString *const sqlTemplate = @"DELETE from %@ where id = ?";

    NSString * sql = [NSString stringWithFormat:sqlTemplate, self.name];
    __block BOOL result;
    [queue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, key];
    }];

    if (!result) {
        NSLog(@"Delete object for key %@ in %@ failed.", key, self.name);
    }
}

- (void)clear {
    static NSString *const sqlTemplate = @"DELETE from %@";

    NSString *sql = [NSString stringWithFormat:sqlTemplate, self.name];
    __block BOOL result;
    [queue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];

    if (!result) {
        NSLog(@"Clear store %@ failed.", self.name);
    }
}

- (void)asyncObjectForKey:(NSString *)key complete:(void (^)(id<NSCoding>))complete {
    dispatch_async(operationQueue, ^{
        id result = [self objectForKey:key];
        complete(result);
    });
}

- (void)asyncSetObject:(id<NSCoding>)object forKey:(NSString *)key complete:(void (^)(void))complete {
    dispatch_barrier_async(operationQueue, ^{
        [self setObject:object forKey:key];
        if (complete) {
            complete();
        }
    });
}

- (void)_createTable:(NSString *)table {
    static NSString *const sqlTemplate =
    @"CREATE TABLE IF NOT EXISTS %@ ( \
    id TEXT NOT NULL, \
    data BLOB NOT NULL, \
    createdTime TEXT NOT NULL, \
    PRIMARY KEY(id)) \
    ";

    NSString *sql = [NSString stringWithFormat:sqlTemplate, table];
    __block BOOL result;
    [queue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];

    if (!result) {
        NSLog(@"Create table %@ failed.", table);
    }
}

@end

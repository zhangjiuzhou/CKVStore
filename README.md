# CKVStore
基于数据库的Key-Value存储。

## Example
```objective-c
    [[CKVStore store] setObject:@"bar" forKey:@"foo"];
    NSLog(@"foo: %@", [[CKVStore store] objectForKey:@"foo"]);
    [[CKVStore store] deleteObjectForKey:@"foo"];
    NSLog(@"foo: %@", [[CKVStore store] objectForKey:@"foo"]);
```

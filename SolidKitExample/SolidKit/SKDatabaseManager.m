//
//  SKDatabaseManager.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKDatabaseManager.h"
#import <sqlite3.h>
#import <objc/runtime.h>
#import "NSString+SKExtension.h"
#import "NSDictionary+SKJSONString.h"
#import "SKFailureHandler.h"

@interface SKDatabaseManager () {
    dispatch_queue_t    _queue;
}

@end

@implementation SKDatabaseManager

static SKDatabaseManager * _manager;

static sqlite3 *database;
static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;
static NSString *dbFileName;
static NSString *tableName = @"log_data";
static NSString *sqliteSequence = @"sqlite_sequence";

#pragma mark - Public

+ (void)clearDatabaseWithCompletionHandler:(SKDatabaseCompletionHandler)completionHandler {
    SKDatabaseManager *manager = [SKDatabaseManager sharedManager];
    dispatch_sync(manager->_queue , ^{
        @autoreleasepool {
            if (![_manager clearTableWithName:tableName]) {
                [SKFailureHandler handleException:2];
                // todo: error number and handler
            } else {
                if (![_manager clearTableWithName:sqliteSequence]) {
                    [SKFailureHandler handleException:2];
                    // todo: error number and handler
                } else if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler();
                    });
                }
            }
        }
    });
}

+ (void)deleteDataCount:(NSInteger)count completionHandler:(SKDatabaseCompletionHandler)completionHandler {
    SKDatabaseManager *manager = [SKDatabaseManager sharedManager];
    dispatch_sync(manager->_queue , ^{
        @autoreleasepool {
            if (![_manager deleteFrom:tableName limit:count]) {
                [SKFailureHandler handleException:2];
                // todo: error number and handler
            } else if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler();
                });
            }
        }
    });
}

+ (void)insertData:(NSDictionary *)dictionary completionHandler:(SKDatabaseCompletionHandler)completionHandler {
    NSString *jsonString = [dictionary convertToJSONString];
    SKDatabaseManager *manager = [SKDatabaseManager sharedManager];
    dispatch_sync(manager->_queue , ^{
        @autoreleasepool {
            if (![_manager insertString:jsonString]) {
                [SKFailureHandler handleException:2];
                // todo: error number and handler
            } else if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler();
                });
            }
        }
    });
}

+ (void)selectDataWithLimit:(NSInteger)limit completionHandler:(SKDatabaseResultCompletionHandler)completionHandler {
    SKDatabaseManager *manager = [SKDatabaseManager sharedManager];
    dispatch_sync(manager->_queue , ^{
        @autoreleasepool {
            NSArray<NSDictionary *> *array = [_manager selectFormTable:tableName limit:limit];
            if (!array) {
                [SKFailureHandler handleException:2];
                // todo: error number and handler
            } else if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(array);
                });
            }
        }
    });
}

+ (void)selectDataWithLimit:(NSInteger)limit offset:(NSInteger)offset completionHandler:(SKDatabaseResultCompletionHandler)completionHandler {
    SKDatabaseManager *manager = [SKDatabaseManager sharedManager];
    dispatch_sync(manager->_queue , ^{
        @autoreleasepool {
            NSArray<NSDictionary *> *array = [_manager selectFormTable:tableName limit:limit offset:offset];
            if (!array) {
                [SKFailureHandler handleException:2];
                // todo: error number and handler
            } else if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(array);
                });
            }
        }
    });
}

+ (void)selectAllWithCompletionHandler:(SKDatabaseResultCompletionHandler)completionHandler {
    SKDatabaseManager *manager = [SKDatabaseManager sharedManager];
    dispatch_sync(manager->_queue , ^{
        @autoreleasepool {
            NSArray<NSDictionary *> *array = [_manager selectAllFromTable:tableName];
            if (!array) {
                [SKFailureHandler handleException:2];
                // todo: error number and handler
            } else if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(array);
                });
            }
        }
    });
}

#pragma mark - Init

+ (void)load {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dbPath = [NSString cachesPathWithFileName:@"com.talisk.solidkit.sqlite"];
    
    BOOL dbExist = [fileManager fileExistsAtPath:dbPath];
    
    if (!dbExist) {
        NSString *bundlePath = [NSString bundlePathWithFileName:@"com.talisk.solidkit" type:@"sqlite"];
        NSString *cachesPath = dbPath;
        NSError *error;
        
        if (![fileManager copyItemAtPath:bundlePath toPath:cachesPath error:&error]) {
            [SKFailureHandler handleException:1];
            // todo: error number and handler
            return;
        }
    }
    dbFileName = dbPath;
    
    NSLog(@"%@", dbPath);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create([@"com.talisk.solidkit.dbqueue" UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        
        if (![self openDatabase]) {
            NSLog(@"请先执行[[SKDatabaseManager sharedManager]openDatabase];打开数据库 ");
        }
    }
    return self;
}

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}
#pragma mark - DB Foundation
#pragma mark =============== 创建表格 ===============

/// 打开数据库
- (BOOL)openDatabase {
    // 0.获取沙盒中的数据库文件名
    NSString *fileName = dbFileName;
    // 1.打开数据库(如果数据库文件不存在,会自动创建)
    int result = sqlite3_open(fileName.UTF8String, &database);
    if (result == SQLITE_OK) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark =============== 执行sql语句 ===============
/// 执行sql语句
- (BOOL)executeSqlString:(NSString *)sqlString {
    
    char *error = NULL;
    int result = sqlite3_exec(database, sqlString.UTF8String, NULL, NULL, &error);
    return result == SQLITE_OK;
}

#pragma mark =============== 插入数据 ===============

- (BOOL)insertString:(NSString *)string {
    NSString *sqlString = [NSString stringWithFormat:@"insert into log_data (data) values ('%@');", string];
    return [self executeSqlString:sqlString];
}

#pragma mark =============== 查询数据 ===============

/// 获取表格中数据行数
- (NSInteger)getTotalRowsFormTable:(NSString *)tableName {
    return [self selectAllFromTable:tableName].count;
}

/// 获取表格中n条数据
- (id)selectFormTable:(NSString *)tableName limit:(NSInteger)limit {
    return [self selectFormTable:tableName limit:limit offset:0];
}

- (id)selectFormTable:(NSString *)tableName limit:(NSInteger)limit offset:(NSInteger)offset {
    if ([self getTotalRowsFormTable:tableName] <= limit) {
        return [self selectAllFromTable:tableName];
    } else {
        NSString * sqlString = [NSMutableString stringWithFormat:@"select * from %@ limit %li offset %li;", tableName, limit, offset];
        return [self selectDataWithSqlString:sqlString];
    }
}

/// 获取表格中第n条数据
- (id)selectFormTable:(NSString *)tableName dataID:(NSInteger)dataID {
    
    if ([self getTotalRowsFormTable:tableName] >= dataID) { // 判断是否越界
        NSString * sqlString = [NSMutableString stringWithFormat:@"select * from %@ where id=%li;", tableName, dataID];
        return [self selectDataWithSqlString:sqlString];
    }
    return nil;
}

/// 获取表格中所有数据
- (NSArray *)selectAllFromTable:(NSString *)tableName {
    NSString * sqlString = [NSMutableString stringWithFormat:@"select * from %@;", tableName];
    return [self selectDataWithSqlString:sqlString];
}


/// 自定义语句查询
- (NSArray<NSDictionary *> *)selectDataWithSqlString:(NSString *)sqlString {
    NSMutableArray *models = nil;
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(database, sqlString.UTF8String, -1, &stmt, NULL);
    if (SQLITE_OK == result) {
        models = [NSMutableArray array];
        NSArray *arr = @[@"id", @"data"];
        NSDictionary *dict = @{@"id": @"integer", @"data": @"text"};
        while (SQLITE_ROW == sqlite3_step(stmt)) {
            NSMutableDictionary *objc = [[NSMutableDictionary alloc] init];
            for ( int i = 0; i < arr.count; i++) {
                if ([dict[arr[i]] isEqualToString:@"text"]) {
                    [objc setValue:[NSString stringWithFormat:@"%@",[self textForColumn:i  stmt:stmt]] forKey:arr[i]];
                    
                } else if ([dict[arr[i]] isEqualToString:@"real"]) {
                    [objc setValue:[NSString stringWithFormat:@"%f",[self doubleForColumn:i  stmt:stmt]] forKey:arr[i]];
                    
                } else if ([dict[arr[i]] isEqualToString:@"integer"]) {
                    
                    [objc setValue:[NSString stringWithFormat:@"%i",[self intForColumn:i  stmt:stmt]] forKey:arr[i]];
                    
                } else if ([dict[arr[i]] isEqualToString:@"customArr"]) {
                    
                    NSString * str = [self textForColumn:i stmt:stmt];
                    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
                    NSArray * resultArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [objc setValue:resultArray forKey:arr[i]];
                }  else if ([dict[arr[i]] isEqualToString:@"customDict"]) {
                    
                    NSString * str = [self textForColumn:i stmt:stmt];
                    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary * resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [objc setValue:resultDict forKey:arr[i]];
                } else if ([dict[arr[i]] isEqualToString:@"blob"]) {
                    
                    NSString * str = [self textForColumn:i + 1 stmt:stmt];
                    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
                    [objc setValue:data forKey:arr[i]];
                }
            }
            [models addObject:objc];
        }
    }
    return [models copy];
}

- (int)intForColumn:(int)index stmt:(sqlite3_stmt *)stmt {
    return sqlite3_column_int(stmt, index);
}

- (double)doubleForColumn:(int)index stmt:(sqlite3_stmt *)stmt {
    return sqlite3_column_double(stmt, index);
}

- (NSString *)textForColumn:(int)index stmt:(sqlite3_stmt *)stmt {
    return [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, index)];
    
}

#pragma mark =============== 数据删除 ===============

- (BOOL)deleteFrom:(NSString *)tableName limit:(NSInteger)limit {
    return [self deleteFrom:tableName withString:[NSString stringWithFormat:@"id in (select id from %@ order by id asc limit %li)", tableName, limit]];
}

- (BOOL)deleteFrom:(NSString *)tableName withString:(NSString *)string {
    if (![self openDatabase]) {
        NSLog(@"请先执行[[SKDatabaseManager sharedManager]openDatabase];打开数据库");
        return NO;
    }
    NSString * sqlString = [NSString stringWithFormat:@"delete from %@ where %@;", tableName, string];
    return [self executeSqlString:sqlString];
}

- (BOOL)clearTableWithName:(NSString *)tableName {
    
    if (![self openDatabase]) {
        NSLog(@"请先执行[[SKDatabaseManager sharedManager]openDatabase];打开数据库");
        return NO;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"delete from %@", tableName];
    return [self executeSqlString:sqlString];
}

/**
 *  删除数据库表格
 *
 *  @param className 类名
 *
 *  @return 删除结果
 */
- (BOOL)deleteTableWithTableName:(id)className {
    
    if (![self openDatabase]) {
        return NO;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"drop table %@",[className class]];
    
    return [self executeSqlString:sqlString];
}

#pragma mark =============== 获取创表语句 ===============

- (NSString *)createTableWithTableName:(NSString *)tableName dict:(NSDictionary *)dict {
    
    NSMutableString *sqlMuString;
    // 拼接sql语句
    sqlMuString = [NSMutableString stringWithFormat:@"create table if not exists %@ (t_default_id integer primary key autoincrement,",tableName];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [sqlMuString appendFormat:@"%@ %@,",key,obj];
    }];
    
    // 去除最后的逗号
    NSRange rang = NSMakeRange(sqlMuString.length-1, 1);
    
    [sqlMuString deleteCharactersInRange:rang];
    
    [sqlMuString appendString:@")"];
    
    return sqlMuString;
}

@end

//
//  SKDatabaseManager.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/18.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SKDatabaseResultCompletionHandler)(NSArray *result);
typedef void(^SKDatabaseCompletionHandler)();

typedef NS_ENUM(NSUInteger, SKDataType) {
    SKDataTypeLog = 0,
    SKDataTypeNetwork = 1
};

@interface SKDatabaseManager : NSObject

+ (void)clearDatabase:(SKDataType)type withCompletionHandler:(SKDatabaseCompletionHandler)completionHandler;

+ (void)deleteDataCount:(NSInteger)count from:(SKDataType)type completionHandler:(SKDatabaseCompletionHandler)completionHandler;

+ (void)insertDictionary:(NSDictionary *)dictionary type:(SKDataType)type completionHandler:(SKDatabaseCompletionHandler)completionHandler;

+ (void)insertString:(NSString *)string type:(SKDataType)type completionHandler:(SKDatabaseCompletionHandler)completionHandler;

+ (void)insertData:(NSDictionary *)dictionary type:(SKDataType)type completionHandler:(SKDatabaseCompletionHandler)completionHandler;

+ (void)selectData:(SKDataType)type WithLimit:(NSInteger)limit completionHandler:(SKDatabaseResultCompletionHandler)completionHandler;

+ (void)selectData:(SKDataType)type withLimit:(NSInteger)limit offset:(NSInteger)offset completionHandler:(SKDatabaseResultCompletionHandler)completionHandler;

+ (void)selectAll:(SKDataType)type withCompletionHandler:(SKDatabaseResultCompletionHandler)completionHandler;

@end

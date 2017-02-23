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

+ (void)clearDatabaseWithCompletionHandler:(SKDatabaseCompletionHandler)completionHandler;
+ (void)deleteDataCount:(NSInteger)count completionHandler:(SKDatabaseCompletionHandler)completionHandler;
+ (void)insertString:(NSString *)string completionHandler:(SKDatabaseCompletionHandler)completionHandler;
+ (void)insertData:(NSDictionary *)dictionary completionHandler:(SKDatabaseCompletionHandler)completionHandler;
+ (void)selectDataWithLimit:(NSInteger)limit completionHandler:(SKDatabaseResultCompletionHandler)completionHandler;
+ (void)selectDataWithLimit:(NSInteger)limit offset:(NSInteger)offset completionHandler:(SKDatabaseResultCompletionHandler)completionHandler;
+ (void)selectAllWithCompletionHandler:(SKDatabaseResultCompletionHandler)completionHandler;

@end

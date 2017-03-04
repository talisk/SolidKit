//
//  SKDatabaseManager+HTTPModel.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/2/26.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDatabaseManager.h"

@class SKHTTPModel;

@interface SKDatabaseManager (HTTPModel)

+ (void)insertModel:(SKHTTPModel *)model to:(SKDataType)type withCompletionHandler:(SKDatabaseCompletionHandler)completionHandler;

@end

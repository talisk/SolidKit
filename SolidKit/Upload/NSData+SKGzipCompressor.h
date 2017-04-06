//
//  NSData+SKGzipCompressor.h
//  SolidKitExample
//
//  Created by Sun,Kai(BBTD) on 2017/4/6.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SKGzipCompressor)

- (NSData *)gzipData;

- (NSData *)gzipUncompress;

@end

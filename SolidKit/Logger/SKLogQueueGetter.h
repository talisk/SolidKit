//
//  SKLogQueueGetter.h
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#ifndef SKLogQueueGetter_h
#define SKLogQueueGetter_h

static dispatch_queue_t log_queue() {
    static dispatch_queue_t solidkit_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        solidkit_queue = dispatch_queue_create("com.talisk.solidkit.logqueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return solidkit_queue;
}

#endif /* SKLogQueueGetter_h */

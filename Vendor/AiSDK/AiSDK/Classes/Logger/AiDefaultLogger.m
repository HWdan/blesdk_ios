//
//  DefaultLogger.m
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import "AiDefaultLogger.h"

@implementation AiDefaultLogger

- (void)d:(nonnull NSString *)msg { 
    NSLog(@"%@", msg);
}

- (void)e:(nonnull NSString *)msg { 
    NSLog(@"%@", msg);
}

- (void)i:(nonnull NSString *)msg { 
    NSLog(@"%@", msg);
}

- (void)w:(nonnull NSString *)msg { 
    NSLog(@"%@", msg);
}

@end

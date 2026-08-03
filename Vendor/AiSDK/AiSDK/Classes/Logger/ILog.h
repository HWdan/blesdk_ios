//
//  ILog.h
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ILog <NSObject>

- (void) d:(NSString *)msg;
- (void) i:(NSString *)msg;
- (void) w:(NSString *)msg;
- (void) e:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END

//
//  AiTimeoutService.h
//  AFNetworking
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiTimeoutService : NSObject

- (void) timeout;
- (void) startTimer:(NSInteger)seconds;
- (void) removeTimer;

@end

NS_ASSUME_NONNULL_END

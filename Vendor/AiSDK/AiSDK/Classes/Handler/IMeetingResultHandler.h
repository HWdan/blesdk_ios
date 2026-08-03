//
//  ITextToAgentResultHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMeetingResultHandler <NSObject>

- (void) convert:(NSInteger)type
            time:(NSDate *)time;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

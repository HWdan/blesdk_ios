//
//  ITextToAgentResultHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ITextToAgentResultHandler <NSObject>

- (void) convert:(NSString *)text
           agent:(NSInteger)agent;
- (void) convertComplete:(NSString *_Nullable)result
                    code:(NSInteger)code
                errorMsg:(NSString *_Nullable)errorMsg;
- (void) changeType:(NSInteger)type;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

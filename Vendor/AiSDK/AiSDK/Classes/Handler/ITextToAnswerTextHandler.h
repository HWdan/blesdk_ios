//
//  ITextToAnswerTextHandler.h
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ITextToAnswerTextHandler <NSObject>

- (void) convert:(NSString *)text;
- (void) convertComplete:(NSString *_Nullable)text
                    code:(NSInteger)code
                errorMsg:(NSString *_Nullable)errorMsg;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

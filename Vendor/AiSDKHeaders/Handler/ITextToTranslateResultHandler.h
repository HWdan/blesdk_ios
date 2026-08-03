//
//  ITextToTranslateResultHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ITextToTranslateResultHandler <NSObject>

- (void) convert:(NSString *)text;
- (void) convertComplete:(NSString *_Nullable)result
                    code:(NSInteger)code
                errorMsg:(NSString *_Nullable)errorMsg;
- (void) changeInputLanguage:(NSInteger)inputLanguage
              outputLanguage:(NSInteger)outputLanguage;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

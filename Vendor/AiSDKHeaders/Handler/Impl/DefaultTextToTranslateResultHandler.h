//
//  DefaultTextToTranslateResultHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import <Foundation/Foundation.h>
#import "ITextToTranslateResultHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface DefaultTextToTranslateResultHandler : NSObject<ITextToTranslateResultHandler>

@property(nonatomic, assign) NSInteger inputLanguage;
@property(nonatomic, assign) NSInteger outputLanguage;

@end

NS_ASSUME_NONNULL_END

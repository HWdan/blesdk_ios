//
//  IHealthAnalysisResultHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HwHealthData;

@protocol IHealthAnalysisResultHandler <NSObject>

- (void) analysis:(HwHealthData *)healthData;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

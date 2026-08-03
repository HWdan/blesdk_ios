//
//  AiDevicePlatformStrategyFactory.h
//  AiSDK
//
//  Reconstructed from AiDevicePlatformStrategyFactory.m
//

#import <Foundation/Foundation.h>
#import "AiDevicePlatformStrategy.h"
#import "AiDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AiDevicePlatformStrategyFactory : NSObject

+ (id<AiDevicePlatformStrategy>)strategyForPlatformType:(HWPlatformType)platformType;

@end

NS_ASSUME_NONNULL_END

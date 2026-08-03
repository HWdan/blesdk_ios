//
//  AiDevicePlatformStrategyFactory.m
//  AiSDK
//

#import "AiDevicePlatformStrategyFactory.h"
#import "AiJieLiDevicePlatformStrategy.h"
#import "AiSifliDevicePlatformStrategy.h"

@implementation AiDevicePlatformStrategyFactory

+ (id<AiDevicePlatformStrategy>)strategyForPlatformType:(HWPlatformType)platformType
{
    static AiSifliDevicePlatformStrategy *sifliStrategy;
    static AiJieLiDevicePlatformStrategy *jieLiStrategy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sifliStrategy = [[AiSifliDevicePlatformStrategy alloc] init];
        jieLiStrategy = [[AiJieLiDevicePlatformStrategy alloc] init];
    });

    // 平台类型到策略的唯一分发点，业务调用方不需要感知具体实现。
    switch (platformType) {
        case HWPlatformTypeJieLi:
            return jieLiStrategy;
        case HWPlatformTypeSifli:
        default:
            return sifliStrategy;
    }
}

@end

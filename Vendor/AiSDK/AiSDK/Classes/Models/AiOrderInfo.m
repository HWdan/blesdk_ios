//
//  AiOrderInfo.m
//  AiSDK
//
//  Created by huawo01 on 2025/9/20.
//

#import "AiOrderInfo.h"

@implementation AiOrderInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"AiOrderInfo--> orderNum: %@, orderType: %@, endTime: %@", @(self.orderNum), @(self.orderType), @(self.endTime)];
}

@end

//
//  DefaultAiWatchfaceNameProvider.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/10.
//

#import "DefaultAiWatchfaceNameProvider.h"

@implementation DefaultAiWatchfaceNameProvider

- (NSString *)name {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userDefault integerForKey:@"ai_watchface_index"];
    if (index >= 10) {
        index = 1;
    } else {
        index += 1;
    }
    [userDefault setObject:@(index) forKey:@"ai_watchface_index"];
    [userDefault synchronize];
    return [NSString stringWithFormat:@"AIFace%@", @(index)];
}

@end

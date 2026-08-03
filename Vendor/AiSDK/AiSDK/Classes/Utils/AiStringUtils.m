//
//  StringUtils.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiStringUtils.h"

@implementation AiStringUtils

+ (BOOL) isEmpty:(NSString *)str
{
    if (str == nil || [@"" isEqualToString:str]) {
        return YES;
    }
    return NO;
}

@end

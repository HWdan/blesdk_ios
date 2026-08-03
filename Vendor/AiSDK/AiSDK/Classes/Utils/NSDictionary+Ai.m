//
//  NSDictionary+Ai.m
//  AiSDK
//
//  Created by HuaWo on 2025/3/27.
//

#import "NSDictionary+Ai.h"

@implementation NSDictionary (Ai)

- (NSString *)stringForKey:(NSString *)key {
    id value = self[key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    return nil;
}

- (NSNumber *)numberForKey:(NSString *)key {
    id value = self[key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        return [formatter numberFromString:value];
    }
    return nil;
}

- (NSArray *)arrayForKey:(NSString *)key {
    id value = self[key];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    id value = self[key];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

@end

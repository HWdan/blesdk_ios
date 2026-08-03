//
//  NSDictionary+Ai.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Ai)

- (NSString *)stringForKey:(NSString *)key;
- (NSNumber *)numberForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

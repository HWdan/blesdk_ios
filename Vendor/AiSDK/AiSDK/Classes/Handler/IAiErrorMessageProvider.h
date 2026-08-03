//
//  IAiErrorMessageProvider.h
//  Pods
//
//  Created by HuaWo on 2024/12/23.
//

#ifndef IAiErrorMessageProvider_h
#define IAiErrorMessageProvider_h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IAiErrorMessageProvider <NSObject>

- (NSString *) messageForCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END

#endif /* IAiErrorMessageProvider_h */

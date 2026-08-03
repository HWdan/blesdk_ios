//
//  IAuth.h
//  Pods
//
//  Created by HuaWo on 2024/12/23.
//

#ifndef IAuth_h
#define IAuth_h
#import <Foundation/Foundation.h>
#import "AiDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IAuth <NSObject>

- (AiDeviceInfo *) authInfo;
- (void) refreshToken;
- (BOOL) isExpired;
- (void) setLoginToken:(NSString *)accessToken;
- (void) refreshTokenComplete:(AiDeviceInfo *)authInfo
                         code:(int)code
                     errorMsg:(NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END

#endif /* IAuth_h */

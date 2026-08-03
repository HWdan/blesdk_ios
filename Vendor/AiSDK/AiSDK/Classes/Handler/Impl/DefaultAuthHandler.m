//
//  DefaultAuthHandler.m
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import "DefaultAuthHandler.h"

@interface DefaultAuthHandler()

@property(nonatomic, strong) AiDeviceInfo *authInfo;

@end


@implementation DefaultAuthHandler


- (AiDeviceInfo *)authInfo { 
    return _authInfo;
}

- (BOOL)isExpired { 
    return NO;
}

- (void)refreshToken { 
    
}

- (void)refreshTokenComplete:(AiDeviceInfo *)authInfo code:(int)code errorMsg:(NSString *)errorMsg { 
    
}

- (void)setLoginToken:(NSString *)accessToken { 
    
}

@end

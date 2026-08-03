//
//  AiVoiceToTextService.h
//  AFNetworking
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import "IVoiceToText.h"
#import "AiTimeoutService.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^AiVoiceToTextCallback)(NSString *result, NSInteger code, NSString *msgCode);

@interface AiVoiceToTextService : AiTimeoutService<IVoiceToText>

- (AiVoiceToTextService *) initWithCallback:(AiVoiceToTextCallback)callback;

@end

NS_ASSUME_NONNULL_END

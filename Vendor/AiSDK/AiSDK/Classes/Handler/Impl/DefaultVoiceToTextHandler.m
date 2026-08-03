//
//  DefaultVoiceToTextHandler.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/14.
//

#import "DefaultVoiceToTextHandler.h"
#import "AiLogger.h"
#import "AiSDK/AiSDK.h"

@implementation DefaultVoiceToTextHandler

- (void)done:(NSString *)result code:(NSInteger)code errorMsg:(NSString *)errorMsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (code != 0) {
            [AiLogger i:@"AiVoiceToText Failed: code: %@, msg: %@", @(code), errorMsg];
        } else {
            [AiLogger i:@"AiVoiceToText Done: %@", result];
        }
        [[AiSDK sharedInstance] voiceToTextCompleted:result code:code msg:errorMsg];
    });
}

@end

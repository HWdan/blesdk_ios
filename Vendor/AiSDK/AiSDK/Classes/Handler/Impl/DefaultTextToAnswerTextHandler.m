//
//  DefaultTextToAnswerTextHandler.m
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import "DefaultTextToAnswerTextHandler.h"
#import "AiLogger.h"
#import "AiSDK/AiSDK.h"
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
@import NativeLib;

@interface DefaultTextToAnswerTextHandler()

@property(nonatomic, assign) BOOL isCanceled;
@property(nonatomic, copy) NSString *chatId;

@end

@implementation DefaultTextToAnswerTextHandler

- (void) getAnswerFromServer:(NSString *)text
{
    if (self.isCanceled) {
        [AiLogger i:@"TextToAnswer 已取消"];
        return;
    }
    
    NSString *requestId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    NSString *locale = [[AiSDK sharedInstance] getDeviceInfo].currentLocale;
    
    //问答
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] textChatWithRequestId:requestId wid:wid thirdUuid:nil inputContent:text contentId:self.chatId language:locale onSuccess:^(NSString * _Nonnull requestId, NSString * _Nonnull sendTextContent, NSString * _Nonnull answerTextContent, NSString * _Nonnull contentId, SubscriptionInfo * _Nullable subscriptionInfo) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
              dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf) {
                    strongSelf.chatId = contentId;
                    [strongSelf convertComplete:answerTextContent code:0 errorMsg:nil];
                }
            });
        
        } onFailure:^(NSString * _Nonnull requestId, ErrorCode * _Nonnull errorCode) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf) {
                    [strongSelf convertComplete:nil code:[errorCode.code integerValue] errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:[errorCode.code integerValue]]];
                }
            });
        }];
}

- (void)cancel {
    self.isCanceled = YES;
}

- (void)convert:(nonnull NSString *)text {
    self.isCanceled = NO;
    [self getAnswerFromServer:text];
}

- (void)convertComplete:(NSString *)text
                   code:(NSInteger)code
               errorMsg:(NSString *)errorMsg
{
    if (self.isCanceled) {
        [AiLogger i:@"TextToAnswer convertComplete 已取消"];
        return;
    }
    if (code != 0) {
        [AiLogger e:@"Text To Answer Failed: %@, %@", @(code), errorMsg];
    } else {
        [AiLogger i:@"%@", text];
    }
    [[AiSDK sharedInstance] textToAnswerCompleted:text code:code msg:[[AiSDK sharedInstance] errorMsgWithCode:code]];
}

@end

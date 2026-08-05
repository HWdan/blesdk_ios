//
//  AiVoiceToTextService.m
//  AFNetworking
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiVoiceToTextService.h"
#import "AiLogger.h"
#import "AiLocaleUtils.h"
#import "AiSDK/AiSDK.h"
#import "HwBluetoothSDK.h"
//#import "HwBluetoothSDK/HwBluetoothSDK.h"
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
@import NativeLib;

#define kRecordTimeout 12

@interface AiVoiceToTextService()

@property(nonatomic, copy) AiVoiceToTextCallback callback;
@property(nonatomic, assign) BOOL isCanceled;
@property(nonatomic, assign) NSInteger langugage;
@property(nonatomic, assign) NSInteger aiType;
@property(nonatomic, copy) NSString *mp3Path;

@end

@implementation AiVoiceToTextService

- (void)dealloc
{
    _callback = nil;
}

- (AiVoiceToTextService *)initWithCallback:(AiVoiceToTextCallback)callback
{
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)cancel
{
    [AiLogger i:@"AiVoiceToTextService cancel"];
    self.isCanceled = YES;
}

- (void)done:(NSString *)result
        code:(NSInteger)code
    errorMsg:(NSString *)errorMsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback != nil) {
            self.callback(result, code, errorMsg);
        }
        if (code != 0) {
            [AiLogger i:@"AiVoiceToText Failed: code: %@, msg: %@", @(code), errorMsg];
        } else {
            [AiLogger i:@"AiVoiceToText Done: %@", result];
        }
    });
}

- (void)prepare
{
    [AiLogger i:@"AiVoiceToTextService prepare"];
}

- (void)destroy {
    [AiLogger i:@"AiVoiceToTextService destroy"];
}

- (void)startRecording:(NSInteger)language
                aiType:(NSInteger)aiType {
    [AiLogger i:@"AiVoiceToTextService startRecording"];
    self.isCanceled = NO;
    [self startTimer:kRecordTimeout];
    self.langugage = language;
    self.aiType = aiType;
    [[AiSDK sharedInstance] voiceDialogStarted];
}

- (void)stopRecording {
    [AiLogger i:@"AiVoiceToTextService stopRecording"];
    [self removeTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getRecordFile];
    });
}


- (void) getRecordFile
{
    [AiLogger i:@"AiVoiceToTextService getRecordFile"];
    if (self.isCanceled) {
        [AiLogger i:@"AiVoiceToTextService getRecordFile 已取消"];
        return;
    }
    
    [[AiSDK sharedInstance].devicePlatformStrategy requestRecordDataWithCallback:^(NSData *data, NSError *error) {
        if (error) {
            [self done:nil code:error.code errorMsg:error.localizedDescription];
            return;
        }
        if (data.length == 0) {
            [self done:nil code:AiErrorRecordVoiceIsEmpty errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorRecordVoiceIsEmpty]];
            return;
        }
        [self voiceToText:data];
        // 下面这个保存只是debug用的
        [self saveMp3Data:data];
    }];
}

- (void) saveMp3Data:(NSData *)data
{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = @"record.mp3";
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
        
    NSError *error = nil;
    BOOL success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (success) {
        [AiLogger i:@"文件保存成功：%@", filePath];
    } else {
        [AiLogger e:@"文件保存失败：%@", error.localizedDescription];
    }
    self.mp3Path = filePath;
}

- (void) voiceToText:(NSData *)voice
{
    if (self.isCanceled) {
        [AiLogger i:@"AiVoiceToTextService voiceToText 已取消"];
        return;
    }
    NSString *requestId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    NSString *locale = [[AiSDK sharedInstance] getDeviceInfo].currentLocale;
    
    if (self.langugage >= 0) {
        NSString *languagePrefix = [HwLanguageUtil getLocaleWithLanguage:self.langugage];
        locale = [AiLocaleUtils fitLocale:languagePrefix];
    }
    
    NSString *format = @"mp3";
    [AiLogger i:@"speechToTextViaLanguageWithRequestId: %@, wid: %@, language: %@", requestId, wid, locale];
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] speechToTextWithRequestId:requestId wid:wid thirdUuid:nil data:voice fileFormat:format language:locale onSuccess:^(NSString * _Nonnull requestId, NSString * _Nonnull text) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.isCanceled) {
                [AiLogger i:@"AiVoiceToTextService onSuccess 已取消"];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (text.length == 0) {
                    [strongSelf done:text code:AiErrorVoiceToTextEmpty errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorVoiceToTextEmpty]];
                } else {
                    [strongSelf done:text code:0 errorMsg:nil];
                }
            });
        }
        
        } onFailure:^(NSString * _Nonnull requestId, ErrorCode * _Nonnull errorCode) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (strongSelf.isCanceled) {
                    [AiLogger i:@"AiVoiceToTextService onFailure 已取消"];
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf done:nil code:[errorCode.code integerValue] errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:[errorCode.code integerValue]]];
                });
            }
        }];
}

- (void)timeout
{
    [super timeout];
    // [self stopRecording];
}

@end

//
//  DefaultTextToAgentResultHandler.m
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import "DefaultMeetingResultHandler.h"
#import "AiLogger.h"
#import "AiSDK/AiSDK.h"
//@import NativeLib
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
#import <HwBluetoothSDK/HwBluetoothSDK.h>
#import "NSDictionary+Ai.h"
@import NativeLib;

@interface DefaultMeetingResultHandler()

@property(nonatomic, assign) BOOL isCanceled;
@property(nonatomic, assign) NSInteger contentType;
@property(nonatomic, copy) NSString *voiceFilePath;
@property(nonatomic, strong) NSDate *meetingTime;

@property(nonatomic, strong) NSString *requestId;

@end

@implementation DefaultMeetingResultHandler

- (void) getMeetingRecorderData
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    [[HwBluetoothSDK sharedInstance] getMeetingRecordDataWithCallback:^(NSData *data, NSError *error) {
        if (error) {
            [self convertComplete:nil code:error.code errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:error.code]];
            return;
        }
        NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970] - now;
        [AiLogger i:@"获取会议记录消耗时间：%@ 秒", @(seconds)];
        if (data.length == 0) {
            [self convertComplete:nil code:AiErrorRecordVoiceIsEmpty errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorRecordVoiceIsEmpty]];
            return;
        }
        [self uploadRecordData:data];
    }];
}

- (NSString *) saveMp3Data:(NSData *)data
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
        return nil;
    }
    return filePath;
}

- (void) uploadRecordData:(NSData *)data
{
    NSString *path = [self saveMp3Data:data];
    if (path.length == 0) {
        [AiLogger e:@"上传录音文件保存后, 录音为空:%@", path];
        [self convertComplete:nil code:AiErrorPhoneStorageFull errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorPhoneStorageFull]];
        return;
    }
    
    self.voiceFilePath = path;
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    NSString *locale = [[AiSDK sharedInstance] getDeviceInfo].currentLocale;
    
    [AiLogger i:@"上传文件路径：%@, wid: %@, locale: %@", self.voiceFilePath, wid, locale];
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] meetingAudioFileUpload2SttWithWid:wid thirdUuid:nil fileURL:[NSURL fileURLWithPath:path] fileFormat:@"mp3" inputLanguage:locale onSuccess:^(NSString * _Nonnull requestId, SubscriptionInfo * _Nullable subscriptionInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [AiLogger i:@"上传文件成功，返回请求ID：%@", requestId];
            if (requestId.length == 0) {
                [strongSelf convertComplete:nil code:AiErrorAFlashUnknownError errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorAFlashUnknownError]];
                return;
            }
            [strongSelf getResultFromServer:requestId];
        }

    } onFailure:^(ErrorCode * _Nonnull errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf convertComplete:nil code:[errorCode.code integerValue] errorMsg:errorCode.message];
        }
    }];
}


- (void) getResultFromServer:(NSString *)requestId
{
    if (self.isCanceled) {
        [AiLogger i:@"AiMeeting 已取消"];
        return;
    }
    
    self.requestId = requestId;
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    [AiLogger i:@"从艾闪请求会议信息，请求ID：%@, wid: %@", requestId, wid];

    __weak typeof(self) weakSelf = self;
    [[AFlash shared] meetingSummaryWithRequestId:requestId wid:wid thirdUuid:nil onSuccess:^(NSString * _Nullable content, SubscriptionInfo * _Nullable subscriptionInfo) {
            // - `status`: 0: 生成中，1: 生成成功，返回对应的数据。
            [AiLogger i:@"返回结果, subscriptionInfo：%@, content: %@", subscriptionInfo, content];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf convertComplete:content code:0 errorMsg:nil];
        }
        } onFailure:^(ErrorCode * _Nonnull errorCode) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf convertComplete:nil code:[errorCode.code integerValue] errorMsg:errorCode.message];
            }
        }];
}

- (void)cancel {
    self.isCanceled = YES;
}

- (void)convert:(NSInteger)type
           time:(NSDate *)time
{
    self.isCanceled = NO;
    self.contentType = type;
    self.meetingTime = time;
    [self getMeetingRecorderData];
}

- (void)convertComplete:(NSString *)text
                   code:(NSInteger)code
               errorMsg:(NSString *)errorMsg
{
    if (self.isCanceled) {
        [AiLogger i:@"Meeting Handler convertComplete 已取消"];
        return;
    }
    if (code != 0) {
        [AiLogger e:@"Meeting Handler Failed: %@, %@", @(code), errorMsg];
        [self failed:code msg:errorMsg];
        return;
    }
    [AiLogger i:@"会议返回的内容：%@", text];
    if (text.length == 0) {
        [self failed:AiErrorMeetingSummaryEmpty msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorMeetingSummaryEmpty]];
        return;
    }
    
    NSString *jsonStr = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    // jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [AiLogger i:@"替换无用字符之后的结果：%@", jsonStr];
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:kNilOptions
                                                      error:&error];

    NSDictionary *jsonDict = (NSDictionary *) jsonObject;
    if (jsonDict == nil) {
        [self failed:AiErrorMeetingParseJsonError msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorMeetingParseJsonError]];
        return;
    }
    
    NSString *title = [jsonDict stringForKey:@"meetingName"];
    NSString *summary = [jsonDict stringForKey:@"summary"];
    NSString *content = [jsonDict stringForKey:@"content"];
    
    if (summary.length == 0) {
        [AiLogger e:@"summary是空的"];
        [self failed:AiErrorMeetingSummaryEmpty msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorMeetingSummaryEmpty]];
        return;
    }
    
    HwMeeting *meeting = [[HwMeeting alloc] initWithTitle:title summary:summary content:content];
    [[HwBluetoothSDK sharedInstance] setAiMeetingResult:meeting type:self.contentType code:0 msg:nil];
    [[AiSDK sharedInstance] meetingResultCompleted:meeting voiceFilePath:self.voiceFilePath meetingTime:self.meetingTime code:0 msg:nil];
}

- (void) failed:(NSInteger)code msg:(NSString *)msg
{
    if (code == 14) {
        [AiLogger i:@"失败，返回错误码：14，所以重试"];
        [[HwBluetoothSDK sharedInstance] notifyAiMeetingHandling];
        [self getResultFromServer:self.requestId];
        return;
    }
    [AiLogger e:@"失败， code: %@, msg: %@", @(code), msg];
    [[HwBluetoothSDK sharedInstance] setAiMeetingResult:nil type:0 code:(int)code msg:msg];
    [[AiSDK sharedInstance] meetingResultCompleted:nil voiceFilePath:nil meetingTime:self.meetingTime code:code msg:msg];
}

@end

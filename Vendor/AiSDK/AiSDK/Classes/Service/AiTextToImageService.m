//
//  AiTextToImageService.m
//  AFNetworking
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiTextToImageService.h"
#import "AiLogger.h"
#import "AiSDK/AiSDK.h"
#import "HwBluetoothSDK/HwBluetoothSDK.h"
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
@import NativeLib;

@interface AiTextToImageService()

@property(nonatomic, copy) AiTextToImageCallback callback;

@end


@implementation AiTextToImageService

- (void)dealloc
{
    _callback = nil;
}

- (AiTextToImageService *)initWithCallback:(AiTextToImageCallback)callback
{
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

- (void)cancel
{
    [AiLogger i:@"AiTextToImageService cancel"];
    self.isCanceled = YES;
}

- (void)convert:(nonnull NSString *)text {
    self.isCanceled = NO;
    NSString *requestId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    NSString *locale = [[AiSDK sharedInstance] getDeviceInfo].currentLocale;
    NSString *format = @"png";
    
    //文生图
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] textDrawingToDataWithRequestId:requestId wid:wid thirdUuid:nil inputContent:text imgFormat:format style:[AiSDK sharedInstance].aiStyle language:locale onSuccess:^(NSString * _Nonnull requestId, NSString * _Nonnull inputText, NSData * _Nonnull bgData, NSData * _Nullable thumbnailData, SubscriptionInfo * _Nullable subscriptionInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.isCanceled) {
                [AiLogger i:@"AiTextToImageService onSuccess 已取消"];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:bgData];
                if (image == nil) {
                    [strongSelf convertComplete:nil code:AiErrorModelError errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorModelError]];
                } else {
                    [strongSelf convertComplete:image code:0 errorMsg:nil];
                }
            });
        }
    } onFailure:^(NSString * _Nonnull requestId, ErrorCode * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.isCanceled) {
                [AiLogger i:@"AiTextToImageService onFailure 已取消"];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf convertComplete:nil code:[error.code integerValue] errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:[error.code integerValue]]];
            });
        }
    }];
}

- (void)convertComplete:(UIImage *_Nullable)image
                   code:(NSInteger)code
               errorMsg:(NSString *_Nullable)errorMsg
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback != nil) {
            self.callback(image, code, errorMsg);
        }
    });
}


@end

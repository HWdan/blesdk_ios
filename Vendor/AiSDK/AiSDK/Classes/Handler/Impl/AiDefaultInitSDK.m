//
//  AiDefaultInitSDK.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiDefaultInitSDK.h"
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
@import NativeLib;
#import "AiDeviceInfo.h"
#import "AiLocaleUtils.h"
#import "AiSpUtils.h"
#import "AiLogger.h"

@interface AiDefaultInitSDK()

@property(nonatomic, assign) NSInteger tryCount;

@end

@implementation AiDefaultInitSDK

- (void)dealloc
{
    [AiLogger i:@"AiDefaultInitSDK dealloc"];
}

- (void)initSDK:(AiDeviceInfo *)deviceInfo
{
    if (deviceInfo == nil || deviceInfo.Id == nil || deviceInfo.width == 0 || deviceInfo.supportedLocales == nil) {
        return;
    }
    
    WatchInfo *info = [[WatchInfo alloc] initWithPayModel:PaymentModelLICENSE_PAY wid:deviceInfo.Id];
    NSString *sizeStr = [NSString stringWithFormat:@"%@*%@",@(deviceInfo.width), @(deviceInfo.height)];
    info.resolution = sizeStr;
    
    info.language = [AiLocaleUtils fitLocale:deviceInfo.currentLocale];
    info.supportedLanguages = [deviceInfo.supportedLocales componentsJoinedByString:@","];
    
    NSString *uid = [AiSpUtils getUUID];
    
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] initializeWithRegion:RegionOVERSEAS watchInfos:@[info] onSuccess:^(NSArray<WatchInfo *> * _Nonnull arr) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                WatchInfo *watch = arr.firstObject;
                strongSelf.tryCount = 0;
                [AiLogger i:@"init success: %@, %@, %@", watch.wid, watch.language, watch.supportedLanguages];
    //            [[AFlash shared] fetchAgentListWithRequestId:@"123" wid:@"124711110806" language:@"zh" pageSize:100 pageNum:0 onSuccess:^(NSString * str, NSInteger a, NSInteger b, NSArray<AiSmart *> * smList) {
    //                int acc = 1;
    //                for (AiSmart *sm in smList) {
    //                    NSLog(@"name: %@, code: %@", sm.name, sm.aismartCode);
    //                }
    //                    } onFailure:^(NSString * str, ErrorCode * c) {
    //                        NSString *msg = c.message;
    //                        NSString *ddd = c.code;
    //                        int bbb = 2;
    //                    }];
            });
        }

    } onFailure:^(ErrorCode * _Nonnull errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"%@ : %@",errorCode.code,errorCode.message);
            [AiLogger e:@"init failed: code: %@, message: %@", errorCode.code, errorCode.message];
            strongSelf.tryCount = 0;
            [strongSelf performSelector:@selector(retryInitSDK:) withObject:deviceInfo afterDelay:5];
        }

    }];
}

- (void)retryInitSDK:(AiDeviceInfo *)deviceInfo
{
    if (deviceInfo == nil || deviceInfo.Id == nil || deviceInfo.width == 0 || deviceInfo.supportedLocales == nil) {
        return;
    }
    
    if (self.tryCount >= 5) {
        return;
    }
    
    WatchInfo *info = [[WatchInfo alloc] initWithPayModel:PaymentModelLICENSE_PAY wid:deviceInfo.Id];
    NSString *sizeStr = [NSString stringWithFormat:@"%@*%@",@(deviceInfo.width), @(deviceInfo.height)];
    info.resolution = sizeStr;
    
    info.language = [AiLocaleUtils fitLocale:deviceInfo.currentLocale];
    info.supportedLanguages = [deviceInfo.supportedLocales componentsJoinedByString:@","];
    
    NSString *uid = [AiSpUtils getUUID];
    
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] initializeWithRegion:RegionOVERSEAS watchInfos:@[info] onSuccess:^(NSArray<WatchInfo *> * _Nonnull arr) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.tryCount = 0;
                WatchInfo *watch = arr.firstObject;
                [AiLogger i:@"retryInitSDK success: %@, %@, %@", watch.wid, watch.language, watch.supportedLanguages];
            });
        }

    } onFailure:^(ErrorCode * _Nonnull errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"%@ : %@",errorCode.code,errorCode.message);
            [AiLogger e:@"retryInitSDK failed: code: %@, message: %@", errorCode.code, errorCode.message];
            [AiLogger i:@"start retryInitSDK"];
            if (strongSelf.tryCount < 5) {
                strongSelf.tryCount ++;
                NSTimeInterval delay = pow(2, self.tryCount) * 0.5; // 0.5s, 1s, 2s, 4s, 8s
                [strongSelf performSelector:@selector(retryInitSDK:) withObject:deviceInfo afterDelay:delay];
            }
        }

    }];
}

@end

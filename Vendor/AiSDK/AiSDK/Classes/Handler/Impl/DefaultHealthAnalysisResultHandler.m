//
//  DefaultTextToAgentResultHandler.m
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import "DefaultHealthAnalysisResultHandler.h"
#import "AiLogger.h"
#import "AiSDK/AiSDK.h"
//@import NativeLib
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
#import <HwBluetoothSDK/HwBluetoothSDK.h>
#import "NSDictionary+Ai.h"
@import NativeLib;

@interface DefaultHealthAnalysisResultHandler()

@property(nonatomic, assign) BOOL isCanceled;
@property(nonatomic, assign) NSInteger contentType;

@end

@implementation DefaultHealthAnalysisResultHandler

- (void)analysis:(HwHealthData *)healthData
{
    if (healthData == nil) {
        [self failed:AiErrorHealthDataNull msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorHealthDataNull]];
        return;
    }
    NSString *requestId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] analyzeDataWithRequestId:requestId wid:wid thirdUuid:nil data:[self healthDataToJsonData:healthData] onSuccess:^(NSString * _Nonnull requestId, NSString * _Nonnull content, SubscriptionInfo * _Nullable subscriptionInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf analysisCompleted:content code:0 errorMsg:nil];
        }
        
    } onFailure:^(NSString * _Nonnull requestId, ErrorCode * _Nonnull errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf analysisCompleted:nil code:[errorCode.code integerValue] errorMsg:errorCode.message];
        }
    }];
}

- (void)cancel {
    self.isCanceled = YES;
}

- (void)analysisCompleted:(NSString *)text
                     code:(NSInteger)code
                 errorMsg:(NSString *)errorMsg
{
    if (self.isCanceled) {
        [AiLogger i:@"DefaultHealthAnalysisResultHandler analysisCompleted 已取消"];
        return;
    }
    if (code != 0) {
        
        [self failed:code msg:errorMsg];
        return;
    }
    [AiLogger i:@"健康分析返回的内容：%@", text];
    if (text.length == 0) {
        [[HwBluetoothSDK sharedInstance] setAiMeetingResult:nil type:0 code:(int)AiErrorMeetingSummaryEmpty msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorMeetingSummaryEmpty]];
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
        [self failed:AiErrorHealthAnalysisResultNull msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorHealthAnalysisResultNull]];
        return;
    }
    
    NSDictionary *report = [jsonDict dictionaryForKey:@"HealthDataAnalysisReport"];
    if (report == nil) {
        [self failed:AiErrorHealthAnalysisResultNull msg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorHealthAnalysisResultNull]];
        return;
    }
    
    NSString *sleep = [self formatRTLText:[report stringForKey:@"Sleep"]];
    NSString *hr = [self formatRTLText:[report stringForKey:@"HeartRate"]];
    NSString *spo2 = [self formatRTLText:[report stringForKey:@"BloodOxygen"]];
    NSString *step = [self formatRTLText:[report stringForKey:@"Steps"]];
    NSString *bp = [self formatRTLText:[report stringForKey:@"BloodPressure"]];
    
    NSString *stress = [self formatRTLText:[report stringForKey:@"Stress"]];
    NSString *pai = [self formatRTLText:[report stringForKey:@"PAI"]];
    NSString *weight = [self formatRTLText:[report stringForKey:@"Weight"]];
    NSString *summary = [self formatRTLText:[report stringForKey:@"Conclusion"]];
    
    HwHealthAnalysisResult *result = [[HwHealthAnalysisResult alloc] init];
    result.step = step;
    result.sleep = sleep;
    result.spO2 = spo2;
    result.heartRate = hr;
    result.bp = bp;
    result.stress = stress;
    result.PAI = pai;
    result.weight = weight;
    if (!summary) {
        summary = @"";
    }
    result.summary = summary;
    [[HwBluetoothSDK sharedInstance] setAiHealthAnalysisResultWithResult:result code:0 msg:nil];
    [[AiSDK sharedInstance] healthAnalysisResultCompleted:result code:0 msg:nil];
}

- (void) failed:(NSInteger)code msg:(NSString *)msg
{
    if (self.isCanceled) {
        
        [AiLogger i:@"failed but is canceled"];
        return;
    }
    [AiLogger e:@"HealthAnalysisResult Failed: %@, %@", @(code), msg];
    [[HwBluetoothSDK sharedInstance] setAiHealthAnalysisResultWithResult:nil code:(int)code msg:msg];
    [[AiSDK sharedInstance] healthAnalysisResultCompleted:nil code:code msg:[[AiSDK sharedInstance] errorMsgWithCode:code]];
}

- (NSData *) healthDataToJsonData:(HwHealthData *)hd
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(1) forKey:@"analysisType"];
    NSMutableArray *data = [NSMutableArray array];
    for (HwHealthDailyData *daily in hd.dailyDataList) {
        NSMutableDictionary *day = [NSMutableDictionary dictionary];
        [day setObject:[self getDateStringBeforeDays:daily.day] forKey:@"day"];
        [day setObject:[NSString stringWithFormat:@"%@", @(hd.gender)] forKey:@"gender"];
        [day setObject:[NSString stringWithFormat:@"%@", @(hd.age)] forKey:@"age"];
        NSString *unit = @"kg";
        float factor = 1.0;
        if (hd.unit == 1) {
            unit = @"lb";
            factor = factor * 2.2;
        }
        [day setObject:[NSString stringWithFormat:@"%.1f%@", hd.weight / 10.0 * factor, unit] forKey:@"weight"];
        
        NSString *heightStr = [NSString stringWithFormat:@"%ldcm", (long)hd.height];

        if (hd.unit == 1) {
            double allIn = hd.height / 2.54;
            int ft = (int)floor(allIn / 12);
            int inh = (int)round(allIn - ft * 12);
            
            if (inh == 12) {
                ft++;
                inh = 0;
            }
            
            heightStr = [NSString stringWithFormat:@"%d ft %d in", ft, inh];
        }
        [day setObject:[NSString stringWithFormat:@"%@", heightStr] forKey:@"height"];
        
        if (daily.step > 0) {
            [day setObject:[NSString stringWithFormat:@"%@", @(daily.step)] forKey:@"step"];
        }
        if (daily.minHr > 0 && daily.maxHr > 0 && daily.avgHr > 0) {
            [day setObject:[NSString stringWithFormat:@"%@/%@/%@", @(daily.minHr), @(daily.maxHr), @(daily.avgHr)] forKey:@"hr"];
        }
        if (daily.minSpO2 > 0 && daily.maxSpO2 > 0 && daily.avgSpO2 > 0) {
            [day setObject:[NSString stringWithFormat:@"%@/%@/%@", @(daily.minSpO2), @(daily.maxSpO2), @(daily.avgSpO2)] forKey:@"sao2"];
        }
        if (daily.minStress > 0 && daily.maxStress > 0 && daily.avgStress > 0) {
            [day setObject:[NSString stringWithFormat:@"%@/%@/%@", @(daily.minStress), @(daily.maxStress), @(daily.avgStress)] forKey:@"stress"];
        }
        if (daily.sleep > 0) {
            [day setObject:[NSString stringWithFormat:@"%@", @(daily.sleep)] forKey:@"sleep"];
        }
        
        if (daily.minBP != nil) {
            [day setObject:[NSString stringWithFormat:@"%@/%@", @(daily.minBP.systolic), @(daily.minBP.diastolic)] forKey:@"pressureLow"];
        }
        if (daily.maxBP != nil) {
            [day setObject:[NSString stringWithFormat:@"%@/%@", @(daily.maxBP.systolic), @(daily.maxBP.diastolic)] forKey:@"pressureHigh"];
        }
        if (daily.avgBP != nil) {
            [day setObject:[NSString stringWithFormat:@"%@/%@", @(daily.avgBP.systolic), @(daily.avgBP.diastolic)] forKey:@"pressureAvg"];
        }
        if (daily.PAI > 0) {
            [day setObject:[NSString stringWithFormat:@"%@", @(daily.PAI)] forKey:@"pai"];
        }
        
        [data addObject:day];
    }
    [dict setObject:data forKey:@"data"];
    [AiLogger i:@"健康数据：%@", dict];
    // 转换为JSON Data
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];

    if (!jsonData) {
        NSLog(@"Error creating JSON: %@", error);
        jsonData = [NSData data];
    }
    return jsonData;
}

- (NSString *)getDateStringBeforeDays:(NSInteger)days {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-days]; // 负数表示过去的天数
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *targetDate = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    return [dateFormatter stringFromDate:targetDate];
}

- (NSString *)formatRTLText:(NSString *)text {
    if (text.length == 0) return text;
    BOOL containsArabic = NO;
    for (NSInteger i = 0; i < text.length; i++) {
        unichar c = [text characterAtIndex:i];
        if ((c >= 0x0600 && c <= 0x06FF) ||
            (c >= 0x0750 && c <= 0x077F) ||
            (c >= 0x08A0 && c <= 0x08FF) ||
            (c >= 0xFB50 && c <= 0xFDFF) ||
            (c >= 0xFE70 && c <= 0xFEFF)) {
            containsArabic = YES;
            break;
        }
    }
    if (containsArabic) {
        return [NSString stringWithFormat:@"\u2067%@\u2069", text];
    }
    return text;
}

@end

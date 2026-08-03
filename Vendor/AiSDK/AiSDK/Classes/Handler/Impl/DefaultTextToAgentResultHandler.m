//
//  DefaultTextToAgentResultHandler.m
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import "DefaultTextToAgentResultHandler.h"
#import "AiLogger.h"
#import "AiSDK/AiSDK.h"
#import <HwBluetoothSDK/HwBluetoothSDK.h>
#import "AiLocaleUtils.h"
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
@import NativeLib;

@interface DefaultTextToAgentResultHandler()

@property(nonatomic, assign) BOOL isCanceled;
@property(nonatomic, copy) NSString *chatId;

@end

@implementation DefaultTextToAgentResultHandler

- (void) getResultFromServer:(NSString *)text
                       agent:(NSInteger)agent
{
    if (self.isCanceled) {
        [AiLogger i:@"TextToAnswer 已取消"];
        return;
    }
    
    NSString *requestId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    NSString *locale = [[AiSDK sharedInstance] getDeviceInfo].currentLocale;
    NSString *agentCode = [self getAgentCode:agent];
    
    [AiLogger i:@"agent, requestId: %@, wid: %@, locale: %@, agentCode: %@, text: %@, agent: %@", requestId, wid, locale, agentCode, text, @(agent)];
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] chatWithRequestId:requestId wid:wid thirdUuid:nil code:agentCode inputType:@"text" contentId:nil textContent:text data:nil fileFormat:nil inputLanguage:locale outputLanguage:locale onSuccess:^(NSString * _Nonnull requestId, NSString * _Nonnull sendTextContent, NSString * _Nonnull outputType, NSString * _Nonnull contentId, NSString * _Nullable answerTextContent, NSString * _Nullable imgUrl, NSString * _Nullable thumbnail,SubscriptionInfo * _Nullable subscriptionInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf convertComplete:answerTextContent code:0 errorMsg:nil];
        }
        
    } onFailure:^(NSString * _Nonnull requestId, ErrorCode * _Nonnull errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf convertComplete:nil code:[errorCode.code integerValue] errorMsg:errorCode.message];
        }
    }];
}

- (void)cancel {
    self.isCanceled = YES;
}

- (void)convert:(nonnull NSString *)text
          agent:(NSInteger)agent
{
    [AiLogger i:@"AiAgen convert: %@, agent: %@", text, @(agent)];
    self.isCanceled = NO;
    [self getResultFromServer:text
                        agent:agent];
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
        [AiLogger e:@"Agent Failed: %@, %@", @(code), errorMsg];
    } else {
        [AiLogger i:@"%@", text];
    }
    [[AiSDK sharedInstance] textToAgentResultCompleted:text code:code msg:errorMsg];
}

- (void)changeType:(NSInteger)type
{
    
}

- (NSString *)getAgentCode:(NSInteger)type {
    // 健康饮食推荐
    if (type == 0x80) return @"XDBzTOFolLyhhCvAeE";
    // 运动健康小助手
    else if (type == 0x81) return @"UsyzpthMuNokQRytgu";
    // 血糖健康
    else if (type == 0x82) return @"biymPApKAGTQPsAoBc";
    // 心理咨询师
    else if (type == 0x83) return @"IVInqJTlidQVXKAkcq";
    // 私人厨师
    else if (type == 0x84) return @"LsSkOiJsvbrFjuqiHd";
    // 旅行规划达人
    else if (type == 0x85) return @"nyeSnuUkfpWBVcGTyj";
    // 食物热量查询
    else if (type == 0x86) return @"senRABnMnArMnEZuaz";
    // 跑步方法
    else if (type == 0x87) return @"UpepVbykjNYQVBqNzT";
    // 文案生成器
    else if (type == 0x88) return @"zVXktFZMAvlalligbC";
    // 占星师
    else if (type == 0x89) return @"wYLAcOcsoWHiSZILML";
    // BMI计算器
    else if (type == 0x8a) return @"FZKaAGPoefFdnousDk";
    // PAS销售文案
    else if (type == 0x8b) return @"JzLDruecsqNvzmFMJl";
    // 广告狂人
    else if (type == 0x8c) return @"WPhCzGnkWnhawbzEAQ";
    // 周报生成
    else if (type == 0x8d) return @"cJxTbxlkxXbNVwYcIj";
    // 星座运势
    else if (type == 0x8e) return @"NVLTuHpaktVDrzHNjd";
    // 今天吃什么
    else if (type == 0x8f) return @"FosXVLnFnluwcWdULH";
    // 说唱歌手
    else if (type == 0x90) return @"cfYoLrwhcYfVMJCnlK";
    // 讲笑话
    else if (type == 0x91) return @"AWPntHPOtHoYmgKZua";
    // 嘲讽大师
    else if (type == 0x92) return @"RbQEcfoRqeSrBuVpdo";
    // 答案之书/数字炸弹
    else if (type == 0x93 || type == 0x94) return @"ppffmXtKZNTUhJGATr";
    //色彩搭配师
    else if (type == 0x95) return @"YvwzrBEOfnidrSjmsA";
    //梦境解析师
    else if (type == 0x96) return @"ARxuWQxwessuYLLcnl";
    //养生专家
    else if (type == 0x97) return @"aWRSlxTjCThUNmoIzZ";
    //护肤小百科
    else if (type == 0x98) return @"CfgKzorLDEHERBHvds";
    //生活小妙招
    else if (type == 0x99) return @"HlXiEmslHHhhTCMpQO";
    //宠物健康顾问
    else if (type == 0x9a) return @"SDnfdQoOSloAaQRIjm";
    //翻译通
    else if (type == 0x9b) return @"eEDSCYpoiGDXjYuUTN";
    //天气预报
    else if (type == 0x9c) return @"ooezoBOLcgRICbTgqr";
    //高情商回复
    else if (type == 0x9d) return @"PztBdQFbqUoFLPFjEN";
    //MBTI 性格专家
    else if (type == 0x9e) return @"ARsXTWwOINhwjfathU";
    //职业规划
    else if (type == 0x9f) return @"aUeOHyCqTLDnWmRiOe";
    //数据分析
    else if (type == 0xa0) return @"FGeFDoqFDOTDQPNysY";
    //PPT 制作工具
    else if (type == 0xa1) return @"xMZgmrKPRmlOENCmtY";
    //PPT 电影解说
    else if (type == 0xa2) return @"OGALDMCSuOrXnjuXTu";
    //创意生成器
    else if (type == 0xa3) return @"puZwjgIixAlHRccluu";
    //每日金句
    else if (type == 0xa4) return @"RlvatycIdppnnHhTei";
    //AI 讲书
    else if (type == 0xa5) return @"LxNYYTDoPPAEpIKcHS";
    //SWOT 专家
    else if (type == 0xa6) return @"NnsvaRLcxwGFBMclDo";
    //记忆力训练
    else if (type == 0xa7) return @"jbcyboJmjlKZHYjGDr";
    //睡眠管家
    else if (type == 0xa8) return @"ulemqSdQyJDwoannEP";
    //聚会玩什么
    else if (type == 0xa9) return @"DvHPZdBkjRUsLDoJcQ";
    //礼物推荐
    else if (type == 0xaa) return @"evGapwHICNGnyGfpvH";
    //编程指导
    else if (type == 0xab) return @"MDgAiLWlbmIHwyHbXw";
    //花语大全
    else if (type == 0xac) return @"LKJxWZFTzQAuoRloiE";
    //个人色彩分析
    else if (type == 0xad) return @"ifhilzELbPoBEaBPBh";
    //手工达人
    else if (type == 0xae) return @"rwezcyCnsxBiJQbRCu";
    //育儿知识
    else if (type == 0xaf) return @"ebUeldvgWLciELeRFp";
    //世界之最
    else if (type == 0xb0) return @"nYjTFZOYqJaNDBcqHV";
    //书库
    else if (type == 0xb1) return @"WDuqZHomeXUmWpuqGz";
    //汽车之家
    else if (type == 0xb2) return @"NmzRCqQkDGlIqcXyOA";
    //地理知识
    else if (type == 0xb3) return @"jhQnMgzAYAzAKVveLq";
    //科学空间
    else if (type == 0xb4) return @"QOxmGfGqWJpeZAuTDG";
    //AI 扩文
    else if (type == 0xb5) return @"lXuqocIsdCclWLqsTW";
    //智商测试
    else if (type == 0xb6) return @"sDpASspVuBBBlvGiOl";
    //恋爱技巧
    else if (type == 0xb7) return @"gkZgzTcvOHPFpVgZio";
    //脑筋急转弯
    else if (type == 0xb8) return @"fjrKZbndzUSIoVfsgs";
    //思维训练
    else if (type == 0xb9) return @"gcacpzITaInBUhZdIh";
    //陪你聊天
    else if (type == 0xba) return @"esUemUtrEEOowiPjvP";
    //概率计算
    else if (type == 0xbb) return @"QrNkOAPTKIAHsCzxJQ";
    
    return @"";
}

@end

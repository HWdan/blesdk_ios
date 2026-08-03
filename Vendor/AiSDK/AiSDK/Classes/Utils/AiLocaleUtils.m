//
//  LocaleUtils.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiLocaleUtils.h"

@implementation AiLocaleUtils

+ (NSString *) fitLocale:(NSString *)lan
{
    if ([lan hasPrefix:@"zh"]) {
        if ([lan hasPrefix:@"zh-Hant"] || [lan hasPrefix:@"zh-TW"] || [lan hasPrefix:@"zh-HK"]) {
            return @"zh-TW";
        } else {
            return @"zh-CN";
        }
    } else if ([lan hasPrefix:@"en"]) {
        return @"en-US";
    } else if ([lan hasPrefix:@"de"]) {
        return @"de-DE";
    } else if ([lan hasPrefix:@"es"]) {
        return @"es-ES";
    } else if ([lan hasPrefix:@"fr"]) {
        return @"fr-FR";
    } else if ([lan hasPrefix:@"it"]) {
        return @"it-IT";
    } else if ([lan hasPrefix:@"hi"]) {
        return @"hi-IN";
    } else if ([lan hasPrefix:@"pl"]) {
        return @"pl-PL";
    } else if ([lan hasPrefix:@"ru"]) {
        return @"ru-RU";
    } else if ([lan hasPrefix:@"cs"]) {
        return @"cs-CZ";
    } else if ([lan hasPrefix:@"vi"]) {
        return @"vi-VN";
    } else if ([lan hasPrefix:@"id"]) {
        return @"id-ID";
    } else if ([lan hasPrefix:@"tr"]) {
        return @"tr-TR";
    } else if ([lan hasPrefix:@"pt"]) {
        return @"pt-PT";
    } else if ([lan hasPrefix:@"th"]) {
        return @"th-TH";
    } else if ([lan hasPrefix:@"ar"]) {
        return @"ar-AE";
    } else if ([lan hasPrefix:@"bn"]) {
        return @"bn-IN";
    } else if ([lan hasPrefix:@"he"]) {
        return @"he-IL";
    } else if ([lan hasPrefix:@"km"]) {
        return @"km-KH";
    } else if ([lan hasPrefix:@"fa"]) {
        return @"fa-IR";
    } else if ([lan hasPrefix:@"ja"]) {
        return @"ja-JP";
    } else if ([lan hasPrefix:@"ms"]) {
        return @"ms-MY";
    } else if ([lan hasPrefix:@"uk"]) {
        return @"uk-UA";
    } else if ([lan hasPrefix:@"nl"]) {
        return @"nl-NL";
    } else if ([lan hasPrefix:@"ko"]) {
        return @"ko-KR";
    } else if ([lan hasPrefix:@"sk"]) {
        return @"sk-SK";
    } else if ([lan hasPrefix:@"hu"]) {
        return @"hu-HU";
    } else if ([lan hasPrefix:@"ro"]) {
        return @"ro-RO";
    } else if ([lan hasPrefix:@"sl"]) {
        return @"sl-SI";
    } else if ([lan hasPrefix:@"bg"]) {
        return @"bg-BG";
    } else if ([lan hasPrefix:@"hr"]) {
        return @"hr-HR";
    } else if ([lan hasPrefix:@"el"]) {
        return @"el-GR";
    } else if ([lan hasPrefix:@"da"]) {
        return @"da-DK";
    } else if ([lan hasPrefix:@"hy"]) {
        return @"hy-AM";
    } else if ([lan hasPrefix:@"ga"]) {
        return @"ga-IE";
    } else if ([lan hasPrefix:@"ka"]) {
        return @"ka-GE";
    } else if ([lan hasPrefix:@"kk"]) {
        return @"kk-KZ";
    } else if ([lan hasPrefix:@"uz"]) {
        return @"uz-UZ";
    } else if ([lan hasPrefix:@"te"]) {
        return @"te-IN";
    } else if ([lan hasPrefix:@"ta"]) {
        return @"ta-IN";
    } else if ([lan hasPrefix:@"or"]) {
        return @"or-IN";
    } else if ([lan hasPrefix:@"mr"]) {
        return @"mr-IN";
    } else if ([lan hasPrefix:@"kn"]) {
        return @"kn-IN";
    } else if ([lan hasPrefix:@"ml"]) {
        return @"ml-IN";
    } else if ([lan hasPrefix:@"gu"]) {
        return @"gu-IN";
    }
    else {
        return @"en-US";
    }
}

@end

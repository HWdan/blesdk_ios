//
//  AuthModel.m
//  Pods
//
//  Created by HuaWo on 2024/12/23.
//

#import "AiDeviceInfo.h"
#import "AiLocaleUtils.h"

@implementation AiDeviceInfo

- (AiDeviceInfo *) init
{
    self = [super init];
    self.platformType = HWPlatformTypeSifli;
    self.supportedLocales = @[@"zh-CN",@"en-US",@"de-DE",@"es-ES",@"fr-FR",@"it-IT",@"hi-IN",@"pl-PL",@"ru-RU",@"cs-CZ",@"vi-VN",@"id-ID",@"tr-TR",@"pt-PT",@"th-TH",@"ar-AE",@"bn-IN",@"he-IL",@"km-KH",@"fa-IR",@"ja-JP",@"ms-MY",@"uk-UA",@"nl-NL",@"ko-KR", @"sk-SK", @"hu-HU", @"ro-RO", @"sl-SI", @"bg-BG", @"hr-HR", @"el-GR", @"da-DK", @"hy-AM", @"ga-IE", @"ka-GE", @"kk-KZ", @"uZ-UZ", @"te-IN", @"ta-IN", @"or-IN", @"mr-IN", @"kn-IN", @"ml-IN", @"gu-IN"];
    return self;
}
- (AiDeviceInfo *) initWithId:(NSString *)Id
                         type:(NSString *)type
                          mac:(NSString *)mac
                        width:(NSInteger)width
                       height:(NSInteger)height
                 cornerRadius:(NSInteger)cornerRadius
               thumbnailWidth:(NSInteger)thumbnailWidth
              thumbnailHeight:(NSInteger)thumbnailHeight
        thumbnailCornerRadius:(NSInteger)thumbnailCornerRadius
                currentLocale:(NSString *)currentLocale
{
    self = [super init];
    self.Id = Id;
    self.type = type;
    self.mac = mac;
    self.width = width;
    self.height = height;
    self.cornerRadius = cornerRadius;
    self.thumbnailWidth = thumbnailWidth;
    self.thumbnailHeight = thumbnailHeight;
    self.thumbnailCornerRadius = thumbnailCornerRadius;
    self.currentLocale = currentLocale;
    self.platformType = HWPlatformTypeSifli;
    self.supportedLocales = @[@"zh-CN",@"en-US",@"de-DE",@"es-ES",@"fr-FR",@"it-IT",@"hi-IN",@"pl-PL",@"ru-RU",@"cs-CZ",@"vi-VN",@"id-ID",@"tr-TR",@"pt-PT",@"th-TH",@"ar-AE",@"bn-IN",@"he-IL",@"km-KH",@"fa-IR",@"ja-JP",@"ms-MY",@"uk-UA",@"nl-NL",@"ko-KR", @"sk-SK", @"hu-HU", @"ro-RO", @"sl-SI", @"bg-BG", @"hr-HR", @"el-GR", @"da-DK", @"hy-AM", @"ga-IE", @"ka-GE", @"kk-KZ", @"uZ-UZ", @"te-IN", @"ta-IN", @"or-IN", @"mr-IN", @"kn-IN", @"ml-IN", @"gu-IN"];
    return self;
}

- (void) setCurrentLocale:(NSString *)currentLocale
{
    _currentLocale = [AiLocaleUtils fitLocale:currentLocale];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[AiDeviceInfo class]]) {
        return NO;
    }
    
    AiDeviceInfo *other = (AiDeviceInfo *)object;
    
    // 比较所有属性
    BOOL isEqual =
        ((self.Id == other.Id) || [self.Id isEqualToString:other.Id]) &&
        ((self.type == other.type) || [self.type isEqualToString:other.type]) &&
        ((self.mac == other.mac) || [self.mac isEqualToString:other.mac]) &&
        ((self.name == other.name) || [self.name isEqualToString:other.name]) &&
        (self.width == other.width) &&
        (self.height == other.height) &&
        (self.cornerRadius == other.cornerRadius) &&
        (self.thumbnailWidth == other.thumbnailWidth) &&
        (self.thumbnailHeight == other.thumbnailHeight) &&
        (self.thumbnailCornerRadius == other.thumbnailCornerRadius) &&
        (self.platformType == other.platformType) &&
        ((self.currentLocale == other.currentLocale) || [self.currentLocale isEqualToString:other.currentLocale]) &&
        ((self.supportedLocales == other.supportedLocales) || [self.supportedLocales isEqualToArray:other.supportedLocales]);
    
    return isEqual;
}

- (NSUInteger)hash {
    // 使用所有属性计算hash值
    return
        [self.Id hash] ^
        [self.type hash] ^
        [self.mac hash] ^
        [self.name hash] ^
        self.width ^
        self.height ^
        self.cornerRadius ^
        self.thumbnailWidth ^
        self.thumbnailHeight ^
        self.thumbnailCornerRadius ^
        self.platformType ^
        [self.currentLocale hash] ^
        [self.supportedLocales hash];
}

@end

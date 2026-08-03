//
//  SpUtils.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiSpUtils.h"
#import "AiStringUtils.h"

@implementation AiSpUtils

+ (NSString *) getUUID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uid = [userDefaults stringForKey:@"ai_uuid"];
    if ([AiStringUtils isEmpty:uid]) {
        NSUUID *uuid = [NSUUID UUID];
        uid = [uuid UUIDString];
        [userDefaults setObject:uid forKey:@"ai_uuid"];
        [userDefaults synchronize];
    }
    return uid;
}

@end

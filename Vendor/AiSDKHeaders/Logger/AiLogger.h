//
//  AiLogger.h
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import "ILog.h"

NS_ASSUME_NONNULL_BEGIN

@interface AiLogger : NSObject

+ (void) setLog:(id<ILog>)log;

+ (void) i:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (void) d:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (void) w:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (void) e:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

NS_ASSUME_NONNULL_END

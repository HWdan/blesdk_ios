//
//  AiLogger.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiLogger.h"
#import "AiDefaultLogger.h"

@implementation AiLogger

static id<ILog> myLog = nil;

+ (void) setLog:(id<ILog>)log
{
    myLog = log;
}

+ (void) i:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
{
    if (myLog == nil) {
        myLog = [[AiDefaultLogger alloc] init];
    }
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [myLog i:msg];
    }
}

+ (void) d:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
{
    if (myLog == nil) {
        myLog = [[AiDefaultLogger alloc] init];
    }
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [myLog d:msg];
    }
}

+ (void) w:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
{
    if (myLog == nil) {
        myLog = [[AiDefaultLogger alloc] init];
    }
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [myLog w:msg];
    }
}

+ (void) e:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
{
    if (myLog == nil) {
        myLog = [[AiDefaultLogger alloc] init];
    }
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [myLog e:msg];
    }
}

@end

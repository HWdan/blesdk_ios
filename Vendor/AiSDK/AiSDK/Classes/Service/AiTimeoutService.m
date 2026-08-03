//
//  TimeoutService.m
//  AFNetworking
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiTimeoutService.h"

@interface AiTimeoutService()

@property(nonatomic, assign) NSTimeInterval startTimeInterval;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) NSInteger seconds;

@end

@implementation AiTimeoutService

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeTimer];
}

- (void) startTimer:(NSInteger)seconds
{
    if (self.timer != nil) {
        [self.timer invalidate];
        _timer = nil;
    }
    self.seconds = seconds;
    if (seconds > 0) {
        self.startTimeInterval = [[NSDate date] timeIntervalSince1970];
        self.timer = [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(timeout) userInfo:nil repeats:NO];
        [self.timer setFireDate:[[NSDate date] dateByAddingTimeInterval:seconds]];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void) timeout
{
    [self.timer invalidate];
    _timer = nil;
}

- (void) removeTimer
{
    [self.timer invalidate];
    _timer = nil;
}

- (void) appDidBecomeActive
{
    if (self.timer && !self.timer.isValid) {
        [self timeout];
        return;
    }
    if (self.startTimeInterval > 0) {
        // 大于0 说明已经开始了
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970];
        if (delta - self.startTimeInterval >= self.seconds) {
            [self timeout];
            return;
        }
    }
}

@end

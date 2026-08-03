//
//  AiWatchfaceState.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiWatchfaceState.h"

@implementation AiWatchfaceState

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = AiWatchfaceProgressStateStartedRecording;
    }
    return self;
}

- (void) failed:(NSInteger)code
            msg:(NSString *)msg
{
    self.state = AiWatchfaceProgressStateFailed;
    self.code = code;
    self.msg = msg;
}

- (void) next
{
    switch (self.state) {
        case AiWatchfaceProgressStateStartedRecording:
            self.state = AiWatchfaceProgressStateStoppedRecording;
            break;
        case AiWatchfaceProgressStateStoppedRecording:
            self.state = AiWatchfaceProgressStateGetPreview;
            break;
        case AiWatchfaceProgressStateGetPreview:
            self.state = AiWatchfaceProgressStateSentPreview;
            break;
        case AiWatchfaceProgressStateSentPreview:
            self.state = AiWatchfaceProgressStateWaitingSendingWatchface;
            break;
        case AiWatchfaceProgressStateWaitingSendingWatchface:
            self.state = AiWatchfaceProgressStateSendingWatchface;
            break;
        case AiWatchfaceProgressStateSendingWatchface:
            self.state = AiWatchfaceProgressStateDone;
            break;
        default:
            break;
    }
}

@end

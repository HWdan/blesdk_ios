//
//  AiAgentState.m
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import "AiAgentState.h"

@implementation AiAgentState

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = AiAgentProgressStateStartedRecording;
    }
    return self;
}

- (void) failed:(NSInteger)code
            msg:(NSString *)msg
{
    self.state = AiAgentProgressStateFailed;
    self.code = code;
    self.msg = msg;
}

- (void) next
{
    switch (self.state) {
        case AiAgentProgressStateStartedRecording:
            self.state = AiAgentProgressStateStoppedRecording;
            break;
        case AiAgentProgressStateStoppedRecording:
            self.state = AiAgentProgressStateGettingAnswer;
            break;
        case AiAgentProgressStateGettingAnswer:
            self.state = AiAgentProgressStateSentAnswer;
            break;
        case AiAgentProgressStateSentAnswer:
            self.state = AiAgentProgressStateDone;
            break;
        default:
            break;
    }
}

@end

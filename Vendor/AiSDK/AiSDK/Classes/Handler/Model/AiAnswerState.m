//
//  AiAnswerState.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "AiAnswerState.h"

@implementation AiAnswerState

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = AiAnswerProgressStateStartedRecording;
    }
    return self;
}

- (void) failed:(NSInteger)code
            msg:(NSString *)msg
{
    self.state = AiAnswerProgressStateFailed;
    self.code = code;
    self.msg = msg;
}

- (void) next
{
    switch (self.state) {
        case AiAnswerProgressStateStartedRecording:
            self.state = AiAnswerProgressStateStoppedRecording;
            break;
        case AiAnswerProgressStateStoppedRecording:
            self.state = AiAnswerProgressStateGettingAnswer;
            break;
        case AiAnswerProgressStateGettingAnswer:
            self.state = AiAnswerProgressStateSentAnswer;
            break;
        case AiAnswerProgressStateSentAnswer:
            self.state = AiAnswerProgressStateDone;
            break;
        default:
            break;
    }
}

@end

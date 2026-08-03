//
//  AiTranslateState.m
//  AiSDK
//
//  Created by sujiang on 2025/3/25.
//

#import "AiTranslateState.h"

@implementation AiTranslateState

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = AiTranslateProgressStateStartedRecording;
    }
    return self;
}

- (void) failed:(NSInteger)code
            msg:(NSString *)msg
{
    self.state = AiTranslateProgressStateFailed;
    self.code = code;
    self.msg = msg;
}

- (void) next
{
    switch (self.state) {
        case AiTranslateProgressStateStartedRecording:
            self.state = AiTranslateProgressStateStoppedRecording;
            break;
        case AiTranslateProgressStateStoppedRecording:
            self.state = AiTranslateProgressStateGettingResult;
            break;
        case AiTranslateProgressStateGettingResult:
            self.state = AiTranslateProgressStateSentResult;
            break;
        case AiTranslateProgressStateSentResult:
            self.state = AiTranslateProgressStateDone;
            break;
        default:
            break;
    }
}

@end

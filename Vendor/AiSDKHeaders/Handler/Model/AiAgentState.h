//
//  AiAgentState.h
//  AiSDK
//
//  Created by HuaWo on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AiAgentProgressState)
{
    AiAgentProgressStateStartedRecording = 1,
    AiAgentProgressStateStoppedRecording,
    AiAgentProgressStateGettingAnswer,
    AiAgentProgressStateSentAnswer,
    AiAgentProgressStateDone,
    AiAgentProgressStateFailed
};

@interface AiAgentState : NSObject

@property(nonatomic, copy) NSString *voiceToTextResult;
@property(nonatomic, assign) AiAgentProgressState state;
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *msg;
@property(nonatomic, assign) NSInteger type;

- (void) failed:(NSInteger)code
            msg:(NSString *)msg;
- (void) next;

@end

NS_ASSUME_NONNULL_END

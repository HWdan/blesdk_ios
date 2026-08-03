//
//  AiAnswerState.h
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AiAnswerProgressState)
{
    AiAnswerProgressStateStartedRecording = 1,
    AiAnswerProgressStateStoppedRecording,
    AiAnswerProgressStateGettingAnswer,
    AiAnswerProgressStateSentAnswer,
    AiAnswerProgressStateDone,
    AiAnswerProgressStateFailed
};

@interface AiAnswerState : NSObject

@property(nonatomic, copy) NSString *voiceToTextResult;
@property(nonatomic, assign) AiAnswerProgressState state;
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *msg;

- (void) failed:(NSInteger)code
            msg:(NSString *)msg;
- (void) next;

@end

NS_ASSUME_NONNULL_END

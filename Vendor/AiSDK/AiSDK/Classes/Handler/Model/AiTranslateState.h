//
//  AiTranslateState.h
//  AiSDK
//
//  Created by sujiang on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AiTranslateProgressState)
{
    AiTranslateProgressStateStartedRecording = 1,
    AiTranslateProgressStateStoppedRecording,
    AiTranslateProgressStateGettingResult,
    AiTranslateProgressStateSentResult,
    AiTranslateProgressStateDone,
    AiTranslateProgressStateFailed
};

@interface AiTranslateState : NSObject

@property(nonatomic, copy) NSString *voiceToTextResult;
@property(nonatomic, assign) AiTranslateProgressState state;
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *msg;
@property(nonatomic, copy) NSString *result;

- (void) failed:(NSInteger)code
            msg:(NSString *)msg;
- (void) next;

@end

NS_ASSUME_NONNULL_END

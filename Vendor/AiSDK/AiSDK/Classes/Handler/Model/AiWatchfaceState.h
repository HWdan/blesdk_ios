//
//  AiWatchfaceState.h
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AiWatchfaceProgressState)
{
    AiWatchfaceProgressStateStartedRecording = 1,
    AiWatchfaceProgressStateStoppedRecording,
    AiWatchfaceProgressStateGetPreview,
    AiWatchfaceProgressStateSentPreview,
    AiWatchfaceProgressStateWaitingSendingWatchface,
    AiWatchfaceProgressStateSendingWatchface,
    AiWatchfaceProgressStateDone,
    AiWatchfaceProgressStateFailed,
};

@interface AiWatchfaceState : NSObject

@property(nonatomic, copy) NSString *voiceToTextResult;
@property(nonatomic, strong) UIImage *resultImage;
@property(nonatomic, assign) AiWatchfaceProgressState state;
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *msg;

- (void) failed:(NSInteger)code
            msg:(NSString *)msg;
- (void) next;

@end

NS_ASSUME_NONNULL_END

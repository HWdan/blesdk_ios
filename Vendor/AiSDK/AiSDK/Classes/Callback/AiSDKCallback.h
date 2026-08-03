//
//  AiSDKCallback.h
//  AiSDK
//
//  Reconstructed from AiSDK.m respondsToSelector: usage + Xcode index + Example HwMainVC.m
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SlifiCustomWatchface;
@class HwMeeting;
@class HwHealthAnalysisResult;

@protocol AiSDKCallback <NSObject>

@optional

- (void)aiStartRecording:(NSInteger)type;
- (void)aiStopRecording:(NSInteger)type;

- (void)aiVoiceToTextDone:(NSString *_Nullable)text type:(NSInteger)type;

- (void)aiAnswerDone:(NSString *_Nullable)result
                code:(NSInteger)code
            errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiTranslateDone:(NSString *_Nullable)result
                   code:(NSInteger)code
               errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiAgentDone:(NSString *_Nullable)result
               code:(NSInteger)code
           errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiMeetingDone:(HwMeeting *_Nullable)meeting
        voiceFilePath:(NSString *_Nullable)voiceFilePath
          meetingTime:(NSDate *_Nullable)meetingTime
                 code:(NSInteger)code
             errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiHealthAnalysisDone:(HwHealthAnalysisResult *_Nullable)healthAnalysis
                        code:(NSInteger)code
                    errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiImageDone:(UIImage *_Nullable)image
               code:(NSInteger)code
           errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiPreviewDone:(UIImage *_Nullable)image
                 code:(NSInteger)code
             errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiStartSendingPreview;
- (void)aiSentPreview:(NSInteger)code errorMsg:(NSString *_Nullable)errorMsg;

- (void)aiStartSendingWatchface;
- (void)aiSendingWatchfaceProgressUpdated:(float)progress;
- (void)aiSentWatchface:(SlifiCustomWatchface *_Nullable)watchface
                   code:(NSInteger)code
               errorMsg:(NSString *_Nullable)errorMsg;

/// 注意：原 API 拼写为 Langugae（非 Language）
- (void)aiDidEnterTranslateWithInputLangugae:(NSInteger)inputLanguage
                             outputLanguage:(NSInteger)outputLanguage;

- (void)aiDidRequestAiTranslateResult;

@end

NS_ASSUME_NONNULL_END

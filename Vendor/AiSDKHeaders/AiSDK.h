//
//  AiSDK.h
//  AiSDK
//
//  Reconstructed from AiSDK.m + Example + Xcode index symbols (Esafenet plaintext unavailable).
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AiSDKCallback.h"
#import "AiDeviceInfo.h"
#import "AiOrderInfo.h"
#import "AiExerciseAnalyzeModel.h"
#import "ILog.h"
#import "IAiWatchfaceNameProvider.h"
#import "IAiErrorMessageProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class SlifiCustomWatchface;
@class HwMeeting;
@class HwHealthAnalysisResult;

/// AI 绘图风格（默认 AiStyleAnime = 3，与 UserDefaults 默认 @"3" 一致）
typedef NS_ENUM(NSInteger, AiStyle) {
    AiStyleInkWater = 1,
    AiStyleCyberpunk,
    AiStyleAnime,
    AiStyleFolding,
    AiStyleKnitted,
    AiStyleFlatAnimation,
    AiStyle3DCartoon,
    AiStyleLego,
    AiStylePencilDrawing,
};

/// AI / 艾闪错误码。AFlash 原始 code 与本地错误混用；本地码避开 1–14/18–20/50/61/1101–1104。
typedef NS_ENUM(NSInteger, AiError) {
    AiErrorAnswerFailed = 80001,
    AiErrorRecordVoiceIsEmpty = 80002,
    AiErrorAgentNotExists = 80003,
    AiErrorMeetingSummaryEmpty = 80004,
    AiErrorMeetingParseJsonError = 80005,
    AiErrorHealthDataNull = 80006,
    AiErrorHealthAnalysisResultNull = 80007,
    AiErrorPhoneStorageFull = 80008,
    AiErrorRecordToTextEmpty = 80009,
    AiErrorScaleAndCropImageFailed = 80010,
    AiErrorImageToBinFailed = 80011,
    AiErrorMakeQjsWatchfaceFailed = 80012,
    AiErrorModelError = 80013,
    AiErrorDeviceInfoIsNull = 80014,
    AiErrorVoiceToTextEmpty = 80015,

    AiErrorAFlashParamsError = 5,
    AiErrorInsufficientFrequency = 8,
    AiErrorDailyInsufficientFreeTimes = 9,
    AiErrorInsufficientFreeTimes = 10,
    AiErrorContentRestrictions = 12,
    AiErrorUnsupportedLanguages = 13,
    AiErrorAFlashUserNotAuth = 61,
    AiErrorAFlashServerError = 50,
    AiErrorAFlashRequestTimeout = 1101,
    AiErrorCannotConnectToAFlash = 1102,
    AiErrorAFlashUnknownError = 1103,
    AiErrorAFlashDomainError = 1105,
    AiErrorAFlashVersionError = 1106,
    AiErrorAFlashConfigError = 1107,
};

@interface AiSDK : NSObject

@property (nonatomic, assign) AiStyle aiStyle;
@property (nonatomic, assign) BOOL isAiWatchfaceWorking;
@property (nonatomic, weak, nullable) id<AiSDKCallback> callback;

+ (instancetype)sharedInstance;

- (void)setDeviceInfo:(AiDeviceInfo *)deviceInfo;
- (AiDeviceInfo *_Nullable)getDeviceInfo;
- (void)cleanDeviceInfo;

- (void)startWorking;
- (void)stopWorking;

- (void)voiceDialogStarted;

- (void)voiceToTextCompleted:(NSString *_Nullable)result
                        code:(NSInteger)code
                         msg:(NSString *_Nullable)msg;

- (void)textToAnswerCompleted:(NSString *_Nullable)result
                         code:(NSInteger)code
                          msg:(NSString *_Nullable)msg;

- (void)textToImageCompleted:(UIImage *_Nullable)image
                        code:(NSInteger)code
                         msg:(NSString *_Nullable)msg;

- (void)textToImageCompleted_JL:(UIImage *_Nullable)image
                           code:(NSInteger)code
                            msg:(NSString *_Nullable)msg;

- (void)imageToPreviewCompleted:(UIImage *_Nullable)image
                           code:(NSInteger)code
                            msg:(NSString *_Nullable)msg;

- (void)previewSyncToDeviceCompleted:(NSInteger)code
                                 msg:(NSString *_Nullable)msg;

- (void)watchfaceSyncProgressUpdated:(CGFloat)progress;

- (void)watchfaceSyncToDeviceCompleted:(SlifiCustomWatchface *_Nullable)watchface
                                  code:(NSInteger)code
                                   msg:(NSString *_Nullable)msg;

- (void)textToAgentResultCompleted:(NSString *_Nullable)result
                              code:(NSInteger)code
                               msg:(NSString *_Nullable)msg;

- (void)textToTranslateResultCompleted:(NSString *_Nullable)result
                                  code:(NSInteger)code
                                   msg:(NSString *_Nullable)msg;

- (void)textToVoiceCompleted:(NSString *_Nullable)filePath
                        code:(NSInteger)code
                         msg:(NSString *_Nullable)msg;

- (void)meetingResultCompleted:(HwMeeting *_Nullable)meeting
                 voiceFilePath:(NSString *_Nullable)voiceFilePath
                   meetingTime:(NSDate *_Nullable)meetingTime
                          code:(NSInteger)code
                           msg:(NSString *_Nullable)msg;

- (void)healthAnalysisResultCompleted:(HwHealthAnalysisResult *_Nullable)healthAnalysis
                                 code:(NSInteger)code
                                  msg:(NSString *_Nullable)msg;

- (NSString *)errorMsgWithCode:(NSInteger)code;

- (void)setLogger:(id<ILog>)logger;

- (NSString *)generateAiWatchfaceName;
- (void)setAiWatchfaceNameProvider:(id<IAiWatchfaceNameProvider>)nameProvider;
- (void)setAiErrorMessageProvider:(id<IAiErrorMessageProvider>)messageProvider;

- (void)getOrderInfoWithMac:(NSString *)mac
                   callback:(void(^)(AiOrderInfo *_Nullable orderInfo, NSString *_Nullable errorMsg))callback;

- (void)getAiExerciseAnalyzeWithType:(int)type
                                data:(NSDictionary *)data
                            callback:(void(^)(AiExerciseAnalyzeModel *_Nullable exerciseAnalyzeModel, NSString *_Nullable errorMsg))callback;

@end

NS_ASSUME_NONNULL_END

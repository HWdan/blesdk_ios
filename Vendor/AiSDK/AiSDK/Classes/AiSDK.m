//
//  AiSDK.m
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import "AiSDK.h"
#import "HwBluetoothSDK/HwBluetoothSDK.h"
#import "WatchfaceSDK/WatchfaceSDK-Swift.h"
//#import <NativeLib/NativeLib.h>
//#import <NativeLib/NativeLib-Swift.h>
@import NativeLib;
#import "AiLocaleUtils.h"
#import "IInitSDK.h"
#import "IVoiceToText.h"
#import "ITextToAnswerTextHandler.h"
#import "ITextToImageHandler.h"
#import "IImageToPreviewHandler.h"
#import "IImageToWatchfaceHandler.h"
#import "ITextToAgentResultHandler.h"
#import "ITextToTranslateResultHandler.h"
#import "IHealthAnalysisResultHandler.h"
#import "IMeetingResultHandler.h"
#import "ITextToVoiceHandler.h"
#import "AiDefaultInitSDK.h"
#import "AiAnswerState.h"
#import "AiWatchfaceState.h"
#import "AiAgentState.h"
#import "AiTranslateState.h"
#import "AiLogger.h"
#import "DefaultVoiceToTextHandler.h"
#import "DefaultTextToAnswerTextHandler.h"
#import "DefaultTextToImageHandler.h"
#import "DefaultImageToPreviewHandler.h"
#import "JLImageToPreviewHandler.h"
#import "AiDevicePlatformStrategyFactory.h"
#import "DefaultAiWatchfaceNameProvider.h"
#import "AiDefaultErrorMessageProvider.h"

#import "DefaultTextToAgentResultHandler.h"
#import "DefaultTextToTranslateResultHandler.h"
#import "DefaultMeetingResultHandler.h"
#import "DefaultHealthAnalysisResultHandler.h"
#import "DefaultTextToVoiceHandler.h"

@interface AiSDK()

@property(nonatomic, copy) HwAiAnswerEnterOrExitCallback aiAnswerEnterOrExitCallback;
@property(nonatomic, copy) HwAiWatchfaceEnterOrExitCallback aiWatchfaceEnterOrExitCallback;
@property(nonatomic, copy) HwGenerateAiWatchfacePreviewRequestCallback aiGenerateWatchfacePreviewCallback;
@property(nonatomic, copy) HwGenerateAiWatchfaceRequestCallback aiGenerateWatchfaceCallback;
@property(nonatomic, copy) HwAiAnswerHandlerCallback aiAnswerHandlerCallback;

@property(nonatomic, copy) HwAiEventCallback aiEventCallback;
@property(nonatomic, copy) HwAiSettingUpdateCallback aiSettingUpdateCallback;

@property(nonatomic, copy) HwGenerateAiMeetingRequestCallback aiGenerateMeetingRequestCallback;
@property(nonatomic, copy) HwGenerateAiTranslateRequestCallback aiGenerateTranslateRequestCallback;
@property(nonatomic, copy) HwGenerateAiHealthAnalysisRequestCallback aiGenerateHealthAnalysisRequestCallback;
@property(nonatomic, copy) HwGenerateAiAgentResultRequestCallback aiGenerateAgentResultRequestCallback;

@property(nonatomic, copy) HwAppStatusRequestCallback appStatusRequestCallback;
@property(nonatomic, copy) HwStartRecordingCallback startRecordingCallback;
@property(nonatomic, copy) HwEndRecordingCallback endRecordingCallback;
@property(nonatomic, copy) HwAiSubscriptionInfoRequestCallback subscriptionInfoRequestCallback;
@property(nonatomic, copy) HwAiVoicePlayRequestCallback voicePlayRequestCallback;

@property(nonatomic, copy) HwBluetoothConnectionStateChangedCallback connectionStateChangedCallback;

@property(nonatomic, strong) AiDeviceInfo *deviceInfo;
@property(nonatomic, assign) BOOL working;

//@property(nonatomic, strong) id<IInitSDK> initSDKHandler;
@property(nonatomic, strong) id<IInitSDK> sdkInitHandler;
@property(nonatomic, strong) id<IVoiceToText> voiceToTextHandler;
@property(nonatomic, strong) id<ITextToAnswerTextHandler> textToAnswerHandler;
@property(nonatomic, strong) id<ITextToImageHandler> textToImageHandler;
@property(nonatomic, strong) id<IImageToPreviewHandler> imageToPreviewHandler;
@property(nonatomic, strong) id<IImageToPreviewHandler> jlImageToPreviewHandler;
@property(nonatomic, strong) id<IImageToWatchfaceHandler> imageToWatchfaceHandler;
@property(nonatomic, strong) id<IAiWatchfaceNameProvider> watchfaceNameProvider;
@property(nonatomic, strong) id<ITextToVoiceHandler> textToVoiceHandler;

@property(nonatomic, strong) id<ITextToAgentResultHandler> textToAgentResultHandler;
@property(nonatomic, strong) id<ITextToTranslateResultHandler> textToTranslateResultHandler;
@property(nonatomic, strong) id<IMeetingResultHandler> meetingResultHandler;
@property(nonatomic, strong) id<IHealthAnalysisResultHandler> healthAnalysisResultHandler;

@property(nonatomic, strong) id<IAiErrorMessageProvider> errorMessageProvider;

@property(nonatomic, strong) AiAnswerState *answerState;
@property(nonatomic, strong) AiWatchfaceState *watchfaceState;
@property(nonatomic, strong) AiAgentState *agentState;
@property(nonatomic, strong) AiTranslateState *translateState;
@property(nonatomic, assign) NSInteger type;

@property(nonatomic, copy) NSString *lastResultText;
@property(nonatomic, strong) AiDefaultErrorMessageProvider *defaultErrorMessageProvider;

@end

@implementation AiSDK

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static AiSDK *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AiSDK alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    [self stopWorking];
    _sdkInitHandler = nil;
    _voiceToTextHandler = nil;
    _textToAnswerHandler = nil;
    _textToImageHandler = nil;
    _imageToPreviewHandler = nil;
    _jlImageToPreviewHandler = nil;
    _imageToWatchfaceHandler = nil;
    
    [_textToAgentResultHandler cancel];
    _textToAgentResultHandler = nil;
    
    [_textToTranslateResultHandler cancel];
    _textToTranslateResultHandler = nil;
    
    [_meetingResultHandler cancel];
    _meetingResultHandler = nil;
    
    [_healthAnalysisResultHandler cancel];
    _healthAnalysisResultHandler = nil;
    
    [_textToVoiceHandler cancel];
    _textToVoiceHandler = nil;
    
    _appStatusRequestCallback = nil;
    _aiAnswerEnterOrExitCallback = nil;
    _aiWatchfaceEnterOrExitCallback = nil;
    _aiGenerateWatchfacePreviewCallback = nil;
    _aiGenerateWatchfaceCallback = nil;
    _startRecordingCallback = nil;
    _endRecordingCallback = nil;
    _callback = nil;
    _watchfaceNameProvider = nil;
    _connectionStateChangedCallback = nil;
    _aiAnswerHandlerCallback = nil;
    _subscriptionInfoRequestCallback = nil;
    _voicePlayRequestCallback = nil;
    
    _aiEventCallback = nil;
    _aiSettingUpdateCallback = nil;
    _aiGenerateMeetingRequestCallback = nil;
    _aiGenerateTranslateRequestCallback = nil;
    _aiGenerateHealthAnalysisRequestCallback = nil;
    _aiGenerateAgentResultRequestCallback = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.working = false;        
        // 添加APP状态的通知监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[SifliWatchfaceSDK getInstance] initSDK];
        
        self.sdkInitHandler = [[AiDefaultInitSDK alloc] init];
        self.watchfaceNameProvider = [[DefaultAiWatchfaceNameProvider alloc] init];
        self.defaultErrorMessageProvider = [[AiDefaultErrorMessageProvider alloc] init];
    }
    return self;
}

- (void) setDeviceInfo:(AiDeviceInfo *)deviceInfo
{
    if (!deviceInfo) {
        return;
    }
    // 开始初始化SDK
    if (_deviceInfo &&
        [_deviceInfo.Id isEqual:deviceInfo.Id] &&
        [_deviceInfo.currentLocale isEqual:deviceInfo.currentLocale] &&
        _deviceInfo.platformType == deviceInfo.platformType) {
        [AiLogger i:@"两次设备信息一致，直接return"];
        return;
    }
    _deviceInfo = deviceInfo;
    self.defaultErrorMessageProvider.deviceLanguageCode = [HwLanguageUtil getLanguageWithLocale:deviceInfo.currentLocale];
    [self.sdkInitHandler initSDK:_deviceInfo];
}

- (AiDeviceInfo *) getDeviceInfo
{
    return _deviceInfo;
}

- (id<AiDevicePlatformStrategy>)devicePlatformStrategy
{
    return [AiDevicePlatformStrategyFactory strategyForPlatformType:self.deviceInfo.platformType];
}

- (void) cleanDeviceInfo
{
    _deviceInfo = nil;
}

- (void) startWorking
{
    [AiLogger i:@"start working"];
    if (self.working) {
        return;
    }
    
    self.working = true;
    [self addDeviceEventListeners];
    [[HwBluetoothSDK sharedInstance] setAppStatus:HwAppStateForeground];
    
    self.voiceToTextHandler = [[DefaultVoiceToTextHandler alloc] init];
    [self.voiceToTextHandler prepare];
}

- (void) stopWorking
{
    [AiLogger i:@"stop working"];
    self.working = false;
    [self removeDeviceEventListeners];
}

//// ======  methods
- (void) voiceDialogStarted
{
    if (self.answerState != nil && self.answerState.state == AiAnswerProgressStateStartedRecording) {
        [[HwBluetoothSDK sharedInstance] setStartRecordingResultWithCode:0 msg:nil];
        if ([self.callback respondsToSelector:@selector(aiStartRecording:)]) {
            [self.callback aiStartRecording:1];
        }
        return;
    } else {
        [AiLogger e:@"answerState:%@", @(self.answerState.state)];
    }
    
    if (self.watchfaceState != nil && self.watchfaceState.state == AiWatchfaceProgressStateStartedRecording) {
        [[HwBluetoothSDK sharedInstance] setStartRecordingResultWithCode:0 msg:nil];
        if ([self.callback respondsToSelector:@selector(aiStartRecording:)]) {
            [self.callback aiStartRecording:0];
        }
        return;
    } else {
        [AiLogger e:@"watchfaceState:%@", @(self.watchfaceState.state)];
    }
    
    if (self.translateState != nil && self.translateState.state == AiTranslateProgressStateStartedRecording) {
        [[HwBluetoothSDK sharedInstance] setStartRecordingResultWithCode:0 msg:nil];
        if ([self.callback respondsToSelector:@selector(aiStartRecording:)]) {
            [self.callback aiStartRecording:0];
        }
        return;
    } else {
        [AiLogger e:@"translateState:%@", @(self.translateState.state)];
    }
    
    if (self.agentState != nil && self.agentState.state == AiAgentProgressStateStartedRecording) {
        [[HwBluetoothSDK sharedInstance] setStartRecordingResultWithCode:0 msg:nil];
        if ([self.callback respondsToSelector:@selector(aiStartRecording:)]) {
            [self.callback aiStartRecording:0];
        }
        return;
    } else {
        [AiLogger e:@"agentState:%@", @(self.agentState.state)];
    }
}
- (void) voiceToTextCompleted:(NSString *)result
                         code:(NSInteger)code
                          msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiVoiceToTextDone:type:)]) {
        [self.callback aiVoiceToTextDone:result type:self.type];
    }
    [AiLogger i:@"voiceToTextCompleted: %@, code: %@, msg: %@, type: %@", result, @(code), msg, @(self.type)];
    if (self.type == HwAiTypeQnI)
    {
        if (self.answerState == nil) {
            return;
        }
        if (self.answerState.state == AiAnswerProgressStateStartedRecording) {
            if (code != 0) {
                [self.answerState failed:code msg:[self errorMsgWithCode:code]];
                return;
            }
        }
    }
    else if (self.type == HwAiTypeWatchface)
    {
        if (self.watchfaceState == nil) {
            return;
        }
        if (self.watchfaceState.state == AiWatchfaceProgressStateStartedRecording) {
            if (code != 0) {
                [self.watchfaceState failed:code msg:[self errorMsgWithCode:code]];
            }
        }
    }
    else if (self.type == HwAiTypeTranslate) {
        if (self.translateState == nil) {
            [AiLogger i:@"translateState is null???"];
            return;
        }
        if (self.translateState.state == AiTranslateProgressStateStartedRecording) {
            if (code != 0) {
                [self.translateState failed:code msg:[self errorMsgWithCode:code]];
            }
        }
    }
    else if (self.type == HwAiTypeHealthAnalysis) {
        
    }
    else if (self.type == HwAiTypeMeeting) {
        
    } else {
        // 智能体
        if (self.agentState == nil) {
            return;
        }
        if (self.agentState.state == AiAgentProgressStateStartedRecording) {
            if (code != 0) {
                [self.agentState failed:code msg:[self errorMsgWithCode:code]];
            }
        }
    }
    
    [[HwBluetoothSDK sharedInstance] setRecordToTextResultWithResult:result code:(int) code msg:[self errorMsgWithCode:code]];
    
    if (code == 0)
    {
        if (self.type == HwAiTypeQnI)
        {
            [AiLogger i:@"Get answer for text: %@", result];
            if (self.textToAnswerHandler == nil) {
                self.textToAnswerHandler = [[DefaultTextToAnswerTextHandler alloc] init];
            }
            [self.textToAnswerHandler convert:result];
            self.answerState.voiceToTextResult = result;
            [self.answerState next];
        }
        else if (self.type == HwAiTypeWatchface)
        {
            self.watchfaceState.voiceToTextResult = result;
            [self.watchfaceState next];
        }
        else if (self.type == HwAiTypeTranslate)
        {
            [AiLogger i:@"直接进行翻译了...: %@", result];
            if (!self.textToTranslateResultHandler) {
                [AiLogger i:@"textToTranslateResultHandler is nil，创建"];
                self.textToTranslateResultHandler = [[DefaultTextToTranslateResultHandler alloc] init];
            }
            [self.textToTranslateResultHandler convert:result];
            self.translateState.voiceToTextResult = result;
            [self.translateState next];
        }
        else if (self.type == HwAiTypeHealthAnalysis)
        {
            
        }
        else if (self.type == HwAiTypeMeeting)
        {
            
        }
        else
        {
            if (!self.textToAgentResultHandler) {
                [AiLogger i:@"textToAgentResultHandler is nil, creating"];
                self.textToAgentResultHandler = [[DefaultTextToAgentResultHandler alloc] init];
            }
            [self.textToAgentResultHandler convert:result agent:self.type];
            // agent
            self.agentState.voiceToTextResult = result;
            [self.agentState next];
        }
    }
}

- (void) textToAnswerCompleted:(NSString *)result
                          code:(NSInteger)code
                           msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiAnswerDone:code:errorMsg:)]) {
        [self.callback aiAnswerDone:result code:code errorMsg:msg];
    }
    
    [[HwBluetoothSDK sharedInstance] setAiAnswerResultWithResult:result code:(int) code msg:[self errorMsgWithCode:code]];
    [self.answerState next];
    self.lastResultText = result;
}

- (void) textToTranslateResultCompleted:(NSString *)result
                                   code:(NSInteger)code
                                    msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiTranslateDone:code:errorMsg:)]) {
        [self.callback aiTranslateDone:result code:code errorMsg:msg];
    }
    self.lastResultText = result;
    [[HwBluetoothSDK sharedInstance] setAiTranslateResultWithResult:result code:(int) code msg:[self errorMsgWithCode:code]];
    [self.translateState next];
}

- (void) textToVoiceCompleted:(NSString *_Nullable)filePath
                         code:(NSInteger)code
                          msg:(NSString *_Nullable)msg
{
    [[HwBluetoothSDK sharedInstance] setAiVoicePlayResultWithCode:code msg:msg];
    if (self.deviceInfo != nil && self.deviceInfo.Id.length > 0) {
        [self sendDeviceSubscriptionInfo:self.deviceInfo.Id];
    }
}

- (void) textToAgentResultCompleted:(NSString *)result
                               code:(NSInteger)code
                                msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiAgentDone:code:errorMsg:)]) {
        [self.callback aiAgentDone:result code:code errorMsg:msg];
    }
    self.lastResultText = result;
    [[HwBluetoothSDK sharedInstance] setAiAgentResultWithResult:result code:(int) code msg:[self errorMsgWithCode:code]];
    [self.agentState next];
}

- (void) meetingResultCompleted:(HwMeeting *_Nullable)meeting
                  voiceFilePath:(NSString *_Nullable)voiceFilePath
                    meetingTime:(NSDate *)meetingTime
                            code:(NSInteger)code
                            msg:(NSString *_Nullable)msg
{
    if ([self.callback respondsToSelector:@selector(aiMeetingDone:voiceFilePath:meetingTime:code:errorMsg:)]) {
        [self.callback aiMeetingDone:meeting voiceFilePath:voiceFilePath meetingTime:meetingTime code:code errorMsg:msg];
        if (code != 0) {
            [AiLogger i:@"回调失败：%@, msg: %@", @(code), msg];
        } else {
            [AiLogger i:@"回调成功, title: %@, content: %@, summary: %@, voice path: %@", meeting.title, meeting.content, meeting.summary, voiceFilePath];
        }
        
    } else {
        [AiLogger i:@"回调为空，或者回调没有实现方法"];
    }
}

- (void) healthAnalysisResultCompleted:(HwHealthAnalysisResult *_Nullable)healthAnalysis
                                code:(NSInteger)code
                                msg:(NSString *_Nullable)msg
{
    if ([self.callback respondsToSelector:@selector(aiHealthAnalysisDone:code:errorMsg:)]) {
        [self.callback aiHealthAnalysisDone:healthAnalysis code:code errorMsg:msg];
    }
}

- (void) textToImageCompleted:(UIImage *)image
                         code:(NSInteger)code
                          msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiImageDone:code:errorMsg:)]) {
        [self.callback aiImageDone:image code:code errorMsg:msg];
    }
    
    if (code != 0) {
        [AiLogger e:@"textToImageCompleted failed: code: %@, msg: %@", @(code), msg];
        [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int)code msg:[self errorMsgWithCode:code]];
        [self cancelAll];
        return;
    } else {
        if (image == nil || self.watchfaceState == nil) {
            [AiLogger e:@"textToImageCompleted failed: image is nil or watchfaceState is nil"];
            [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int)AiErrorModelError msg:[self errorMsgWithCode:AiErrorModelError]];
            [self cancelAll];
            return;
        }
        [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:@"JW_AIPreview1" code:0 msg:nil];
    }
    
    self.imageToPreviewHandler = [[DefaultImageToPreviewHandler alloc] initWithImage:image deviceInfo:self.deviceInfo needSyncToDevice:YES];
    [self.watchfaceState next];
    self.watchfaceState.resultImage = image;
    [self.imageToPreviewHandler start];
    if ([self.callback respondsToSelector:@selector(aiStartSendingPreview)]) {
        [self.callback aiStartSendingPreview];
    }
}

- (void) textToImageCompleted_JL:(UIImage *)image
                         code:(NSInteger)code
                          msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiImageDone:code:errorMsg:)]) {
        [self.callback aiImageDone:image code:code errorMsg:msg];
    }
    
    if (code != 0) {
        [AiLogger e:@"textToImageCompleted failed: code: %@, msg: %@", @(code), msg];
        [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int)code msg:[self errorMsgWithCode:code]];
        [self cancelAll];
        return;
    } else {
        if (image == nil || self.watchfaceState == nil) {
            [AiLogger e:@"textToImageCompleted failed: image is nil or watchfaceState is nil"];
            [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int)AiErrorModelError msg:[self errorMsgWithCode:AiErrorModelError]];
            [self cancelAll];
            return;
        }
    }
    
    self.jlImageToPreviewHandler = [[JLImageToPreviewHandler alloc] initWithImage:image deviceInfo:self.deviceInfo needSyncToDevice:YES];
    [self.watchfaceState next];
    self.watchfaceState.resultImage = image;
    [self.jlImageToPreviewHandler start];
    if ([self.callback respondsToSelector:@selector(aiStartSendingPreview)]) {
        [self.callback aiStartSendingPreview];
    }
}

- (void) imageToPreviewCompleted:(UIImage *)image
                            code:(NSInteger)code
                             msg:(NSString *)msg
{
    if ([self.callback respondsToSelector:@selector(aiPreviewDone:code:errorMsg:)]) {
        [self.callback aiPreviewDone:image code:code errorMsg:msg];
    }
    
    if (code != 0) {
        [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int)code msg:msg];
        [self cancelAll];
        self.isAiWatchfaceWorking = NO;
        return;
    }
}
- (void) previewSyncToDeviceCompleted:(NSInteger)code
                                  msg:(NSString *)msg
{
    
    if ([self.callback respondsToSelector:@selector(aiSentPreview:errorMsg:)]) {
        [self.callback aiSentPreview:code errorMsg:msg];
    }
    
    if (code != 0) {
        [AiLogger e:@"previewSyncToDeviceCompleted failed: code: %@, msg: %@", @(code), msg];
        [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int)code msg:msg];
        [self cancelAll];
        self.isAiWatchfaceWorking = NO;
        return;
    }
    [AiLogger i:@"previewSyncToDeviceCompleted"];
    [self.watchfaceState next];
}
- (void) watchfaceSyncProgressUpdated:(CGFloat)progress
{
    if ([self.callback respondsToSelector:@selector(aiSendingWatchfaceProgressUpdated:)]) {
        [self.callback aiSendingWatchfaceProgressUpdated:progress];
    }
}
- (void) watchfaceSyncToDeviceCompleted:(SlifiCustomWatchface *)watchface
                                   code:(NSInteger)code
                                    msg:(NSString *)msg
{
    self.isAiWatchfaceWorking = NO;
    if ([self.callback respondsToSelector:@selector(aiSentWatchface:code:errorMsg:)]) {
        [self.callback aiSentWatchface:watchface code:code errorMsg:msg];
    }
    
    if (code != 0) {
        [[HwBluetoothSDK sharedInstance] setAiWatchfaceResultWithWatchfaceName:nil code:(int)code msg:msg];
        [self cancelAll];
        return;
    }
    [[HwBluetoothSDK sharedInstance] setAiWatchfaceResultWithWatchfaceName:watchface.name code:0 msg:nil];
    [self.watchfaceState next];
    if (code != 0) {
        [AiLogger e:@"安装表盘失败：code: %@, msg: %@", @(code), msg];
    } else {
        [AiLogger i:@"安装表盘成功：%@", watchface.name];
    }
}

- (NSString *) errorMsgWithCode:(NSInteger)code
{
    NSString *msg = [self.defaultErrorMessageProvider messageForCode:code];
    if (!msg && [self.errorMessageProvider respondsToSelector:@selector(messageForCode:)]) {
        msg = [self.errorMessageProvider messageForCode:code];
    }
    if (!msg) {
        msg = @"Failed";
    }
    return msg;
}

- (void) addDeviceEventListeners
{
    
    [AiLogger i:@"addDeviceEventListeners -- start"];
    
    __weak AiSDK *weakSelf = self;
    _aiAnswerEnterOrExitCallback = ^(BOOL enter) {
        if (weakSelf.working) {
            if (enter) {
                [weakSelf didEnterAiAnswer];
            } else {
                [weakSelf didExistAiAnswer];
            }
        }
    };
    _aiWatchfaceEnterOrExitCallback = ^(BOOL enter) {
        if (weakSelf.working) {
            if (enter) {
                [weakSelf didEnterAiWatchface];
            } else {
                [weakSelf didExistAiWatchface];
            }
        }
    };
    _aiGenerateWatchfacePreviewCallback = ^(NSInteger type) {
        if (weakSelf.working) {
            [weakSelf didRequestWatchfacePreview];
        }
    };
    _aiGenerateWatchfaceCallback = ^(NSInteger type) {
        if (weakSelf.working) {
            [weakSelf didRequestWatchface];
        }
    };
    _appStatusRequestCallback = ^{
        [weakSelf didRequestAppStatus];
    };
    _startRecordingCallback = ^(int type, int language, int outputLanguage) {
        [AiLogger i:@"startRecording, type: %@, language: %@", @(type), @(language)];
        if (weakSelf.working) {
            [weakSelf didRequestStartRecording:type language:language outputLanguage:outputLanguage];
        }
//        if (language >= 0) {
//            weakSelf.defaultErrorMessageProvider.deviceLanguageCode = language;
//        }
    };
    _endRecordingCallback = ^(int type) {
        if (weakSelf.working) {
            [weakSelf didRequestEndRecording:type];
        }
    };
    _connectionStateChangedCallback = ^(HwBluetoothConnectionState state) {
        if (state == HwBluetoothConnectionStateConnected) {
            [weakSelf connectionStateChanged:YES];
        } else {
            [weakSelf connectionStateChanged:NO];
        }
    };
    
    _aiAnswerHandlerCallback = ^(BOOL play) {
        [weakSelf didHandleAnswer:play];
    };
    
    _aiEventCallback = ^(BOOL enter, HwAiType type, int param1, int param2, int param3) {
        /**
         if (weakSelf.working) {
             if (enter) {
                 [weakSelf didEnterAiWatchface];
             } else {
                 [weakSelf didExistAiWatchface];
             }
         }
         */
        if (enter)
        {
            if (type == HwAiTypeWatchface) {
                
            }
            else if (type == HwAiTypeQnI) {
                
            }
            else if (type == HwAiTypeTranslate) {
                [weakSelf didEnterAiTranslateWithInputLanguage:param1 outputLanguage:param2];
            }
            else if (type == HwAiTypeMeeting) {
                [weakSelf didEnterAiMeeting];
            }
            else if (type == HwAiTypeAgent) {
                [weakSelf didEnterAiAgent:param1];
            }
            else if (type == HwAiTypeHealthAnalysis) {
                [weakSelf didEnterAiHealthAnalysis];
            }
        }
        else
        {
            if (type == HwAiTypeWatchface) {
                
            }
            else if (type == HwAiTypeQnI) {
                
            }
            else if (type == HwAiTypeTranslate) {
                [weakSelf didExitAiTranslate];
            }
            else if (type == HwAiTypeMeeting) {
                [weakSelf didExitAiMeeting];
            }
            else if (type == HwAiTypeAgent) {
                [weakSelf didExitAiAgent];
            }
            else if (type == HwAiTypeHealthAnalysis) {
                [weakSelf didExitAiHealthAnalysis];
            }
        }
    };
    _aiSettingUpdateCallback = ^(HwAiType type, int param1, int param2, int param3) {
        [weakSelf didUpdateAiSettings:type param1:param1 param2:param2 param3:param3];
    };
    _aiGenerateMeetingRequestCallback = ^(NSDate *meetingTime, NSInteger contentType) {
        [weakSelf didRequestMeetingResult:contentType
                              meetingTime:meetingTime];
    };
    _aiGenerateTranslateRequestCallback = ^{
        [weakSelf didRequestTranslateResult];
    };
    _aiGenerateHealthAnalysisRequestCallback = ^(HwHealthData *healthData) {
        [weakSelf didRequestHealthAnalysis:healthData];
    };
    _aiGenerateAgentResultRequestCallback = ^{
        [weakSelf didRequestAgentResult];
    };
    _voicePlayRequestCallback = ^(NSInteger state, NSInteger lan, NSInteger volumn, NSString *crc) {
        [weakSelf voicePlayRequestHandleWithState:state language:lan volumn:volumn crc:crc];
    };
    _subscriptionInfoRequestCallback = ^(NSString *mac) {
        [weakSelf subscriptionInfoRequestHandle:mac];
    };
    
    [[HwBluetoothSDK sharedInstance] addAiAnswerEnterOrExitListener:_aiAnswerEnterOrExitCallback];
    
    [[HwBluetoothSDK sharedInstance] addAiWatchfaceEnterOrExitListener:_aiWatchfaceEnterOrExitCallback];
    [[HwBluetoothSDK sharedInstance] addGenerateAiWatchfacePreviewRequestListener:_aiGenerateWatchfacePreviewCallback];
    [[HwBluetoothSDK sharedInstance] addGenerateAiWatchfaceRequestListener:_aiGenerateWatchfaceCallback];
    [[HwBluetoothSDK sharedInstance] addAppStatusRequestListener:_appStatusRequestCallback];
    [[HwBluetoothSDK sharedInstance] addStartRecordingRequestListener:_startRecordingCallback];
    [[HwBluetoothSDK sharedInstance] addEndRecordingRequestListener:_endRecordingCallback];
    [[HwBluetoothSDK sharedInstance] addBluetoothConnectionStateChangedCallback:_connectionStateChangedCallback];
    
    [[HwBluetoothSDK sharedInstance] addAiAnswerHandlerListener:_aiAnswerHandlerCallback];
    [[HwBluetoothSDK sharedInstance] addAiSettingUpdateListener:_aiSettingUpdateCallback];
    [[HwBluetoothSDK sharedInstance] addGenerateAiTranslateRequestListener:_aiGenerateTranslateRequestCallback];
    [[HwBluetoothSDK sharedInstance] addGenerateAiHealthAnalysisRequestListener:_aiGenerateHealthAnalysisRequestCallback];
    [[HwBluetoothSDK sharedInstance] addGenerateAiAgentResultRequestListener:_aiGenerateAgentResultRequestCallback];
    [[HwBluetoothSDK sharedInstance] addGenerateAiMeetingRequestListener:_aiGenerateMeetingRequestCallback];
    [[HwBluetoothSDK sharedInstance] addAiEventListener:_aiEventCallback];
    [[HwBluetoothSDK sharedInstance] addAiVoicePlayRequestListener:_voicePlayRequestCallback];
    [[HwBluetoothSDK sharedInstance] addAiSubscriptionInfoRequestListener:_subscriptionInfoRequestCallback];
    
    [AiLogger i:@"addDeviceEventListeners -- end"];
}

- (void) removeDeviceEventListeners
{
    [[HwBluetoothSDK sharedInstance] removeAiAnswerEnterOrExitListener:_aiAnswerEnterOrExitCallback];
    [[HwBluetoothSDK sharedInstance] removeAiWatchfaceEnterOrExitListener:_aiWatchfaceEnterOrExitCallback];
    [[HwBluetoothSDK sharedInstance] removeGenerateAiWatchfacePreviewRequestListener:_aiGenerateWatchfacePreviewCallback];
    [[HwBluetoothSDK sharedInstance] removeGenerateAiWatchfaceRequestListener:_aiGenerateWatchfaceCallback];
    [[HwBluetoothSDK sharedInstance] removeAppStatusRequestListener:_appStatusRequestCallback];
    [[HwBluetoothSDK sharedInstance] removeStartRecordingRequestListener:_startRecordingCallback];
    [[HwBluetoothSDK sharedInstance] removeEndRecordingRequestListener:_endRecordingCallback];
    [[HwBluetoothSDK sharedInstance] removeBluetoothConnectionStateChangedCallback:_connectionStateChangedCallback];
    
    [[HwBluetoothSDK sharedInstance] removeAiAnswerHandlerListener:_aiAnswerHandlerCallback];
    [[HwBluetoothSDK sharedInstance] removeAiSettingUpdateListener:_aiSettingUpdateCallback];
    [[HwBluetoothSDK sharedInstance] removeGenerateAiTranslateRequestListener:_aiGenerateTranslateRequestCallback];
    [[HwBluetoothSDK sharedInstance] removeGenerateAiHealthAnalysisRequestListener:_aiGenerateHealthAnalysisRequestCallback];
    [[HwBluetoothSDK sharedInstance] removeGenerateAiAgentResultRequestListener:_aiGenerateAgentResultRequestCallback];
    [[HwBluetoothSDK sharedInstance] removeGenerateAiMeetingRequestListener:_aiGenerateMeetingRequestCallback];
    [[HwBluetoothSDK sharedInstance] removeAiEventListener:_aiEventCallback];
    [[HwBluetoothSDK sharedInstance] removeAiSubscriptionInfoRequestListener:_subscriptionInfoRequestCallback];
    [[HwBluetoothSDK sharedInstance] removeAiVoicePlayRequestListener:_voicePlayRequestCallback];
    
    _aiAnswerEnterOrExitCallback = nil;
    _aiWatchfaceEnterOrExitCallback = nil;
    _aiGenerateWatchfacePreviewCallback = nil;
    _aiGenerateWatchfaceCallback = nil;
    _appStatusRequestCallback = nil;
    _startRecordingCallback = nil;
    _endRecordingCallback = nil;
    _aiEventCallback = nil;
    
    _aiAnswerHandlerCallback = nil;
    _aiSettingUpdateCallback = nil;
    _aiGenerateTranslateRequestCallback = nil;
    _aiGenerateHealthAnalysisRequestCallback = nil;
    _aiGenerateAgentResultRequestCallback = nil;
    _aiGenerateMeetingRequestCallback = nil;
    
    _voicePlayRequestCallback = nil;
    _subscriptionInfoRequestCallback = nil;
}

- (void) appDidEnterBackground:(NSNotification *)noti
{
    [[HwBluetoothSDK sharedInstance] setAppStatus:HwAppStateForeground];
}

- (void) appDidEnterForeground:(NSNotification *)noti
{
    [[HwBluetoothSDK sharedInstance] setAppStatus:HwAppStateForeground];
}

- (void) didEnterAiAnswer
{
    [AiLogger i:@"didEnterAiAnswer"];
}

- (void) didExistAiAnswer
{
    [AiLogger i:@"didExistAiAnswer"];
    [self cancelAll];
}

- (void) didRequestAiAnswer
{
    [AiLogger i:@"didRequestAiAnswer"];
    if (self.answerState == nil)
    {
        [[HwBluetoothSDK sharedInstance] setAiAnswerResultWithResult:nil code:AiErrorAnswerFailed msg:[self errorMsgWithCode:AiErrorAnswerFailed]];
        [self cancelAll];
    }
    else
    {
        if (self.answerState.state == AiAnswerProgressStateFailed) {
            [[HwBluetoothSDK sharedInstance] setAiAnswerResultWithResult:nil code:(int) self.answerState.code msg:[self errorMsgWithCode:self.answerState.code]];
            [self cancelAll];
        } else {
            [self.answerState next];
        }
    }
}

- (void) didHandleAnswer:(BOOL)play
{
    [AiLogger i:@"didHandleAnswer: %@", @(play)];
    if (self.textToVoiceHandler) {
        [self.textToVoiceHandler stop];
    }
    if (!play) {
        [self.textToVoiceHandler stop];
        return;
    }
    if (!self.lastResultText) {
        [AiLogger i:@"lastResultText is null"];
        return;
    }
    self.textToVoiceHandler = [[DefaultTextToVoiceHandler alloc] init];
    [self.textToVoiceHandler handle:self.lastResultText play:play];
}

- (void) didEnterAiWatchface
{
    [AiLogger i:@"didEnterAiWatchface"];
    self.isAiWatchfaceWorking = YES;
}

- (void) didExistAiWatchface
{
    [AiLogger i:@"didExistAiWatchface"];
    self.isAiWatchfaceWorking = NO;
    [self cancelAll];
}

- (void) didEnterAiTranslateWithInputLanguage:(NSInteger)inputLanguage
                               outputLanguage:(NSInteger)outputLanguage
{
    [AiLogger i:@"didEnterAiTranslate"];
    if ([self.callback respondsToSelector:@selector(didEnterAiTranslateWithInputLanguage:outputLanguage:)]) {
        [self.callback aiDidEnterTranslateWithInputLangugae:inputLanguage outputLanguage:outputLanguage];
    }
    if (!self.textToTranslateResultHandler) {
        self.textToTranslateResultHandler = [[DefaultTextToTranslateResultHandler alloc] init];
    }
    [self.textToTranslateResultHandler changeInputLanguage:inputLanguage outputLanguage:outputLanguage];
}

- (void) didEnterAiAgent:(NSInteger)type
{
    [AiLogger i:@"didEnterAiAgent"];
    if (!self.textToAgentResultHandler) {
        self.textToAgentResultHandler = [[DefaultTextToAgentResultHandler alloc] init];
    }
}

- (void) didEnterAiHealthAnalysis
{
    [AiLogger i:@"didEnterAiHealthAnalysis"];
    if (self.agentState == nil)
    {
        
        
        [self cancelAll];
    }
    else
    {
        if (self.agentState.state == AiAgentProgressStateFailed) {
            [[HwBluetoothSDK sharedInstance] setAiTranslateResultWithResult:nil code:(int) self.agentState.code msg:[self errorMsgWithCode:self.agentState.code]];
            [self cancelAll];
        } else {
            [self.agentState next];
        }
    }
}

- (void) didEnterAiMeeting
{
    [AiLogger i:@"didEnterAiMeeting"];
}

- (void) didExitAiTranslate
{
    [AiLogger i:@"didExitAiTranslate"];
    [self cancelAll];
}

- (void) didExitAiAgent
{
    [AiLogger i:@"didExitAiAgent"];
    [self cancelAll];
}

- (void) didExitAiHealthAnalysis
{
    [AiLogger i:@"didExitAiHealthAnalysis"];
    [self cancelAll];
}

- (void) didExitAiMeeting
{
    [AiLogger i:@"didExitAiMeeting"];
    [self cancelAll];
}

- (void) didUpdateAiSettings:(HwAiType)type param1:(int) param1 param2:(int) param2 param3:(int) param3
{
    [AiLogger i:@"didUpdateAiSettings: %@, param1: %@, param2: %@", @(type), @(param1), @(param2)];
    if (type == HwAiTypeTranslate) {
        if (!self.textToTranslateResultHandler) {
            self.textToTranslateResultHandler = [[DefaultTextToTranslateResultHandler alloc] init];
        }
        [self.textToTranslateResultHandler changeInputLanguage:param1 outputLanguage:param2];
    }
    else if (type == HwAiTypeAgent) {
        if (!self.textToAgentResultHandler) {
            self.textToAgentResultHandler = [[DefaultTextToAgentResultHandler alloc] init];
        }
        [self.textToAgentResultHandler changeType:param1];
    }
}

- (void) didRequestAgentResult
{
    [AiLogger i:@"didRequestAgentResult"];
}

- (void) didRequestTranslateResult
{
    [AiLogger i:@"didRequestTranslateResult"];
    if ([self.callback respondsToSelector:@selector(aiDidRequestAiTranslateResult)]) {
        [self.callback aiDidRequestAiTranslateResult];
    }
    
    if (self.translateState == nil)
    {
        [[HwBluetoothSDK sharedInstance] setAiTranslateResultWithResult:nil code:AiErrorAnswerFailed msg:[self errorMsgWithCode:AiErrorAnswerFailed]];
        [self cancelAll];
    }
    else
    {
        if (self.translateState.state == AiTranslateProgressStateFailed) {
            [[HwBluetoothSDK sharedInstance] setAiTranslateResultWithResult:nil code:(int) self.translateState.code msg:[self errorMsgWithCode:self.translateState.code]];
            [self cancelAll];
        } else {
            [self.translateState next];
        }
    }
}

- (void) didRequestMeetingResult:(NSInteger)contentType
                     meetingTime:(NSDate *)meetingTime
{
    [AiLogger i:@"didRequestMeetingResult"];
    self.meetingResultHandler = [[DefaultMeetingResultHandler alloc] init];
    [self.meetingResultHandler convert:contentType time:meetingTime];
}

- (void) didRequestHealthAnalysis:(HwHealthData *)healthData
{
    [AiLogger i:@"didRequestHealthAnalysis"];
    self.healthAnalysisResultHandler = [[DefaultHealthAnalysisResultHandler alloc] init];
    [self.healthAnalysisResultHandler analysis:healthData];
}


- (void) connectionStateChanged:(BOOL)connected
{
    if (!connected) {
        self.isAiWatchfaceWorking = NO;
    }
}

- (void) didRequestWatchfacePreview
{
    [AiLogger i:@"didRequestWatchfacePreview"];
    if (self.watchfaceState == nil) {
        [AiLogger e:@"didRequestWatchfacePreview watchfaceState is nil"];
        return;
    }
    if (self.watchfaceState.state == AiWatchfaceProgressStateFailed) {
        [[HwBluetoothSDK sharedInstance] setAiWatchfacePreviewWithPreviewName:nil code:(int) self.watchfaceState.code msg:[self errorMsgWithCode:self.watchfaceState.code]];
        [self cancelAll];
        [AiLogger e:@"didRequestWatchfacePreview state failed"];
        return;
    }
    if (self.textToImageHandler == nil) {
        self.textToImageHandler = [[DefaultTextToImageHandler alloc] init];
    }
    self.isAiWatchfaceWorking = YES;
    [self.textToImageHandler convert:self.watchfaceState.voiceToTextResult];
    [self.watchfaceState next];
}

- (void) didRequestWatchface
{
    [AiLogger i:@"didRequestWatchface"];
    if (self.watchfaceState == nil || self.watchfaceState.resultImage == nil) {
        [[HwBluetoothSDK sharedInstance] setAiWatchfaceResultWithWatchfaceName:nil code:(int) self.watchfaceState.code msg:[self errorMsgWithCode:self.watchfaceState.code]];
        [AiLogger i:@"watchfaceState == %@ ，resultImage == %@",self.watchfaceState,self.watchfaceState.resultImage];
        return;
    }
    [self.watchfaceState next];
    if ([self.callback respondsToSelector:@selector(aiStartSendingWatchface)]) {
        [self.callback aiStartSendingWatchface];
    }
    self.isAiWatchfaceWorking = YES;
    
    self.imageToWatchfaceHandler = [self.devicePlatformStrategy createWatchfaceHandlerWithImage:self.watchfaceState.resultImage
                                                                                      deviceInfo:self.deviceInfo];
    [self.imageToWatchfaceHandler start];
}

- (void) didRequestAppStatus
{
    [AiLogger i:@"didRequestAppStatus"];
    [[HwBluetoothSDK sharedInstance] setAppStatus:HwAppStateForeground];
}

- (void) didRequestStartRecording:(NSInteger)type
                         language:(NSInteger)langugage
                   outputLanguage:(NSInteger)outputLanguage
{
    [self cancelAll];
    self.type = type;
    self.lastResultText = nil;
    [AiLogger i:@"didRequestStartRecording: %@, langugage: %@, outputLanguage: %@", @(type), @(langugage), @(outputLanguage)];
    // 0: watchface, 1: qa
    if (type == HwAiTypeQnI) {
        self.answerState = [[AiAnswerState alloc] init];
    }
    else if (type == HwAiTypeWatchface) {
        self.watchfaceState = [[AiWatchfaceState alloc] init];
        self.isAiWatchfaceWorking = YES;
    }
    else if (type == HwAiTypeTranslate) {
        self.translateState = [[AiTranslateState alloc] init];
        if (outputLanguage >= 0) {
            if (!self.textToTranslateResultHandler) {
                self.textToTranslateResultHandler = [[DefaultTextToTranslateResultHandler alloc] init];
            }
            [self.textToTranslateResultHandler changeInputLanguage:langugage outputLanguage:outputLanguage];
        }
    }
    else {
        self.agentState = [[AiAgentState alloc] init];
        self.agentState.type = type;
    }
    [self.voiceToTextHandler startRecording:langugage
                                     aiType:type];
}

- (void) didRequestEndRecording:(NSInteger)type
{
    [[HwBluetoothSDK sharedInstance] setEndRecordingResultWithCode:0 msg:nil];
    [self.voiceToTextHandler stopRecording];
    [AiLogger i:@"didRequestEndRecording, answerState.code: %@,watchfaceState.code:%@, answerState.msg: %@,watchfaceState.msg:%@,type: %@", @(self.answerState.code),@(self.watchfaceState.code), self.answerState.msg,self.watchfaceState.msg, @(self.type)];
    if (self.type == 1) {
        if (self.answerState == nil) {
            return;
        }
        if (self.answerState.state == AiAnswerProgressStateFailed) {
            [AiLogger i:@"<<AiAnswerProgressStateFailed, 设置setRecordToTextResultWithResult给固件了>>"];
            [[HwBluetoothSDK sharedInstance] setRecordToTextResultWithResult:nil code:(int)self.answerState.code msg:self.answerState.msg];
            [self cancelAll];
            return;
        }
        [self.answerState next];
    } else {
        if (self.watchfaceState == nil) {
            return;
        }
        if (self.watchfaceState.state == AiWatchfaceProgressStateFailed) {
            [AiLogger i:@"<<AiWatchfaceProgressStateFailed, 设置setRecordToTextResultWithResult给固件了>>"];
            [[HwBluetoothSDK sharedInstance] setRecordToTextResultWithResult:nil code:(int)self.watchfaceState.code msg:self.watchfaceState.msg];
            [self cancelAll];
            return;
        }
        [self.watchfaceState next];
    }
}

- (void) getOrderInfoWithMac:(NSString *)mac
                    callback:(void(^)(AiOrderInfo *orderInfo, NSString *_Nullable errorMsg))callback
{
    NSString *Id = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    Id = [Id lowercaseStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] queryAllOrderWithWid:Id pageNum:0 pageSize:10 onSuccess:^(NSArray<Order *> * _Nonnull list) {
        Order *fisrt = [list firstObject];
        if (!fisrt) {
            callback(nil, @"Failed!");
            return;
        }
        
        AiOrderInfo *orderInfo = [[AiOrderInfo alloc] init];
        orderInfo.Id = fisrt.orderId;
        orderInfo.price = fisrt.orderPrice;
        orderInfo.orderStatus = fisrt.orderStatus;
        orderInfo.orderCurrency = fisrt.orderCurrency;
        orderInfo.orderNum = fisrt.orderNum;
        orderInfo.orderType = fisrt.orderType;
        orderInfo.startTime = fisrt.startTime;
        orderInfo.endTime = fisrt.endTime;
        callback(orderInfo, nil);
        
    } onFailure:^(ErrorCode *error) {
        NSString *msg = [weakSelf errorMsgWithCode:[error.code integerValue]];
        callback(nil, msg);
    }];
}

- (void) getOrderInfo2WithMac:(NSString *)mac
                     callback:(void(^)(AiOrderInfo *orderInfo, NSString *_Nullable errorMsg))callback
{
    NSString *Id = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    Id = [Id lowercaseStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] queryProductsSubscriptionWithWid:Id onSuccess:^(NSArray<ProductsSubscription *> *list) {
        if (list.count == 0) {
            [AiLogger i:@"没有订单信息"];
            // callback(nil, @"No Subscription Products");
            AiOrderInfo *orderInfo = [[AiOrderInfo alloc] init];
            callback(orderInfo, nil);
            return;
        }
        
        NSInteger leftCount = 0;
        NSInteger type = 0;
        NSTimeInterval endTime = 0;
        
        for (int i = 0; i < list.count; i ++) {
            ProductsSubscription *sub = [list objectAtIndex:i];
            
            if (sub.productSource != 1) {
                [AiLogger i:@"不是用户订阅"];
                continue;
            }
            
            type = sub.productType;
            if (sub.remainingNum >= 0) {
                leftCount += sub.remainingNum;
                endTime = MAX(endTime, sub.expireAt);
            } else {
                leftCount = -1;
                endTime = sub.expireAt;
                break;
            }
        }
        
        AiOrderInfo *orderInfo = [[AiOrderInfo alloc] init];
        orderInfo.orderNum = leftCount;
        orderInfo.orderType = type;
        orderInfo.endTime = endTime;
        callback(orderInfo, nil);
    } onFailure:^(ErrorCode *error) {
        NSString *msg = [weakSelf errorMsgWithCode:[error.code integerValue]];
        callback(nil, msg);
    }];
}

- (void) getAiExerciseAnalyzeWithType:(int)type
                                 data:(NSDictionary *)data
                             callback:(void(^)(AiExerciseAnalyzeModel *exerciseAnalyzeModel, NSString *_Nullable errorMsg))callback
{
    NSString *requestId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])];
    NSString *wid = [[AiSDK sharedInstance] getDeviceInfo].Id;
    
    __weak typeof(self) weakSelf = self;
    [[AFlash shared] analyzeDataWithRequestId:requestId wid:wid thirdUuid:nil data:[self exerciseAnalyzeDataToJsonData:data] onSuccess:^(NSString * _Nonnull requestId, NSString * _Nonnull content, SubscriptionInfo * _Nullable subscriptionInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            AiExerciseAnalyzeModel *exerciseAnalyzeModel = [self analysisCompleted:content];
            callback(exerciseAnalyzeModel, nil);
        }
        
    } onFailure:^(NSString * _Nonnull requestId, ErrorCode * _Nonnull errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSString *msg = [weakSelf errorMsgWithCode:[errorCode.code integerValue]];
            callback(nil, msg);
        }
    }];
}

- (AiExerciseAnalyzeModel *)analysisCompleted:(NSString *)text
{
    [AiLogger i:@"运动分析返回的内容：%@", text];
    if (text.length == 0) {

        [AiLogger i:@"运动分析返回的内容：是空的"];
        return nil;
    }
    
    NSString *jsonStr = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [AiLogger i:@"替换无用字符之后的结果：%@", jsonStr];
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:kNilOptions
                                                      error:&error];

    NSDictionary *jsonDict = (NSDictionary *) jsonObject;
    if (jsonDict == nil) {
        [AiLogger i:@"转为jsonDict之后的结果：%@", jsonStr];
        return nil;;
    }
    
    NSArray *trainingHighlights = jsonDict[@"trainingHighlights"];
    NSDictionary *trainingHighlightsDict = trainingHighlights.firstObject;
    AiExerciseAnalyzeModel *result = [[AiExerciseAnalyzeModel alloc] init];
    result.trainingHighlights = trainingHighlightsDict[@"content"];

    NSArray *basicAnalysis = jsonDict[@"basicAnalysis"];
    for (int i = 0; i < basicAnalysis.count; i++) {
        NSDictionary *basicDict = basicAnalysis[i];
        if ([basicDict[@"category"] isEqualToString:@"exerciseDuration"]) {
            result.exerciseDurationAnalysis = basicDict[@"analysis"];
        } else if ([basicDict[@"category"] isEqualToString:@"calorieConsumption"]) {
            result.calorieConsumptionAnalysis = basicDict[@"analysis"];
        } else if ([basicDict[@"category"] isEqualToString:@"heartRate"]) {
            result.heartRateAnalysis = basicDict[@"analysis"];
        } else if ([basicDict[@"category"] isEqualToString:@"trainingEffect"]) {
            result.trainingEffectAnalysis = basicDict[@"analysis"];
        } else if ([basicDict[@"category"] isEqualToString:@"recoveryTime"]) {
            result.recoveryTimeAnalysis = basicDict[@"analysis"];
        }
    }
    
    NSArray *summarySuggestions = jsonDict[@"summarySuggestions"];
    NSDictionary *summarySuggestionsDict = trainingHighlights.firstObject;
    result.summarySuggestions = summarySuggestionsDict[@"content"];
    
    return result;
}

- (NSData *) exerciseAnalyzeDataToJsonData:(NSDictionary *)day
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(38) forKey:@"analysisType"];
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:day];
    [dict setObject:data forKey:@"data"];
    [AiLogger i:@"运动数据：%@", dict];
    // 转换为JSON Data
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];

    if (!jsonData) {
        NSLog(@"Error creating JSON: %@", error);
        jsonData = [NSData data];
    }
    return jsonData;
}

- (void) cancelAll
{
    [self.voiceToTextHandler cancel];
    [self.textToImageHandler cancel];
    [self.imageToPreviewHandler cancel];
    [self.jlImageToPreviewHandler cancel];
    [self.imageToWatchfaceHandler cancel];
    [self.textToAgentResultHandler cancel];
    [self.textToTranslateResultHandler cancel];
    [self.meetingResultHandler cancel];
    [self.healthAnalysisResultHandler cancel];
    [self.textToVoiceHandler cancel];
}

- (void) setLogger:(id<ILog>)logger
{
    [AiLogger setLog:logger];
}

- (AiStyle) aiStyle
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *styleStr = [userDefaults stringForKey:@"ai_sdk_style"];
    if (styleStr == nil) {
        // 动漫，默认
        styleStr = @"3";
        [userDefaults setObject:styleStr forKey:@"ai_sdk_style"];
        [userDefaults synchronize];
    }
    return [styleStr integerValue];
}

- (void) setAiStyle:(AiStyle)aiStyle
{
    NSString *styleStr = [NSString stringWithFormat:@"%@", @(aiStyle)];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:styleStr forKey:@"ai_sdk_style"];
    [userDefaults synchronize];
}

- (NSString *) generateAiWatchfaceName
{
    NSString *name = [self.watchfaceNameProvider name];
    if (name.length == 0) {
        name = @"AIFace1";
    }
    return name;
}

- (void) voicePlayRequestHandleWithState:(NSInteger)state
                                language:(NSInteger)language
                                  volumn:(NSInteger)volumn
                                     crc:(NSString *)crc
{
    [AiLogger i:@"voicePlayRequestHandleWithState: %@, language: %@, volumn: %@, crc: %@", @(state), @(language), @(volumn), crc];
    if (self.textToVoiceHandler) {
        if ([self.textToVoiceHandler isHandling:self.lastResultText]) {
            [AiLogger i:@"Is Converting text: %@", self.lastResultText];
            return;
        }
        if ([self.textToVoiceHandler isPlaying:self.lastResultText]) {
            [AiLogger i:@"Is Playing text: %@", self.lastResultText];
            return;
        }
        [self.textToVoiceHandler stop];
    }
    if (state == 0) {
        [self.textToVoiceHandler stop];
        return;
    }
    if (!self.lastResultText) {
        [AiLogger i:@"lastResultText is null"];
        return;
    }
    self.textToVoiceHandler = [[DefaultTextToVoiceHandler alloc] init];
    [self.textToVoiceHandler handle:self.lastResultText state:state language:language volumn:volumn crc:crc];
}

- (void) sendDeviceSubscriptionInfo:(NSString *) mac
{
    [self subscriptionInfoRequestHandle:mac];
}

- (void) subscriptionInfoRequestHandle:(NSString *)mac
{
    [AiLogger i:@"请求订阅信息：%@", mac];
    NSString *Id = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    Id = [Id lowercaseStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    [self getOrderInfo2WithMac:Id callback:^(AiOrderInfo * _Nonnull orderInfo, NSString * _Nullable errorMsg) {
        [AiLogger i:@"返回订单信息：%@, errorMsg: %@", orderInfo, errorMsg];
        NSInteger type = 0;
        if (orderInfo.orderNum >= 0) {
            type = 1;
        }
        else if (orderInfo.orderType == 0) {
            type = 2;
        }
        else if (orderInfo.orderType == 1) {
            type = 3;
        }
        else if (orderInfo.orderType == 2) {
            type = 4;
        }
        if (orderInfo.endTime <= 0) {
            type = 0;
        }
        [[HwBluetoothSDK sharedInstance] setAiSubscriptionInfoWithType:type
                                                             startTime:orderInfo.startTime
                                                               endTime:orderInfo.endTime
                                                             leftCount:orderInfo.orderNum];
    }];
}


- (void) setAiWatchfaceNameProvider:(id<IAiWatchfaceNameProvider>)nameProvider
{
    self.watchfaceNameProvider = nameProvider;
}

- (void) setAiErrorMessageProvider:(id<IAiErrorMessageProvider>)messageProvider
{
    self.errorMessageProvider = messageProvider;
}

- (void)setWorking:(BOOL)working {
    _working = working;
    
    [AiLogger i:@"working: %@", working ? @"为true" : @"为false"];
}

@end

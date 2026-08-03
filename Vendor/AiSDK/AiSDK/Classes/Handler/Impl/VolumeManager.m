//
//  VolumeManager.m
//  AiSDK
//
//  Created by HuaWo on 2025/10/23.
//

#import "VolumeManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface VolumeManager()

@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation VolumeManager

+ (instancetype)sharedManager {
    static VolumeManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioSession = [AVAudioSession sharedInstance];
    }
    return self;
}

// 设置系统音量
- (void)setSystemVolume:(float)volume {
    UISlider *volumeSlider = [self getSystemVolumeSlider];
    if (volumeSlider) {
        [volumeSlider setValue:volume animated:YES];
        [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

// 获取当前系统音量
- (float)getCurrentVolume {
    return [self.audioSession outputVolume];
}

// 获取系统音量滑块
- (UISlider *)getSystemVolumeSlider {
    
    // 确保只创建一次
    if (!self.volumeView) {
        self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 100, 100)];
        // 添加到 keyWindow
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.volumeView];
    }
        
    for (UIView *view in self.volumeView.subviews) {
        if ([view isKindOfClass:[UISlider class]]) {
            return (UISlider *)view;
        }
    }
    return nil;
}


@end

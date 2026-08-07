//
//  DefaultImageToPreviewHandler.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import "DefaultImageToPreviewHandler.h"
#import "AiDeviceInfo.h"
#import "AiImageUtils.h"
#import "AiSDK.h"
#import "AiLogger.h"
#import "AiFileUtils.h"
#import "HwBluetoothSDK/HwBluetoothSDK.h"
#import "WatchfaceSDK/WatchfaceSDK-Swift.h"

@interface DefaultImageToPreviewHandler()

@property(nonatomic, assign) BOOL isCanceled;
@property(nonatomic, assign) BOOL needSyncToDevice;
@property(nonatomic, strong) UIImage *source;
@property(nonatomic, strong) UIImage *background;
@property(nonatomic, strong) AiDeviceInfo *deviceInfo;

@end

@implementation DefaultImageToPreviewHandler

- (void)dealloc
{
    _source = nil;
    _deviceInfo = nil;
    _background = nil;
}

- (DefaultImageToPreviewHandler *) initWithImage:(UIImage *_Nonnull)image
                                      deviceInfo:(AiDeviceInfo *)deviceInfo
                                needSyncToDevice:(BOOL)needSyncToDevice
{
    self = [super init];
    if (self) {
        self.source = image;
        self.deviceInfo = deviceInfo;
        self.needSyncToDevice = needSyncToDevice;
    }
    return self;
}

- (void)cancel { 
    [AiLogger i:@"ImageToPreviewHandler cancel"];
    self.isCanceled = YES;
}

- (void)makePreviewDone:(UIImage *_Nullable)preview
                   code:(NSInteger)code
               errorMsg:(NSString *_Nullable)errorMsg
{
    if (_isCanceled) {
        [AiLogger i:@"makePreviewDone is canceled"];
        return;
    }
    
    [[AiSDK sharedInstance] imageToPreviewCompleted:preview code:code msg:errorMsg];
    if (self.needSyncToDevice) {
        if (code != 0) {
            [self syncToDeviceDone:AiErrorScaleAndCropImageFailed errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorScaleAndCropImageFailed]];
            return;
        }
        [self startMakePreviewBin:preview];
    }
}

- (void)start
{
    [AiLogger i:@"preview handler start"];
    self.isCanceled = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [AiImageUtils generateFitSizePreViewImage:self.source
                                                             width:self.deviceInfo.width
                                                            height:self.deviceInfo.height];
        
        self.background = [AiImageUtils generateFitSizeRoundedImage:image
                                                              width:self.deviceInfo.thumbnailWidth
                                                             height:self.deviceInfo.thumbnailHeight
                                                       cornerRadius:self.deviceInfo.thumbnailCornerRadius];
        
        if (self.background == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AiLogger e:@"background is nil"];
                [self makePreviewDone:nil code:AiErrorScaleAndCropImageFailed errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorScaleAndCropImageFailed]];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makePreviewDone:self.background code:0 errorMsg:nil];
        });
    });
}

- (void) startMakePreviewBin:(UIImage *)preview
{
    NSString *binPath = [AiImageUtils exportSifliBin:preview fileName:@"JW_AIPreview1.bin"];
    NSString *filePath = [AiFileUtils generatePreviewZip:binPath];
    
    if (filePath == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AiLogger e:@"filePath is nil"];
            [self syncToDeviceDone:AiErrorMakeQjsWatchfaceFailed errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorMakeQjsWatchfaceFailed]];
        });
        return;
    }
    
    HwBluetoothDevice *device = [HwBluetoothCenter sharedInstance].connectedDevice;
    if (device == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AiLogger e:@"disconnected"];
            [self syncToDeviceDone:HwBCCodeBLEDisconnected errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:HwBCCodeBLEDisconnected]];
        });
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSString *deviceUUID = device.peripheral.identifier.UUIDString;
    [[SifliWatchfaceSDK getInstance] syncZipFileWithDevIdentifier:deviceUUID filePath:url type:3 progressCallback:^(NSInteger progress) {
        NSLog(@"preview progress: %@", @(progress));
    } finishCallback:^(BOOL success, NSString *message, NSInteger code, NSNumber *devCode) {
        if (!success) {
            [AiLogger e:@"sync preview to device failed: %@", @(code)];
            [self syncToDeviceDone:AiErrorMakeQjsWatchfaceFailed errorMsg:[[AiSDK sharedInstance] errorMsgWithCode:AiErrorMakeQjsWatchfaceFailed]];
            return;
        } else {
            [self syncToDeviceDone:0 errorMsg:nil];
        }
    }];
}

- (void) syncToDeviceDone:(NSInteger)code
                 errorMsg:(NSString *)errorMsg
{
    if (self.isCanceled) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AiSDK sharedInstance] previewSyncToDeviceCompleted:code msg:errorMsg];
    });
    _source = nil;
    _deviceInfo = nil;
    _background = nil;
}

@end

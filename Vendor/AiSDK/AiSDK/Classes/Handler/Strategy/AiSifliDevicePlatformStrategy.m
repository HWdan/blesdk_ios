//
//  AiSifliDevicePlatformStrategy.m
//  AiSDK
//

#import "AiSifliDevicePlatformStrategy.h"
#import "AiSDK.h"
#import "DefaultImageToWatchfaceHandler.h"
#import "HwBluetoothSDK.h"
//#import "HwBluetoothSDK/HwBluetoothSDK.h"

@implementation AiSifliDevicePlatformStrategy

- (id<IImageToWatchfaceHandler>)createWatchfaceHandlerWithImage:(UIImage *)image
                                                      deviceInfo:(AiDeviceInfo *)deviceInfo
{
    return [[DefaultImageToWatchfaceHandler alloc] initWithImage:image deviceInfo:deviceInfo];
}

- (void)requestRecordDataWithCallback:(AiDeviceRecordDataCallback)callback
{
    [[HwBluetoothSDK sharedInstance] getAiRecordDataWithCallback:callback];
}

- (void)completeTextToImageWithSDK:(AiSDK *)sdk
                              image:(UIImage *)image
                               code:(NSInteger)code
                           errorMsg:(NSString *)errorMsg
{
    [sdk textToImageCompleted:image code:code msg:errorMsg];
}

@end

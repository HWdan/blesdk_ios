//
//  AiJieLiDevicePlatformStrategy.m
//  AiSDK
//

#import "AiJieLiDevicePlatformStrategy.h"
#import "AiSDK.h"
#import "JLImageToWatchfaceHandler.h"
#import "HwBluetoothSDK.h"
//#import "HwBluetoothSDK/HwBluetoothSDK.h"

@implementation AiJieLiDevicePlatformStrategy

- (id<IImageToWatchfaceHandler>)createWatchfaceHandlerWithImage:(UIImage *)image
                                                      deviceInfo:(AiDeviceInfo *)deviceInfo
{
    return [[JLImageToWatchfaceHandler alloc] initWithImage:image deviceInfo:deviceInfo];
}

- (void)requestRecordDataWithCallback:(AiDeviceRecordDataCallback)callback
{
    [[HwBluetoothSDK sharedInstance] getJLAiRecordDataWithCallback:callback];
}

- (void)completeTextToImageWithSDK:(AiSDK *)sdk
                              image:(UIImage *)image
                               code:(NSInteger)code
                           errorMsg:(NSString *)errorMsg
{
    [sdk textToImageCompleted_JL:image code:code msg:errorMsg];
}

@end

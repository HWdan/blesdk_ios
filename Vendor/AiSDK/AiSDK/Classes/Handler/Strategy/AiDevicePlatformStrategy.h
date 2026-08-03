//
//  AiDevicePlatformStrategy.h
//  AiSDK
//
//  Reconstructed from AiSifli/AiJieLi strategy .m implementations
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IImageToWatchfaceHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class AiDeviceInfo;
@class AiSDK;

typedef void (^AiDeviceRecordDataCallback)(NSData *_Nullable data, NSError *_Nullable error);

@protocol AiDevicePlatformStrategy <NSObject>

- (id<IImageToWatchfaceHandler>)createWatchfaceHandlerWithImage:(UIImage *)image
                                                     deviceInfo:(AiDeviceInfo *)deviceInfo;

- (void)requestRecordDataWithCallback:(AiDeviceRecordDataCallback)callback;

- (void)completeTextToImageWithSDK:(AiSDK *)sdk
                             image:(UIImage *_Nullable)image
                              code:(NSInteger)code
                          errorMsg:(NSString *_Nullable)errorMsg;

@end

NS_ASSUME_NONNULL_END

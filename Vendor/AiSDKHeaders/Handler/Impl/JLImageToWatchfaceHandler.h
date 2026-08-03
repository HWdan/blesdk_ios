//
//  JLImageToWatchfaceHandler.h
//  AiSDK
//
//  Reconstructed from JLImageToWatchfaceHandler.m (mirrors DefaultImageToWatchfaceHandler.h)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IImageToWatchfaceHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class AiDeviceInfo;

@interface JLImageToWatchfaceHandler : NSObject <IImageToWatchfaceHandler>

- (JLImageToWatchfaceHandler *)initWithImage:(UIImage *)image
                                  deviceInfo:(AiDeviceInfo *)deviceInfo;

@end

NS_ASSUME_NONNULL_END

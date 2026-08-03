//
//  JLImageToPreviewHandler.h
//  AiSDK
//
//  Reconstructed from JLImageToPreviewHandler.m (mirrors DefaultImageToPreviewHandler.h)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IImageToPreviewHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class AiDeviceInfo;

@interface JLImageToPreviewHandler : NSObject <IImageToPreviewHandler>

- (JLImageToPreviewHandler *)initWithImage:(UIImage *)image
                                deviceInfo:(AiDeviceInfo *)deviceInfo
                          needSyncToDevice:(BOOL)needSyncToDevice;

@end

NS_ASSUME_NONNULL_END

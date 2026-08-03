//
//  DefaultImageToPreviewHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IImageToPreviewHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class AiDeviceInfo;
@interface DefaultImageToPreviewHandler : NSObject<IImageToPreviewHandler>

- (DefaultImageToPreviewHandler *) initWithImage:(UIImage *_Nonnull)image
                                      deviceInfo:(AiDeviceInfo *_Nonnull)deviceInfo
                                needSyncToDevice:(BOOL)needSyncToDevice;

@end

NS_ASSUME_NONNULL_END

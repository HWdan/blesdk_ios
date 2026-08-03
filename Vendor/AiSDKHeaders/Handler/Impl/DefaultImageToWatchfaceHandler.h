//
//  DefaultImageToWatchfaceHandler.h
//  AiSDK
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IImageToWatchfaceHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class AiDeviceInfo;
@interface DefaultImageToWatchfaceHandler : NSObject<IImageToWatchfaceHandler>

- (DefaultImageToWatchfaceHandler *) initWithImage:(UIImage *_Nonnull)image
                                        deviceInfo:(AiDeviceInfo *_Nonnull)deviceInfo;

@end

NS_ASSUME_NONNULL_END

//
//  IInitSDK.h
//  Pods
//
//  Created by HuaWo on 2024/12/23.
//

#ifndef IInitSDK_h
#define IInitSDK_h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AiDeviceInfo;
@protocol IInitSDK <NSObject>
- (void) initSDK:(AiDeviceInfo *)deviceInfo;
@end

NS_ASSUME_NONNULL_END

#endif /* IInitSDK_h */

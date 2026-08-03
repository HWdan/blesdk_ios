//
//  UIImage+HwSDK.h
//  HwBluetoothSDK
//
//  Created by HuaWo on 2022/8/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HwSDK)

- (UIImage *)hwClipimageSize:(CGSize)imageSize;

- (UIImage*)hwTransformtoSize:(CGSize)newsize;

@end

NS_ASSUME_NONNULL_END

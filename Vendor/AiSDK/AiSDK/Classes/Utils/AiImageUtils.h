//
//  AiImageUtils.h
//  AiSDK
//
//  Reconstructed from AiImageUtils.m + Xcode index
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiImageUtils : NSObject

+ (UIImage *)generateFitSizeImage:(UIImage *)source
                            width:(CGFloat)targetWidth
                           height:(CGFloat)targetHeight;

+ (UIImage *)generateFitSizePreViewImage:(UIImage *)source
                                   width:(CGFloat)targetWidth
                                  height:(CGFloat)targetHeight;

+ (UIImage *)generateJLFitSizePreViewImage:(UIImage *)source
                                     width:(CGFloat)width
                                    height:(CGFloat)height;

+ (UIImage *)generateFitSizeRoundedImage:(UIImage *)source
                                   width:(CGFloat)targetWidth
                                  height:(CGFloat)targetHeight
                            cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)generateFitSizeRoundedImage:(UIImage *)source
                                   width:(CGFloat)targetWidth
                                  height:(CGFloat)targetHeight
                            cornerRadius:(CGFloat)cornerRadius
                                  opaque:(BOOL)opaque;

+ (NSString *_Nullable)exportSifliBin:(UIImage *)image
                             fileName:(NSString *)fileName;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

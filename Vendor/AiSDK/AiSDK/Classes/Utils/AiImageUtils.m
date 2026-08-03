//
//  ImageUtils.m
//  AiSDK
//
//  Created by HuaWo on 2025/1/10.
//

#import "AiImageUtils.h"
#import "WatchfaceSDK/WatchfaceSDK-Swift.h"

@implementation AiImageUtils

+ (UIImage *) generateFitSizeImage:(UIImage *)source
                             width:(CGFloat)targetWidth
                            height:(CGFloat)targetHeight
{
    // 获取原始图像的宽高
    CGSize originalSize = source.size;
    
    // 计算目标区域的宽高比
    CGFloat targetAspectRatio = targetWidth / targetHeight;
    CGFloat imageAspectRatio = originalSize.width / originalSize.height;
    
    // 计算裁剪区域的宽高
    CGFloat cropWidth = originalSize.width;
    CGFloat cropHeight = originalSize.height;
    
    // 判断目标区域的宽高比与原图的宽高比，来确定裁剪的大小
    if (targetAspectRatio > imageAspectRatio) {
        // 目标区域的宽高比大于原图的宽高比，按高度缩放
        cropWidth = originalSize.height * targetAspectRatio;
    } else {
        // 目标区域的宽高比小于或等于原图的宽高比，按宽度缩放
        cropHeight = originalSize.width / targetAspectRatio;
    }
    
    // 计算裁剪区域的起始点（保证裁剪区域在图片中心）
    CGFloat originX = (originalSize.width - cropWidth) / 2.0;
    CGFloat originY = (originalSize.height - cropHeight) / 2.0;
    
    // 创建裁剪区域的矩形
    CGRect cropRect = CGRectMake(originX, originY, cropWidth, cropHeight);
    
    // 裁剪图像
    CGImageRef imageRef = CGImageCreateWithImageInRect(source.CGImage, cropRect);
    
    // 创建裁剪后的 UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放 CGImage 对象
    CGImageRelease(imageRef);
    
    // 重新调整裁剪后的图片大小以适配目标宽高
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(targetWidth, targetHeight), NO, source.scale);
    [croppedImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage *) generateFitSizePreViewImage:(UIImage *)source
                                    width:(CGFloat)targetWidth
                                   height:(CGFloat)targetHeight
{
    UIImage *finalImage = [self generateFitSizeImage:source width:targetWidth height:targetHeight];
    return [self addTimeDateWeekWidgetsPreview:finalImage];
}

+ (UIImage *)addTimeDateWeekWidgetsPreview:(UIImage *)backgroundImage
{
    // 1. 获取背景图片的尺寸
    CGSize backgroundSize = backgroundImage.size;
    // 2. 开启一个图形上下文，准备绘制
    UIGraphicsBeginImageContextWithOptions(backgroundSize, NO, backgroundImage.scale);
    // 3. 绘制背景图片
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundSize.width, backgroundSize.height)];
    // 4. 将小图片绘制到指定位置
    CGFloat timeWidth = 124 + 40 + 124;
    CGFloat timeHeight = 96;
    CGFloat timeY = 60;
    CGFloat dateY = timeY + timeHeight + 10;
    CGFloat dateWidth = 56;
    CGFloat weekWidth = 114;
    CGFloat weekY = dateY;
    
    CGFloat width = backgroundImage.size.width;
    CGFloat x = (width - timeWidth) / 2;
    
    UIImage *hour1 = [self loadImageWithName:@"time_b_31"];
    // hour1 = [self scaleImage:hour1 toSize:CGSizeMake(62, timeHeight)];
    
    UIImage *hour2 = [self loadImageWithName:@"time_b_32"];
    // hour2 = [self scaleImage:hour2 toSize:CGSizeMake(62, timeHeight)];
    
    UIImage *mh = [self loadImageWithName:@"time_b_25"];
    // mh = [self scaleImage:mh toSize:CGSizeMake(40, timeHeight)];
    
    UIImage *min1 = [self loadImageWithName:@"time_b_30"];
    // min1 = [self scaleImage:min1 toSize:CGSizeMake(62, timeHeight)];
    
    UIImage *min2 = [self loadImageWithName:@"time_b_30"];
    // min2 = [self scaleImage:min2 toSize:CGSizeMake(62, timeHeight)];
    
    CGFloat drawX = x;
    [hour1 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    drawX += 62;
    [hour2 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    drawX += 62;
    [mh drawInRect:CGRectMake(drawX, timeY, 40, timeHeight)];
    drawX += 40;
    [min1 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    drawX += 62;
    [min2 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    
    
    UIImage *date1 = [self loadImageWithName:@"date_num_31"];
    UIImage *date2 = [self loadImageWithName:@"date_num_31"];
    
    drawX = (width - dateWidth - weekWidth - 4) / 2;
    [date1 drawInRect:CGRectMake(drawX, dateY, dateWidth / 2, 40)];
    drawX += dateWidth / 2;
    [date2 drawInRect:CGRectMake(drawX, dateY, dateWidth / 2, 40)];
    drawX += dateWidth / 2;
    
    UIImage *week = [self loadImageWithName:@"week_06"];
    [week drawInRect:CGRectMake(drawX, weekY, 114, 40)];
    
    // 5. 获取合成后的图片
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    // 6. 结束图形上下文
    UIGraphicsEndImageContext();
    return mergedImage;
}

+ (UIImage *) generateJLFitSizePreViewImage:(UIImage *)source
                                      width:(CGFloat)width
                                     height:(CGFloat)height {
    UIImage *finalImage = [self generateFitSizeImage:source width:width height:height];
    return [self addTimeJLDateWeekWidgetsPreview:finalImage];
}

+ (UIImage *)addTimeJLDateWeekWidgetsPreview:(UIImage *)backgroundImage
{
    // 1. 获取背景图片的尺寸
    CGSize backgroundSize = backgroundImage.size;
    // 2. 开启一个图形上下文，准备绘制
    UIGraphicsBeginImageContextWithOptions(backgroundSize, NO, backgroundImage.scale);
    // 3. 绘制背景图片
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundSize.width, backgroundSize.height)];
    // 4. 将小图片绘制到指定位置
    CGFloat timeWidth = 124 + 40 + 124;
    CGFloat timeHeight = 96;
    CGFloat timeY = 60;
    CGFloat dateY = timeY + timeHeight + 10;
    CGFloat dateWidth = 56;
    CGFloat weekWidth = 114;
    CGFloat weekY = dateY;
    
    CGFloat width = backgroundImage.size.width;
    CGFloat x = (width - timeWidth) / 2;
    
    UIImage *hour1 = [self loadImageWithName:@"time_num1_jl"];
    
    UIImage *hour2 = [self loadImageWithName:@"time_num0_jl"];
    
    UIImage *mh = [self loadImageWithName:@"time_num_colon_jl"];
    
    UIImage *min1 = [self loadImageWithName:@"time_num0_jl"];
    
    UIImage *min2 = [self loadImageWithName:@"time_num8_jl"];
    
    CGFloat drawX = x;
    [hour1 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    drawX += 62;
    [hour2 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    drawX += 62;
    [mh drawInRect:CGRectMake(drawX, timeY, 40, timeHeight)];
    drawX += 40;
    [min1 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    drawX += 62;
    [min2 drawInRect:CGRectMake(drawX, timeY, 62, timeHeight)];
    
    
    drawX = (width - dateWidth - weekWidth - 4) / 2 - 10;
    UIImage *week = [self loadImageWithName:@"week_wed_jl"];
    [week drawInRect:CGRectMake(drawX, weekY, 114, 40)];
    drawX += 114;
    
    UIImage *date1 = [self loadImageWithName:@"function_num0_jl"];
    UIImage *date2 = [self loadImageWithName:@"function_num1_jl"];
    
    [date1 drawInRect:CGRectMake(drawX, dateY, dateWidth / 2, 40)];
    drawX += dateWidth / 2;
    [date2 drawInRect:CGRectMake(drawX, dateY, dateWidth / 2, 40)];
    drawX += dateWidth / 2;
    
    [date1 drawInRect:CGRectMake(drawX, dateY, dateWidth / 2, 40)];
    drawX += dateWidth / 2;
    [date2 drawInRect:CGRectMake(drawX, dateY, dateWidth / 2, 40)];
    drawX += dateWidth / 2;
    
    
    // 5. 获取合成后的图片
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    // 6. 结束图形上下文
    UIGraphicsEndImageContext();
    return mergedImage;
}

+ (UIImage *) generateFitSizeRoundedImage:(UIImage *)source
                                    width:(CGFloat)targetWidth
                                   height:(CGFloat)targetHeight
                             cornerRadius:(CGFloat)cornerRadius
                                   opaque:(BOOL)opaque;
{
    // 获取原始图像的宽高
    CGSize originalSize = source.size;
    
    // 计算目标区域的宽高比
    CGFloat targetAspectRatio = targetWidth / targetHeight;
    CGFloat imageAspectRatio = originalSize.width / originalSize.height;
    
    // 计算裁剪区域的宽高
    CGFloat cropWidth = originalSize.width;
    CGFloat cropHeight = originalSize.height;
    
    // 判断目标区域的宽高比与原图的宽高比，来确定裁剪的大小
    if (targetAspectRatio > imageAspectRatio) {
        // 目标区域的宽高比大于原图的宽高比，按高度缩放
        cropWidth = originalSize.height * targetAspectRatio;
    } else {
        // 目标区域的宽高比小于或等于原图的宽高比，按宽度缩放
        cropHeight = originalSize.width / targetAspectRatio;
    }
    
    // 计算裁剪区域的起始点（保证裁剪区域在图片中心）
    CGFloat originX = (originalSize.width - cropWidth) / 2.0;
    CGFloat originY = (originalSize.height - cropHeight) / 2.0;
    
    // 创建裁剪区域的矩形
    CGRect cropRect = CGRectMake(originX, originY, cropWidth, cropHeight);
    
    // 裁剪图像
    CGImageRef imageRef = CGImageCreateWithImageInRect(source.CGImage, cropRect);
    
    // 创建裁剪后的 UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放 CGImage 对象
    CGImageRelease(imageRef);
    
    // 在一个新的图形上下文中绘制带圆角的图片
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(targetWidth, targetHeight), opaque, source.scale);
    
    // 设置圆角矩形路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, targetWidth, targetHeight) cornerRadius:cornerRadius];
    [path addClip];  // 将图形上下文裁剪成圆角形状
    
    // 绘制裁剪后的图像
    [croppedImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    // 获取最终的图像
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage *) generateFitSizeRoundedImage:(UIImage *)source
                                    width:(CGFloat)targetWidth
                                   height:(CGFloat)targetHeight
                             cornerRadius:(CGFloat)cornerRadius
{
    // 获取原始图像的宽高
    CGSize originalSize = source.size;
    
    // 计算目标区域的宽高比
    CGFloat targetAspectRatio = targetWidth / targetHeight;
    CGFloat imageAspectRatio = originalSize.width / originalSize.height;
    
    // 计算裁剪区域的宽高
    CGFloat cropWidth = originalSize.width;
    CGFloat cropHeight = originalSize.height;
    
    // 判断目标区域的宽高比与原图的宽高比，来确定裁剪的大小
    if (targetAspectRatio > imageAspectRatio) {
        // 目标区域的宽高比大于原图的宽高比，按高度缩放
        cropWidth = originalSize.height * targetAspectRatio;
    } else {
        // 目标区域的宽高比小于或等于原图的宽高比，按宽度缩放
        cropHeight = originalSize.width / targetAspectRatio;
    }
    
    // 计算裁剪区域的起始点（保证裁剪区域在图片中心）
    CGFloat originX = (originalSize.width - cropWidth) / 2.0;
    CGFloat originY = (originalSize.height - cropHeight) / 2.0;
    
    // 创建裁剪区域的矩形
    CGRect cropRect = CGRectMake(originX, originY, cropWidth, cropHeight);
    
    // 裁剪图像
    CGImageRef imageRef = CGImageCreateWithImageInRect(source.CGImage, cropRect);
    
    // 创建裁剪后的 UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放 CGImage 对象
    CGImageRelease(imageRef);
    
    // 在一个新的图形上下文中绘制带圆角的图片
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(targetWidth, targetHeight), NO, source.scale);
    
    // 设置圆角矩形路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, targetWidth, targetHeight) cornerRadius:cornerRadius];
    [path addClip];  // 将图形上下文裁剪成圆角形状
    
    // 绘制裁剪后的图像
    [croppedImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    // 获取最终的图像
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return finalImage;
}


+ (NSString *) exportSifliBin:(UIImage *)image
                     fileName:(NSString *)fileName
{
    NSData *data = [QjsFileUtils exportBinWithSource:image color:nil];
    if (data == nil) {
        return nil;
    }
    
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    BOOL success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (success) {
        NSLog(@"文件保存成功：%@", filePath);
    } else {
        NSLog(@"文件保存失败：%@", error.localizedDescription);
        return nil;
    }
    return filePath;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    UIImage *scaledImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ctx) {
        // 绘制缩放后的图片
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
    return scaledImage;
}

+ (UIImage *)loadImageWithName:(NSString *)imageName
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [bundle pathForResource:@"AiSDK" ofType:@"bundle"];
    NSBundle *aiSDKBundle = [NSBundle bundleWithPath:bundlePath];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", imageName] inBundle:aiSDKBundle compatibleWithTraitCollection:nil];
    return image;
}

@end

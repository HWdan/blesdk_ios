//
//  AiDeviceInfo.h
//  AiSDK
//
//  Reconstructed from AiDeviceInfo.m + usages + Xcode index
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HWPlatformType) {
    HWPlatformTypeSifli = 0,
    HWPlatformTypeJieLi = 1,
};

@interface AiDeviceInfo : NSObject

@property (nonatomic, copy, nullable) NSString *Id;
@property (nonatomic, copy, nullable) NSString *type;
@property (nonatomic, copy, nullable) NSString *mac;
@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger cornerRadius;

@property (nonatomic, assign) NSInteger thumbnailWidth;
@property (nonatomic, assign) NSInteger thumbnailHeight;
@property (nonatomic, assign) NSInteger thumbnailCornerRadius;

@property (nonatomic, assign) BOOL needPreviewBorder;
@property (nonatomic, assign) CGFloat previewBorderWidth;
@property (nonatomic, strong, nullable) UIColor *previewBorderColor;

@property (nonatomic, copy, nullable) NSString *currentLocale;
@property (nonatomic, copy, nullable) NSArray<NSString *> *supportedLocales;

@property (nonatomic, assign) HWPlatformType platformType;

- (instancetype)init;

- (instancetype)initWithId:(NSString *)Id
                      type:(NSString *)type
                       mac:(NSString *)mac
                     width:(NSInteger)width
                    height:(NSInteger)height
              cornerRadius:(NSInteger)cornerRadius
            thumbnailWidth:(NSInteger)thumbnailWidth
           thumbnailHeight:(NSInteger)thumbnailHeight
     thumbnailCornerRadius:(NSInteger)thumbnailCornerRadius
             currentLocale:(NSString *)currentLocale;

@end

NS_ASSUME_NONNULL_END

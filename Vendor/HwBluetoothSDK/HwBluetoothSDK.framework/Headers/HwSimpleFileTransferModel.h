#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SimpleFileTransferType) {
    SimpleFileTransferTypeWatchFace = 0,
};

@interface HwSimpleFileTransferModel : NSObject

@property (nonatomic, assign) SimpleFileTransferType transferType;
@property (nonatomic, assign) NSInteger watchFaceID;
@property (nonatomic, strong, nullable) NSData *fileData;

@end

NS_ASSUME_NONNULL_END

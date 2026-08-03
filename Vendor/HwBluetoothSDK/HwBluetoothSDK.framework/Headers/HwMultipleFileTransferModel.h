#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MultipleFileTransferPhotoType) {
    MultipleFileTransferPhotoTypePNG = 0,
    MultipleFileTransferPhotoTypeJPG = 1,
};

typedef NS_ENUM(NSInteger, MultipleFileTransferMusicType) {
    MultipleFileTransferMusicTypeMP3 = 0,
    MultipleFileTransferMusicTypeWAV = 1,
};

@interface HwMultipleFileTransferModel : NSObject

@property (nonatomic, strong, nullable) NSData *fileData;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, assign) MultipleFileTransferPhotoType photoType;
@property (nonatomic, assign) MultipleFileTransferMusicType musicType;

@end

NS_ASSUME_NONNULL_END

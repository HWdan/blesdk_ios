#import <Foundation/Foundation.h>
#import "HwMultipleFileTransferModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MultipleFileTransferType) {
    MultipleFileTransferTypeMusic = 0x01,
    MultipleFileTransferTypePhoto = 0x02,
    MultipleFileTransferTypeAIDialPreview = 0x03,
    MultipleFileTransferTypeOnlineDial = 0x04,
    MultipleFileTransferTypeCustomDialImage = 0x05,
    MultipleFileTransferTypeAIDialImage = 0x06,
};

typedef void (^HwMultipleFileTransferReadyCallback)(BOOL success, NSError * _Nullable error);
typedef void (^HwMultipleFileTransferProgressCallback)(float progress, NSError * _Nullable error);
typedef void (^HwMultipleFileTransferFinishCallback)(BOOL success, NSError * _Nullable error);

@class HwBluetoothCenter;

@interface HwBluetoothCenter (MultipleFileTransfer)

- (void)startMultipleFileTransfer:(NSArray<HwMultipleFileTransferModel *> *)models
                     transferType:(MultipleFileTransferType)transferType
                    readyCallback:(HwMultipleFileTransferReadyCallback _Nullable)readyCallback
                 progressCallback:(HwMultipleFileTransferProgressCallback _Nullable)progressCallback
                   finishCallback:(HwMultipleFileTransferFinishCallback _Nullable)finishCallback;

- (void)startMultipleFileTransferWithFilePath:(NSString *)filePath
                                 transferType:(MultipleFileTransferType)transferType
                                readyCallback:(HwMultipleFileTransferReadyCallback _Nullable)readyCallback
                             progressCallback:(HwMultipleFileTransferProgressCallback _Nullable)progressCallback
                               finishCallback:(HwMultipleFileTransferFinishCallback _Nullable)finishCallback;

- (void)setMftLogBlock:(void (^ _Nullable)(NSString *log))logBlock;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>
#import "HwSimpleFileTransferModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HwSimpleFileTransferReadyCallback)(BOOL success, NSError * _Nullable error);
typedef void (^HwSimpleFileTransferProgressCallback)(float progress, NSError * _Nullable error);
typedef void (^HwSimpleFileTransferFinishCallback)(BOOL success, NSError * _Nullable error);

@class HwBluetoothCenter;

@interface HwBluetoothCenter (SimpleFileTransfer)

- (void)startSimpleFileTransfer:(HwSimpleFileTransferModel *)model
                  readyCallback:(HwSimpleFileTransferReadyCallback _Nullable)readyCallback
               progressCallback:(HwSimpleFileTransferProgressCallback _Nullable)progressCallback
                 finishCallback:(HwSimpleFileTransferFinishCallback _Nullable)finishCallback;

- (void)setSftLogBlock:(void (^ _Nullable)(NSString *log))logBlock;

@end

NS_ASSUME_NONNULL_END

//
//  AiOrderInfo.h
//  AiSDK
//
//  Reconstructed from AiOrderInfo.m + AiSDK.m order mapping + Xcode index
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiOrderInfo : NSObject

@property (nonatomic, copy, nullable) NSString *Id;
@property (nonatomic, copy, nullable) NSString *price;
@property (nonatomic, assign) NSInteger orderStatus;
@property (nonatomic, assign) NSInteger orderNum;
@property (nonatomic, assign) NSInteger orderType;
@property (nonatomic, assign) int64_t startTime;
@property (nonatomic, assign) int64_t endTime;
@property (nonatomic, copy, nullable) NSString *orderCurrency;

@end

NS_ASSUME_NONNULL_END

//
//  VolumeManager.h
//  AiSDK
//
//  Reconstructed from VolumeManager.m + Xcode index
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VolumeManager : NSObject

+ (instancetype)sharedManager;

- (void)setSystemVolume:(float)volume;
- (float)getCurrentVolume;

@end

NS_ASSUME_NONNULL_END

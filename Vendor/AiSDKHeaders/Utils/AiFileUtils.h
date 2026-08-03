//
//  AiFileUtils.h
//  AiSDK
//
//  Created by HuaWo on 2025/1/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiFileUtils : NSObject

+ (NSString *_Nullable) generatePreviewZip:(NSString *_Nonnull)previewBinPath;
+ (NSString *) generateTextToVoicePath;

@end

NS_ASSUME_NONNULL_END

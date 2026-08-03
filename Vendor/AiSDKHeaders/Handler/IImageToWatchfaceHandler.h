//
//  ITextToAnswerTextHandler.h
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IImageToWatchfaceHandler <NSObject>

- (void) start;
- (void) generateDone:(NSString *_Nullable)name
                 code:(NSInteger)code
             errorMsg:(NSString *_Nullable)errorMsg;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

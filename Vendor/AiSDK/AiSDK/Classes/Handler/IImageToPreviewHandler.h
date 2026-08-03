//
//  ITextToAnswerTextHandler.h
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IImageToPreviewHandler <NSObject>

- (void) start;
- (void) makePreviewDone:(UIImage *_Nullable)preview
                    code:(NSInteger)code
                errorMsg:(NSString *_Nullable)errorMsg;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

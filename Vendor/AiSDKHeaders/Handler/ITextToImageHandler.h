//
//  ITextToAnswerTextHandler.h
//  AiSDK
//
//  Created by HuaWo on 2024/12/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ITextToImageHandler <NSObject>

- (void) convert:(NSString *)text;
- (void) convertComplete:(UIImage *_Nullable)image
                    code:(NSInteger)code
                errorMsg:(NSString *_Nullable)errorMsg;
- (void) cancel;

@end

NS_ASSUME_NONNULL_END

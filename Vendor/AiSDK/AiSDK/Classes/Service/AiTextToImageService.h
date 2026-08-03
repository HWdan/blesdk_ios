//
//  AiTextToImageService.h
//  AFNetworking
//
//  Created by HuaWo on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ITextToImageHandler.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^AiTextToImageCallback)(UIImage *image, NSInteger code, NSString *msg);

@interface AiTextToImageService : NSObject<ITextToImageHandler>

@property(nonatomic, assign) BOOL isCanceled;
- (AiTextToImageService *) initWithCallback:(AiTextToImageCallback)callback;

@end

NS_ASSUME_NONNULL_END

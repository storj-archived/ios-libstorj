//
//  SJFileDeleteCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJStorjErrorCallbackBlock.h"

typedef void (^SJFileDeleteCallbackBlock)();

@interface SJFileDeleteCallback : NSObject

@property (nonatomic) SJErrorCallbackBlock _Nonnull onError;
@property (nonatomic) SJFileDeleteCallbackBlock _Nonnull onSuccess;

-(void) success;

-(void) errorWithCode:(int) errorCode
         errorMessage:(NSString *) errorMessage;

@end

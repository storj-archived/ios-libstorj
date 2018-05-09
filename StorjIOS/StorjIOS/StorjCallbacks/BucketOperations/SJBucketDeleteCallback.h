//
//  SJBucketDeleteCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SJStorjErrorCallbackBlock.h"

typedef void (^SJBucketDeleteCallbackBlock)();

@interface SJBucketDeleteCallback : NSObject

@property (nonatomic) _Nonnull SJBucketDeleteCallbackBlock onSuccess;
@property (nonatomic) _Nonnull SJErrorCallbackBlock onError;

-(void) success;

-(void) errorWithCode:(int) errorCode errorMessage: (NSString *_Nonnull) errorMessage;

@end

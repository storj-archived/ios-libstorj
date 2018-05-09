//
//  SJBucketCreateCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SJBucket.h"
#import "SJStorjErrorCallbackBlock.h"

typedef void (^SJBucketCreateCallbackBlock)(SJBucket * _Nullable sjBucket);

@interface SJBucketCreateCallback : NSObject

@property (nonatomic) SJBucketCreateCallbackBlock _Nonnull onSuccess;
@property (nonatomic) SJErrorCallbackBlock _Nonnull onError;

-(void) successWithSJBucket: (SJBucket *_Nonnull) sjBucket;

-(void) errorWithCode:(int)errorCode message:(NSString *_Nonnull)errorString;

@end


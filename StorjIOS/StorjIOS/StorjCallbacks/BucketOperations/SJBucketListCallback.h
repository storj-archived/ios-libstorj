//
//  SJBucketListCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJBucket.h"
#import "SJStorjErrorCallbackBlock.h"

typedef void (^SJBucketListCallbackBlock)(NSArray<SJBucket *> * _Nullable bucketsArray);

@interface SJBucketListCallback : NSObject

@property (nonatomic) SJBucketListCallbackBlock _Nonnull onSuccess;
@property (nonatomic) SJErrorCallbackBlock _Nonnull onError;

-(void) successWithArray:(NSArray <SJBucket *> *_Nonnull) bucketList;

-(void) errorWithCode: (int) errorCode message:(NSString *_Nonnull) errorMessage;

@end

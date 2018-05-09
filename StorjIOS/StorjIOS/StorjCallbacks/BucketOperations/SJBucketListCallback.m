//
//  BucketListCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJBucketListCallback.h"

@implementation SJBucketListCallback

@synthesize onSuccess;
@synthesize onError;

-(void) successWithArray:(NSArray<SJBucket *> *)bucketList {
    if(onSuccess) {
        onSuccess(bucketList);
    }
}

-(void) errorWithCode:(int)errorCode message:(NSString *)errorMessage {
    if(onError) {
        onError(errorCode, errorMessage);
    }
}

@end



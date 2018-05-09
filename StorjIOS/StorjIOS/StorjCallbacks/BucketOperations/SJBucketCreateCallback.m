//
//  SJBucketCreateCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJBucketCreateCallback.h"

@implementation SJBucketCreateCallback

@synthesize onSuccess;
@synthesize onError;

-(void) successWithSJBucket:(SJBucket *)sjBucket {
    if(onSuccess) {
        onSuccess(sjBucket);
    }
}

-(void) errorWithCode:(int)errorCode message:(NSString *)errorString {
    if(onError) {
        onError(errorCode, errorString);
    }
}
@end



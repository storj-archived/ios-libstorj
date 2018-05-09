//
//  SJBucketDeleteCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJBucketDeleteCallback.h"

@implementation SJBucketDeleteCallback

@synthesize onSuccess;
@synthesize onError;

-(void) success {
    if(onSuccess) {
        onSuccess();
    }
}

-(void) errorWithCode:(int)code errorMessage:(NSString *) errorMessage {
    if(onError) {
        onError(code, errorMessage);
    }
}

@end

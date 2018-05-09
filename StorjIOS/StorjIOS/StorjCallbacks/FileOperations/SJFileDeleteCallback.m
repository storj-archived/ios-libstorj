//
//  SJFileDeleteCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJFileDeleteCallback.h"

@implementation SJFileDeleteCallback

@synthesize onSuccess;
@synthesize onError;

-(void)success {
    if(onSuccess) {
        onSuccess();
    }
}

-(void)errorWithCode:(int)errorCode
        errorMessage:(NSString *)errorMessage {
    if(onError) {
        onError(errorCode, errorMessage);
    }
}

@end



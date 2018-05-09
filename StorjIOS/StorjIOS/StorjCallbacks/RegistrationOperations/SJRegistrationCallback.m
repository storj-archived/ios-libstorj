//
//  SJRegistrationCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 1/29/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJRegistrationCallback.h"

@implementation SJRegistrationCallback

@synthesize onSuccess;
@synthesize onError;

-(void)success:(NSString *) email {
    if(onSuccess) {
        onSuccess(email);
    }
}

-(void)errorWithCode:(int)errorCode message:(NSString *)message {
    if(onError) {
        onError(errorCode, message);
    }
}

@end

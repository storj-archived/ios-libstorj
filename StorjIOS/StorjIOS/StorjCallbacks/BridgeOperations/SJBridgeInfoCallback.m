//
//  SJBridgeInfoCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJBridgeInfoCallback.h"

@implementation SJBridgeInfoCallback

@synthesize onSuccess;
@synthesize onError;

-(void)successWithDictionary:(NSDictionary *)infoDictionary {
    if(onSuccess) {
        onSuccess(infoDictionary);
    }
}

-(void) errorWithCode:(int)errorCode message:(NSString *)errorMessage {
    if(onError) {
        onError(errorCode, errorMessage);
    }
}

@end

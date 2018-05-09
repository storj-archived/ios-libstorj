//
//  SJFileListCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJFileListCallback.h"

@implementation SJFileListCallback

@synthesize onSuccess;
@synthesize onError;

-(void)successWithArray:(NSArray<SJFile *> *)fileArray {
    if(onSuccess) {
        onSuccess(fileArray);
    }
}

-(void)errorWithCode:(int)errorCode errorMessage:(NSString *)errorMessage {
    if(onError) {
        onError(errorCode, errorMessage);
    }
}
@end

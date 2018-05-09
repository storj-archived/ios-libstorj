//
//  SJFileUploadCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJFileUploadCallback.h"

@implementation SJFileUploadCallback

@synthesize onSuccess;
@synthesize onProgress;
@synthesize onError;

-(void)uploadComplete:(SJFile *)file {
    if(onSuccess) {
        onSuccess(file);
    }
}

-(void)uploadProgressWithFileId:(NSString *)fileId
                       progress:(double)progress
                  uploadedBytes:(double)uploadedBytes
                     totalBytes:(double)totalBytes {
    if(onProgress) {
        onProgress(fileId, progress, uploadedBytes, totalBytes);
    }
}

-(void)errorWithCode:(int)errorCode
        errorMessage:(NSString *)errorMessage {
    if(onError) {
        onError(errorCode, errorMessage);
    }
}

@end

//
//  SJFileDownloadCallback.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJFileDownloadCallback.h"

@implementation SJFileDownloadCallback

@synthesize onDownloadProgress;
@synthesize onDownloadComplete;
@synthesize onError;

-(void)downloadProgressWithFileId:(NSString *)fileId
                         progress:(double)progress
                  downloadedBytes:(double)downloadedBytes
                       totalBytes:(long)totalBytes {
    if(onDownloadProgress) {
        onDownloadProgress(fileId, progress, downloadedBytes, totalBytes);
    }
}

-(void) downloadCompleteWithFileId:(NSString *)fileId
                         localPath:(NSString *)localPath {
    if(onDownloadComplete) {
        onDownloadComplete(fileId, localPath);
    }
}

-(void) errorWithCode:(int)errorCode
         errorMessage:(NSString *)errorMessage {
    if(onError) {
        onError(errorCode, errorMessage);
    }
}

@end

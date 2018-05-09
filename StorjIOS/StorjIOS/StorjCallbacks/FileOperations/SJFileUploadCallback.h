//
//  SJFileUploadCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJStorjErrorCallbackBlock.h"
#import "SJFile.h"

typedef void (^SJFileUploadCompleteCallBack)(SJFile *file);

typedef void (^SJFileUploadProgressCallbackBlock)(NSString *fileId,
                                                    double progress,
                                                    double uploadedBytes,
                                                    double totalBytes);

@interface SJFileUploadCallback : NSObject

@property (nonatomic, strong) SJFileUploadCompleteCallBack onSuccess;
@property (nonatomic, strong) SJErrorCallbackBlock onError;
@property (nonatomic, strong) SJFileUploadProgressCallbackBlock onProgress;

-(void) uploadProgressWithFileId:(NSString *)fileId
                       progress:(double) progress
                  uploadedBytes:(double) uploadedBytes
                     totalBytes:(double) totalBytes;

-(void) uploadComplete:(SJFile *) file;

-(void) errorWithCode:(int) errorCode
         errorMessage:(NSString *) errorMessage;

@end

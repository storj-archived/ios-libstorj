//
//  SJFileDownloadCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SJStorjErrorCallbackBlock.h"

typedef void (^SJFileDownloadProgressCallbackBlock)(NSString *fileId,
                                                    double progress,
                                                    double downloadedBytes,
                                                    double totalBytes);

typedef void (^SJFileDownloadComplete)(NSString *fileId,
                                       NSString *localPath);

@interface SJFileDownloadCallback : NSObject
@property (nonatomic) SJFileDownloadProgressCallbackBlock onDownloadProgress;
@property (nonatomic) SJFileDownloadComplete onDownloadComplete;
@property (nonatomic) SJErrorCallbackBlock onError;

-(void) downloadProgressWithFileId: (NSString *) fileId
                          progress:(double) progress
                   downloadedBytes: (double) downloadedBytes
                        totalBytes: (long) totalBytes;

-(void) downloadCompleteWithFileId:(NSString *) fileId
                         localPath:(NSString *) localPath;

-(void) errorWithCode:(int) errorCode
         errorMessage:(NSString *) errorMessage;

@end



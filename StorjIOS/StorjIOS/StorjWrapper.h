//
//  StorjWrapper.h
//  StorjIOS
//
//  Created by Andrea Tullis on 06/07/2017.
//  Copyright © 2017 angu2111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJRegistrationCallback.h"
#import "SJBucketCreateCallback.h"
#import "SJBucketListCallback.h"
#import "SJBucketDeleteCallback.h"
#import "SJBridgeInfoCallback.h"
#import "SJFileDeleteCallback.h"
#import "SJFileListCallback.h"
#import "SJFileDownloadCallback.h"
#import "SJFileUploadCallback.h"

#import "SJBucket.h"
#import "SJFile.h"
#import "SJKeys.h"

//@using StorjIOS;

typedef struct{
    void * _Nonnull handle;
    char *bucket_id;
    char *file_id;
    char *path;
} download_handle_t;

typedef struct {
    void *handle;
    char *bucket_id;
    char *file_name;
    char *path;
} upload_hadle_t;

#define STORJ_BRIDGE_RATE_ERROR 1005


@interface StorjWrapper : NSObject

-(instancetype _Nonnull) init;

-(instancetype _Nonnull) initWithHost:(NSString *_Nonnull)host
                                 port:(int) port
                          andProtocol:(NSString *_Nonnull)protocol;

-(NSString *_Nonnull) getErrorWithCode:(int) errorCode;

#pragma Bridge operations
-(void) getBridgeInfo:(SJBridgeInfoCallback *_Nonnull)callback;

-(void) setProxy:(NSString *_Nonnull)proxy;

-(UInt64) getTime;

#pragma mark - Mnemonic operations
-(NSString *_Nullable) generateMnemonic:(int)strength;

-(BOOL) checkMnemonic:(NSString *_Nonnull)mnemonic;

#pragma mark - User operations
-(void) registerUser:(NSString * _Nonnull)username
            password:(NSString * _Nonnull)password
        withCallback:(SJRegistrationCallback* _Nonnull) callback;

#pragma mark - Keys operations
-(BOOL) authFileExist;

-(SJKeys *_Nullable) getKeysWithPassphrase:(NSString *_Nonnull) passphrase;

-(BOOL) importKeys: (SJKeys *_Nonnull) keys
       andPassphrase:(NSString *_Nonnull) passphrase;

-(BOOL) deleteAuthFile;

-(BOOL) verifyKeysWithUserEmail:(NSString *_Nonnull) email
                    andPassword:(NSString *_Nonnull)password;

-(BOOL) verifyKeys: (SJKeys *_Nonnull) keys;

#pragma mark - Buckets operations
-(void) getBucketListWithCompletion:(SJBucketListCallback *_Nonnull)callback;

-(void) createBucket:(NSString *_Nonnull)bucketName
        withCallback:(SJBucketCreateCallback* _Nonnull)callback;

-(void) deleteBucket:(NSString *_Nonnull)bucketName
      withCompletion:(SJBucketDeleteCallback* _Nonnull)callback;


#pragma mark - File operations
-(void) listFilesForBucketId:(NSString *_Nonnull) bucketId
              withCompletion:(SJFileListCallback *_Nonnull)completion;

-(void) deleteFile:(NSString *_Nonnull)fileId
        fromBucket:(NSString * _Nonnull)bucketId
    withCompletion:(SJFileDeleteCallback * _Nonnull)completion;

#pragma mark - Download file operations
-(long) downloadFile:(NSString * _Nonnull)fileId
          fromBucket:(NSString * _Nonnull)bucketId
           localPath:(NSString * _Nonnull)localPath
      withCompletion:(SJFileDownloadCallback* _Nonnull) completion;

-(BOOL) cancelDownload: (long) fileRef;

#pragma mark - Upload file operations
-(long) uploadFile:(NSString * _Nonnull)file
          toBucket:(NSString * _Nonnull)bucketId
    withCompletion:(SJFileUploadCallback *_Nonnull)completion;

-(BOOL) cancelUpload:(long) fileRef;

@end


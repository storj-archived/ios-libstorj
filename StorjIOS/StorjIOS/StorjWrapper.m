//
//  StorjWrapper.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2018/02/03.
//  Copyright © 2018 Storj. All rights reserved.
//

#import "StorjWrapper.h"
#import <curl.h>
#import <StorjCompletionCallbacks.h>
#import "storj.h"

#define CLI_VERSION "libstorj-1.0.1"

#define DEFAULT_HOST @"api.storj.io"
#define DEFAULT_PORT 443
#define DEFAULT_PROTOCOL @"https"

@interface StorjWrapper ()
{
    NSString *_proto;
    NSString *_host;
    int _port;
    SJKeys *_keys;
    storj_env_t *_env;
}

@end

@implementation StorjWrapper

-(instancetype) init
{
    self = [self initWithHost:DEFAULT_HOST
                         port:DEFAULT_PORT
                  andProtocol:DEFAULT_PROTOCOL];
    
    return self;
}

-(instancetype) initWithHost: (NSString *)host
                        port: (int)port
                 andProtocol: (NSString *)protocol
{
    if(self = [super init])
    {
        _host = host;
        _port = port;
        _proto = protocol;
    }
    
    return self;
}

-(NSString *) generateMnemonic: (int) strength
{
    char *mnemonic = NULL;
    storj_mnemonic_generate(strength, &mnemonic);
    
    return mnemonic ? [NSString stringWithUTF8String:mnemonic] : nil;
}

-(BOOL) checkMnemonic: (NSString *) mnemonic
{
    if(!mnemonic)
    {
        return NO;
    }
    
    const char *cMnemonic = [mnemonic cStringUsingEncoding: NSUTF8StringEncoding];
    
    return storj_mnemonic_check(cMnemonic);
}

-(void) registerUser: (NSString *) username
            password: (NSString *) password
        withCallback: (SJRegistrationCallback * _Nonnull) callback
{
    
    storj_env_t *environment = [self initEnvironmentWithUser:username password:password mnemonic:nil];
    
    [self _registerUser:username password:password withCallback:callback onEnvironment:environment];
    
    [self runEventLoop:environment];
    
    [self destroyEnvironment:environment];
}

-(BOOL) authFileExist {
    NSLog(@"AuthFile path: %@", [self getAuthFilePath]);
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getAuthFilePath] isDirectory:NULL];
}

-(SJKeys *_Nullable) getKeysWithPassphrase:(NSString *_Nonnull) passphrase
{
    if(!_keys)
    {
        _keys = [self _exportKeysWithPassphrase:passphrase];
    }
    return _keys;
}

-(BOOL) importKeys: (SJKeys *_Nonnull) keys
     andPassphrase:(NSString *_Nonnull) passphrase
{
    NSLog(@"Import keys");
    int encryptionResult =
    storj_encrypt_write_auth([[self getAuthFile] cStringUsingEncoding:NSUTF8StringEncoding],
                             [passphrase cStringUsingEncoding:NSUTF8StringEncoding],
                             [[keys getEmail] cStringUsingEncoding:NSUTF8StringEncoding],
                             [[keys getPassword] cStringUsingEncoding:NSUTF8StringEncoding],
                             [[keys getMnemonic] cStringUsingEncoding:NSUTF8StringEncoding]);
    BOOL isSuccess = 0 == encryptionResult;
    if(isSuccess) {
        _keys = keys;
        [self destroyEnvironment:_env];
        _env = [self initEnvironmentWithKeys:keys];
        [self startLooper];
    }
    
    return isSuccess;
}

-(BOOL) deleteAuthFile {
    NSString *authFilePath = [self getAuthFile];
    NSError *error;
    if([[NSFileManager defaultManager] isDeletableFileAtPath:authFilePath]) {
        if([[NSFileManager defaultManager] removeItemAtPath:authFilePath error:&error]) {
            _keys = nil;
            return YES;
        } else {
            NSLog(@"Error while deleting auth file: %@", [error localizedDescription]);
            return NO;
        }
    }
    return NO;
}

-(BOOL) verifyKeysWithUserEmail:(NSString *)email
                    andPassword:(NSString *)password {
    
    NSLog(@"Verify keys");
    storj_env_t *environment = [self initEnvironmentWithUser:email password:password mnemonic:nil];
    __block BOOL isCompleted = NO;
    __block BOOL isVerificationSuccessfull = NO;
    
    SJBucketListCallback *callback = [[SJBucketListCallback alloc] init];
    
    callback.onSuccess = ^(NSArray<SJBucket *> * _Nullable bucketsArray) {
        isCompleted = YES;
        isVerificationSuccessfull = YES;
    };
    
    callback.onError = ^(int errorCode, NSString * _Nullable errorMessage) {
        isCompleted = YES;
        isVerificationSuccessfull = NO;
    };
    
    [self _getBucketListWithCompletion:callback
                         onEnvironment:environment];
    
    [self runEventLoop:environment];
    [self destroyEnvironment:environment];
    
    while(!isCompleted) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return isVerificationSuccessfull;
}

-(BOOL) verifyKeys: (SJKeys *_Nonnull) keys
{
#pragma mark TODO implement check for mnemonic verify
    return [self verifyKeysWithUserEmail:[keys getEmail] andPassword:[keys getPassword]];
}

-(void) getBucketListWithCompletion: (SJBucketListCallback *) callback
{
    if(![self checkEnvironment])
    {
        [callback errorWithCode:0 message:@"Unable to retreive environment"];
        return;
    }
    [self _getBucketListWithCompletion: callback onEnvironment: _env];
}

-(void) createBucket: (NSString *) bucketName
        withCallback: (SJBucketCreateCallback *) callback
{
    if(![self checkEnvironment])
    {
        [callback errorWithCode:0 message:@"Unable to retreive environment"];
        return;
    }
    
    [self _createBucket:bucketName withCallback:callback onEnvironment:_env];
}

-(void) deleteBucket: (NSString *) bucketName
      withCompletion: (SJBucketDeleteCallback *) callback
{
    if(![self checkEnvironment]){
        [callback errorWithCode:0 errorMessage:@"Unable to retreive environment"];
        return;
    }
    [self _deleteBucket:bucketName withCompletion:callback onEnvironment:_env];
}

-(void) listFilesForBucketId:(NSString *_Nonnull) bucketId
              withCompletion:(SJFileListCallback *_Nonnull)completion
{
    if(![self checkEnvironment]){
        [completion errorWithCode:0 errorMessage:@"Unable to retreive environment"];
        return;
    }
    
    [self _listFilesForBucketId:bucketId withCompletion:completion onEnvironment:_env];
}

-(void) deleteFile: (NSString *) fileId
        fromBucket: (NSString *) bucketId
    withCompletion: (SJFileDeleteCallback *) callback
{
    if(![self checkEnvironment]){
        [callback errorWithCode:0 errorMessage:@"Unable to retreive environment"];
        return;
    }
    
    [self _deleteFile:fileId fromBucket:bucketId withCompletion:callback onEnvironment:_env];
}

-(long) uploadFile: (NSString * _Nonnull) file
          toBucket: (NSString * _Nonnull) bucketId
    withCompletion: (SJFileUploadCallback * _Nonnull) completion
{
    if(![self checkEnvironment])
    {
        [completion errorWithCode:0 errorMessage:@"Unable to retreive environment"];
        
        return -1;
    }
    
    return [self _uploadFile:file toBucket:bucketId withCompletion:completion onEnvironment:_env];
}

-(long) uploadFile: (NSString * _Nonnull) file
          toBucket: (NSString * _Nonnull) bucketId
          fileName: (NSString * _Nonnull) fileName
    withCompletion: (SJFileUploadCallback * _Nonnull) completion
{
    if(![self checkEnvironment])
    {
        [completion errorWithCode:0 errorMessage:@"Unable to retreive environment"];
        
        return -1;
    }
    
    return [self _uploadFile:file toBucket:bucketId withCompletion:completion onEnvironment:_env];
}

-(BOOL) cancelUpload:(long) fileRef
{
    return [self _cancelUpload:fileRef];
}

-(long) downloadFile: (NSString *) fileId
          fromBucket: (NSString *) bucketId
           localPath: (NSString * _Nonnull) localPath
      withCompletion: (SJFileDownloadCallback * _Nonnull) callback
{
    if(![self checkEnvironment])
    {
        [callback errorWithCode:0 errorMessage:@"Unable to retreive environment"];
        return -1;
    }
    
    return [self _downloadFile:fileId
                    fromBucket:bucketId
                     localPath:localPath
                withCompletion:callback
                 onEnvironment:_env];
}

-(BOOL) cancelDownload: (long) fileRef
{
    return [self _cancelDownload: fileRef];
}

-(void)getBridgeInfo:(SJBridgeInfoCallback *) callback {
    storj_bridge_get_info(_env,
                          (__bridge void *)callback,
                          bridge_info_completion_callback);
}

-(BOOL) checkEnvironment
{
    
    if(![self getKeysWithPassphrase:@""])
    {
        return NO;
    }
    
    if(!_env)
    {
        _env = [self initEnvironmentWithUser: [_keys getEmail]
                                    password: [_keys getPassword]
                                    mnemonic: [_keys getMnemonic]];
        [self startLooper];
    }
    return YES;
}

-(storj_env_t *) initEnvironment {
    
    return [self initEnvironmentWithUser:nil password:nil mnemonic:nil];
}

-(storj_env_t *) initEnvironmentWithKeys: (SJKeys *) keys
{
    
    return [self initEnvironmentWithUser:[keys getEmail]
                                password:[keys getPassword]
                                mnemonic:[keys getMnemonic]];
}

-(storj_env_t *) initEnvironmentWithUser: (NSString *) user
                                password: (NSString *) password
                                mnemonic: (NSString *) mnemonic {
    NSLog(@"Init env with user: %@, pass: %@, mnem: %@", user, password, mnemonic);
    storj_bridge_options_t *bridge_options = malloc(sizeof(storj_bridge_options_t));;;
    bridge_options->proto = [_proto cStringUsingEncoding:NSUTF8StringEncoding];
    bridge_options->host  = [_host cStringUsingEncoding:NSUTF8StringEncoding];
    bridge_options->port  = _port;
    bridge_options->user = [user cStringUsingEncoding:NSUTF8StringEncoding];
    bridge_options->pass = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    storj_http_options_t *http_options = malloc(sizeof(storj_http_options_t));
    http_options->user_agent = CLI_VERSION;
    http_options->low_speed_limit = STORJ_LOW_SPEED_LIMIT;
    http_options->low_speed_time = STORJ_LOW_SPEED_TIME;
    http_options->timeout = STORJ_HTTP_TIMEOUT;
    http_options->cainfo_path = NULL;
    http_options->proxy_url = NULL;
    
    storj_encrypt_options_t *encrypt_options = malloc(sizeof(storj_encrypt_options_t));
    encrypt_options->mnemonic = [mnemonic cStringUsingEncoding:NSUTF8StringEncoding];
    
    storj_log_options_t *log_options = malloc(sizeof(storj_log_options_t));
    log_options->logger = json_logger;
    log_options->level = 4;
    
    storj_env_t *environment = storj_init_env(bridge_options, encrypt_options, http_options, log_options);
    if(!environment) {
        NSLog(@"Failed to initialize Storj Env");
        return nil;
    }
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootDir = dirPaths[0];
    const char * tmp_path = [rootDir cStringUsingEncoding:kCFStringEncodingUTF8];
    environment->tmp_path = strdup(tmp_path);
    environment->loop = (uv_loop_t *) malloc(sizeof(uv_loop_t));
    uv_loop_init(environment->loop);
    return environment;
}

-(void) destroyEnvironment:(storj_env_t *)environment {
    if(environment){
        NSLog(@"Env exist: %d, tmp exist: %d", environment != NULL, environment->tmp_path != NULL);
        uv_loop_close(environment->loop);
        free(environment->loop);
        storj_destroy_env(environment);
    }
}

-(void) startLooper {
    NSLog(@"Starting looper");
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"inside detach");
        int loopCount = 1;
        while(_env) {
            //            NSLog(@"LoopCount: %d", loopCount);
            [self runEventLoop:_env];
            [NSThread sleepForTimeInterval:0.005];
            loopCount++;
        }
    }];
    NSLog(@"End of startLoop");
}

-(void) runEventLoop:(storj_env_t *) environment{
    while(uv_run(environment->loop, UV_RUN_ONCE));
}

-(NSString *) getAuthDirectory {
    NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains
                               (NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    if(![[NSFileManager defaultManager]fileExistsAtPath:appSupportDir isDirectory:NULL]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:appSupportDir
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    return appSupportDir;
}

-(NSString *)getDocumentsDirectory {
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains
                                     (NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    return documentsDirectory;
}

-(NSString *) getAuthFilePath {
    
    return [@[self.getAuthDirectory, @"/api.storj.io.config.json"] componentsJoinedByString:@""];
}

-(NSString *) getAuthFile {
    NSString *authFilePath = [self getAuthFilePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:authFilePath isDirectory:NULL]) {
        [[NSFileManager defaultManager] createFileAtPath:authFilePath contents:nil attributes:nil];
    }
    
    return authFilePath;
}

-(void) _registerUser: (NSString *)username
             password: (NSString *)password
         withCallback: (SJRegistrationCallback * _Nonnull)callback
        onEnvironment: (storj_env_t *) environment
{
    storj_bridge_register(environment,
                          [username cStringUsingEncoding:NSUTF8StringEncoding],
                          [password cStringUsingEncoding:NSUTF8StringEncoding],
                          (__bridge void *)callback,
                          register_completion_callback);
}

-(SJKeys *) _exportKeysWithPassphrase:(NSString *) passphrase
{
    
    char * userEmail = NULL;
    char * userPassword = NULL;
    char * mnemonic = NULL;
    
    if(storj_decrypt_read_auth([[self getAuthFile] cStringUsingEncoding:NSUTF8StringEncoding],
                               [passphrase cStringUsingEncoding:NSUTF8StringEncoding],
                               &userEmail, &userPassword, &mnemonic))
    {
        return nil;
    }
    
    return [[SJKeys alloc] initWithEmail:[NSString stringWithUTF8String:userEmail]
                                password:[NSString stringWithUTF8String:userPassword]
                                mnemonic:[NSString stringWithUTF8String:mnemonic]];
}

-(void) _getBucketListWithCompletion:(SJBucketListCallback *) callback
                       onEnvironment: (storj_env_t *) environment
{
    storj_bridge_get_buckets(environment,
                             (__bridge_retained void *)callback,
                             bucket_list_completion_callback);
}

-(void) _createBucket: (NSString *) bucketName
         withCallback: (SJBucketCreateCallback *) callback
        onEnvironment: (storj_env_t *) environment
{
#pragma TODO free str
    char *cbucketName = strdup([bucketName cStringUsingEncoding:NSUTF8StringEncoding]);
    storj_bridge_create_bucket(environment,
                               cbucketName,
                               (__bridge_retained void *)callback,
                               bucket_create_completion_callback);
}

-(void) _deleteBucket: (NSString *) bucketName
       withCompletion: (SJBucketDeleteCallback *) callback
        onEnvironment: (storj_env_t *) environment
{
    const char *cBucketName = [bucketName cStringUsingEncoding:NSUTF8StringEncoding];
    storj_bridge_delete_bucket(environment,
                               cBucketName,
                               (__bridge_retained void *)callback,
                               bucket_delete_completion_callback);
}

-(void) _listFilesForBucketId:(NSString *_Nonnull) bucketId
               withCompletion:(SJFileListCallback *_Nonnull)completion
                onEnvironment: (storj_env_t *) environment
{
    storj_bridge_list_files(environment,
                            [bucketId cStringUsingEncoding:NSUTF8StringEncoding],
                            (__bridge_retained void *)completion,
                            file_list_completion_callback);
}

-(void) _deleteFile: (NSString *) fileId
         fromBucket: (NSString *) bucketId
     withCompletion: (SJFileDeleteCallback *) callback
      onEnvironment: (storj_env_t *) environment
{
    const char * bucket_id = [bucketId cStringUsingEncoding:NSUTF8StringEncoding];
    const char * file_id = [fileId cStringUsingEncoding:NSUTF8StringEncoding];
    printf("\nDeleting file at wrapper: from bucket: %s, fileID: %s\n", bucket_id, file_id);
    storj_bridge_delete_file(environment,
                             bucket_id,
                             file_id,
                             (__bridge_retained void *)callback,
                             file_delete_completion_callback);
}

-(long) _uploadFile: (NSString * _Nonnull) localPath
           toBucket: (NSString * _Nonnull) bucketId
           fileName: (NSString * _Nonnull) fileName
     withCompletion: (SJFileUploadCallback * _Nonnull) completion
      onEnvironment: (storj_env_t *) environment
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootDir = dirPaths[0];
    environment->tmp_path = strdup([rootDir cStringUsingEncoding:kCFStringEncodingUTF8]);
    
    storj_upload_state_t *upload_state = malloc(sizeof(storj_upload_state_t));
    NSString *filePath = nil;
    if(!localPath){
        return -1;
    }
    if([localPath hasPrefix:@"file://"]){
        filePath = [localPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    } else {
        filePath = localPath;
    }
    
    char * c_localPath = strdup([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
    FILE *fileWriter = fopen(c_localPath, "r");
    if(!fileWriter){
        
        NSLog(@"Error with openning file");
        return -1;
    }
    char *c_fileName;
    if(fileName)
    {
        c_fileName = strdup([fileName cStringUsingEncoding:NSUTF8StringEncoding]);
    } else
    {
        c_fileName = strdup([[localPath lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    char *c_bucketId = strdup([bucketId cStringUsingEncoding:NSUTF8StringEncoding]);
    
    storj_upload_opts_t upload_opts = {
        .prepare_frame_limit = 1,
        .push_frame_limit = 64,
        .push_shard_limit = 64,
        .rs = true,
        .index = NULL,
        .bucket_id = c_bucketId,
        .file_name = c_fileName,
        .fd = fileWriter
    };
    
    upload_state = storj_bridge_store_file(environment,
                                           &upload_opts,
                                           (__bridge_retained void *) completion,
                                           file_upload_progress_callback,
                                           file_upload_completion_callback);
    
    if(!upload_state || upload_state->error_status != 0 || upload_state == 0){
        return -1;
    }
    
    return (long)upload_state;
    
}

-(long) _uploadFile: (NSString * _Nonnull) file
           toBucket: (NSString * _Nonnull) bucketId
     withCompletion: (SJFileUploadCallback * _Nonnull) completion
      onEnvironment: (storj_env_t *) environment
{
    return [self _uploadFile: file
                    toBucket: bucketId
                    fileName: nil
              withCompletion: completion
               onEnvironment: environment];
}

#pragma mark TODO add checks for state casting result to prevent NPE
-(BOOL) _cancelUpload:(long) fileRef
{
    storj_upload_state_t *state = (storj_upload_state_t *) fileRef;
    int result = storj_bridge_store_file_cancel(state);
    printf("cancel upload result: %d", result);
    return result == 0;
}

-(long) _downloadFile: (NSString *) fileId
           fromBucket: (NSString *) bucketId
            localPath: (NSString * _Nonnull) localPath
       withCompletion: (SJFileDownloadCallback * _Nonnull) callback
        onEnvironment: (storj_env_t *) environment
{
    NSLog(@"download file: %@", localPath);
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath])
    {
        if(![[NSFileManager defaultManager] createFileAtPath:localPath contents:nil attributes:nil])
        {
            json_logger("Unable to create file", 4, NULL);
            return -1;
        } else {
            //            json_logger(localPath, 4, NULL);
        }
    }
    const char * path = [localPath cStringUsingEncoding:NSUTF8StringEncoding];
    const char * file_id = [fileId cStringUsingEncoding:NSUTF8StringEncoding];
    const char * bucket_id = [bucketId cStringUsingEncoding:NSUTF8StringEncoding];
    
    json_logger([[NSString stringWithFormat:@"before handle: path: %s, bucketID %s, fileID %s", path, bucket_id, fileId] cStringUsingEncoding:NSUTF8StringEncoding], 4, NULL);
    
    download_handle_t *download_handle = malloc(sizeof(download_handle_t));;
    download_handle->handle = (__bridge_retained void *)(callback);
    download_handle->bucket_id = strdup(bucket_id);
    download_handle->file_id = strdup(file_id);
    download_handle->path = strdup(path);
    json_logger([[NSString stringWithFormat:@"After handle: path: %s, FileID: %s, bucketID: %s",
                  download_handle->path,
                  download_handle->file_id,
                  download_handle->bucket_id] cStringUsingEncoding:NSUTF8StringEncoding], 4, NULL);
    FILE *fd = fopen(path, "w+");
    if(!fd)
    {
        json_logger("Unable to open file", 4, NULL);
        [callback errorWithCode:-1 errorMessage:@"Unable to open file"];
        return -1;
    }
    storj_download_state_t *state = storj_bridge_resolve_file(environment,
                                                              download_handle->bucket_id,
                                                              download_handle->file_id,
                                                              fd,
                                                              download_handle,
                                                              file_download_progress_callback,
                                                              file_download_completion_callback);
    
    if(!state)
    {
        json_logger(storj_strerror(STORJ_MEMORY_ERROR), 4, NULL);
        [callback errorWithCode:-1
                   errorMessage:[NSString stringWithFormat:@"%s",
                                 storj_strerror(STORJ_MEMORY_ERROR)]];
        return -1;
    }
    
    if (state->error_status)
    {
        json_logger(storj_strerror(state->error_status), 4, NULL);
        [callback errorWithCode:-1 errorMessage:[NSString stringWithFormat:@"%s",
                                                 storj_strerror(state->error_status)]];
        return -1;
    }
    
    return (long)state;
}

-(BOOL) _cancelDownload: (long) fileRef
{
    storj_download_state_t *state = (storj_download_state_t *) fileRef;
    int result = storj_bridge_resolve_file_cancel(state);
    
    return result == 0;
}

@end

//
//  StorjWrapper.m
//  StorjIOS
//
//  Created by Andrea Tullis on 06/07/2017.
//  Copyright © 2017 angu2111. All rights reserved.
//

#import "StorjWrapper.h"
#import "storj.h"
#import <curl.h>
#import <StorjCompletionCallbacks.h>
#define CLI_VERSION "libstorj-1.0.1"


@interface StorjWrapper () {
    storj_bridge_options_t bridge_options;
    storj_log_options_t log_options;
    storj_http_options_t http_options;
    storj_encrypt_options_t encrypt_options;
    storj_env_t *env;
    
}

@end

@implementation StorjWrapper

-(instancetype)init {
    self = [self initWithHost:@"api.storj.io" port:443 andProtocol:@"https"];
    
    return self;
}

-(instancetype)initWithHost:(NSString *)host
                       port:(int)port
                andProtocol:(NSString *)protocol {
    if(self = [super init]) {
        bridge_options.proto = [protocol cStringUsingEncoding:NSUTF8StringEncoding];
        bridge_options.host  = [host cStringUsingEncoding:NSUTF8StringEncoding];
        bridge_options.port  = port;
        bridge_options.user  = NULL;
        bridge_options.pass  = NULL;
        
        http_options.user_agent = CLI_VERSION;
        http_options.low_speed_limit = STORJ_LOW_SPEED_LIMIT;
        http_options.low_speed_time = STORJ_LOW_SPEED_TIME;
        http_options.timeout = STORJ_HTTP_TIMEOUT;
        encrypt_options.mnemonic = NULL;
        
        log_options.logger = json_logger;
        log_options.level = 4;
        env = storj_init_env(&bridge_options, NULL, &http_options, &log_options);
        env->tmp_path = [[NSTemporaryDirectory()stringByStandardizingPath] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    return self;
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

-(BOOL)authFileExist {
    NSLog(@"AuthFile path: %@", [self getAuthFilePath]);
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getAuthFilePath] isDirectory:NULL];
}

-(BOOL) verifyKeysWithUserEmail:(NSString *)email
                    andPassword:(NSString *)password {
    __block BOOL isCompleted = NO;
    __block BOOL isVerificationSuccessfull = NO;
        [self setUsername:email password:password];
        SJBucketListCallback *callback = [[SJBucketListCallback alloc] init];
        callback.onSuccess = ^(NSArray<SJBucket *> * _Nullable bucketsArray) {
            isCompleted = YES;
            isVerificationSuccessfull = YES;
        };
        callback.onError = ^(int errorCode, NSString * _Nullable errorMessage) {
            isCompleted = YES;
            isVerificationSuccessfull = NO;
        };
    [self getBucketListWithCompletion:callback];
    while(!isCompleted) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return isVerificationSuccessfull;
}

-(void)setProxy:(NSString *)proxy {
    const char *proxy_url = [proxy cStringUsingEncoding:NSUTF8StringEncoding];
    http_options.proxy_url = proxy_url;
    env = storj_init_env(&bridge_options, &encrypt_options, &http_options, &log_options);
}

-(BOOL) deleteAuthFile {
    NSString *authFilePath = [self getAuthFile];
    NSError *error;
    if([[NSFileManager defaultManager] isDeletableFileAtPath:authFilePath]) {
        if([[NSFileManager defaultManager] removeItemAtPath:authFilePath error:&error]) {
            return YES;
        } else {
            NSLog(@"Error while deleting auth file: %@", [error localizedDescription]);
            return NO;
        }
    }
    return NO;
}

-(void)getBridgeInfo:(SJBridgeInfoCallback *) callback; {
    storj_bridge_get_info(env,
                          (__bridge void *)callback,
                          bridge_info_completion_callback);
    
    uv_run(env->loop, UV_RUN_DEFAULT);
}

-(UInt64)getTime {
    
    return storj_util_timestamp();
}

-(NSString *)generateMnemonic:(int) strength {
    char *mnemonic = NULL;
    storj_mnemonic_generate(strength, &mnemonic);
    encrypt_options.mnemonic = mnemonic;
    env = storj_init_env(&bridge_options, &encrypt_options, &http_options, &log_options);
    env->tmp_path = [NSTemporaryDirectory() cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *mnemonicString = [[NSString alloc] initWithUTF8String: mnemonic];
    
    return mnemonicString;
}

-(void)setMnemonic:(NSString *_Nonnull) mnemonic
             error:(NSError *_Nullable *__null_unspecified) error {
    const char *cMnemonic = [mnemonic cStringUsingEncoding:NSUTF8StringEncoding];
    if(!storj_mnemonic_check(cMnemonic)) {
        *error = [[NSError alloc] initWithDomain:@"StorjWrapperErrorDomain" code:-1 userInfo:nil];
    }
    
    encrypt_options.mnemonic = cMnemonic;
    env = storj_init_env(&bridge_options, &encrypt_options, &http_options, &log_options);
    env->tmp_path = [NSTemporaryDirectory() cStringUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)getMnemonic {
    NSString *mnemonicString= [[NSString alloc] initWithUTF8String:encrypt_options.mnemonic];
    
    return mnemonicString;
}

-(BOOL) checkMnemonic {
    return storj_mnemonic_check(encrypt_options.mnemonic);
}

-(BOOL)checkMnemonic:(NSString *)mnemonic {
    NSError *error;
    [self setMnemonic:mnemonic error:&error];
    
    return [self checkMnemonic];
}

-(NSDictionary *)getKeysWithPassCode:(NSString *)passcode {
    int result = [self exportKeysWithPasscode:passcode];
    if(!env -> bridge_options -> user
       || !env -> bridge_options -> pass
       || !env -> encrypt_options -> mnemonic) {
        NSLog(@"KEYS ERROR");
    }
    if(result == 0) {
        return @{@"email": [NSString stringWithUTF8String:env -> bridge_options -> user],
                 @"password": [NSString stringWithUTF8String:env -> bridge_options -> pass],
                 @"mnemonic": [NSString stringWithUTF8String:env -> encrypt_options -> mnemonic]};
    } else {
        return nil;
    }
}

-(int)exportKeysWithPasscode:(NSString *) passcode {
    char * userEmail = NULL;
    char * userPassword = NULL;
    char * mnemonic = NULL;
    int decryptionResult = storj_decrypt_read_auth(
                                                   [[self getAuthFile] cStringUsingEncoding:NSUTF8StringEncoding],
                                                   [passcode cStringUsingEncoding:NSUTF8StringEncoding],
                                                   &userEmail, &userPassword, &mnemonic);
    if(decryptionResult == 0) {
        [self setUsername:[NSString stringWithUTF8String:userEmail]
                 password:[NSString stringWithUTF8String:userPassword]];
        NSError *error;
        [self setMnemonic:[NSString stringWithUTF8String:mnemonic] error: &error];
    }
    
    return decryptionResult;
}

-(BOOL)importKeysWithEmail:(NSString *)email
                  password:(NSString *)password
                  mnemonic:(NSString *)mnemonic
               andPasscode:(NSString *)passcode {
    int encryptionResult =
        storj_encrypt_write_auth([[self getAuthFile] cStringUsingEncoding:NSUTF8StringEncoding],
                                 [passcode cStringUsingEncoding:NSUTF8StringEncoding],
                                 [email cStringUsingEncoding:NSUTF8StringEncoding],
                                 [password cStringUsingEncoding:NSUTF8StringEncoding],
                                 [mnemonic cStringUsingEncoding:NSUTF8StringEncoding]);
    if(0 == encryptionResult) {
        [self setUsername:email password:password];
        NSError *error;
        
        [self setMnemonic:mnemonic error:&error];
    }
    
    return 0 == encryptionResult;
}

-(void)registerUser:(NSString *)username
           password:(NSString *)password
       withCallback:(SJRegistrationCallback * _Nonnull)callback {
    storj_bridge_register(env,
                          [username cStringUsingEncoding:NSUTF8StringEncoding],
                          [password cStringUsingEncoding:NSUTF8StringEncoding],
                          (__bridge void *)callback,
                          register_completion_callback);
    
    uv_run(env->loop, UV_RUN_DEFAULT);
}

-(void)getBucketListWithCompletion:(SJBucketListCallback *)callback {
        storj_bridge_get_buckets(env,
                                 (__bridge_retained void *)callback,
                                 bucket_list_completion_callback);
    
        uv_run(env->loop, UV_RUN_DEFAULT);
}

-(void)createBucket:(NSString *)bucketName
       withCallback:(SJBucketCreateCallback *)callback {
    storj_bridge_create_bucket(env,
                               [bucketName cStringUsingEncoding:NSUTF8StringEncoding],
                               (__bridge void *)callback,
                               bucket_create_completion_callback);
    
    uv_run(env->loop, UV_RUN_DEFAULT);
}

-(void)deleteBucket:(NSString *)bucketName
     withCompletion:(SJBucketDeleteCallback *)callback {
    const char *bucket_name = [bucketName cStringUsingEncoding:NSUTF8StringEncoding];
    storj_bridge_delete_bucket(env,
                               bucket_name,
                               (__bridge void *)callback,
                               bucket_delete_completion_callback);
    
    uv_run(env->loop, UV_RUN_DEFAULT);
}

-(void)setUsername:(NSString *)username
          password:(NSString *)password {
    bridge_options.user = [username cStringUsingEncoding:NSUTF8StringEncoding];
    bridge_options.pass = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    env = storj_init_env(&bridge_options, &encrypt_options, &http_options, &log_options);
}

-(long)uploadFile:(NSString * _Nonnull)file
         toBucket:(NSString * _Nonnull)bucketId
   withCompletion:(SJFileUploadCallback * _Nonnull)completion; {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootDir = dirPaths[0];
    env->tmp_path = [rootDir cStringUsingEncoding:kCFStringEncodingUTF8];
    
    storj_upload_state_t *upload_state = malloc(sizeof(storj_upload_state_t));
    NSString *fileName = nil;
    if(!file){
        return -1;
    }
    if([file hasPrefix:@"file://"]){
        fileName = [file stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    } else {
        fileName = file;
    }
    
    char * fname = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *fd = fopen(fname, "r");
    if(!fd){

        NSLog(@"Error with openning file");
        return -1;
    }
    storj_upload_opts_t upload_opts = {
        .prepare_frame_limit = 1,
        .push_frame_limit = 64,
        .push_shard_limit = 64,
        .rs = true,
        .index = NULL,
        .bucket_id = [bucketId cStringUsingEncoding:NSUTF8StringEncoding],
        .file_name = [[file lastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding],
        .fd = fd
    };
    
    upload_state = storj_bridge_store_file(env,
                            &upload_opts,
                            (__bridge_retained void *) completion,
                            file_upload_progress_callback,
                            file_upload_completion_callback);
    
    if(!upload_state || upload_state->error_status != 0 || upload_state == 0){
        return -1;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        uv_run(env->loop, UV_RUN_DEFAULT);
    });
    return (long)upload_state;
}

#pragma mark TODO add checks for state casting result to prevent NPE
-(BOOL) cancelUpload:(long) fileRef{
    storj_upload_state_t *state = (storj_upload_state_t *) fileRef;
    int result = storj_bridge_store_file_cancel(state);
    printf("cancel upload result: %d", result);
    return result == 0;
}

-(long)downloadFile:(NSString *)fileId
         fromBucket:(NSString *)bucketId
          localPath:(NSString * _Nonnull)localPath
     withCompletion:(SJFileDownloadCallback * _Nonnull) callback
{
    NSLog(@"download file: %@", localPath);
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]){
        if(![[NSFileManager defaultManager] createFileAtPath:localPath contents:nil attributes:nil]){
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
    if(!fd){
        json_logger("Unable to open file", 4, NULL);
        [callback errorWithCode:-1 errorMessage:@"Unable to open file"];
        return -1;
    }
    storj_download_state_t *state = storj_bridge_resolve_file(env,
                                                              download_handle->bucket_id,
                                                              download_handle->file_id,
                                                              fd,
                                                              download_handle,
                                                              file_download_progress_callback,
                                                              file_download_completion_callback);

    if(!state) {
        json_logger(storj_strerror(STORJ_MEMORY_ERROR), 4, NULL);
        [callback errorWithCode:-1
                   errorMessage:[NSString stringWithFormat:@"%s",
                                 storj_strerror(STORJ_MEMORY_ERROR)]];
        return -1;
    }
    
    if (state->error_status) {
        json_logger(storj_strerror(state->error_status), 4, NULL);
        [callback errorWithCode:-1 errorMessage:[NSString stringWithFormat:@"%s",
                                                 storj_strerror(state->error_status)]];
        return -1;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        uv_run(env->loop, UV_RUN_DEFAULT);
    });

    return (long)state;
}

-(BOOL) cancelDownload: (long) fileRef {
    storj_download_state_t *state = (storj_download_state_t *) fileRef;
    int result = storj_bridge_resolve_file_cancel(state);
    
    return result == 0;
}

-(void)deleteFile:(NSString *)fileId
       fromBucket:(NSString *)bucketId
   withCompletion:(SJFileDeleteCallback *)callback {
    const char * bucket_id = [bucketId cStringUsingEncoding:NSUTF8StringEncoding];
    const char * file_id = [fileId cStringUsingEncoding:NSUTF8StringEncoding];
    printf("\nDeleting file at wrapper: from bucket: %s, fileID: %s\n", bucket_id, file_id);
    storj_bridge_delete_file(env,
                             bucket_id,
                             file_id,
                             (__bridge void *)callback,
                             file_delete_completion_callback);
    
    uv_run(env->loop, UV_RUN_DEFAULT);
}

-(void)listFiles:(NSString *_Nonnull) bucketId
  withCompletion:(SJFileListCallback *_Nonnull)completion {
    
    storj_bridge_list_files(env,
                            [bucketId cStringUsingEncoding:NSUTF8StringEncoding],
                            (__bridge_retained void *)completion,
                            file_list_completion_callback);
    
    uv_run(env->loop, UV_RUN_DEFAULT);
}

@end

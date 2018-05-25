//
//  StorjCompletionCallbacks.m
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/13/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//
#define DEBUG 1

#import "StorjCompletionCallbacks.h"

void json_logger(const char *message, int level, void *handle)
{
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    NSString *filePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"storjLog.txt"]];
    
    FILE *fp;
    
    fp = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "a+");
    if(!fp){
        return;
    }
    fprintf(fp, "\nmessage: '%s', level: '%i'", message, level);
    fclose(fp);
}

void register_completion_callback(uv_work_t *work_req, int status){
    assert(status == 0);
    json_request_t *req = work_req->data;
    SJRegistrationCallback *callback = (__bridge SJRegistrationCallback *)req->handle;
    if (req->status_code != 201) {
        if(DEBUG){
            printf("Request failed with status code: %i\n", req->status_code);
        }
        struct json_object *error;
        json_object_object_get_ex(req->response, "error", &error);
        NSString *errorString = [NSString stringWithFormat:@"Error: %s",
                                 json_object_get_string(error)];
        [callback errorWithCode:req->status_code message:errorString];
    } else {
        struct json_object *email;
        json_object_object_get_ex(req->response, "email", &email);
        
        NSString *emailString = @"";
        if(email){
            emailString = [NSString stringWithUTF8String:json_object_get_string(email)];
        }
        if(DEBUG){
            printf("Successfully registered for %s.\n",
                   [emailString cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        [callback success:emailString];
        
        
    }
    json_object_put(req->response);
    json_object_put(req->body);
    free(req);
    free(work_req);
}

void bucket_delete_completion_callback(uv_work_t *work_req, int status)
{
    assert(status == 0);
    json_request_t *req = work_req->data;
    SJBucketDeleteCallback *callback = (__bridge SJBucketDeleteCallback *)req->handle;
    switch (req -> status_code) {
        case 200:
        case 204:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [callback success];
            });
            break;
        }
        case 401:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [callback errorWithCode:401 errorMessage:@"Invalid user credentials"];
            });
            break;
        }
        default:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [callback errorWithCode:req->status_code errorMessage:@"Failed to destroy bucket"];
            });
            break;
        }
    }

    json_object_put(req->response);
    free(req->path);
    free(req);
    free(work_req);
}

void bucket_list_completion_callback(uv_work_t *work_req, int status)
{
    assert(status == 0);
    get_buckets_request_t *req = work_req->data;
    
    SJBucketListCallback *callBack = (__bridge SJBucketListCallback *)req->handle;
    
    
    if (req->status_code == 401) {
        NSLog(@"Inv user cred");
        [callBack errorWithCode:req->status_code message:@"Invalid user credentials"];
        goto clean;
    } else if (req->status_code != 200 && req->status_code != 304) {
        NSLog(@"Req failed");
        [callBack errorWithCode:req->status_code message:@"Request failed"];
        goto clean;
    }
    if(DEBUG){
        NSLog(@"TotalBuckets: %d",req->total_buckets);
    }
    if(req->total_buckets > 0) {
        NSMutableArray *buckets = [NSMutableArray new];
        for (int i = 0; i < req->total_buckets; i++) {
            storj_bucket_meta_t *bucket = &req->buckets[i];
            if(DEBUG){
                printf("ID: %s \tDecrypted: %s \tCreated: %s \tName: %s\n",
                       bucket->id, bucket->decrypted ? "true" : "false",
                       bucket->created, bucket->name);
            }
            SJBucket *sjBucket = [[SJBucket alloc] initWithCharId:bucket->id
                                                             name:bucket->name
                                                          created:bucket->created
                                                             hash:0
                                                      isDecrypted:bucket->decrypted];
            [buckets addObject:sjBucket];
        }
        
        [callBack successWithArray: buckets];
    }
clean:
    storj_free_get_buckets_request(req);
    free(work_req);
}

void bucket_create_completion_callback(uv_work_t *work_req, int status)
{
    assert(status == 0);
    create_bucket_request_t *req = work_req->data;
    SJBucketCreateCallback * callback = (__bridge SJBucketCreateCallback *)req->handle;
    if (req->status_code == 404) {
        [callback errorWithCode:404
                        message:[NSString stringWithFormat:
                                 @"Cannot create bucket %s. Name already exists", req->bucket_name]];
        if(DEBUG){
            printf("Cannot create bucket [%s]. Name already exists \n", req->bucket->name);
        }
        goto clean_variables;
    } else if (req->status_code == 401) {
        [callback errorWithCode:401 message:@"Invalid user credentials"];
        if(DEBUG){
            printf("Invalid users credentials");
        }
        goto clean_variables;
    }
    
    if (req->status_code != 201) {
        [callback errorWithCode:201 message:@"Request failed"];
        if(DEBUG){
            printf("Request failed with status code: %i: %s\n",
                   req->status_code,
                   storj_strerror(req->status_code));
        }
        goto clean_variables;
    }
    
    if (req->bucket != NULL) {
        if(DEBUG){
            printf("Bucket created:\nid: %s \tDecrypted: %s \tName: %s \tCreated: %s\n",
                   req->bucket->id,
                   req->bucket->decrypted ? "true" : "false",
                   req->bucket->name,
                   req->bucket->created);
        }
        SJBucket *bucket = [[SJBucket alloc] initWithCharId:req->bucket -> id
                                                       name:req-> bucket -> name
                                                    created:req -> bucket -> created
                                                       hash:0
                                                isDecrypted:req -> bucket -> decrypted];
        [callback successWithSJBucket:bucket];
    } else {
        [callback errorWithCode:0 message:@"Failed to add bucket"];
    }
    
clean_variables:
    json_object_put(req->response);
    free((char *)req->encrypted_bucket_name);
    free(req->bucket);
    free(req);
    free(work_req);
}

void bridge_info_completion_callback(uv_work_t *work_req, int status)
{
    assert(status == 0);
    
    json_request_t *req = work_req->data;
    
    SJBridgeInfoCallback* callback = (__bridge SJBridgeInfoCallback *)req->handle;
    if (req->error_code || req->response == NULL) {
        free(req);
        free(work_req);
        if (req->error_code) {
            const char *errorMessage = curl_easy_strerror(req->error_code);
            printf("%s",errorMessage);
        }
        [callback errorWithCode:req->error_code message:@"Unknown error"];
        //TODO: Call the callback with an error
        exit(1);
    }
    
    struct json_object *info;
    json_object_object_get_ex(req->response, "info", &info);
    
    struct json_object *title;
    json_object_object_get_ex(info, "title", &title);
    struct json_object *description;
    json_object_object_get_ex(info, "description", &description);
    struct json_object *version;
    json_object_object_get_ex(info, "version", &version);
    struct json_object *host;
    json_object_object_get_ex(req->response, "host", &host);
    
    NSString *stringTitle = [[NSString alloc] initWithUTF8String:json_object_get_string(title)];
    NSString *stringDescription = [[NSString alloc] initWithUTF8String:json_object_get_string(description)];
    NSString *stringVersion = [[NSString alloc] initWithUTF8String:json_object_get_string(version)];
    NSString *stringHost = [[NSString alloc] initWithUTF8String:json_object_get_string(host)];
    
    [callback successWithDictionary:@{@"title":stringTitle,
                                      @"description":stringDescription,
                                      @"version": stringVersion,
                                      @"host":stringHost}];
    json_object_put(req->response);
    free(req);
    free(work_req);
}

void file_delete_completion_callback(uv_work_t *work_req, int status)
{
    assert(status == 0);
    json_request_t *req = work_req->data;
    SJFileDeleteCallback *callback = (__bridge SJFileDeleteCallback *) req->handle;
    
    switch (req -> status_code) {
        case 200:
        case 204:
            if(DEBUG){
                printf("File deleted successfully");
            }
            [callback success];
            break;
        case 401:
            if(DEBUG){
                printf("Invalid user credentials");
            }
            [callback errorWithCode:401 errorMessage:@"Invalid user credentials"];
            break;
        default:
            if(DEBUG){
                printf("Failed to remove file from bucket with code: %d", req -> status_code);
            }
            [callback errorWithCode:req -> status_code
                       errorMessage:@"Failed to remove file from bucket"];
            break;
    }
    
    json_object_put(req->response);
    free(req->path);
    free(req);
    free(work_req);
}

void file_list_completion_callback(uv_work_t *work_req, int status)
{
    assert(status == 0);
    list_files_request_t *req = work_req->data;
    SJFileListCallback *callback = (__bridge_transfer SJFileListCallback*)req->handle;

    if(req->status_code != 200){
        switch (req->status_code) {
            case 404:{
                if(DEBUG){
                    printf("Bucket id [%s] does not exist\n", req->bucket_id);
                }
                [callback errorWithCode:404 errorMessage:@"Bucket does not exist"];
                break;}
            case 400:{
                if(DEBUG){
                    printf("Bucket id [%s] is invalid\n", req->bucket_id);
                }
                [callback errorWithCode:400 errorMessage:@"Bucket id is invalid"];
                break;}
            case 401:{
                if(DEBUG){
                    printf("Invalid user credentials.\n");
                }
                [callback errorWithCode:401 errorMessage:@"Invalid user credentials"];
                break;}
            default:{
                if(DEBUG){
                    printf("Request failed with status code: %i\n", req->status_code);
                }
                [callback errorWithCode:req ->status_code
                            errorMessage:@"Request failed with unknown error"];
                break;}
        }
        goto cleanup;
    } else {
        
        if (req->total_files == 0) {
            if(DEBUG){
                printf("No files for bucket.\n");
            }
        }
        NSMutableArray *files = [NSMutableArray array];
        for (int i = 0; i < req->total_files; i++) {
            
            storj_file_meta_t *file = &req->files[i];
            SJFile *sjFile = [[SJFile alloc] initWithBucketId:req->bucket_id
                                                      created:file->created
                                                      erasure:file->erasure
                                                         hmac:file->hmac
                                                       fileId:file->id
                                                        index:file->index
                                                     mimeType:file->mimetype
                                                         name:file->filename
                                                         size:file->size
                                                  isDecrypted:file->decrypted];
            [files addObject:sjFile];
        }
        [callback successWithArray:files];
    }
    
cleanup:
    storj_free_list_files_request(req);
    free(work_req);
}

void file_download_progress_callback(double progress,
                   uint64_t downloaded_bytes,
                   uint64_t total_bytes,
                   void *handle)
{
    download_handle_t *download_handle = (download_handle_t *)handle;
    SJFileDownloadCallback * callback = (__bridge SJFileDownloadCallback *)download_handle->handle;
    
    NSString *fileId;
    if(download_handle->file_id){
        fileId = [NSString stringWithUTF8String:download_handle->file_id];
    } else {
        fileId = @"empty";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [callback downloadProgressWithFileId: fileId
                                    progress: progress
                             downloadedBytes: downloaded_bytes
                                  totalBytes: total_bytes];
    });
}

void file_download_completion_callback(int status, FILE *fd, void *handle) {
    download_handle_t *download_handle = (download_handle_t *)handle;
    SJFileDownloadCallback *callback = (__bridge SJFileDownloadCallback *)download_handle->handle;
    json_logger([[NSString stringWithFormat:@"download complete status: %d", status] cStringUsingEncoding:kCFStringEncodingUTF8], 4, NULL);
    if (status) {
        switch(status) {
            case STORJ_FILE_DECRYPTION_ERROR:{
                json_logger("Unable to decrypt file, check encryption keys.", 4, NULL);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callback errorWithCode:status
                               errorMessage:@"Unable to decrypt file, check encryption keys."];
                });
                break;
            }
            default:
                json_logger([[NSString stringWithFormat:@"Download failure: %d", status] cStringUsingEncoding:kCFStringEncodingUTF8], 4, NULL);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callback errorWithCode:status errorMessage:[NSString stringWithUTF8String:storj_strerror(status)]];
                });
        }
        
        return;
    }
    printf("Download Success!\n id: %s, localPath: %s", download_handle->file_id, download_handle->path);
    NSString *fileId;
    if(download_handle->file_id){
        fileId = [NSString stringWithUTF8String:download_handle->file_id];
    } else {
        json_logger("Wrong fileID", 4, NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
            [callback errorWithCode: -1 errorMessage:@"Wrong fileID"];
        });
        
        return;
    }
    
    NSString *localPath;
    if(download_handle->path){
        localPath = [NSString stringWithUTF8String:download_handle->path];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            json_logger("Wrong file path", 4, NULL);
            [callback errorWithCode:-1 errorMessage:@"Wrong file path"];
            
            return;
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [callback downloadCompleteWithFileId: fileId localPath:localPath];
    });

    free(download_handle->bucket_id);
    free(download_handle->file_id);
    
    free(download_handle->path);
//    free(download_handle);
}

void file_upload_completion_callback(int status,
                                     storj_file_meta_t *file,
                                     void *handle){
    SJFileUploadCallback *callback = (__bridge SJFileUploadCallback*)handle;
    if (status != 0) {
        json_logger([[NSString stringWithFormat:@"Upload failure: %s", storj_strerror(status)]
                     cStringUsingEncoding:kCFStringEncodingUTF8], 4, NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errorMessage = nil;
            if(storj_strerror(status)){
                errorMessage = [NSString stringWithUTF8String:storj_strerror(status)];
            }
            [callback errorWithCode:status errorMessage:errorMessage];
        });
        return;
    }
    __block SJFile *sjFile = [[SJFile alloc]initWithBucketId:file->bucket_id
                                             created:file->created
                                             erasure:file->erasure
                                                hmac:file->hmac
                                              fileId:file->id
                                               index:file->index
                                            mimeType:file->mimetype
                                                name:file->filename
                                                size:file->size
                                         isDecrypted:file->decrypted];
    NSString *logFile = [NSString stringWithFormat:@"Upload complete. SJFILE{ bucketId: %@, created: %@, erasure: %@, hmac: %@, id: %@, index: %@, mimetype: %@, filename: %@, size: %ld}", [sjFile _bucketId],
                         [sjFile _created],
                         [sjFile _erasure],
                         [sjFile _hmac],
                         [sjFile _fileId],
                         [sjFile _index],
                         [sjFile _mimeType],
                         [sjFile _name],
                         [sjFile _size]];
    
    json_logger([logFile cStringUsingEncoding:kCFStringEncodingUTF8], 4, NULL);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [callback uploadComplete:sjFile];
    });
}

void file_upload_progress_callback(double progress,
                                   uint64_t uploaded_bytes,
                                   uint64_t total_bytes,
                                   void *handle){
    SJFileUploadCallback *callback = (__bridge SJFileUploadCallback *)handle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [callback uploadProgressWithFileId:@"FileId"
                                  progress:progress
                             uploadedBytes:uploaded_bytes
                                totalBytes:total_bytes];
    });
}

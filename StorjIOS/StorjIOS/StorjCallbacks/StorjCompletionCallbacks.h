//
//  StorjCompletionCallbacks.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/13/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "storj.h"
#import "RegistrationOperations/SJRegistrationCallback.h"
#import "BucketOperations/SJBucketCreateCallback.h"
#import "BucketOperations/SJBucketDeleteCallback.h"
#import "BucketOperations/SJBucketListCallback.h"
#import "FileOperations/SJFileDeleteCallback.h"
#import "BridgeOperations/SJBridgeInfoCallback.h"
#import "SJFileListCallback.h"
#import "SJFileDownloadCallback.h"
#import "SJFileUploadCallback.h"
#import "../StorjWrapper.h"

void json_logger(const char *message,
                 int level,
                 void *handle);

void register_completion_callback(uv_work_t *work_req,
                                  int status);

void bucket_delete_completion_callback(uv_work_t *work_req,
                                       int status);

void bucket_list_completion_callback(uv_work_t *work_req,
                                     int status);

void bucket_create_completion_callback(uv_work_t *work_req,
                                       int status);


void download_file_progress_callback(double progress,
                                     uint64_t downloaded_bytes,
                                     uint64_t total_bytes,
                                     void *handle);

void download_file_complete_callback(int status,
                                     FILE *fd,
                                     void *handle);

void bridge_info_completion_callback(uv_work_t *work_req,
                                     int status);

void file_delete_completion_callback(uv_work_t *work_req,
                                     int status);

void file_list_completion_callback(uv_work_t *work_req,
                         int status);

void file_download_progress_callback(double progress,
                                     uint64_t downloaded_bytes,
                                     uint64_t total_bytes,
                                     void *handle);

void file_download_completion_callback(int status,
                                       FILE *fd,
                                       void *handle);

void file_upload_completion_callback(int status,
                                     storj_file_meta_t *file,
                                     void *handle);

void file_upload_progress_callback(double progress,
                                   uint64_t downloaded_bytes,
                                   uint64_t total_bytes,
                                   void *handle);

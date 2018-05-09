//
//  SJFile.h
//  StorjIOS
//
//  Created by Barterio on 3/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SJ_FILE_FILE_ID "fileId"
#define SJ_FILE_MIME_TYPE "mimeType"
#define SJ_FILE_NAME "name"
#define SJ_FILE_CREATED "created"
#define SJ_FILE_ERASURE "erasure"
#define SJ_FILE_HMAC "hmac"
#define SJ_FILE_INDEX "index"
#define SJ_FILE_IS_DECRYPTED "isDecrypted"
#define SJ_FILE_SIZE "size"

@interface SJFile : NSObject

@property (nonatomic, strong) NSString *_bucketId;
@property (nonatomic, strong) NSString *_created;
@property (nonatomic, strong) NSString *_erasure;
@property (nonatomic, strong) NSString *_hmac;
@property (nonatomic, strong) NSString *_fileId;
@property (nonatomic, strong) NSString *_index;
@property (nonatomic, strong) NSString *_mimeType;
@property (nonatomic, strong) NSString *_name;
@property long _size;
@property BOOL _isDecrypted;

-(instancetype)init;

-(instancetype) initWithBucketId: (const char *) bucketId
                         created: (const char *) created
                         erasure: (const char *) erasure
                            hmac: (const char *) hmac
                          fileId: (const char *) fileId
                           index: (const char *) index
                        mimeType: (const char *) mimeType
                            name: (const char *) name
                            size: (long) size
                     isDecrypted: (BOOL) isDecrypted;

@end

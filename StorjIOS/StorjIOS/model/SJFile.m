//
//  File.m
//  StorjIOS
//
//  Created by Barterio on 3/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJFile.h"

@implementation SJFile

@synthesize _bucketId;
@synthesize _fileId;
@synthesize _created;
@synthesize _name;
@synthesize _hmac;
@synthesize _index;
@synthesize _erasure;
@synthesize _mimeType;
@synthesize _size;
@synthesize _isDecrypted;

-(instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}

-(instancetype) initWithBucketId: (const char *) bucketId
                         created: (const char *) created
                         erasure: (const char *) erasure
                            hmac: (const char *) hmac
                          fileId: (const char *) fileId
                           index: (const char *) index
                        mimeType: (const char *) mimeType
                            name: (const char *) name
                            size: (long) size
                     isDecrypted: (BOOL) isDecrypted{
    
    if(self = [super init]){
        self._bucketId = [SJFile checkAndReturnStringFromChar:bucketId];
        self._created = [SJFile checkAndReturnStringFromChar:created];
        self._erasure = [SJFile checkAndReturnStringFromChar:erasure];
        self._hmac = [SJFile checkAndReturnStringFromChar:hmac];
        self._fileId = [SJFile checkAndReturnStringFromChar:fileId];
        self._index = [SJFile checkAndReturnStringFromChar:index];
        self._mimeType = [SJFile checkAndReturnStringFromChar:mimeType];
        self._name = [SJFile checkAndReturnStringFromChar:name];
        self._size = size;
        self._isDecrypted = isDecrypted;}
    return self;
}


+(NSString *) checkAndReturnStringFromChar:(const char *)value{
//    strncmp(value, "", )
    
    if(value && value != NULL){
        @try{
            return [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
//            return [NSString stringWithUTF8String:value];
        }
        @catch(NSException *e){
            return @"";
        }
    }
    return @"";
}

@end

//
//  SJBucket.m
//  StorjIOS
//
//  Created by Barterio on 3/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJBucket.h"

@implementation SJBucket
@synthesize _id, _hash, _name, _created, _isDecrypted;

-(instancetype) initWithId: (NSString *) bucketId
                      name: (NSString *) bucketName
                   created: (NSString *) created
                      hash: (long) hash
               isDecrypted: (BOOL) isDecrypted{
    if(self = [super init]){
        _id = bucketId;
        _name = bucketName;
        _created = created;
        _hash = hash;
        _isDecrypted = isDecrypted;
    }
    
    return self;
}

-(instancetype)initWithCharId: (const char *) bucketId
                         name: (const char *) bucketName
                      created: (const char *) created
                         hash: (long) hash
                  isDecrypted: (BOOL) isDecrypted{

    return [self initWithId: [SJBucket checkAndReturnStringFromChar: bucketId]
                       name: [SJBucket checkAndReturnStringFromChar: bucketName]
                    created: [SJBucket checkAndReturnStringFromChar: created]
                       hash: hash
                isDecrypted: isDecrypted];
}

+(NSString *) checkAndReturnStringFromChar:(const char *)value{
    
    if(value){
        return [[NSString alloc]initWithUTF8String:value];
    }
    return @"";
}

@end


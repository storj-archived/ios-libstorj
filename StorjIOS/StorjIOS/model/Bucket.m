//
//  SJBucket.m
//  StorjIOS
//
//  Created by Barterio on 3/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJBucket.h"

@implementation SJBucket
@synthesize _id, _hash, _name, _created, _isStarred, _isDecrypted;

-(instancetype) initWithId: (NSString *) bucketId
                      name: (NSString *) bucketName
                   created: (NSString *) created
                      hash: (long) hash
               isDecrypted: (BOOL) isDecrypted{
    
    return [self initWithId:bucketId
                       name:bucketName
                    created:created
                       hash:hash
                isDecrypted:isDecrypted
                  isStarred:NO];
}

-(instancetype) initWithId: (NSString *) bucketId
                      name: (NSString *) bucketName
                   created: (NSString *) created
                      hash: (long) hash
               isDecrypted: (BOOL) isDecrypted
                 isStarred: (BOOL) isStarred{
    if(self = [super init]){
        _id = bucketId;
        _name = bucketName;
        _created = created;
        _hash = hash;
        _isDecrypted = isDecrypted;
        _isStarred = isStarred;
    }
    return self;
    
}



@end

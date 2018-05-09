//
//  SJBucket.h
//  StorjIOS
//
//  Created by Barterio on 3/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJBucket : NSObject

@property (nonatomic, strong) NSString * _id;
@property (nonatomic, strong, getter=name) NSString * _name;
@property (nonatomic, strong, getter=created) NSString * _created;
@property long _hash;
@property BOOL _isDecrypted;

-(instancetype) initWithId: (NSString *) bucketId
                      name: (NSString *) bucketName
                   created: (NSString *) created
                      hash: (long) hash
               isDecrypted: (BOOL) isDecrypted;

-(instancetype)initWithCharId: (const char *) bucketId
                         name: (const char *) bucketName
                      created: (const char *) created
                         hash: (long) hash
                  isDecrypted: (BOOL) isDecrypted;



@end

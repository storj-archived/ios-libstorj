//
//  SJKeys.h
//  StorjIOS
//
//  Created by Barterio on 5/25/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJKeys : NSObject

-(instancetype) initWithEmail: (NSString *) email
                     password: (NSString *) password
                     mnemonic: (NSString *) mnemonic;

-(NSString *) getEmail;

-(NSString *) getPassword;

-(NSString *) getMnemonic;

-(BOOL) areKeysValid;

-(NSDictionary *) toDictionary;

@end

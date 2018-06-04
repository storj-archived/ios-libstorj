//
//  SJKeys.m
//  StorjIOS
//
//  Created by Barterio on 5/25/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJKeys.h"

@implementation SJKeys
{
    NSString *_email;
    NSString *_pass;
    NSString *_mnemonic;
}

-(instancetype) initWithEmail: (NSString *) email
                     password: (NSString *) password
                     mnemonic: (NSString *) mnemonic
{
    if(self = [super init])
    {
        _email = email;
        _pass = password;
        _mnemonic = mnemonic;
    }
    
    return self;
}

-(NSString *) getEmail
{
    return _email;
}

-(NSString *) getPassword
{
    return _pass;
}

-(NSString *) getMnemonic
{
    return _mnemonic;
}

-(BOOL) areKeysValid
{
    return _email && _email.length > 0 && _pass && _pass.length > 0 && _mnemonic && _mnemonic.length > 0;
}

-(NSDictionary *) toDictionary
{
    
    return @{
             @"email" : _email ? _email : @"(nil)",
             @"password" : _pass ? _pass : @"(nil)",
             @"mnemonic" : _mnemonic ? _mnemonic : @"(nil)"
             };
}


@end

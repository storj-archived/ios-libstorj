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
    NSString *_user;
    NSString *_pass;
    NSString *_mnemonic;
}

-(instancetype) initWithUser: (NSString *) user
                    password: (NSString *) password
                    mnemonic: (NSString *) mnemonic
{
    if(self = [super init])
    {
        _user = user;
        _pass = password;
        _mnemonic = mnemonic;
    }
    
    return self;
}

-(NSString *) getUser
{
    return _user;
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
    return _user && _user.length > 0 && _pass && _pass.length > 0 && _mnemonic && _mnemonic.length > 0;
}

-(NSDictionary *) toDictionary
{
    
    return @{
             @"user" : _user ? _user : @"(nil)",
             @"password" : _pass ? _pass : @"(nil)",
             @"mnemonic" : _mnemonic ? _pass : @"(nil)"
             };
}


@end

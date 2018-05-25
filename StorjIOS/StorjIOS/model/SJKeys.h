//
//  SJKeys.h
//  StorjIOS
//
//  Created by Barterio on 5/25/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJKeys : NSObject

-(instancetype) initWithUser: (NSString *) user
                    password: (NSString *) password
                    mnemonic: (NSString *) mnemonic;

-(NSString *) getUser;

-(NSString *) getPassword;

-(NSString *) getMnemonic;

-(NSDictionary *) describeKeys;

@end

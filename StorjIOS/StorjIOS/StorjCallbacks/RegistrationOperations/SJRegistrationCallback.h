//
//  SJRegistrationCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 1/29/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJStorjErrorCallbackBlock.h"

typedef void(^SJSuccessRegistrationCallbackBlock)(NSString * _Nonnull email);

@interface SJRegistrationCallback : NSObject

@property (nonatomic) SJSuccessRegistrationCallbackBlock _Nonnull onSuccess;
@property (nonatomic) SJErrorCallbackBlock _Nonnull onError;

-(void)success:(NSString *_Nonnull)email;

-(void)errorWithCode:(int) errorCode message:(NSString *_Nonnull)message ;

@end

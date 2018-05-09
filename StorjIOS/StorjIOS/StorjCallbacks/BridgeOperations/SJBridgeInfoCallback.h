//
//  SJBridgeInfoCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJStorjErrorCallbackBlock.h"

typedef void (^SJBridgeInfoCallbackBlock)(NSDictionary * _Nonnull infoDictionary);

@interface SJBridgeInfoCallback : NSObject

@property (nonatomic) SJBridgeInfoCallbackBlock _Nonnull onSuccess;
@property (nonatomic) SJErrorCallbackBlock _Nonnull onError;

-(void) successWithDictionary:(NSDictionary *_Nonnull) infoDictionary;

-(void) errorWithCode:(int) errorCode message:(NSString *_Nonnull) errorMessage;

@end



//
//  SJFileListCallback.h
//  StorjIOS
//
//  Created by Bogdan Artemenko on 2/12/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJStorjErrorCallbackBlock.h"
#import "SJFile.h"

typedef void (^SJFileListCallbackBlock)(NSArray<SJFile *> * _Nullable fileArray);

@interface SJFileListCallback : NSObject

@property (nonatomic) _Nonnull SJFileListCallbackBlock onSuccess;
@property (nonatomic) _Nonnull SJErrorCallbackBlock onError;

-(void) successWithArray:(NSArray<SJFile *>*_Nonnull) fileArray;

-(void) errorWithCode:(int)errorCode errorMessage:(NSString *_Nonnull)errorMessage;

@end

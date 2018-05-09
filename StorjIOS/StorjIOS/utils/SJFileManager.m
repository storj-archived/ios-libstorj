//
//  SJFileManager.m
//  StorjIOS
//
//  Created by Barterio on 4/23/18.
//  Copyright © 2018 Bogdan Artemenko. All rights reserved.
//

#import "SJFileManager.h"

@implementation SJFileManager

+(NSString *)applicationDirectory{
    NSString *applicationDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    if(![[NSFileManager defaultManager]fileExistsAtPath:applicationDirectory isDirectory:NULL]){
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    return applicationDirectory;
}

+(NSString *) getAuthFilePath{
    return nil;
}

@end

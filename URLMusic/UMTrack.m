//
//  UMTrack.m
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import "UMTrack.h"

@implementation UMTrack

- (instancetype)initWithName:(NSString *)name artist:(NSString *)artist previewUrl:(NSString *)previewUrl
{
    self = [super init];
    if (self) {
        self.name = [name copy];
        self.artist = [artist copy];
        self.previewUrl = [previewUrl copy];
    }
    return self;
}

@end

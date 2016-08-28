//
//  UMTrack.h
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMTrack : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *previewUrl;

- (instancetype)initWithName:(NSString *)name
                      artist:(NSString *)artist
                  previewUrl:(NSString *)previewUrl;

@end

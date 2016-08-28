//
//  UMDownload.m
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import "UMDownload.h"

@implementation UMDownload


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.url = nil;
        self.state = UMDownloadNULL;
        self.downloading = NO;
        self.paused = NO;
        self.progress = 0.0;
        self.resumeData = nil;
        self.downloadTask = nil;
    }
    return self;
}

+ (instancetype)downloadWithURLString:(NSString *)url
{
    UMDownload *download = [[UMDownload alloc] init];
    download.url = [url copy];
    
    return download;
}

@end

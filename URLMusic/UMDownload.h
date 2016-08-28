//
//  UMDownload.h
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    UMDownloadNULL,
    UMDownloadDownloading,
    UMDownloadPaused,
    UMDownloadDownloaded,
} UMDownloadState;


@interface UMDownload : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) UMDownloadState state;
@property (nonatomic, assign, getter=isDownloading) BOOL downloading;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, copy) NSData *resumeData;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

+ (instancetype)downloadWithURLString:(NSString *)url;

@end

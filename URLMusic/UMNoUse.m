//
//  UMNoUse.m
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import "UMNoUse.h"

@implementation UMNoUse




+ (void)test2
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"doc %@", doc);
    
    NSURL *imgURL = [NSURL URLWithString:@"http://www.uwing.cn/wp-content/uploads/2014/11/20c4923e2b68839ceb6268cfe5dc3d53.jpg"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:imgURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"---%@", location);
        NSLog(@"----- %@,   %@, %lld, %@", response.MIMEType, response.suggestedFilename, response.expectedContentLength, response.textEncodingName);
        if (location) {
            //            NSString *to = [doc stringByAppendingPathComponent:@"123.jpg"];
            //            NSString *from = [NSString stringWithFormat:@"%@", location];
            //            NSError *err;
            //            [[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:&err];
            //            NSLog(@"err %@", err);
        }
        
    }];
    
    [task resume];
}

+ (void)test1
{
    NSURL *url = [NSURL URLWithString:@"http://www.jianshu.com"];
    NSURLSession *session = [NSURLSession sharedSession];
    //    NSURLSessionDataTask *dtask = [session dataTaskWithURL:url];
    NSURLSessionDataTask *dtask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [dtask resume];
    
    NSLog(@"%ld", dtask.state);
    NSLog(@"%@", dtask.description);
}


@end

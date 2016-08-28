//
//  ViewController.m
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import "ViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>


#import "UMTrackCell.h"
#import "UMTrack.h"
#import "UMDownload.h"



@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSURLSessionDownloadDelegate, UMTrackCellDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dTask;

@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *downloadArray;


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

static NSString * const ID = @"TrackCell";

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _session;
}

- (NSMutableArray *)resultArray
{
    if (!_resultArray) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

- (NSMutableArray *)downloadArray
{
    if (!_downloadArray) {
        _downloadArray = [NSMutableArray array];
    }
    return _downloadArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = tColor;
    
    self.searchBar.text = @"dangerous";
    [self.searchBar becomeFirstResponder];
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *text = searchBar.text;
    if (!text.length) return;
    
    // 通知用户需要使用网络 显示在状态栏 转圈圈
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 转义字符串 确保url可用
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *searchTerm = [text stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?media=music&entity=song&term=%@", searchTerm];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    self.dTask = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 主线程 关闭网络转圈圈
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                [self updateResultData:data];
            }
        }
    }];
    
    [self.dTask resume];
}

- (void)updateResultData:(NSData *)data
{
    if (!data) return;
    
    NSError *err;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"%@", err.localizedDescription);
        return;
    }
    
//    NSLog(@"%@", response);
    [self.resultArray removeAllObjects];
    [self.downloadArray removeAllObjects];
    
    NSArray *result = response[@"results"];
    for (NSDictionary *trackDick in result) {
        NSString *name = trackDick[@"trackName"];
        NSString *artist = trackDick[@"artistName"];
        NSString *previewUrl = trackDick[@"previewUrl"];
        
        UMTrack *track = [[UMTrack alloc] initWithName:name artist:artist previewUrl:previewUrl];
        [self.resultArray addObject:track];
        
        UMDownload *download = [UMDownload downloadWithURLString:previewUrl];
        [self.downloadArray addObject:download];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointZero animated:NO];
    });
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.delegate = self;
    
    UMTrack *track = self.resultArray[indexPath.row];
    cell.titleLabel.text = track.name;
    cell.artistLabel.text = track.artist;
    
    // 是否已经下载
    BOOL downloaded = [self localFileExistsForTrack:track];
    
    UMDownload *download = self.downloadArray[indexPath.row];
    BOOL downloading = download.isDownloading;
    
    // 正在下载
    if (downloading) {
        cell.progressView.progress = download.progress;
        // 是否暂停
        cell.progressLabel.text = download.isPaused?@"Paused":@"Downloading...";
//        cell.pauseButton.selected = download.isPaused;
        [cell.pauseButton setTitle:download.isPaused?@"Resume":@"Pasue" forState:UIControlStateNormal];
    }
    
    // 按钮状态
    cell.progressView.hidden = !downloading;
    cell.pauseButton.hidden = !downloading;
    cell.cancelButton.hidden = !downloading;
    cell.progressLabel.hidden = !downloading;
    
    cell.downloadButton.hidden = downloaded || downloading;
    
    // cell 选中状态
    cell.selectionStyle = downloaded?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMTrack *track = self.resultArray[indexPath.row];
    if ([self localFileExistsForTrack:track]) {
        NSURL *url = [self localFilePathWithURLString:track.previewUrl];
//        MPMoviePlayerViewController *mpv = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
//        [self presentMoviePlayerViewControllerAnimated:mpv];
        
        AVPlayerViewController *avpv = [AVPlayerViewController new];
        avpv.player = [AVPlayer playerWithURL:url];
        [avpv.player play];
        [self presentViewController:avpv animated:YES completion:nil];
        [self presentViewController:avpv animated:YES completion:^{
            if (avpv) {
                
            }
        }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UMTrackCellDelegate

/**
 *  下载按钮点击
 */
- (void)trackCellDownloadButtonDidClick:(UMTrackCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 下载
    UMDownload *download = self.downloadArray[indexPath.row];
    download.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:download.url]];
    [download.downloadTask resume];
    download.downloading = YES;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/**
 *  取消
 */
- (void)trackCellCancelButtonDidClick:(UMTrackCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    UMDownload *download = self.downloadArray[indexPath.row];
    [download.downloadTask cancel];
    download.downloadTask = nil;
    download.downloading = NO;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/**
 *  暂停或继续
 */
- (void)trackCellPauseORResumeButtonDidClick:(UMTrackCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UMDownload *download = self.downloadArray[indexPath.row];
    
    if (download.isDownloading) {
        if (!download.isPaused) { // 正在下载 --> 暂停
            __weak typeof(download) wkDownload = download;
            [download.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (resumeData) {
                    wkDownload.resumeData = resumeData;
                }
            }];
            download.downloadTask = nil;
        } else {        // 正在暂停 －－> 恢复下载
            if (download.resumeData) { // 有数据
                download.downloadTask = [self.session downloadTaskWithResumeData:download.resumeData];
            } else {                   // 没有数据
                download.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:download.url]];
            }
            [download.downloadTask resume];
        }
        
        download.paused = !download.isPaused;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}




#pragma mark - NSURLSessionDownloadDelegate

/**
 *  下载结束
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
//    NSLog(@"finish %@", location.path);
    NSString *urlString = downloadTask.originalRequest.URL.absoluteString;
    
    // 拷贝文件
    NSURL *destinationURL = [self localFilePathWithURLString:urlString];
//    NSLog(@"dest %@", destinationURL);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:destinationURL error:nil];
    NSError *err;
    [fileManager copyItemAtURL:location toURL:destinationURL error:&err];
    if (err) {
        NSLog(@"%@", err.localizedDescription);
    }
    
    __block NSIndexPath *indexPath;
    [self.downloadArray enumerateObjectsUsingBlock:^(UMDownload *download, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([download.url isEqualToString:urlString]) {
            *stop = YES;
            download.downloading = NO;
            download.downloadTask = nil;
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        }
    }];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", urlString];
//    NSArray *filteredArray = [self.downloadArray filteredArrayUsingPredicate:predicate];
//    UMDownload *download = [filteredArray firstObject];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

/**
 *  监控进度
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //找到正在下载的download
    __block UMDownload *download;
    __block NSIndexPath *indexPath;
    NSString *urlString = downloadTask.originalRequest.URL.absoluteString;
    [self.downloadArray enumerateObjectsUsingBlock:^(UMDownload *download1, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([download1.url isEqualToString:urlString]) {
            *stop = YES;
            download = download1;
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        }
    }];
    
    //计算下载进度
    download.progress = totalBytesWritten / totalBytesExpectedToWrite;
    
    //计算下载文件大小。NSByteCountFormatter能将字节值转换为可读字符串
    NSString *totalSize = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleBinary];

    // 更新cell
    dispatch_async(dispatch_get_main_queue(), ^{
        UMTrackCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.progressView.progress = download.progress;
        cell.progressLabel.text = [NSString stringWithFormat:@"%.1f%% of %@", download.progress * 100, totalSize];
    });

}




#pragma mark - 文件是否存在

/**
 *  对应本地文件
 */
- (NSURL *)localFilePathWithURLString:(NSString *)urlString
{
    // 存放在doc下
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSString *lastPathComponent = url.lastPathComponent;
    NSString *lastPathComponent = [urlString lastPathComponent];
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:lastPathComponent];
    return [NSURL fileURLWithPath:fullPath];
}

/**
 *  是否已存在
 */
- (BOOL)localFileExistsForTrack:(UMTrack *)track
{
    NSURL *localUrl = [self localFilePathWithURLString:track.previewUrl];
    return [[NSFileManager defaultManager] fileExistsAtPath:localUrl.path];
}





@end

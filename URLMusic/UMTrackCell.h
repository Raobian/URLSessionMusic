//
//  UMTrackCell.h
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMTrackCell;

@protocol UMTrackCellDelegate <NSObject>

- (void)trackCellDownloadButtonDidClick:(UMTrackCell *)cell;
- (void)trackCellCancelButtonDidClick:(UMTrackCell *)cell;
- (void)trackCellPauseORResumeButtonDidClick:(UMTrackCell *)cell;

@end



@interface UMTrackCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (nonatomic, weak)  id<UMTrackCellDelegate> delegate;

@end

//
//  UMTrackCell.m
//  URLMusic
//
//  Created by 边文辉 on 16/8/28.
//  Copyright © 2016年 bianwenhui. All rights reserved.
//

#import "UMTrackCell.h"


@interface UMTrackCell ()



@end


@implementation UMTrackCell

- (void)awakeFromNib {
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)downloadBtnDidClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackCellDownloadButtonDidClick:)]) {
        [self.delegate trackCellDownloadButtonDidClick:self];
    }
}

- (IBAction)cancelBtnDidClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackCellCancelButtonDidClick:)]) {
        [self.delegate trackCellCancelButtonDidClick:self];
    }
}

- (IBAction)pauseOrResumeDidClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(trackCellPauseORResumeButtonDidClick:)]) {
        [self.delegate trackCellPauseORResumeButtonDidClick:self];
    }
}




@end

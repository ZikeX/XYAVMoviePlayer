//
//  XYAVMoviePlayer.m
//  XYAVMoviePlayerExample
//
//  Created by xiaoyu on 2016/10/14.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "XYAVMoviePlayer.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XYAVMoviePlayer ()

@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@end

@implementation XYAVMoviePlayer {
    NSTimer *durationTimer;
}

#pragma mark - init
-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithImage:(UIImage *)image{
    return [self init];
}

-(instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage{
    return [self init];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupPlayer];
        [self setFrame:frame];
    }
    return self;
}

#pragma mark - setup
-(void)setupPlayer{
    if (self.playerLayer) {
        return;
    }
    
    self.mediaPlayerView = [[UIView alloc] init];
    self.mediaPlayerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.mediaPlayerView];
    
    self.shortCutImageView = [[UIImageView alloc] init];
    self.shortCutImageView.backgroundColor = [UIColor clearColor];
    [self.mediaPlayerView addSubview:self.shortCutImageView];
    
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.mediaPlayerView.layer addSublayer:self.playerLayer];
    
//    self.unMuteVolumn = [AVAudioSession sharedInstance].outputVolume;
//    self.currentVolumn = self.unMuteVolumn;
    
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
}

- (void)startDurationTimer {
    [durationTimer invalidate];
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:durationTimer forMode:UITrackingRunLoopMode];
}

- (void)stopDurationTimer {
    [durationTimer invalidate];
}

-(void)monitorVideoPlayback{
    CMTime currentTimeCM = self.playerLayer.player.currentTime;
    CMTime durationTimeCM = self.playerLayer.player.currentItem.duration;
    if (currentTimeCM.timescale == 0 || durationTimeCM.timescale == 0) {
        return;
    }
    long currentTimeK = currentTimeCM.value*1000/currentTimeCM.timescale;
    long totalTimeK = durationTimeCM.value*1000/durationTimeCM.timescale;
    
    if (self.playerLayer.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
//        NSLog(@"AVPlayerTimeControlStatusPlaying");
        
    }else if(self.playerLayer.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate){
//        NSLog(@"AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate");
        //没有收到buffer
        
    }else if (self.playerLayer.player.timeControlStatus == AVPlayerTimeControlStatusPaused){
//        NSLog(@"AVPlayerTimeControlStatusPaused");
    }
    
//    if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying ||
//        self.moviePlayerController.playbackState == MPMoviePlaybackStateSeekingForward ||
//        self.moviePlayerController.playbackState == MPMoviePlaybackStateSeekingBackward ) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(player:didPlayerTimePass:timeTotal:)]) {
//            [self.delegate player:self didPlayerTimePass:currentTime timeTotal:totalTime];
//        }
//    }
}

#pragma mark - control
// Plays items from the current queue, resuming paused playback if possible.
- (void)play {
    [self.playerLayer.player play];
    [self startDurationTimer];
}

// Pauses playback if playing.
- (void)pause {
    [self.playerLayer.player pause];
    [self stopDurationTimer];
}

// Ends playback. Calling -play again will start from the beginnning of the queue.
- (void)stop {
    [self pause];
    [self stopDurationTimer];
}

-(void)jumpToTime:(float)progress {
    CMTime durationTimeCM = self.playerLayer.player.currentItem.duration;
    if (durationTimeCM.timescale == 0) {
        return;
    }
    long totalTime = durationTimeCM.value/durationTimeCM.timescale;
    [self.playerLayer.player seekToTime:CMTimeMakeWithSeconds(totalTime*progress, 1 *NSEC_PER_SEC)];
    [self play];
}

-(void)changePlayingVolumn:(float)aVolumn{
    if (aVolumn == 0) {
        _mute = YES;
    }else{
        _mute = NO;
    }
    self.playerLayer.player.volume = aVolumn;
}

#pragma mark - setter & getter
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.mediaPlayerView.frame = self.bounds;
    self.playerLayer.frame = self.mediaPlayerView.bounds;
    self.shortCutImageView.frame = self.mediaPlayerView.bounds;
}

- (void)setMute:(BOOL)mute {
    _mute = mute;
    [self.playerLayer.player setMuted:mute];
}

-(void)setPlayURL:(NSString *)playURL{
    _playURL = playURL;
    if (playURL) {
        NSURL *sourceMovieURL = [NSURL URLWithString:playURL];
        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        self.playerLayer.player = player;
        
        [self changePlayingVolumn:self.currentVolumn];
    }
}

-(void)setCurrentVolumn:(float)currentVolumn{
    [self changePlayingVolumn:currentVolumn];
}

-(float)currentVolumn{
    if (self.mute) {
        return 0;
    }
    return self.playerLayer.player.volume;
}

@end
//
//  WAMPMusicPlayerViewController.m
//  AudioDemo
//
//  Created by Jayaprada Behera on 01/04/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAMPMusicPlayerViewController.h"
#import "GVMusicPlayerController.h"
#include "NSString+TimeToString.h"

@interface WAMPMusicPlayerViewController ()<GVMusicPlayerControllerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *TrackCurrentPlaybackTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *trackLengthLbl;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;

@property (weak, nonatomic) IBOutlet UILabel *artistNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *songNameLbl;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) NSTimer *timer;
@property BOOL panningProgress;
@property BOOL panningVolume;

- (IBAction)nextButtonTouchUpInside:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)prevButtonTouchUpInside:(id)sender;
- (IBAction)playpauseButtonTouchUpInside:(id)sender;
- (IBAction)trackProgressChanged:(id)sender;
- (IBAction)repeatButtonTouchUpInside:(id)sender;
- (IBAction)shuffleButtonTouchUpInside:(id)sender;
- (IBAction)progressEnd;
- (IBAction)volumeEnd;
@end

@implementation WAMPMusicPlayerViewController
@synthesize setIndexOfPlayingCellCallBack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}
- (void)viewWillAppear:(BOOL)animated {
    
    // NOTE: add and remove the WAMusicPlayerController delegate in
    // the viewWillAppear / viewDidDisappear methods, not in the
    // viewDidLoad / viewDidUnload methods - it will result in dangling
    // objects in memory.
    
    [super viewWillAppear:animated];
    
    [[GVMusicPlayerController sharedInstance] addDelegate:self];
    
}
- (void)viewDidDisappear:(BOOL)animated {
//    [[WAMusicPlayerController sharedInstance] removeDelegate:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
  
    if (self.isPlayNewSong) {
        [[GVMusicPlayerController sharedInstance] setQueueWithItemCollection:self.mediaItemCollection];
        [[GVMusicPlayerController sharedInstance] play];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
    [self.timer fire];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:backBarButton];

}

-(IBAction)backButtonTapped:(id)sender{
    
    if(self.setIndexOfPlayingCellCallBack){
        self.setIndexOfPlayingCellCallBack(self.nowPlayingSongItemIndexValue,self.nowPlayingSongState);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.shuffleButton.selected = ([GVMusicPlayerController sharedInstance].shuffleMode != MPMusicShuffleModeOff);
    [self setCorrectRepeatButtomImage];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    [[GVMusicPlayerController sharedInstance] remoteControlReceivedWithEvent:receivedEvent];
}

- (void)setCorrectRepeatButtomImage {
    NSString *imageName;
    
    switch ([GVMusicPlayerController sharedInstance].repeatMode) {
        case MPMusicRepeatModeAll:
            imageName = @"Track_Repeat_On";
            break;
            
        case MPMusicRepeatModeOne:
            imageName = @"Track_Repeat_On_Track";
            break;
            
        case MPMusicRepeatModeNone:
            imageName = @"Track_Repeat_Off";
            break;
            
        default:
            imageName = @"Track_Repeat_Off";
            break;
    }
    
    [self.repeatButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)timedJob {
    if (!self.panningProgress) {
        self.progressSlider.value = [GVMusicPlayerController sharedInstance].currentPlaybackTime;
        self.TrackCurrentPlaybackTimeLbl.text = [NSString stringFromTime:[GVMusicPlayerController sharedInstance].currentPlaybackTime];
    }
}

#pragma mark - AVMusicPlayerControllerDelegate

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState {
   
    if (playbackState == MPMusicPlaybackStatePlaying) {
        self.nowPlayingSongState = 1;
    }else if (playbackState == MPMusicPlaybackStatePaused){
        self.nowPlayingSongState = 2;
    }
    
    self.playPauseButton.selected = (playbackState == MPMusicPlaybackStatePlaying);
    
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer trackDidChange:(MPMediaItem *)nowPlayingItem previousTrack:(MPMediaItem *)previousTrack {
    
    // Time labels
    NSTimeInterval trackLength = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.trackLengthLbl.text = [NSString stringFromTime:trackLength];
    self.progressSlider.value = 0;
    self.progressSlider.maximumValue = trackLength;
    
    // Labels
    self.songNameLbl.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    self.artistNameLbl.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    
    // Artwork
    MPMediaItemArtwork *artwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork != nil) {
        self.songImageView.image = [artwork imageWithSize:self.songImageView.frame.size];
    }else{
        self.songImageView.image=[UIImage imageNamed:@"music"];
    }
    
    NSLog(@"Proof that this code is being called, even in the background!");
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer endOfQueueReached:(MPMediaItem *)lastTrack {
   
    NSLog(@"End of queue, but last track was %@", [lastTrack valueForProperty:MPMediaItemPropertyTitle]);
    
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer volumeChanged:(float)volume {
    
    if (!self.panningVolume) {
        
        self.volumeSlider.value = volume;
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButtonTouchUpInside:(id)sender {
    [[GVMusicPlayerController sharedInstance] skipToNextItem];
    self.nowPlayingSongItemIndexValue++;

}
- (IBAction)volumeChanged:(id)sender {
    
    UISlider *slider = sender;
    self.panningVolume = YES;
    [GVMusicPlayerController sharedInstance].volume = slider.value;
}

- (IBAction)prevButtonTouchUpInside:(id)sender {
    
    [[GVMusicPlayerController sharedInstance] skipToPreviousItem];
    self.nowPlayingSongItemIndexValue--;
    
}

- (IBAction)playpauseButtonTouchUpInside:(id)sender {
    
    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying) {
        [[GVMusicPlayerController sharedInstance] pause];
    } else {
        [[GVMusicPlayerController sharedInstance] play];
    }

}

- (IBAction)trackProgressChanged:(id)sender {
    
    // While dragging the progress slider around, we change the time label,
    // but we're not actually changing the playback time yet.
    
    UISlider *slider = sender;
    self.panningProgress = YES;
    self.TrackCurrentPlaybackTimeLbl.text = [NSString stringFromTime:slider.value];

}
- (IBAction)progressEnd {
    // Only when dragging is done, we change the playback time.
    [GVMusicPlayerController sharedInstance].currentPlaybackTime = self.progressSlider.value;
    self.panningProgress = NO;
}
- (IBAction)volumeEnd {
    self.panningVolume = NO;
}

- (IBAction)repeatButtonTouchUpInside:(id)sender {
  
    switch ([GVMusicPlayerController sharedInstance].repeatMode) {
        case MPMusicRepeatModeAll:
            // From all to one
            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeOne;
            break;
            
        case MPMusicRepeatModeOne:
            // From one to none
            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeNone;
            break;
            
        case MPMusicRepeatModeNone:
            // From none to all
            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeAll;
            break;
            
        default:
            [GVMusicPlayerController sharedInstance].repeatMode = MPMusicRepeatModeAll;
            break;
    }
    
    [self setCorrectRepeatButtomImage];

}

- (IBAction)shuffleButtonTouchUpInside:(id)sender {
    
    self.shuffleButton.selected = !self.shuffleButton.selected;
    
    if (self.shuffleButton.selected) {
        [GVMusicPlayerController sharedInstance].shuffleMode = MPMusicShuffleModeSongs;
    } else {
        [GVMusicPlayerController sharedInstance].shuffleMode = MPMusicShuffleModeOff;
    }

}

@end

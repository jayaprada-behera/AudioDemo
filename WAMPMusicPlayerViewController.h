//
//  WAMPMusicPlayerViewController.h
//  AudioDemo
//
//  Created by Jayaprada Behera on 01/04/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface WAMPMusicPlayerViewController : UIViewController
@property(nonatomic,strong)void (^setIndexOfPlayingCellCallBack)(NSInteger indexValue,NSInteger stateOfMusic);
@property(nonatomic)NSInteger nowPlayingSongItemIndexValue;
@property(nonatomic,strong)MPMediaItemCollection *mediaItemCollection;
@property(nonatomic)NSInteger nowPlayingSongState;
@property(nonatomic)BOOL isPlayNewSong;

@end

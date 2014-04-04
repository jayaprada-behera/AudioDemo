//
//  WARootViewController.m
//  AudioDemo
//
//  Created by Jayaprada Behera on 01/04/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WARootViewController.h"
#import "WAMPMusicPlayerViewController.h"
#import "GVMusicPlayerController.h"
#import "NSString+TimeToString.h"

#import <MediaPlayer/MediaPlayer.h>
#import "WASongCell.h"
#import "WASong.h"

typedef enum{
    playState=1,
    pauseState=2,
    unKnownState = 3
}musicPlaybackState;

@interface WARootViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,GVMusicPlayerControllerDelegate>
{
    NSArray *songItemArray;
    CGFloat itemDur;
    NSTimer *timer;
    CGFloat minutes;
    CGFloat secs;
    
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UIView *loadingMainView;
@property (weak, nonatomic) IBOutlet UIView *loadingSubView;
@property (weak, nonatomic) IBOutlet UITableView *songTableView;
@property(nonatomic,strong) NSArray *songs;
@property(nonatomic,strong) NSMutableArray *songObjects;
@property(nonatomic,strong)NSMutableArray *selectedIndexArray;
@property(nonatomic)NSInteger musicState;
@property(nonatomic,strong)NSIndexPath *cellIndexPath;
@property(nonatomic,strong)NSMutableArray *selectedButtonIndexArray;

@end

@implementation WARootViewController

@synthesize songTableView;
@synthesize songs;
@synthesize songObjects;
@synthesize selectedIndexArray;
@synthesize cellIndexPath;
@synthesize loadingMainView;
@synthesize loadingSubView;
@synthesize loadingSpinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.songTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingSubView.layer.borderWidth = 3.f;
    self.loadingSubView.layer.cornerRadius = 5.f;
    
    [self.loadingSpinner startAnimating];
    [self.loadingMainView setHidden:NO];

    [[GVMusicPlayerController sharedInstance] addDelegate:self];
    
    self.title = @"Songs";
    
    minutes = 0;
    secs = 0;
    
    self.songObjects = [NSMutableArray new];
    
    if (self.selectedIndexArray == nil) {
        self.selectedIndexArray = [[NSMutableArray alloc]init];
    }
    if (self.selectedButtonIndexArray == nil) {
        self.selectedButtonIndexArray = [[NSMutableArray alloc]init];
    }
    self.songTableView.delegate = self;
    self.songTableView.dataSource = self;
    [self enumarateSongArray];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshMusic:)];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Pick songs" style:UIBarButtonItemStylePlain target:self action:@selector(PickSongButtonTapped:)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
}
-(void)enumarateSongArray{

    self.songs = [self fetchAllSongsFromLibrary];
    [self.songs enumerateObjectsUsingBlock:^(MPMediaItem *songItem, NSUInteger idx, BOOL *stop){
        
        WASong *song = [[WASong alloc] init];
        song.songName = [songItem valueForProperty:MPMediaItemPropertyTitle];
        song.artistName = [songItem valueForProperty:MPMediaItemPropertyArtist];
        song.songDuration = [songItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
        song.songID = [songItem valueForProperty:MPMediaItemPropertyPersistentID];
        song.songImage = [[songItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(40.f, 40.f)];
        
        [self.songObjects addObject:song];
        if (idx == songs.count -1) {
            [self performSelector:@selector(hideLoadingView) withObject:(id)kCFBooleanTrue afterDelay:0.8f];

        }
    }];
    
    [self.songTableView reloadData];
}
-(void)hideLoadingView{

    [self.loadingMainView setHidden:YES];

}
-(IBAction)refreshMusic:(id)sender{
    
    [self.loadingSpinner startAnimating];
    [self.loadingMainView setHidden:NO];
    [self enumarateSongArray];
    
}
-(NSArray *) fetchAllSongsFromLibrary{
    
    MPMediaQuery *songsQuery = [[MPMediaQuery alloc]init];
    songItemArray = [songsQuery items];
    return songItemArray;
    
}

#pragma mark - UITableView Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.songObjects.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellID = @"songCellIdentifier";
    WASongCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        NSArray *cellNibs = [[NSBundle mainBundle] loadNibNamed:@"WASongCell" owner:self options:nil];
        cell = [cellNibs objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    WASong *song = [self.songObjects objectAtIndex:indexPath.row];
    
    MPMediaItem *temp = [self retriveMPMediaItemForIndex:indexPath.row];
    
//    UIImage *image = nil;
//    MPMediaItemArtwork *itemArtwork = [temp valueForProperty:
//                                       MPMediaItemPropertyArtwork];
//    if(itemArtwork != nil)
//        image = [itemArtwork imageWithSize:cell.imageView.frame.size];
    if (song.songImage == nil)
        cell.imageView.image = [UIImage imageNamed:@"music.png"] ;
    else
        cell.imageView.image = song.songImage;
    
    cell.cellButtonTouchUpInsideCallback = ^(){
        [self playMusicButtonTappedFromCell:indexPath.row withMusicState:0 andCellIndex:indexPath];
    };
    
    cell.songName.text = song.songName;
    
    NSTimeInterval trackLength = [[temp valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    cell.songDuration.text = [NSString stringWithFormat:@"Duration: %@ mins",[NSString stringFromTime:trackLength]];
    if (self.selectedIndexArray.count >0) {
        
        NSInteger row = [[self.selectedIndexArray objectAtIndex:0]integerValue ];
        
        if (row == indexPath.row) {
            
            if (self.musicState == pauseState){
                [cell.equaliserSongButton setShowActivity:YES state:pauseState];
            }
            else{
                [cell.equaliserSongButton setShowActivity:YES state:playState];
            }
        }else{
            [cell.equaliserSongButton setShowActivity:NO state:0];
        }
        if (row == indexPath.row) {
            if (self.musicState == playState) {
                cell.spinnersongButton.image = [UIImage imageNamed:stopImage];
                [cell.spinnersongButton setColourR:0.0 G:1.0 B:0.0 A:1.0];
                
            }else if(self.musicState == pauseState){
                cell.spinnersongButton.image = [UIImage imageNamed:playImage];
                [cell.spinnersongButton setColourR:1.0 G:0.0 B:0.0 A:1.0];
            }else{
                cell.spinnersongButton.image = [UIImage imageNamed:playImage];
                [cell.spinnersongButton setColourR:0.0 G:0.0 B:1.0 A:1.0];
            }
        }else{
            cell.spinnersongButton.image = [UIImage imageNamed:playImage];
            [cell.spinnersongButton setColourR:0.0 G:1.0 B:0.0 A:1.0];
            [cell.spinnersongButton setProgress:0.0f];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WAMPMusicPlayerViewController *musicPlayerVC = [[WAMPMusicPlayerViewController alloc]init];
    
    if (![self.selectedIndexArray containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        //newCellTapped
        [self.selectedIndexArray removeAllObjects];
        [self.selectedIndexArray addObject:[NSNumber numberWithInt:indexPath.row]];
        musicPlayerVC.isPlayNewSong = YES;
    }else{
        musicPlayerVC.isPlayNewSong = NO;
    }
    
    [self.songTableView reloadData];
    
    NSArray *array = [self getAllMPMediaItemWithIndexValue:indexPath.row];
    MPMediaItemCollection *itemCollection = [MPMediaItemCollection collectionWithItems:array];
    musicPlayerVC.mediaItemCollection = itemCollection;
    musicPlayerVC.nowPlayingSongItemIndexValue = indexPath.row;
    
    musicPlayerVC.setIndexOfPlayingCellCallBack = ^(NSInteger indexvalue,NSInteger stateOfMusic){
        [self cellSelectedMethodCallBackWithIndexValue:indexvalue andMusicState:stateOfMusic];
    };
    [self.navigationController pushViewController:musicPlayerVC animated:YES];
    
}
-(void)cellSelectedMethodCallBackWithIndexValue:(NSInteger)rowNumber andMusicState:(NSInteger)musicState{
    self.musicState = musicState;
    [self.selectedIndexArray removeAllObjects];
    if (![self.selectedIndexArray containsObject:[NSNumber numberWithInt:rowNumber]]) {
        [self.selectedIndexArray addObject:[NSNumber numberWithInt:rowNumber]];
    }
    [self.songTableView reloadData];
}
-(MPMediaItem *)retriveMPMediaItemForIndex:(int)i {
    
    WASong *song = [self.songObjects objectAtIndex:i];
    
    MPMediaItem *temp;
    MPMediaQuery *searchQuery = [[MPMediaQuery alloc] init];
    NSPredicate *test = [NSPredicate predicateWithFormat:@"title contains[cd] %@",song.songName];
    NSArray *filteredArray = [[searchQuery items] filteredArrayUsingPredicate:test];
    
    for (MPMediaItem *mediaItem in filteredArray){
        if ([[mediaItem valueForProperty:MPMediaItemPropertyPersistentID] isEqual:song.songID])
            temp = mediaItem;
    }
    return temp;
}

-(NSArray *)getAllMPMediaItemWithIndexValue:(NSInteger )indexValue{
    
    NSMutableArray *array_items = [NSMutableArray new];
    MPMediaItem *temp;
    temp = [self retriveMPMediaItemForIndex:indexValue];
    [array_items addObject:temp];
    
    //retrive rest of the MPMediaItems ,,i.e the song below  and above of the current song
    for (int i = indexValue; i < self.songObjects.count; i++) {
        temp = [self retriveMPMediaItemForIndex:i];
        if (![array_items containsObject:temp])
            [array_items addObject:temp];
    }
    for (int i =0 ; i < self.songObjects.count; i++) {
        temp = [self retriveMPMediaItemForIndex:i];
        if (![array_items containsObject:temp])
            [array_items addObject:temp];
    }
    return array_items;
}

-(void)playMusicButtonTappedFromCell:(NSInteger)rowNumber withMusicState:(NSInteger )musicState andCellIndex:(NSIndexPath *)cellIndexPath_{
    
    self.cellIndexPath = cellIndexPath_;
    
    if (![self.selectedButtonIndexArray containsObject:[NSNumber numberWithInt:rowNumber]]) {
        //new button tapped
        [self.selectedButtonIndexArray removeAllObjects];
        [self.selectedButtonIndexArray addObject:[NSNumber numberWithInt:rowNumber]];
        itemDur = 0.f;
        [[GVMusicPlayerController sharedInstance] stop];
        NSArray *array = [self getAllMPMediaItemWithIndexValue:rowNumber];
        MPMediaItemCollection *itemCollection = [MPMediaItemCollection collectionWithItems:array];
        [[GVMusicPlayerController sharedInstance] setQueueWithItemCollection:itemCollection];
    }
    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying) {
        [[GVMusicPlayerController sharedInstance] pause];
    } else {
        [[GVMusicPlayerController sharedInstance] play];
    }
}

#pragma mark - AVMusicPlayerControllerDelegate

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState {
    
    if (playbackState == MPMusicPlaybackStatePlaying) {
        self.musicState = 1;
        timer= [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(updateProgress)
                                              userInfo:nil
                                               repeats:YES];
    }else if (playbackState == MPMusicPlaybackStatePaused){
        
        [timer invalidate];
        self.musicState = 2;
        
    }else {
        NSLog(@"%d:pbState",playbackState);
        [timer invalidate];
        self.musicState = 3;
        //playback state is nil
    }
    
    [self.songTableView reloadData];
    
//    [cell.spinnersongButton setNeedsLayout];
//    [cell.spinnersongButton setNeedsDisplay];
    
}
-(void)updateProgress{
    
    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying || [GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePaused ) {
        
        itemDur++;
        secs++;
        
        if (secs>59) {
            secs = 0;
            minutes++;
        }
        
        NSLog(@"min%f,sec:%f",minutes,secs);
        
        WASong *song = [self.songObjects objectAtIndex:self.cellIndexPath.row];
        
        CGFloat progress =itemDur/[song.songDuration doubleValue];
        
        NSLog(@"dur%f,progress:%f",itemDur,progress);

        WASongCell *cell = (WASongCell *)[self.songTableView cellForRowAtIndexPath:self.cellIndexPath];
        
        if (itemDur <= [song.songDuration doubleValue]) {
            [cell.spinnersongButton setProgress:progress];
        }
        else{
            cell.spinnersongButton.image = [UIImage imageNamed:playImage];
            [cell.spinnersongButton setProgress:0.0f];
        }
    }else{
        
    }
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer trackDidChange:(MPMediaItem *)nowPlayingItem previousTrack:(MPMediaItem *)previousTrack {
   

    if (nowPlayingItem!=nil) {
        NSInteger indexOfTrack = [songs indexOfObject:nowPlayingItem];
        self.cellIndexPath = [[self.cellIndexPath indexPathByRemovingLastIndex]  indexPathByAddingIndex:indexOfTrack];
        
        NSLog(@"track:%@,prevTrack:%@ nowPlayingItem index %d",[nowPlayingItem valueForProperty:MPMediaItemPropertyTitle],[previousTrack valueForProperty:MPMediaItemPropertyTitle],indexOfTrack);
        self.musicState = 1;
        if (![self.selectedIndexArray containsObject:[NSNumber numberWithInt:indexOfTrack]]) {
            //newCellTapped
            [self.selectedIndexArray removeAllObjects];
            [self.selectedIndexArray addObject:[NSNumber numberWithInt:indexOfTrack]];
            itemDur= 0.f;
            secs = 0;
            minutes = 0.f;
            //change value of cellIndexPath_
        }
        [self.songTableView reloadData];
    }
    //increase or decrease NSIndexpath
    //http://stackoverflow.com/questions/9636086/how-to-increment-an-nsindexpath
    //http://stackoverflow.com/questions/1331659/nsindexpath-incrementing-values
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer endOfQueueReached:(MPMediaItem *)lastTrack {
    
    NSLog(@"End of queue, but last track was %@", [lastTrack valueForProperty:MPMediaItemPropertyTitle]);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

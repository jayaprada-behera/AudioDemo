//
//  WAFirstViewController.m
//  AudioDemo
//
//  Created by Jayaprada Behera on 04/04/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAFirstViewController.h"
#import "WARootViewController.h"
#import "WAMPMusicPlayerViewController.h"

@interface WAFirstViewController ()<MPMediaPickerControllerDelegate>
{
    WAMPMusicPlayerViewController *musicVC ;
}
- (IBAction)allSongsButtonTapped:(id)sender;

- (IBAction)deviceSongButtonTapped:(id)sender;
@end

@implementation WAFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    musicVC  = [[WAMPMusicPlayerViewController alloc]init];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)allSongsButtonTapped:(id)sender {
    
    WARootViewController *rootVC = [[WARootViewController alloc] init];
    [self.navigationController pushViewController:rootVC animated:YES];
}

- (IBAction)deviceSongButtonTapped:(id)sender {
#if !(TARGET_IPHONE_SIMULATOR)
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    [self presentViewController:picker animated:YES completion:nil];
#endif

}
#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        musicVC.mediaItemCollection = mediaItemCollection;
        musicVC.isPlayNewSong = YES;
        [self.navigationController pushViewController:musicVC  animated:YES];
    }];
}


@end

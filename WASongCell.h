//
//  WASongCell.h
//  AudioDemo
//
//  Created by Jayaprada Behera on 01/04/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAPlayMusicAnimationView.h"
#import "WAAudioButton.h"

@interface cellWidgetButton : UIButton {
    WAPlayMusicAnimationView *equaliserView;
}

- (void) setShowActivity:(BOOL) show state:(NSInteger )musicState;

@end


@interface WASongCell : UITableViewCell

@property(weak,nonatomic)IBOutlet UILabel *songName;

@property(weak,nonatomic)IBOutlet UILabel *songDuration;
@property(weak,nonatomic)IBOutlet UIImageView *imageView;

@property(weak,nonatomic)IBOutlet cellWidgetButton *equaliserSongButton;

@property(weak,nonatomic)IBOutlet WAAudioButton *spinnersongButton;
@property(weak,nonatomic)IBOutlet  UIView *spinnerView;

@property(readwrite,copy)void (^cellButtonTouchUpInsideCallback)();

-(IBAction)spinnersongButtonTouchUpInside:(id)sender;
@end

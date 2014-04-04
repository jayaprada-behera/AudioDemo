//
//  WASongCell.m
//  AudioDemo
//
//  Created by Jayaprada Behera on 01/04/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WASongCell.h"
@implementation cellWidgetButton

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

-(void) _init {
    equaliserView = [[WAPlayMusicAnimationView alloc] initWithFrame:self.bounds];
    equaliserView.backgroundColor = [UIColor whiteColor];
   [self addSubview:equaliserView];
    equaliserView.hidden=YES;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

//- (void) layoutSubviews {
//    self.imageView.hidden = NO;
//    [super layoutSubviews];
//
////    self.imageView.hidden = !activityIndicatorView.hidden;
//}

- (void) setShowActivity:(BOOL) show state:(NSInteger )musicState{
    
    equaliserView.hidden = !show;
    if (show) {
        [equaliserView animateEqualiser:YES forState:musicState];
    } else {
        [equaliserView animateEqualiser:NO forState:musicState];
    }
}


@end


@implementation WASongCell
@synthesize songDuration;
@synthesize songName;
@synthesize spinnersongButton;
@synthesize equaliserSongButton;
@synthesize imageView;
@synthesize spinnerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)spinnersongButtonTouchUpInside:(id)sender{
    self.cellButtonTouchUpInsideCallback();
}
@end

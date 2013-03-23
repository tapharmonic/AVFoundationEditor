//
//  THVolumeAutomationView.h
//  Rampy
//
//  Created by Bob McCune on 2/28/13.
//  Copyright (c) 2013 Bob McCune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface THVolumeAutomationView : UIView

@property (nonatomic, strong) NSArray *audioRamps;
@property (nonatomic) CMTime duration;

@end

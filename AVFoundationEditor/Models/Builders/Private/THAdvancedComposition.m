//
//  MIT License
//
//  Copyright (c) 2013 Bob McCune http://bobmccune.com/
//  Copyright (c) 2013 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//

#import "THAdvancedComposition.h"
#import "AVPlayerItem+THAdditions.h"

#define VIDEO_SIZE CGSizeMake(1280, 720)
#define VIDEO_BOUNDS CGRectMake(0, 0, VIDEO_SIZE.width, VIDEO_SIZE.height)

@interface THAdvancedComposition ()
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong) CALayer *titleLayer;
@property (nonatomic, strong) AVVideoComposition *videoComposition;
@end

@implementation THAdvancedComposition

- (id)initWithComposition:(AVComposition *)composition
		 videoComposition:(AVVideoComposition *)videoComposition
				 audioMix:(AVAudioMix *)audioMix
			   titleLayer:(CALayer *)titleLayer {
	self = [super initWithComposition:composition];
	if (self) {
		self.videoComposition = videoComposition;
		self.audioMix = audioMix;
		self.titleLayer = titleLayer;
	}
	return self;
}

- (AVPlayerItem *)makePlayable {
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
	playerItem.videoComposition = self.videoComposition;
	playerItem.audioMix = self.audioMix;

	AVSynchronizedLayer *synchLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playerItem];
	synchLayer.bounds = VIDEO_BOUNDS;
	[synchLayer addSublayer:self.titleLayer];

	// WARNING: This is calling a category method I added to carry the synch layer to the
	// player view controller.  This is not part of AV Foundation.
	playerItem.titleLayer = synchLayer;
	return playerItem;
}

- (AVAssetExportSession *)makeExportable {
	if (self.titleLayer) {
		CALayer *parentLayer = [self createLayer];
		CALayer *videoLayer = [self createLayer];
		[parentLayer addSublayer:videoLayer];
		[parentLayer addSublayer:self.titleLayer];
		self.titleLayer.geometryFlipped = YES;

		// Use AVVideoCompositionCoreAnimationTool to composite the Core Animation
		// title layers with the video content when exporting the video
		AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
		[(AVMutableVideoComposition *)self.videoComposition setAnimationTool:animationTool];
	}

	AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:[self.composition copy]
																	 presetName:AVAssetExportPreset1280x720];
	session.audioMix = self.audioMix;
	session.videoComposition = self.videoComposition; 
	return session;
}

- (CALayer *)createLayer {
	CALayer *layer = [CALayer layer];
	layer.frame = VIDEO_BOUNDS;
	return layer;
}

@end

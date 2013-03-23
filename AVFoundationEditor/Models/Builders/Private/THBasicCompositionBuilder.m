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

#import "THBasicCompositionBuilder.h"
#import "THBasicComposition.h"
#import "THAdvancedComposition.h"

@interface THBasicCompositionBuilder ()
@property (nonatomic, strong) THTimeline *timeline;
@property (nonatomic, strong) AVMutableComposition *composition;
@end

@implementation THBasicCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
	self = [super init];
	if (self) {
		_timeline = timeline;
	}
	return self;
}

- (id <THComposition>)buildComposition {

	self.composition = [AVMutableComposition composition];

	[self addCompositionTrackOfType:AVMediaTypeVideo forMediaItems:self.timeline.videos];
	[self addCompositionTrackOfType:AVMediaTypeAudio forMediaItems:self.timeline.voiceOvers];
	[self addCompositionTrackOfType:AVMediaTypeAudio forMediaItems:self.timeline.musicItems];

	return [THBasicComposition compositionWithComposition:self.composition];
}

- (void)addCompositionTrackOfType:(NSString *)mediaType forMediaItems:(NSArray *)mediaItems {
	if (!THIsEmpty(mediaItems)) {
		AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:mediaType
																					preferredTrackID:kCMPersistentTrackID_Invalid];
		// Set insert cursor to 0
		CMTime cursorTime = kCMTimeZero;

		for (THMediaItem *item in mediaItems) {

			if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
				cursorTime = item.startTimeInTimeline;
			}

			AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType][0];
			[compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];

			// Move cursor to next item time
			cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
		}
	}
}

@end

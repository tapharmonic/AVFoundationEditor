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

#import "THMainViewController.h"
#import "THPlayerViewController.h"
#import "THTimelineViewController.h"
#import "THVideoPickerViewController.h"
#import "THVideoItem.h"
#import "THCompositionBuilderFactory.h"
#import "THCompositionBuilder.h"
#import "THTimeline.h"
#import "THNotifications.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"

#define SEGUE_ADD_MEDIA_PICKER	@"addMediaPickerViewController"
#define SEGUE_ADD_PLAYER		@"addPlayerViewController"
#define SEGUE_ADD_TIMELINE		@"addTimelineViewController"

@interface THMainViewController ()
@property (nonatomic, strong) THCompositionBuilderFactory *factory;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@end

@implementation THMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Wires up child view controller relationships
	[[AppDelegate sharedDelegate] prepareMainViewController];

	self.factory = [[THCompositionBuilderFactory alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(exportComposition:)
												 name:THExportRequestedNotification
											   object:nil];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)loadMediaItem:(THMediaItem *)mediaItem {
	[self.playerViewController loadInitialPlayerItem:[mediaItem makePlayable]];
}

- (void)previewMediaItem:(THMediaItem *)mediaItem {
	[self.playerViewController playPlayerItem:[mediaItem makePlayable]];
}

- (void)prepareTimelineForPlayback {
	THTimeline *timeline = self.timelineViewController.currentTimeline;
	id<THCompositionBuilder> builder = [self.factory builderForTimeline:timeline];
	id<THComposition> composition = [builder buildComposition];
	[self.playerViewController playPlayerItem:[composition makePlayable]];
}

- (void)addMediaItem:(THMediaItem *)item toTimelineTrack:(THTrack)track {
	[self.timelineViewController addTimelineItem:item toTrack:track];
}

- (void)stopPlayback {
	[self.playerViewController stopPlayback];
}

- (void)exportComposition:(NSNotification *)notification {
	THTimeline *timeline = self.timelineViewController.currentTimeline;
	id<THCompositionBuilder> builder = [self.factory builderForTimeline:timeline];
	id<THComposition> composition = [builder buildComposition];

	self.exportSession = [composition makeExportable];
	self.exportSession.outputURL = [self exportURL];
	self.exportSession.outputFileType = AVFileTypeMPEG4;

	[self.exportSession exportAsynchronouslyWithCompletionHandler:^ {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self writeExportedVideoToAssetsLibrary];
		});
	}];

	self.playerViewController.exporting = YES;
	[self monitorExportProgress];
}

- (void)monitorExportProgress {
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	__weak id weakSelf = self;
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		AVAssetExportSessionStatus status = [weakSelf exportSession].status;
		if (status == AVAssetExportSessionStatusExporting) {
			DDProgressView *progressView = [weakSelf playerViewController].exportProgressView.progressView;
			[progressView setProgress:[weakSelf exportSession].progress];
			[weakSelf monitorExportProgress];
		} else if (status == AVAssetExportSessionStatusFailed) {
			NSLog(@"Failed");
		} else if (status == AVAssetExportSessionStatusCompleted) {
			[weakSelf playerViewController].exporting = NO;
		}
	});
}

- (void)writeExportedVideoToAssetsLibrary {
	NSURL *exportURL = self.exportSession.outputURL;
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL]) {
		[library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error){
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																		message:[error localizedRecoverySuggestion]
																	   delegate:nil
															  cancelButtonTitle:@"OK"
															  otherButtonTitles:nil];
					[alertView show];
				}
#if !TARGET_IPHONE_SIMULATOR
				[[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
#endif
			});
		}];
	} else {
		NSLog(@"Video could not be exported to assets library.");
	}
}


- (NSURL *)exportURL {
	NSString *filePath = nil;
	NSUInteger count = 0;
	do {
		filePath = NSTemporaryDirectory();
		NSString *numberString = count > 0 ? [NSString stringWithFormat:@"-%li", (unsigned long)count] : @"";
		filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Masterpiece-%@.m4v", numberString]];
		count++;
	} while([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
	return [NSURL fileURLWithPath:filePath];
}

@end

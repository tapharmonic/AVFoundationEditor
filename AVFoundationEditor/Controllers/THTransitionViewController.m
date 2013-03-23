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

#import "THTransitionViewController.h"
#import "THVideoTransitionTypeViewModel.h"
#import "THVideoTransitionDurationViewModel.h"

@interface THTransitionViewController ()
@property (nonatomic, strong) THVideoTransition *transition;
@property (nonatomic, strong) NSArray *transitionTypes;
@end

@implementation THTransitionViewController

+ (id)controllerWithTransition:(THVideoTransition *)transition {
	return [[self alloc] initWithTransition:transition];
}

- (id)initWithTransition:(THVideoTransition *)transition {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		_transition = transition;
		self.transitionTypes = @[@"None", @"Disolve", @"Push"];
		self.tableView.showsVerticalScrollIndicator = NO;
	}
	return self;
}

- (CGSize)contentSizeForViewInPopover {
	return CGSizeMake(200, 150);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.transitionTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}

	cell.textLabel.text = self.transitionTypes[indexPath.row];

	return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *currentIndexPath = [tableView indexPathForSelectedRow];
	if (![currentIndexPath isEqual:indexPath]) {
		[self.tableView deselectRowAtIndexPath:currentIndexPath animated:YES];
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *type = self.transitionTypes[indexPath.row];
	if ([type isEqualToString:@"Disolve"]) {
		self.transition.type = THVideoTransitionTypeDisolve;
	} else if ([type isEqualToString:@"Push"]) {
		self.transition.type = THVideoTransitionTypePush;
	} else {
		self.transition.type = THVideoTransitionTypeNone;
	}
	[self.delegate transitionSelected];
}

@end

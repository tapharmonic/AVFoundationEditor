//
//  THRelationshipSegue.m
//  Temp
//
//  Created by Bob McCune on 3/7/13.
//  Copyright (c) 2013 Bob McCune. All rights reserved.
//

#import "THTabBarRelationshipSegue.h"
#import "THTabBarController.h"
#import "THTabBarItem.h"
#import "NSString+THAdditions.h"

#define VIEW_REGEX @"TH([A-Za-z]+)PickerViewController"

@implementation THTabBarRelationshipSegue

- (void)perform {
	THTabBarController *tabBarController = (THTabBarController *)self.sourceViewController;
	NSMutableArray *tabBarItems = [NSMutableArray arrayWithArray:tabBarController.tabBarItems];
	
	NSString *className = NSStringFromClass([self.destinationViewController class]);
	NSString *imageName = [className stringByMatchingRegex:VIEW_REGEX capture:1];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:self.destinationViewController];
	controller.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[tabBarItems addObject:[THTabBarItem itemWithImageName:imageName controller:controller]];
	tabBarController.tabBarItems = tabBarItems;
}

@end

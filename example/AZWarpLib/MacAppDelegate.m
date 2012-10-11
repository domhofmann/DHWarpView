//
//  DHAppDelegate.m
//  AZWarpLib
//
//  Created by Alex Gray on 10/10/12.
//  Copyright (c) 2012 Proofe Solutions LLC. All rights reserved.
//

#import "MacAppDelegate.h"
#import "AZWarpView.h"

@implementation MacAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSView 		*cc 		= [[self window]		contentView];
    AZWarpView 	*warpView 	= [[AZWarpView  alloc] initWithFrame: cc.frame];
    NSImageView *imageView 	= [[NSImageView alloc] initWithFrame: NSInsetRect(cc.frame, 100, 100)];
	NSImage 	*ii 		= [[NSImage 	alloc] initWithData:
							   [NSData dataWithContentsOfURL:
								[NSURL URLWithString:@"http://www.appelogen.be/wp-content/images/brenda_dickson.jpg"]]];
	imageView.image = ii;
	[warpView addSubview:imageView];
    [cc addSubview:warpView];

    warpView.topLeft 	 = CGPointMake(0, NSMidY(cc.frame));
    warpView.topRight 	 = CGPointMake(NSMidX(cc.frame),NSMaxY(cc.frame));
    warpView.bottomLeft  = CGPointMake(0,22);
    warpView.bottomRight = CGPointMake(NSMidX(cc.frame), 224);
    [warpView warp];
}

@end

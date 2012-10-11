//
//  AZWarpView.h
//  DHWarpViewExample
//
//  Created by Alex Gray on 10/10/12.
//  Copyright (c) 2012 Proofe Solutions LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface AZWarpView : NSView

@property (nonatomic, assign) CGSize baseSize;
@property (nonatomic, assign) CGPoint topLeft, topRight, bottomRight, bottomLeft;

- (void) warp;

@end

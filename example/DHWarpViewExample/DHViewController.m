//
//  DHViewController.m
//  DHWarpViewExample
//
//  Created by Dominik Hofmann on 6/14/12.
//  Copyright (c) 2012 Proofe Solutions LLC. All rights reserved.
//

#import "DHViewController.h"
#import "DHWarpView.h"

@implementation DHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    DHWarpView *warpView = [[DHWarpView alloc] initWithFrame:CGRectMake(0, 0, 275, 95)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com/images/srpr/logo3w.png"]]]];
    [warpView addSubview:imageView];
    [self.view addSubview:warpView];
    
    warpView.topLeft = CGPointMake(0, 0);
    warpView.topRight = CGPointMake(275, 20);
    warpView.bottomLeft = CGPointMake(0, 95);
    warpView.bottomRight = CGPointMake(320, 150);
    [warpView warp];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end

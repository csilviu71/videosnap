//
//  main.m
//  videosnap
//
//  Created by Matthew Hutchinson on 5/8/15.
//  Copyright (c) 2015 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

/**
 * interrupt handling (tinyurl.com/lutqg2z)
 */

BOOL is_interrupted = NO;

void SIGINT_handler(int signum) {
	if (!is_interrupted) {
		is_interrupted = YES;
	} else {
		exit(0);
	}
}


/**
 * main
 */
int main(int argc, const char * argv[]) {

	signal(SIGINT, &SIGINT_handler);

	VideoSnap *videoSnap = [[VideoSnap alloc] init];
//	[VideoSnap printHelp: @"test"];

	return [videoSnap processArgs: argc argv:argv];
}
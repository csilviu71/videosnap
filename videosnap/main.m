//
//  main.m
//  videosnap
//
//  Created by Matthew Hutchinson on 5/8/15.
//  Copyright (c) 2015 Matthew Hutchinson. All rights reserved.
//

#import <Foundation/Foundation.h>

// logging helpers
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) printf(__VA_ARGS__)
#define verbose(...) (is_verbose && fprintf(stderr, __VA_ARGS__))

// version
#define VERSION @"0.0.2"

//// defaults
#define DEFAULT_RECORDING_FILENAME @"movie.mov"
#define DEFAULT_RECORDING_SIZE     @"SD480"
#define DEFAULT_VIDEO_SIZES        @[@"120", @"240", @"SD480", @"HD720"]
#define CAPTURE_FRAMES_PER_SECOND	 20



/**
 * globals
 */
BOOL is_verbose;
// global var used to signal interrupt happened (tinyurl.com/lutqg2z)
BOOL is_interrupted;


/**
 * print formatted help and options
 */
//void printHelp(NSString * commandName) {
//
//	printf("VideoSnap (%s)\n\n", [VERSION UTF8String]);
//
//	printf("  Record video and audio from a QuickTime capture device\n\n");
//
//	printf("  See the argument list below for all available options.\n");
//	printf("  By default videosnap will capture and encode using the\n");
//	printf("  H.264(SD480)/AAC format to 'movie.mov'. If you do not\n");
//	printf("  specify a duration, capturing will continue until you\n");
//	printf("  interrupt with CTRL+c.\n");
//
//	printf("\n    usage: %s [options] [file ...]", [commandName UTF8String]);
//	printf("\n  example: %s -t 5.75 -d 'Built-in iSight' -s 'HD720' my_movie.mov\n\n", [commandName UTF8String]);
//
//	printf("  -l          List attached QuickTime capture devices\n");
//	printf("  -t x.xx     Set duration of video (in seconds)\n");
//	printf("  -w x.xx     Set delay before capturing starts (in seconds) \n");
//	printf("  -d device   Set the capture device by name\n");
//	printf("  --no-audio  Disable audio capturing\n");
//	printf("  -v          Turn ON verbose mode (OFF by default)\n");
//	printf("  -h          Show help\n");
//	printf("  -s          Set the H.264 video size/quality\n");
//	for (id videoSize in DEFAULT_VIDEO_SIZES) {
//		printf("                %s%s\n", [videoSize UTF8String], [[videoSize isEqualToString:DEFAULT_RECORDING_SIZE] ? @" (default)" : @"" UTF8String]);
//	}
//	printf("\n");
//}


/**
 * process command line arguments and start capturing
 */
//int processArgs(VideoSnap *videoSnap, int argc, const char * argv[]) {
//
//	// argument defaults
//	AVCaptureDevice *device            = nil;
//	NSString        *filePath          = nil;
//	NSNumber        *recordingDuration = @2.0; //nil
//	NSNumber        *delaySeconds      = nil;
//	NSString        *videoSize         = DEFAULT_RECORDING_SIZE;
//	BOOL            noAudio            = NO;
//
//	int i;
//	for (i = 1; i < argc; ++i) {
//
//		// check for switches
//		if (argv[i][0] == '-') {
//
//			// noAudio
//			if (strcmp(argv[i], "--no-audio") == 0) {
//				noAudio = YES;
//			}
//
//			// check flag
//			switch (argv[i][1]) {
//
//					// show help
//				case 'h':
//					printHelp([NSString stringWithUTF8String:argv[0]]);
//					return 0;
//					break;
//
//					// set verbose flag
//				case 'v':
//					is_verbose = YES;
//					break;
//
//					// list devices
//				case 'l':
//					[VideoSnap listDevices];
//					return 0;
//					break;
//
//					// device
//				case 'd':
//					if (i+1 < argc) {
//						device = [VideoSnap deviceNamed:[NSString stringWithUTF8String:argv[i+1]]];
//						if (!device) {
//							error("Device \"%s\" not found - aborting\n", argv[i+1]);
//							return 1;
//						}
//						++i;
//					}
//					break;
//
//					// videoSize
//				case 's':
//					if (i+1 < argc) {
//						videoSize = [NSString stringWithUTF8String:argv[i+1]];
//						++i;
//					}
//					break;
//
//					// delaySeconds
//				case 'w':
//					if (i+1 < argc) {
//						delaySeconds = [NSNumber numberWithFloat:[[NSString stringWithUTF8String:argv[i+1]] floatValue]];
//						++i;
//					}
//					break;
//
//					// recordingDuration
//				case 't':
//					if (i+1 < argc) {
//						recordingDuration = [NSNumber numberWithFloat:[[NSString stringWithUTF8String:argv[i+1]] floatValue]];
//						++i;
//					}
//					break;
//			}
//		} else {
//			filePath = [NSString stringWithUTF8String:argv[i]];
//		}
//	}
//
//	// check we have a file
//	if (!filePath) {
//		filePath = DEFAULT_RECORDING_FILENAME;
//		verbose("(no filename specified, using default)\n");
//	}
//
//	// check we have a device
//	if (!device) {
//		device = [VideoSnap defaultDevice];
//		if (!device) {
//			error("No video devices found! - aborting\n");
//			return 1;
//		} else {
//			verbose("(no device specified, using default)\n");
//		}
//	}
//
//	// check we have a valid videoSize
//	NSArray *validChosenSize = [DEFAULT_VIDEO_SIZES filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *option, NSDictionary *bindings) {
//		return [videoSize isEqualToString:option];
//	}]];
//
//	if (!validChosenSize.count) {
//		error("Invalid video size! (must be %s) - aborting\n", [[DEFAULT_VIDEO_SIZES componentsJoinedByString:@", "] UTF8String]);
//		return 128;
//	}
//
//	// show options in verbose mode
//	verbose("(options before recording)\n");
//	if (recordingDuration) {
//		verbose("  duration: %.2fs\n", [recordingDuration floatValue]);
//	} else {
//		verbose("  duration: (infinite)\n");
//	}
//	verbose("  delay:    %.2fs\n",    [delaySeconds floatValue]);
//	verbose("  file:     %s\n",       [filePath UTF8String]);
//	verbose("  device:   %s\n",       [[device localizedName] UTF8String]);
//	verbose("            - %s\n",     [[device modelID] UTF8String]);
//	verbose("  video:    %s H.264\n", [videoSize UTF8String]);
//	verbose("  audio:    %s\n",       [noAudio ? @"(none)": @"HQ AAC" UTF8String]);
//
//	// start the capture session with options
//	[videoSnap prepareCapture:device
//									 filePath:filePath
//					recordingDuration:recordingDuration
//									videoSize:videoSize
//									withDelay:delaySeconds
//										noAudio:noAudio];
//
//	return 0;
//}


/**
 * signal interrupt handler
 */
void SIGINT_handler(int signum) {
	verbose("\n(caught signal: [%d])\n", signum);
	if (!is_interrupted) {
		is_interrupted = YES;
	} else {
		verbose("(aborting)");
		exit(0);
	}
}


/**
 * main
 */
int main(int argc, const char * argv[]) {

	// global defaults
	is_verbose     = YES;
	is_interrupted = NO;

	// setup interrupt handler
	signal(SIGINT, &SIGINT_handler);

	console("\nRUNNING!\n");

//	VideoSnap *videoSnap;
//	videoSnap = [[VideoSnap alloc] init];

	// process args and run the videoSnap
//	return processArgs(videoSnap, argc, argv);
}
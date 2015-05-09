//
//  VideoSnap.m
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2013 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

@implementation VideoSnap

static NSString *const VERSION                    = @"0.0.2";
static NSString *const DEFAULT_RECORDING_FILENAME = @"movie.mov";
static NSString *const DEFAULT_RECORDING_SIZE     = @"SD480";


+ (NSArray *)videoDevices {
	NSMutableArray *devices = [[NSMutableArray alloc] init];
	[devices addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]];
	[devices addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed]];

	for (AVCaptureDevice *thisDevice in devices) {
		if([thisDevice isConnected] == NO) {
			[devices removeObject:thisDevice];
		}
	}

	return devices;
}


+ (AVCaptureDevice *)defaultDevice {
	return [[self videoDevices] firstObject];
}


+ (AVCaptureDevice *)deviceNamed:(NSString *)name {
	AVCaptureDevice *device = nil;
	NSArray *devices = [VideoSnap videoDevices];
	for (AVCaptureDevice *thisDevice in devices) {
		if ([name isEqualToString:[thisDevice description]]) {
			device = thisDevice;
		}
	}

	return device;
}


- (id)initWithArgs:(NSArray *)args {
	runLoop = [NSRunLoop currentRunLoop];
	return [super init];
}


-(void)console:(NSString *)message {
	if(!isSilent || isVerbose) {
  	fprintf(stdout, "%s", [message UTF8String]);
	}
}


-(void)error:(NSString *)message {
	fprintf(stderr, "%s", [message UTF8String]);
}


-(void)verbose:(NSString *)message {
	if(isVerbose) {
		fprintf(stdout, "%s", [message UTF8String]);
	}
}

-(void)listDevices {
	unsigned long deviceCount = [[VideoSnap videoDevices] count];

	if (deviceCount > 0) {
		[self console: [NSString stringWithFormat:@"Found %li connected video device%s:\n",
										  deviceCount,
										  (deviceCount > 1) ? "s" : ""
										]];

		for (AVCaptureDevice *device in [VideoSnap videoDevices]) {
			[self console: [NSString stringWithFormat:@"* %s%s",
												[[device localizedName] UTF8String],
												(([VideoSnap defaultDevice] == device) ? " (default)" : "\n")
											]];
		}
	} else {
	  [self console: @"no video devices found.\n"];
	}
}


- (Boolean)prepareCapture:(AVCaptureDevice *)videoDevice
					  	filePath:(NSString *)filePath
	   recordingDuration:(NSNumber *)recordingDuration
	  				 videoSize:(NSString *)videoSize
	  				 withDelay:(NSNumber *)delaySeconds
	  					 noAudio:(Boolean)noAudio {

	Boolean success = NO;

//	NSError *nserror;
//
//	captureSession      = [[QTCaptureSession alloc] init];
//	maxRecordingSeconds = recordingDuration;
//
//	// add video device
//	if ([self addVideoDevice:videoDevice]) {
//
//		// add audio device
//		if (!noAudio) {
//			[self addAudioDevice:videoDevice];
//		}
//
//		// create the movie file output and add to session
//		captureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
//		success = [captureSession addOutput:captureMovieFileOutput error:&nserror];
//		if (!success) {
//			error("Could not add file '%s' as output to the capture session\n", [filePath UTF8String]);
//			return success;
//		} else {
//			[captureMovieFileOutput setDelegate:self];
//		}
//
//		// set compression
//		NSString *videoCompression = [NSString stringWithFormat:@"QTCompressionOptions%@SizeH264Video", videoSize];
//		[self setCompressionOptions:videoCompression audioCompression:@"QTCompressionOptionsHighQualityAACAudio"];
//
//		if (is_interrupted) {
//			verbose("(nothing captured)\n");
//			return YES;
//		}
//		
//		// start capture session running
//		verbose("(starting capture session)\n");
//		[captureSession startRunning];
//		success = [captureSession isRunning];
//
//		if (success) {
//			if (delaySeconds) {
//				[self sleep:[delaySeconds doubleValue]];
//			}
//			[self startCapture:filePath];
//		} else {
//			error("Could not start the capture session\n");
//		}
//	}

	return success;
}


- (void)sleep:(double)sleepSeconds {
//	verbose("(delaying for %.2lf seconds)\n", sleepSeconds);
	[runLoop runUntilDate:[[[NSDate alloc] init] dateByAddingTimeInterval: sleepSeconds]];
//  verbose("(delay period ended)\n");
}


- (Boolean)addVideoDevice:(AVCaptureDevice *)videoDevice {

	Boolean success = NO;
//	NSError *nserror;
//
//	// attempt to open the device for capturing
//	success = [videoDevice open:&nserror];
//	if (!success) {
//		error("Could not open the video device\n");
//		return success;
//	}
//
//	// add the video device to the capture session as a device input
//	verbose("(adding video device to capture session)\n");
//	captureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
//	success = [captureSession addInput:captureVideoDeviceInput error:&nserror];
//	if (!success) {
//		error("Could not add the video device to the session\n");
//		return success;
//	}

	return success;
}


- (Boolean)addAudioDevice:(AVCaptureDevice *)videoDevice {

//	Boolean success = NO;
//	NSError *nserror;
//
//	verbose("(adding audio device to capture session)\n");
	// if the video device doesn't supply audio, add an audio device input to the session
//	if (![videoDevice hasMediaType:QTMediaTypeSound] && ![videoDevice hasMediaType:QTMediaTypeMuxed]) {
//		QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
//		success = [audioDevice open:&nserror];
//
//		if (!success) {
//			audioDevice = nil;
//			error("Could not open the audio device\n");
//			return success;
//		}
//
//		if (audioDevice) {
//			captureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
//			success = [captureSession addInput:captureAudioDeviceInput error:&nserror];
//			if (!success) {
//				error("Could not add the audio device to the session\n");
//				return success;
//			}
//		}
//	}
	return YES;
}



- (void)setCompressionOptions:(NSString *)videoCompression
						 audioCompression:(NSString *)audioCompression {

//	NSEnumerator *connectionEnumerator = [[captureMovieFileOutput connections] objectEnumerator];
//	QTCaptureConnection *connection;
//
//	// iterate over each output connection for the capture session and specify the desired compression
//	while ((connection = [connectionEnumerator nextObject])) {
//		NSString *mediaType = [connection mediaType];
//		QTCompressionOptions *compressionOptions = nil;
//		// (see all valid compression types in QTCompressionOptions.h)
//		if ([mediaType isEqualToString:QTMediaTypeVideo]) {
//			verbose("(setting video compression to %s)\n", [videoCompression UTF8String]);
//			compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:videoCompression];
//		} else if ([mediaType isEqualToString:QTMediaTypeSound]) {
//			verbose("(setting audio compression to %s)\n", [audioCompression UTF8String]);
//			compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:audioCompression];
//		}
//
//		// set the compression options for the movie file output
//		[captureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
//	}
}


//- (void)captureOutput:(QTCaptureFileOutput *)captureOutput
//didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer
//			 fromConnection:(QTCaptureConnection *)connection {
//
//	if (is_interrupted) {
//		[self stopCapture];
//	}
//
//	// check we have started to record some bytes
//	long recordedBytes = [captureMovieFileOutput recordedFileSize];
//	if (recordedBytes > 0) {
//		
//		if (!recordingStartedDate) {
//  		recordingStartedDate = [[NSDate alloc] init];
//
//			if (maxRecordingSeconds && !recordingTimer) {
//				console("Started capture...\n");
//				[self startRecordingTimer:[maxRecordingSeconds doubleValue]];
//			} else {
//				console("Started capture (ctrl+c to stop)...\n");
//			}
//		}
//	}
//}


- (void)startCapture:(NSString *)filePath {
//	[captureMovieFileOutput recordToOutputFileURL: [NSURL fileURLWithPath:filePath]];
	[runLoop run];
}


- (void)stopCapture {
//	[captureMovieFileOutput recordToOutputFileURL:nil];
}


//- (void)captureOutput:(QTCaptureFileOutput *)captureOutput
//didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
//			 forConnections:(NSArray *)connections
//					 dueToError:(NSError *)error {
//
//	if (!error) {
//		verbose("(finished writing to file)\n");
//		NSString *outputDuration = QTStringFromTime([captureMovieFileOutput recordedDuration]);
//		console("Captured %s of video to '%s'\n", [outputDuration UTF8String], [[outputFileURL lastPathComponent] UTF8String]);
//	} else {
//		error("Could not finalize writing video to file\n");
//		fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
//	}
//
//	[self finishCapture];
//}


-(void)finishCapture {

//	if ([captureSession isRunning]) {
//		verbose("(stopping capture session)\n");
//		[captureSession stopRunning];
//	}
//
//	if ([[captureVideoDeviceInput device] isOpen]) {
//		verbose("(closing video device)\n");
//		[[captureVideoDeviceInput device] close];
//	}
//
//	if ([[captureAudioDeviceInput device] isOpen]) {
//		verbose("(closing audio device)\n");
//		[[captureAudioDeviceInput device] close];
//	}

	exit(0);
}

@end




















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
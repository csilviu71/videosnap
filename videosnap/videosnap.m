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
static NSString *const DEFAULT_RECORDING_FILEPATH = @"movie.mov";
static NSString *const DEFAULT_RECORDING_FORMAT   = @"SD480";
NSArray *RECORDING_FORMATS;


- (id)init {

	RECORDING_FORMATS = [NSArray arrayWithObjects: @"120", @"240", @"SD480", @"HD720", nil];

	numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

	recordingDuration = nil;
	fileURL           = [NSURL fileURLWithPath: DEFAULT_RECORDING_FILEPATH];
  recordingFormat   = DEFAULT_RECORDING_FORMAT;
	delaySeconds      = @0.0;
	captureDevice     = [VideoSnap defaultDevice];
	isVerbose         = NO;
	isSilent          = NO;
	noAudio           = NO;
  runLoop           = [NSRunLoop currentRunLoop];

	return [super init];
}


- (int)processArgs:(int)argc argv:(const char *[])argv {

	for (int i=1; i<argc; ++i) {

		// check for a switch
		if (argv[i][0] == '-') {

			// noAudio
			if (strcmp(argv[i], "--no-audio") == 0) {
				noAudio = YES;
			}

			// check arguments
			switch (argv[i][1]) {

				case 'h':
					[VideoSnap printHelp: [NSString stringWithUTF8String:argv[0]]];
					return 0;
					break;

				case 'l':
					[self printDeviceList];
					return 0;
					break;

				case 's':
					isSilent = YES;
					break;

				case 'v':
					isVerbose = YES;
					break;

				case 'd':
					if (i+1 < argc) {
						NSString *chosenDeviceName = [NSString stringWithUTF8String:argv[i+1]];
						captureDevice = [VideoSnap deviceNamed: chosenDeviceName];
						if (!captureDevice) {
							[self error: [NSString stringWithFormat:@"Device \"%s\" not found\n", [chosenDeviceName UTF8String]]];
							return 1;
						}
						++i;
					}
					break;

				case 'f':
					if (i+1 < argc) {
						recordingFormat = [NSString stringWithUTF8String:argv[i+1]];

						// check recordingFormat is valid
						NSArray *validChosenSize = [RECORDING_FORMATS filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *option, NSDictionary *bindings) {
							return [recordingFormat isEqualToString:option];
						}]];

						if (!validChosenSize.count) {
							[self error: [NSString stringWithFormat: @"Invalid recording format (must be %s)\n", [[RECORDING_FORMATS componentsJoinedByString:@", "] UTF8String]]];
							return 1;
						}

						++i;
					}
					break;

				case 'w':
					if (i+1 < argc) {
						delaySeconds = [numberFormatter numberFromString: [NSString stringWithUTF8String:argv[i+1]]];
						++i;
					}
					break;

				case 't':
					if (i+1 < argc) {
						recordingDuration = [numberFormatter numberFromString: [NSString stringWithUTF8String:argv[i+1]]];
						++i;
					}
					break;
			}
		} else {
			fileURL = [NSURL fileURLWithPath: [NSString stringWithUTF8String:argv[i]]];
		}
	}

	// show options in verbose mode
	if (recordingDuration) {
		[self verbose: [NSString stringWithFormat:@"  duration: %.2fs\n", [recordingDuration floatValue]]];
	} else {
		[self verbose: @"  duration: (infinite)\n"];
	}

	[self verbose: [NSString stringWithFormat:@"     delay: %.2fs\n", [delaySeconds floatValue]]];
	[self verbose: [NSString stringWithFormat:@"      file: %s\n",    [[fileURL path] UTF8String]]];
	[self verbose: [NSString stringWithFormat:@"    device: %s\n",    [[captureDevice localizedName] UTF8String]]];
	[self verbose: [NSString stringWithFormat:@"            - %s\n",  [[captureDevice modelID] UTF8String]]];
	[self verbose: [NSString stringWithFormat:@"     video: %s\n",    [recordingFormat UTF8String]]];
	[self verbose: [NSString stringWithFormat:@"     audio: %s\n",    [noAudio ? @"(none)": @"HQ AAC" UTF8String]]];

	return 0;
}


+ (void)printHelp: (NSString *)commandName {

	printf("VideoSnap (%s)\n\n", [VERSION UTF8String]);

	printf("  Record video and audio from a capture device\n\n");

	printf("  See the argument list below for all available options.\n");
	printf("  By default videosnap will capture and encode using the\n");
	printf("  H.264(SD480)/AAC format to 'movie.mov'. If you do not\n");
	printf("  specify a duration, capturing will continue until you\n");
	printf("  interrupt with CTRL+c.\n");

	printf("\n    usage: %s [options] [file ...]", [commandName UTF8String]);
	printf("\n  example: %s -t 5.75 -d 'Built-in iSight' -f 'HD720' my_movie.mov\n\n", [commandName UTF8String]);

	printf("  -h          Show help\n");
	printf("  -l          List attached capture devices\n");
	printf("  -t x.xx     Set duration of video (in seconds)\n");
	printf("  -w x.xx     Set delay before capturing starts (in seconds) \n");
	printf("  -d device   Set the capture device by name\n");
	printf("  --no-audio  Disable audio capturing\n");
  printf("  -v          Turn ON verbose mode (OFF by default)\n");
	printf("  -s          Turn ON silent mode (OFF by default)\n");
	printf("  -f          Set the H.264 video format\n");

	for (id videoSize in RECORDING_FORMATS) {
		printf("                %s%s\n", [videoSize UTF8String], [(videoSize == DEFAULT_RECORDING_FORMAT) ? @" (default)" : @"" UTF8String]);
	}
	printf("\n");
}


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

-(void)printDeviceList {
	unsigned long deviceCount = [[VideoSnap videoDevices] count];

	if (deviceCount > 0) {
		printf("Found %li connected video device%s:\n", deviceCount, (deviceCount > 1) ? "s" : "");

		for (AVCaptureDevice *thisDevice in [VideoSnap videoDevices]) {
			printf("* %s%s\n", [[thisDevice localizedName] UTF8String], (([VideoSnap defaultDevice] == thisDevice) ? " (default)" : ""));
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
 * process command line arguments and start capturing
 */
//int processArgs(VideoSnap *videoSnap, int argc, const char * argv[]) {
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
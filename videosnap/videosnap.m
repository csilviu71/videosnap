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


+ (instancetype)videoSnap {
	return [[self alloc] init];
}


- (id)init {

	RECORDING_FORMATS = [NSArray arrayWithObjects: @"120", @"240", @"SD480", @"HD720", nil];
	recordingDuration = nil;
	fileURL           = [NSURL fileURLWithPath: DEFAULT_RECORDING_FILEPATH];
  recordingFormat   = DEFAULT_RECORDING_FORMAT;
	delaySeconds      = nil;
	captureDevice     = [VideoSnap defaultDevice];
	isVerbose         = YES;//NO;
	isSilent          = NO;
	noAudio           = NO;
  runLoop           = [NSRunLoop currentRunLoop];

	return [super init];
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


-(void)printDeviceList {
	unsigned long deviceCount = [[VideoSnap videoDevices] count];

	if (deviceCount > 0) {
		printf("Found %li connected video device%s:\n", deviceCount, (deviceCount > 1) ? "s" : "");

		for (AVCaptureDevice *thisDevice in [VideoSnap videoDevices]) {
			printf("* %s%s\n", [[thisDevice localizedName] UTF8String], (([VideoSnap defaultDevice] == thisDevice) ? " (default)" : ""));
		}
	} else {
	  console("no video devices found.\n");
	}
}


- (int)processArgs:(int)argc argv:(const char *[])argv {

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

	for (int i=1; i<argc; ++i) {

		// check for a switch
		if (argv[i][0] == '-') {

			if (strcmp(argv[i], "--no-audio") == 0) {
				noAudio = YES;
			}

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
							error("Device \"%s\" not found\n", [chosenDeviceName UTF8String]);
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
							error("Invalid recording format (must be %s)\n", [[RECORDING_FORMATS componentsJoinedByString:@", "] UTF8String]);
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

	// print options in verbose mode
	verbose("* Options before capturing\n");
	if (recordingDuration) {
		verbose("  duration: %.2fs\n", [recordingDuration floatValue]);
	} else {
		verbose("  duration: (infinite)\n");
	}

	verbose("     delay: %.2fs\n", [delaySeconds floatValue]);
	verbose("      file: %s\n",    [[fileURL path] UTF8String]);
	verbose("    device: %s\n",    [[captureDevice localizedName] UTF8String]);
	verbose("            - %s\n",  [[captureDevice modelID] UTF8String]);
	verbose("     video: %s\n",    [recordingFormat UTF8String]);
	verbose("     audio: %s\n",    [noAudio ? @"(none)": @"HQ AAC" UTF8String]);

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath: [fileURL path]]) {
		error("File already exists at %s\n", [[fileURL path] UTF8String]);
		return 1;
	}

	if([self startCapture]) {
		return 0;
	} else {
		return 1;
	}
}


- (Boolean)startCapture {

	Boolean success = NO;

	if ([self prepareCapture]) {
		verbose("* Starting capture session\n");
		[captureSession startRunning];
		if (delaySeconds > 0) {
			[self sleep:[delaySeconds doubleValue]];
		}
		console("Started recording to %s ...\n", [[fileURL relativePath] UTF8String]);
		[movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
		[runLoop run];
		success = YES;
	}

	return success;
}


- (Boolean)prepareCapture {

	Boolean success = NO;
	verbose("* Setting up a new capture session\n");
	captureSession = [[AVCaptureSession alloc] init];

	if ([self addVideoDevice]) {
		if (!noAudio) {
			[self addAudioDevice];
		}

		verbose("  Adding output: file\n");
		movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(5, 30); //<< SET MAX DURATION (seconds/fps)
	
		if ([captureSession canAddOutput:movieFileOutput]) {
			[captureSession addOutput:movieFileOutput];

			AVCaptureConnection *captureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];

			if (captureConnection.supportsVideoMinFrameDuration) {
				verbose("  Setting min frame rate\n");
				captureConnection.videoMinFrameDuration = CMTimeMake(1, 30); // 20 is CAPTURE_FRAMES_PER_SECOND
			}
			if (captureConnection.supportsVideoMaxFrameDuration) {
				verbose("  Setting max frame rate\n");
				captureConnection.videoMaxFrameDuration = CMTimeMake(1, 30);
			}

			verbose("  Setting video format\n");
			//	AVCaptureSessionPresetHigh - Highest recording quality (varies per device)
			//	AVCaptureSessionPresetMedium - Suitable for WiFi sharing (actual values may change)
			//	AVCaptureSessionPresetLow - Suitable for 3G sharing (actual values may change)
			//	AVCaptureSessionPreset640x480 - 640x480 VGA (check its supported before setting it)
			//	AVCaptureSessionPreset1280x720 - 1280x720 720p HD (check its supported before setting it)
			//	AVCaptureSessionPresetPhoto - Full photo resolution (not supported for video output)

			[captureSession setSessionPreset:AVCaptureSessionPresetMedium];
			// check size based configs are supported before setting them
			if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
				verbose("  Setting video size\n");
				[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
			}

			success = YES;
		}
	}

	return success;
}


- (Boolean)addVideoDevice {
	Boolean success = NO;
	NSError *nserror;

	verbose("  Adding input: video\n");
	videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&nserror];

	if (!nserror) {
		if ([captureSession canAddInput:videoInputDevice]) {
			[captureSession addInput:videoInputDevice];
			success = YES;
		} else {
			error("  Couldn't add video input to capture session\n");
		}
	} else {
		error("  Couldn't create video input\n");
		error("%s\n", [[nserror localizedDescription] UTF8String]);
	}

	return success;
}


- (Boolean)addAudioDevice {
	Boolean success = NO;
	NSError *nserror;

	verbose("  Adding input: audio\n");
	AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&nserror];

	if (audioInput) {
		if (!nserror) {
  		[captureSession addInput:audioInput];
	  	success = YES;
		} else {
			error("  Couldn't create audio input\n");
			error("%s\n", [[nserror localizedDescription] UTF8String]);
		}
	} else {
		error("  Couldn't find an audio capture device\n");
	}

	return success;
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


- (void)sleep:(double)sleepSeconds {
	verbose("* Delaying for %.2lf seconds\n", sleepSeconds);
	[runLoop runUntilDate:[[[NSDate alloc] init] dateByAddingTimeInterval: sleepSeconds]];
  verbose("* Delay period ended\n");
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


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
			fromConnections:(NSArray *)connections {

	verbose("didStartRecordingToOutputFileAtURL - enter\n");
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
										fromConnections:(NSArray *)connections
															error:(NSError *)nserror {

	verbose("didFinishRecordingToOutputFileAtURL - enter\n");

	if (!nserror) {
		verbose("* Finished writing to file\n");
		// NSString *outputDuration = QTStringFromTime([captureMovieFileOutput recordedDuration]);
		// console("Captured %s of video to '%s'\n", [outputDuration UTF8String], [[outputFileURL lastPathComponent] UTF8String]);
	} else {
		error("Could not finalize writing video to file\n");
		error("%s\n", [[nserror localizedDescription] UTF8String]);
	}

	[self stopCapture];
}


-(void)stopCapture {

	//[movieFileOutput startRecordingToOutputFileURL:nil recordingDelegate:self];

	if ([captureSession isRunning]) {
		verbose("* Stopping capture session\n");
		[captureSession stopRunning];
	}

	exit(0);
}

@end
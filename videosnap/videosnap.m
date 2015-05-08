//
//  VideoSnap.m
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2013 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

@implementation VideoSnap

- (id)init {
	runLoop = [NSRunLoop currentRunLoop];
	return [super init];
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


+(void)listDevices {
	unsigned long deviceCount = [[self videoDevices] count];

	if (deviceCount > 0) {
//		console("Found %li connected video device%s:\n", deviceCount, (deviceCount > 1) ? "s" : "");
		for (AVCaptureDevice *device in [self videoDevices]) {
			printf("* %s%s", [[device localizedName] UTF8String], ([self defaultDevice] == device) ? " (default)" : "\n");
		}
	} else {
//		console("no video devices found.\n");
	}
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


- (BOOL)prepareCapture:(AVCaptureDevice *)videoDevice
					  	filePath:(NSString *)filePath
	   recordingDuration:(NSNumber *)recordingDuration
	  				 videoSize:(NSString *)videoSize
	  				 withDelay:(NSNumber *)delaySeconds
	  					 noAudio:(BOOL)noAudio {

	BOOL success = NO;

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


- (BOOL)addVideoDevice:(AVCaptureDevice *)videoDevice {

	BOOL success = NO;
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


- (BOOL)addAudioDevice:(AVCaptureDevice *)videoDevice {

//	BOOL success = NO;
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
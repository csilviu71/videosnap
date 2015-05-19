//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2013 Matthew Hutchinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

// logging macros
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) if(!isSilent || isVerbose) { fprintf(stdout, __VA_ARGS__); }
#define verbose(...) if(isVerbose) { fprintf(stdout, __VA_ARGS__); }

// VideoSnap
@interface VideoSnap : NSObject <AVCaptureFileOutputRecordingDelegate> {
	Boolean   noAudio;
	Boolean   isVerbose;
	Boolean   isSilent;
	NSNumber  *delaySeconds;
	NSNumber  *recordingDuration;
	NSString  *recordingFormat;
	NSURL     *fileURL;
	NSRunLoop *runLoop;

	AVCaptureDevice          *captureDevice;
	AVCaptureSession         *captureSession;
	AVCaptureMovieFileOutput *movieFileOutput;
	AVCaptureDeviceInput     *videoInputDevice;

//	NSNumber                 *maxRecordingSeconds;
//	NSDate									 *recordingStartedDate;
//	AVCaptureSession         *captureSession;
//	AVCaptureMovieFileOutput *movieFileOutput;
//	AVCaptureDeviceInput     *videoInputDevice;
}

// class methods

/**
 * Returns attached capture devices that have video. Includes
 * video-only devices and any audio/video devices
 *
 * @return NSArray
 */
+(NSArray *)videoDevices;

/**
 * Returns default capture device for video or nil if none found
 *
 * @return AVCaptureDevice
 */
+(AVCaptureDevice *)defaultDevice;

/**
 * Returns capture device matching name or nil if a device matching the name
 * cannot be found
 *
 * @return AVCaptureDevice
 */
+(AVCaptureDevice *)deviceNamed:(NSString *)name;

/**
 * Prints command help information with example arguments
 */
+(void)printHelp:(NSString *)commandName;

/**
 * Alloc and initialize a new instance of this class
 */
+ (instancetype)videoSnap;


// Instance methods

-(id)init;

/**
 * Parse command line arguments and run command
 */
-(int)processArgs:(int)argc argv:(const char *[])argv;

/**
 * Prints all attached & connected AVCaptureDevice's capable of video capturing
 */
-(void)printDeviceList;

/**
 * Creates a capture session on device, saving to a filePath for recordSeconds
 * return YES if successful
 *
 * @return Boolean
 */
-(Boolean)prepareCapture;

/**
 * Adds a video device to the capture session returns YES if successful
 *
 * @return Boolean
 */
-(Boolean)addVideoDevice;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns YES if successful
 *
 * @return Boolean
 */
-(Boolean)addAudioDevice;

/**
 * Sets compression video/audio options on the output file
 */
-(void)setCompressionOptions:(NSString *)videoCompression audioCompression:(NSString *)audioCompression;

/**
 * Starts capture session recording, returns YES if started successfully
 */
-(Boolean)startCapture;

/**
 * Pauses execution for a number of seconds
 */
-(void)sleep:(double)sleepSeconds;


/**
 * AVCaptureFileOutputRecordingDelegate methods
 */
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections;
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error;

/**
 * Stops the capture and writes to the output file
 */
-(void)stopCapture;

@end

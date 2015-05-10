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


// VideoSnap
@interface VideoSnap : NSObject {
	Boolean         noAudio;
	Boolean         isVerbose;
	Boolean         isSilent;
	NSNumber        *delaySeconds;
	NSNumber        *recordingDuration;
	NSString        *recordingFormat;
	NSURL           *fileURL;
	NSRunLoop       *runLoop;
	
	
	AVCaptureDevice   *captureDevice;
	NSNumberFormatter *numberFormatter;


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

// Instance methods

-(id)init;

/**
 * Parse command line arguments and run command
 */
-(int)processArgs:(int)argc argv:(const char *[])argv;

/**
 * Logs console messages to stdout
 */
-(void)console:(NSString *)message;
-(void)error:(NSString *)message;
-(void)verbose:(NSString *)message;


/**
 * Prints all attached & connected AVCaptureDevice's capable of video capturing
 */
-(void)printDeviceList;



/**
 * Creates a capture session on device, saving to a filePath for recordSeconds
 * return (BOOL) YES successful or (BOOL) NO if not
 *
 * @return Boolean
 */
-(Boolean)prepareCapture:(AVCaptureDevice *)device filePath:(NSString *)filePath recordingDuration:(NSNumber *)recordingDuration videoSize:(NSString *)videoSize withDelay:(NSNumber *)withDelay noAudio:(Boolean)noAudio;

/**
 * Sleeps for a number of seconds
 */
-(void)sleep:(double)sleepSeconds;


/**
 * Starts capturing to the file path
 */
-(void)startCapture:(NSString *)filePath;

/**
 * Stops the capture and writes to the output file
 */
-(void)stopCapture;

/**
 * Stops capture session and closes devices
 */
-(void)finishCapture;

/**
 * Adds a video device to the capture session returns YES if successful
 *
 * @return Boolean
 */
-(Boolean)addVideoDevice:(AVCaptureDevice *)videoDevice;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns YES if successful
 *
 * @return Boolean
 */
-(Boolean)addAudioDevice:(AVCaptureDevice *)videoDevice;

/**
 * Sets compression video/audio options on the output file
 */
-(void)setCompressionOptions:(NSString *)videoCompression audioCompression:(NSString *)audioCompression;

@end

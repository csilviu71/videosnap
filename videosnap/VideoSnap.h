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
	NSNumber                 *maxRecordingSeconds;     // record duration
	NSDate									 *recordingStartedDate;    // when recording started
	NSRunLoop                *runLoop;

	BOOL                     *WeAreRecording;
	AVCaptureSession         *CaptureSession;
	AVCaptureMovieFileOutput *MovieFileOutput;
	AVCaptureDeviceInput     *VideoInputDevice;
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
 * Lists all attached & connected AVCaptureDevice's capable of video capturing
 */
+(void)listDevices;


// instance methods

-(id)init;

/**
 * Creates a capture session on device, saving to a filePath for recordSeconds
 * return (BOOL) YES successful or (BOOL) NO if not
 *
 * @return BOOL
 */
-(BOOL)prepareCapture:(AVCaptureDevice *)device filePath:(NSString *)filePath recordingDuration:(NSNumber *)recordingDuration videoSize:(NSString *)videoSize withDelay:(NSNumber *)withDelay noAudio:(BOOL)noAudio;

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
 * Adds a video device to the capture session returns (BOOL) YES if successful
 *
 * @return BOOL
 */
-(BOOL)addVideoDevice:(AVCaptureDevice *)videoDevice;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns (BOOL) YES if successful
 *
 * @return BOOL
 */
-(BOOL)addAudioDevice:(AVCaptureDevice *)videoDevice;

/**
 * Sets compression video/audio options on the output file
 */
-(void)setCompressionOptions:(NSString *)videoCompression audioCompression:(NSString *)audioCompression;

@end

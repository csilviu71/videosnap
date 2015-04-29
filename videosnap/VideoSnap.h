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

// logging helpers
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) printf(__VA_ARGS__)
#define verbose(...) (is_verbose && fprintf(stderr, __VA_ARGS__))

// version
#define VERSION @"0.0.2"

// defaults
#define DEFAULT_RECORDING_FILENAME @"movie.mov"
#define DEFAULT_RECORDING_SIZE     @"SD480"
#define DEFAULT_VIDEO_SIZES        @[@"120", @"240", @"SD480", @"HD720"]
#define CAPTURE_FRAMES_PER_SECOND	 20

// global verbose flag
extern BOOL is_verbose;

// global var used to signal interrupt happened (tinyurl.com/lutqg2z)
extern BOOL is_interrupted;

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

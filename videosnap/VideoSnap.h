//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2013 Matthew Hutchinson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

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

// global verbose flag
extern BOOL is_verbose;

// global var used to signal interrupt happened (tinyurl.com/lutqg2z)
extern BOOL is_interrupted;

// VideoSnap
@interface VideoSnap : NSObject {
	QTCaptureSession         *captureSession;          // session
	QTCaptureMovieFileOutput *captureMovieFileOutput;  // file output
	QTCaptureDeviceInput     *captureVideoDeviceInput; // video input
	QTCaptureDeviceInput     *captureAudioDeviceInput; // audio input
	NSNumber                 *maxRecordingSeconds;     // record duration
	NSDate									 *recordingStartedDate;    // when recording started
	NSTimer                  *recordingTimer;          // recording timer
	NSRunLoop                *runLoop;
}

// class methods

/**
 * Returns attached QTCaptureDevice objects that have video. Includes
 * video-only devices (QTMediaTypeVideo) and any audio/video devices
 *
 * @return autoreleased array of video devices
 */
+(NSArray *)videoDevices;

/**
 * Returns default QTCaptureDevice object for video or nil if none found
 *
 * @return QTCaptureDevice
 */
+(QTCaptureDevice *)defaultDevice;

/**
 * Returns QTCaptureDevice matching name or nil if a device matching the name
 * cannot be found
 *
 * @return QTCaptureDevice
 */
+(QTCaptureDevice *)deviceNamed:(NSString *)name;


// instance methods

-(id)init;

/**
 * Creates a capture session on device, saving to a filePath for recordSeconds
 * return (BOOL) YES successful or (BOOL) NO if not
 *
 * @return BOOL
 */
-(BOOL)prepareCapture:(QTCaptureDevice *)device filePath:(NSString *)filePath recordingDuration:(NSNumber *)recordingDuration videoSize:(NSString *)videoSize withDelay:(NSNumber *)withDelay noAudio:(BOOL)noAudio;

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
-(BOOL)addVideoDevice:(QTCaptureDevice *)videoDevice;

/**
 * Starts the recording timer
 */
-(void)startRecordingTimer:(double)recordingSeconds;

/**
 * Called when the recording timer finishes
 */
-(void)checkRecordingTimer:(NSTimer *)timer;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns (BOOL) YES if successful
 *
 * @return BOOL
 */
-(BOOL)addAudioDevice:(QTCaptureDevice *)videoDevice;

/**
 * Sets compression video/audio options on the output file
 */
-(void)setCompressionOptions:(NSString *)videoCompression audioCompression:(NSString *)audioCompression;

/**
 * QTCaptureMovieFileOutput delegate called when camera samples from the output
 * buffer
 */
-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;

/**
 * QTCaptureMovieFileOutput delegate, called when output file has been finally
 * written to
 */
-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;

@end

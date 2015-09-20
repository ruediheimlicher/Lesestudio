
#import <Cocoa/Cocoa.h>

// This view class was stolen from /Developer/Examples/CoreAudio/Services/MatrixMixerTest/
// and sub-classed to be presented horizontally.

@interface MeteringView : NSView {
	int 	mNumChannels;
	
	double  mMinDB;
	double	mMaxDB;
	double 	mMinValue;
	double 	mMaxValue; 
	
	float  *mMeterValues;
	float  *mOldMeterValues;
	
	int	   *mClipValues;
	
	float 	firstTrackOffset;
	
	BOOL drawsMetersOnly;
	BOOL mHasClip;
    BOOL mFirstTime;
}

- (void) setNumChannels: (int) num;
- (int)  numChannels;
- (void) setMinValue: (double) num; // min value (usually 0)
- (void) setMaxValue: (double) num; // max value (usually 1 to √2)

- (void) setDirty: (BOOL)dirty;

- (void) setMinDB: (double) num; // min db value (usually -INF)
- (void) setMaxDB: (double) num; // max db value (usually 0 to +6)

- (void) setHasClipIndicator: (BOOL) hasClip;

- (float)  pixelForValue: (double) value inSize: (int) size;

- (void) updateMeters: (float *) meterValues;	// takes an array of floats
												// meterValue[0]: db value for channel 0
												// meterValue[1]: db peak for channel 0
												// meterValue[2]: db value for channel 1
												// meterValue[3]: db peak for channel 1 ...etc

@end

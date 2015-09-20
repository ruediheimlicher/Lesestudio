//
//  rAudioSettings.h
//  RecPlayII
//
//  Created by Sysadmin on 05.12.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rKanal.h"
#import "Quicktime/Quicktime.h"

@interface rAudioSettings : NSWindowController 
	{
	IBOutlet NSPanel *				SettingsPanel;
   
	IBOutlet NSSlider *				gainControl;
	IBOutlet NSTextField*			gainControlText;
	IBOutlet NSTextField *			LesestudioString;
	IBOutlet NSPopUpButton *		FormatPop;
    

	IBOutlet NSButton *				SchliessenTaste;
	IBOutlet NSTextField *			OutputFormatText;
	BOOL							mOutputFormatWasSetByUser;
	IBOutlet NSPopUpButton *		DevicePopKnopf;
	IBOutlet NSPopUpButton *		InputPopKnopf;
	IBOutlet NSPopUpButton *		InputFormatPopKnopf;
	IBOutlet NSPopUpButton *		PrevDevicePopKnopf;
	rKanal *						SoundKanal;
	
    UserData                        mSavedSettings;
    NSMutableArray *				mRecDeviceChannelStrips;
	Float32							HardwareGainSicher;
	BOOL							mUseHardwareGain;
	BOOL							mGrabberWasRecording;
	BOOL							mGrabberWasPreviewing;
	BOOL							mGrabberWasPaused;
    BOOL							SettingsChanged;
    NSTimer *                       VorschauTimer;

}
- (id)initWithKanal:(rKanal*)derKanal;
- (IBAction)setGainText:(id)sender;
- (OSStatus)openAndConfigureStdAudio:(ComponentInstance*)outCI;
- (IBAction)selectOutputFormat:(id)sender;
- (void)updateOutputFormatText:(id)sender;
- (void)setSettingsChanged:(BOOL)derStatus;
- (BOOL)SettingsChanged;
- (void)stopChannelPreview;
- (void)startChannelPreview;
- (void)showPanel:(id)sender;
- (IBAction)reportDevice:(id)sender;
- (void)updateRecordDeviceControls:(id)sender;
- (void)updateRecordDevicesPopup:(id)sender;
- (void)updateInputOutputPopUp:(NSPopUpButton*)sender withClass:(ComponentPropertyClass)theClass;
- (IBAction)reportRecordInput:(id)sender;
@end

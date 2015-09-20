//
//  rAudioSettings.mm
//  RecPlayII
//
//  Created by Sysadmin on 05.12.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "rAudioSettings.h"

#import "WhackedDebugMacros.h"

#import <AudioToolbox/AudioFormat.h>
#import <unistd.h> // for getpid()


@implementation rAudioSettings
//**


/*
	The SGAudio * object registers itself as a listener for all Listenable SGAudioChannel
	component properties.  It captures the ones it understands and forwards them as
	NSNotification's to the defaultCenter.
	
	Our SGAudioSettings dialog registers itself as an interested observer of all notifications
	sent from its SGAudio * channel object, and here, in sgAudioPropListener, it interprets
	and acts on some important notifications (like device hotplugging).
*/

- (void)sgAudioPropListener:(NSNotification*)n
{
    NSString * name = [n name];
    NSArray * modes = [[NSArray alloc] initWithObjects:
                            NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil];

        // we want to ensure that ui is updated on the main thread only.
        // NSNotifications fire on the thread in which the notification was posted,
        // which may or may not be the main thread when the SGAudioChannel is concerned.
        // So we explicitly performSelectorOnMainThread: rather than calling the update
        // methods directly.
        
    if ([name isEqualToString:SGAudioDeviceListChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updateRecordDevicesPopup:) withObject:self waitUntilDone:NO modes:modes];
//        [self performSelectorOnMainThread:@selector(updatePreviewDevicesPopup:) withObject:self waitUntilDone:NO modes:modes];
    }
    
       
    else if ([name isEqualToString:SGAudioRecordDeviceDiedNotification])
    {
        [[DevicePopKnopf selectedItem] setEnabled:NO];
        NSRunAlertPanel(@"WhackedTV",
                        [NSString stringWithFormat:@"\"%@\" disappeared.  Please select a new record device.",
                            [DevicePopKnopf titleOfSelectedItem]],
                        nil, nil, nil);
    }
    
    
    else if ([name isEqualToString:SGAudioRecordDeviceHoggedChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updateRecordDevicesPopup:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioRecordDeviceStreamFormatChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updateRecordDeviceFormatPopUp:) withObject:self waitUntilDone:NO modes:modes];
//        [self performSelectorOnMainThread:@selector(updateRecordDeviceChannelsBox:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioRecordDeviceStreamFormatListChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updateRecordDeviceFormatPopUp:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioRecordDeviceInputSelectionNotification] ||
                [name isEqualToString:SGAudioRecordDeviceInputListChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updateRecordDeviceInputPopUp:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioPreviewDeviceDiedNotification])
    {
        [[PrevDevicePopKnopf selectedItem] setEnabled:NO];
        NSRunAlertPanel(@"WhackedTV",
                        [NSString stringWithFormat:@"\"%@\" disappeared.  Please select a new preview device.",
                            [PrevDevicePopKnopf titleOfSelectedItem]],
                        nil, nil, nil);
    }
    
    
    else if ([name isEqualToString:SGAudioPreviewDeviceHoggedChangedNotification])
    {
//        [self performSelectorOnMainThread:@selector(updatePreviewDevicesPopup:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioPreviewDeviceStreamFormatChangedNotification] ||
                [name isEqualToString:SGAudioPreviewDeviceStreamFormatListChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updatePreviewDeviceFormatPopUp:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioPreviewDeviceOutputSelectionChangedNotification] ||
                [name isEqualToString:SGAudioPreviewDeviceOutputListChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updatePreviewDeviceOutputPopUp:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    
    else if ([name isEqualToString:SGAudioOutputStreamFormatChangedNotification])
    {
        [self performSelectorOnMainThread:@selector(updateOutputFormatText:) withObject:self waitUntilDone:NO modes:modes];
    }
    
    [modes release];
}

/*________________________________________________________________________________________
*/

- (void)registerForNotifications:(BOOL)doRegister
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (doRegister)
    {
            // register for all notifications from our SGAudio instance
        [nc addObserver:self selector:@selector(sgAudioPropListener:) name:nil object:SoundKanal];
    }
    else {
        [nc removeObserver:self];
    }
}





//**
- (id)initWithKanal:(rKanal*)derKanal;
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPAudioSettings"];
		//[derKanal release];
	SoundKanal=derKanal;
	[SoundKanal retain];

	HardwareGainSicher=0;
	
	return self;
}

- (void)setSettingsChanged:(BOOL)derStatus
{
SettingsChanged=derStatus;
}

- (BOOL)SettingsChanged
{
return SettingsChanged;
}

- (void) awakeFromNib
{
	OSErr err=noErr;
	SettingsChanged=NO;
	NSLog(@"AudioSettings awake");
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 24];
	NSColor * RecPlayFarbe=[NSColor cyanColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	NSFont* Titelfont;
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	//[TitelString setFont: Titelfont];
	//[TitelString setTextColor: TitelFarbe];
	[SchliessenTaste setKeyEquivalent:@"\r"];
	
	//gainControl setzen HardwareGainSicher speichern
	Float32 tempGain;
	mUseHardwareGain=YES;
    ComponentPropertyClass propClass = 
		(mUseHardwareGain) ? kQTPropertyClass_SGAudioRecordDevice 
						   : kQTPropertyClass_SGAudio;
	
	//DeviceChannelStrip UpdateGain
	UInt32 size = 0, flags = 0;
    Float32 * array = NULL;
    
    if (noErr == [SoundKanal getPropertyInfoWithClass:propClass
                                        id:kQTSGAudioPropertyID_PerChannelGain 
                                        type:NULL 
                                        size:&size flags:&flags]
                            && size && (flags & kComponentPropertyFlagCanGetNow))
	{
		//NSLog(@"err=0 size: %d",size);
		array = (Float32*)malloc(size);
		err=[SoundKanal getPropertyWithClass:propClass
											id:kQTSGAudioPropertyID_PerChannelGain 
										  size:size 
									   address:array sizeUsed:&size];
		if (  size/sizeof(Float32))
		{
			HardwareGainSicher=array[0];
			[gainControl setFloatValue:array[0]];
			//NSLog(@"updateGain: %f %f kontrolle: %f",array[0],array[1],[gainControl floatValue]);
			[gainControlText setStringValue:[NSString stringWithFormat:@"%.2f", [gainControl floatValue]]];
			[gainControl setNeedsDisplay];
		}
		
	}
	if (array)
		free(array);
	
	[self updateRecordDeviceControls:self];
		
//	[self startChannelPreview];
    [self registerForNotifications:YES];

	
	[self updateOutputFormatText:self];
		
	
}

- (IBAction)reportClose:(id)sender
{
	OSErr err=noErr;
	//gainControl setzen HardwareGainSicher speichern
	Float32 tempGain;
	mUseHardwareGain=YES;
    ComponentPropertyClass propClass = 
		(mUseHardwareGain) ? kQTPropertyClass_SGAudioRecordDevice 
						   : kQTPropertyClass_SGAudio;
	
	//DeviceChannelStrip UpdateGain
	UInt32 size = 0, flags = 0;
    Float32 * array = NULL;
    
    if (noErr == [SoundKanal getPropertyInfoWithClass:propClass
												   id:kQTSGAudioPropertyID_PerChannelGain 
												 type:NULL 
												 size:&size flags:&flags]
		&& size && (flags & kComponentPropertyFlagCanGetNow))
	{
		Float32 * chanGains = (Float32*)malloc(size * sizeof(Float32));
		UInt32 numChannelGains = size/sizeof(Float32);
		
		// set all chanGains to -1, indicating that we wish to ignore them.
		// we will put non -1 values into the indeces we wish to set.
		for (int i = 0; i < size/sizeof(Float32); i++)
		{
			chanGains[i] = -1.;
		}
		
		// loop through the channel strip array again, this time getting the appropriate
		// volume levels to set on the SGAudioChannel.
		//NSLog(@"gainControl: %f",[gainControl floatValue]);
		chanGains[0] = [gainControl floatValue];
		chanGains[1] = [gainControl floatValue];
		
		
		
		
		err=[SoundKanal setSGAudioPropertyWithClass:propClass 
												 id:kQTSGAudioPropertyID_PerChannelGain 
											   size:size
											address:chanGains];
		
		if (chanGains)
			free(chanGains);
	}
	if (SettingsChanged)
	{
	[NSApp stopModalWithCode:2];
	}
	else
	{
	[NSApp stopModalWithCode:1];
	}
	[[self window]orderOut:NULL];
	NSLog(@"AudioSettings awake end");
}

- (IBAction)reportCancel:(id)sender
{

  [NSApp stopModalWithCode:0];
  [[self window]orderOut:NULL];
  

}



- (IBAction)setGainText:(id)sender
{
//NSLog(@"setGainText: %f",[sender floatValue]);
[gainControlText setStringValue:[NSString stringWithFormat:@"%.2f", [sender floatValue]]];

}


- (OSStatus)openAndConfigureStdAudio:(ComponentInstance*)outCI
{
    // use StdAudio dialog to let user set an output format
    OSStatus err = noErr;
    AudioStreamBasicDescription format;
    ComponentInstance ci;
    SoundDescriptionHandle sdh = NULL;
    UInt32  size = 0;
    AudioChannelLayout *pLayout = NULL;
    SCExtendedProcs xProcs;
	
		// we'll (arbitrarily) limit the format choices shown in the dialog to the below list.
		// (this is purely for pedagogical purposes)
    UInt32 limitedFormats[] = { 'lpcm', 'aac ', 'alac', 'samr', 'ima4' };
	
		// and we'll limit the audio channel layout tags shown in the dialog
		// to these.  If we don't limit the channel layouts to this restricted
		// list, StdAudio will show a laundry list of every channel layout tag
		// defined in CoreAudioTypes.h.
    AudioChannelLayoutTag limitedTagList[] =
    {
			// Prepending kAudioChannelLayoutTag_DiscreteInOrder to the
			// accepted list of channel layout tags lets StdAudio know
			// how many discrete channels are present in our input signal.
            // You need to OR in the real discrete number of channels (see below).
        kAudioChannelLayoutTag_DiscreteInOrder,
            // Prepending kAudioChannelLayoutTag_UseChannelDescriptions to the
			// accepted list of channel layout tags allows passthru of a custom 
			// input layout that would not otherwise be presented in the dialog (i.e. 3.0 surround)
        kAudioChannelLayoutTag_UseChannelDescriptions, 
        
        kAudioChannelLayoutTag_Mono,
        kAudioChannelLayoutTag_Stereo,
        kAudioChannelLayoutTag_Quadraphonic,
        kAudioChannelLayoutTag_MPEG_5_0_A,
        kAudioChannelLayoutTag_MPEG_5_0_B,
        kAudioChannelLayoutTag_MPEG_5_0_C,
        kAudioChannelLayoutTag_MPEG_5_0_D,
        kAudioChannelLayoutTag_MPEG_5_1_A,
        kAudioChannelLayoutTag_MPEG_5_1_B,
        kAudioChannelLayoutTag_MPEG_5_1_C,
        kAudioChannelLayoutTag_MPEG_5_1_D,
        kAudioChannelLayoutTag_AudioUnit_6_0,
        kAudioChannelLayoutTag_AAC_6_0,
        kAudioChannelLayoutTag_MPEG_6_1_A,
        kAudioChannelLayoutTag_AAC_6_1,
        kAudioChannelLayoutTag_AudioUnit_7_0,
        kAudioChannelLayoutTag_AAC_7_0,
        kAudioChannelLayoutTag_MPEG_7_1_A,
        kAudioChannelLayoutTag_MPEG_7_1_B,
        kAudioChannelLayoutTag_MPEG_7_1_C,
        kAudioChannelLayoutTag_Emagic_Default_7_1
     };
    
    
        // We configure StdAudio by telling it the starting input format and output formats,
        // plus any restrictions we want to set.
        
        // First we get the input format (asbd)
		   
    BAILSETERR( [SoundKanal getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice
                                    id:kQTSGAudioPropertyID_StreamFormat 
                                    size:sizeof(format) 
                                    address:&format sizeUsed:NULL] );
 
        // then we get the channel map property, since the record device StreamFormat
        // property does not take into account deactivated channels, always reporting
        // the full number of channels present on the device
    BAILSETERR( [SoundKanal getPropertyInfoWithClass:kQTPropertyClass_SGAudioRecordDevice
                                    id:kQTSGAudioPropertyID_ChannelMap 
                                    type: NULL
                                    size: &size
                                    flags:NULL] );
    
		// if the number of total channels on the record device differs from the number
		// of enabled channels, we need to adjust some of the fields in the AudioStreamBasicDescription
    if ( (size != 0) && (format.mChannelsPerFrame != size/sizeof(SInt32)) )
    {
        UInt32 oldNumChans = format.mChannelsPerFrame;
        format.mChannelsPerFrame = size/sizeof(SInt32); // channel map is an array of SInt32's.
        
        // adjust the fields of the asbd that need adjusting
        if (0 == (format.mFormatFlags & kAudioFormatFlagIsNonInterleaved) )
        {
            UInt32 bytesPerFramePerChannel = format.mBytesPerFrame / oldNumChans;
            format.mBytesPerFrame = format.mBytesPerPacket = format.mChannelsPerFrame * bytesPerFramePerChannel;
        }
    }

    BAILSETERR( OpenADefaultComponent(StandardCompressionType, StandardCompressionSubTypeAudio, &ci) );
    
    
        // configure the dialog to only allow a subset of compression formats
    BAILSETERR( QTSetComponentProperty(ci, kQTPropertyClass_SCAudio,
                                        kQTSCAudioPropertyID_ClientRestrictedCompressionFormatList,
                                        sizeof(limitedFormats), limitedFormats) );

    
        // configure the dialog to only allow a subset of channel layouts
    limitedTagList[0] |= format.mChannelsPerFrame;
    BAILSETERR( QTSetComponentProperty(ci, kQTPropertyClass_SCAudio,
                                        kQTSCAudioPropertyID_ClientRestrictedChannelLayoutTagList,
                                        sizeof(limitedTagList), limitedTagList) );
                                                
                                        
    
        // set the input format of the StdAudio component to that of our recording input asbd
    BAILSETERR( QTSetComponentProperty(ci, kQTPropertyClass_SCAudio, 
                                            kQTSCAudioPropertyID_InputBasicDescription, 
                                            sizeof(format), &format) );
                                            
        // set the input layout of the StdAudio component to that of our recording device
    if (noErr == [SoundKanal getPropertyInfoWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                            id:kQTSGAudioPropertyID_ChannelLayout 
                                            type:NULL size:&size flags:NULL] && size)
    {
        pLayout = (AudioChannelLayout*)malloc(size);
        [SoundKanal getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                id:kQTSGAudioPropertyID_ChannelLayout 
                                size:size address:pLayout sizeUsed:&size];
								
								
			// see if this layout can be made into a tag
		if (pLayout->mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelDescriptions)
		{
			UInt32 tag;
			UInt32 propSize = sizeof(tag);
			if (noErr == AudioFormatGetProperty(
									kAudioFormatProperty_TagForChannelLayout,
									size, pLayout,
									&propSize, &tag))
				pLayout->mChannelLayoutTag = tag;
		}
		
        BAILSETERR( QTSetComponentProperty(ci, kQTPropertyClass_SCAudio, 
                                        kQTSCAudioPropertyID_InputChannelLayout, 
                                        size, pLayout) );
    }     
    
                                            
        // set the output format of the StdAudio component to that of our SGAudio's output.
    BAILSETERR( [SoundKanal getPropertyWithClass:kQTPropertyClass_SGAudio 
                                        id:kQTSGAudioPropertyID_SoundDescription 
                                        size:sizeof(sdh) address:&sdh sizeUsed:NULL] );
    
    BAILSETERR( QTSetComponentProperty(ci, kQTPropertyClass_SCAudio, 
                                        kQTSCAudioPropertyID_SoundDescription, 
                                        sizeof(sdh), &sdh) );
    DisposeHandle((Handle)sdh);
    sdh = NULL;
    
        // display a custom title in the window
    memset(&xProcs, 0, sizeof(xProcs));
	
		// Icky. the SCExtendedProcs struct is a holdover from older Standard Compression
		// components, and as such, it takes a pascal string as its custom name.  Sigh.
    strcpy((char*)xProcs.customName + 1, "Output Format");
    xProcs.customName[0] = strlen((char*)xProcs.customName + 1);
    BAILSETERR( QTSetComponentProperty(ci, kQTPropertyClass_SCAudio, 
                                        kQTSCAudioPropertyID_ExtendedProcs, 
                                        sizeof(xProcs), &xProcs) );

	*outCI = ci;
bail:
	if (pLayout)
		free(pLayout);
	DisposeHandle((Handle)sdh);
	return err;
}


- (void)updateOutputFormatText:(id)sender
{

#pragma unused(sender)
    OSStatus err = noErr;
    SoundDescriptionHandle sdh = NULL;
    NSString * name = nil;

    
	BAILSETERR( [SoundKanal getPropertyWithClass: kQTPropertyClass_SGAudio 
										 id: kQTSGAudioPropertyID_SoundDescription 
									   size: sizeof(sdh)
									address: &sdh
								   sizeUsed: NULL] );
    
    BAILSETERR( QTSoundDescriptionGetProperty(sdh,
                        kQTPropertyClass_SoundDescription,
                        kQTSoundDescriptionPropertyID_UserReadableText,
                        sizeof(name), &name, NULL) );
    
    [OutputFormatText setStringValue:name];
bail:
    [name release];
	DisposeHandle((Handle)sdh);
    if (err)
        NSRunAlertPanel(@"WhackedTV", 
			[NSString stringWithFormat:@"Trouble updating output format (Error %ld)", err],
			 nil, nil, nil);
}


// for the duration of the SGAudioSettings dialog, we want to preview.  But several
// properties can only be set when the channel is not in recording or previewing mode,
// so we'll call this method to stop/start the preview if we receive a -2200 error
// on the first try
- (OSStatus)setSGAudioPropertyWithClass:(ComponentPropertyClass)theClass
                                id:(ComponentPropertyID)theID
                                size:(ByteCount)sz
                                address:(ConstComponentValuePtr)addr
{
    OSStatus err = noErr;
    err = [SoundKanal setPropertyWithClass: theClass 
										id: theID 
									  size: sz 
								   address: addr];
	
    if (err == kQTPropertyAskLaterErr)
    {
        [self stopChannelPreview];
        
        err = [SoundKanal setPropertyWithClass: theClass 
											id: theID 
										  size: sz 
									   address: addr];
        
//        [self startChannelPreview];
    }
    
    return err;
}

/*________________________________________________________________________________________
*/

- (void)updateFormatPopUp:(NSPopUpButton*)sender withClass:(ComponentPropertyClass)theClass
{
    AudioStreamBasicDescription * formats = NULL;
    AudioStreamBasicDescription curFormat;
    UInt32 i, size, flags;
    OSStatus err = noErr;
    NSLog(@"updateFormatPopUp: sender: %@",[sender description]);
    [sender removeAllItems];
    
	BAILSETERR( [SoundKanal getPropertyWithClass: theClass 
										 id: kQTSGAudioPropertyID_StreamFormat 
									   size: sizeof(curFormat) 
									address: &curFormat
								   sizeUsed: NULL] );
	
	BAILSETERR( [SoundKanal getPropertyInfoWithClass: theClass 
										 id: kQTSGAudioPropertyID_StreamFormatList 
										 type:NULL size:&size flags:&flags] );
    assert(flags & kComponentPropertyFlagCanGetNow);

    formats = (AudioStreamBasicDescription*)malloc(size);
	BAILSETERR( [SoundKanal getPropertyWithClass: theClass 
										 id: kQTSGAudioPropertyID_StreamFormatList 
									   size: size
									address: formats
								   sizeUsed: &size] );
    
    NSLog(@"Anzahl Descriptors: %ld",size/sizeof(AudioStreamBasicDescription));
    for (i = 0; i < size/sizeof(AudioStreamBasicDescription); i++)
    {
        NSString * name = nil;
        SoundDescriptionHandle sdh = NULL;
        
			// QTSoundDescriptionSet/GetProperty{Info} API's can help us by
			// giving us a nicely formatted CFString of the format in question
        BAILSETERR( QTSoundDescriptionCreate(&formats[i], NULL, 0, NULL, 0, 
                        kQTSoundDescriptionKind_Movie_AnyVersion, &sdh) );
                        
        BAILSETERR( QTSoundDescriptionGetProperty(sdh, kQTPropertyClass_SoundDescription,
                        kQTSoundDescriptionPropertyID_UserReadableText,
                        sizeof(name), &name, NULL) );
        
        DisposeHandle((Handle)sdh);    

        [sender addItemWithTitle:name];
        [name release];
        
        if (formats[i].mSampleRate == curFormat.mSampleRate &&
            formats[i].mFormatID == curFormat.mFormatID &&
            formats[i].mFormatFlags == curFormat.mFormatFlags &&
            formats[i].mChannelsPerFrame == curFormat.mChannelsPerFrame &&
            formats[i].mBitsPerChannel == curFormat.mBitsPerChannel &&
            formats[i].mFramesPerPacket == curFormat.mFramesPerPacket &&
            formats[i].mBytesPerFrame == curFormat.mBytesPerFrame &&
            formats[i].mBytesPerPacket == curFormat.mBytesPerPacket)
        {
            [sender selectItemAtIndex:i];
        }
    }
                                            
bail:
    if (err)
        NSRunAlertPanel(@"WhackedTV", 
			[NSString stringWithFormat:@"Trouble updating format list (Error %ld)", err], 
			nil, nil, nil);
    if (formats) 
		free(formats);
    return;
}


/*________________________________________________________________________________________
*/

- (void)updateRecordDeviceFormatPopUp:(id)sender
{
#pragma unused(sender)
	NSLog(@"updateRecordDeviceFormatPopUp: sender: %@",[sender description]);
    [self updateFormatPopUp:InputFormatPopKnopf 
            withClass:kQTPropertyClass_SGAudioRecordDevice];
}

/*________________________________________________________________________________________
*/


/*________________________________________________________________________________________
*/

- (IBAction)selectRecordDeviceFormat:(id)sender
{
    OSStatus err = noErr;
    AudioStreamBasicDescription * formats = NULL;
    UInt32 size = 0;
    
    BAILSETERR( [SoundKanal getPropertyInfoWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                            id:kQTSGAudioPropertyID_StreamFormatList 
                                            type:NULL size:&size flags:NULL] );
    formats = (AudioStreamBasicDescription *)malloc(size);
    
    BAILSETERR( [ SoundKanal getPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                        id:kQTSGAudioPropertyID_StreamFormatList 
                                        size:size 
                                        address:formats sizeUsed:NULL] );
    
    BAILSETERR( [self setSGAudioPropertyWithClass:kQTPropertyClass_SGAudioRecordDevice 
                                        id:kQTSGAudioPropertyID_StreamFormat 
                                        size:sizeof(AudioStreamBasicDescription) 
                                        address:&formats[[sender indexOfSelectedItem]]] );
bail:
    if (formats)
        free(formats);
    return;
}

/*________________________________________________________________________________________
*/



- (IBAction)selectOutputFormat:(id)sender
{
//SGAudioSettings selectOutputFormat

#pragma unused(sender)
    // use StdAudio dialog to let user set an output format
    OSStatus err = noErr;
    ComponentInstance ci;
    SoundDescriptionHandle sdh = NULL;
	    
		
	BAILSETERR( [self openAndConfigureStdAudio:&ci] );
	
        // show the dialog (this call blocks until the dialog is finished)
    BAILSETERR( SCRequestImageSettings(ci) );
    
	
		// now we'll get the new output sound description
		// (I use the SoundDescription property because it encompasses 
		// the 1. AudioStreamBasicDescription, 2. AudioChannelLayout, and
		// 3. MagicCookie of the output format.  Otherwise I'd have to
		// make three separate property get/set pairs of calls
    BAILSETERR( QTGetComponentProperty(ci, kQTPropertyClass_SCAudio, 
                                        kQTSCAudioPropertyID_SoundDescription, 
                                        sizeof(sdh), &sdh, NULL) );


    BAILSETERR( [self setSGAudioPropertyWithClass:kQTPropertyClass_SGAudio 
                                    id:kQTSGAudioPropertyID_SoundDescription 
                                    size:sizeof(sdh) address:&sdh] );
	//HLock((Handle)sdh);
//   NSData* OutputDaten=[NSData dataWithBytes:(Handle)sdh length:GetHandleSize((Handle)sdh)];
	//NSData* OutputDaten=[NSData dataWithBytes:sdh length:GetHandleSize((Handle)sdh)];
	//NSLog(@"OutputDaten: %@  l: %d",[OutputDaten description],GetHandleSize((Handle)sdh));
	
	//HUnlock((Handle)sdh);
	
	
	[self updateOutputFormatText:self];
	SettingsChanged=YES;
bail:
	if (err == userCanceledErr)
		err = noErr; // canceling is ok.
		
    if (err)
		NSRunAlertPanel(@"Output Format:", 
			[NSString stringWithFormat:@"Trouble setting output format (Error %ld)", err], 
			nil, nil, nil);
			
    DisposeHandle((Handle)sdh);
    CloseComponent(ci);
}

- (void)idleTimer:(NSTimer*)timer
{
#pragma unused(timer)
	SGIdle([SoundKanal SoundKanal]);
}


- (void)stopChannelPreview
{
    [VorschauTimer invalidate];
    [VorschauTimer release];
    VorschauTimer = nil;

SGStop([SoundKanal SoundKanal]);
SGRelease([SoundKanal SoundKanal]);
}

- (void)startChannelPreview
{
    if (VorschauTimer == nil)
    {
        VorschauTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                        interval:.05
                                        target:self 
                                        selector:@selector(idleTimer:)  
                                        userInfo:nil repeats:YES];
    }
NSLog(@"startChannelPreview");
SGPrepare([SoundKanal SoundKanal],true,false);
//SGStartPreview([SoundKanal SoundKanal]);
[[NSRunLoop currentRunLoop] addTimer:VorschauTimer forMode:NSModalPanelRunLoopMode];
[[NSRunLoop currentRunLoop] addTimer:VorschauTimer forMode:NSEventTrackingRunLoopMode];

}

- (IBAction)selectRecordDevice:(id)sender
{
    NSArray *       deviceList = [SoundKanal deviceList];
    NSDictionary *  devDict = nil;
    OSStatus        err = noErr;
    
    devDict = [deviceList objectAtIndex:[(NSMenuItem*)[sender selectedItem] tag]];
   // NSLog(@"selectRecordDevice: %@",[devDict description]);
    if (devDict)
    {
        NSString * uid = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceUIDKey];
		NSLog(@"selectRecordDevice: uid: %@",uid);
		NSString *		curDevUID = nil;
		
		BAILSETERR( [SoundKanal getPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
											 id: kQTSGAudioPropertyID_DeviceUID 
										   size: sizeof(curDevUID) 
										address: &curDevUID 
									   sizeUsed: NULL] );
		
		if ( NO == [curDevUID isEqualToString: uid] )
		{
		//	[self stopChannelPreview];
			
			BAILSETERR( [self setSGAudioPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice
												 id: kQTSGAudioPropertyID_DeviceUID
											   size: sizeof(uid)
											address: &uid] );
											
			// make sure we start off totally fresh, namely
			// 1. nuke record device layout
			// 2. nuke output layout
			// 3. nuke output magic cookie
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
									id: kQTSGAudioPropertyID_ChannelLayout 
								  size: 0  address:NULL] );
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudio 
									id: kQTSGAudioPropertyID_ChannelLayout
								  size: 0  address:NULL] );
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudio 
									id: kQTSGAudioPropertyID_MagicCookie
								  size: 0  address:NULL] );
			
			
//			[self startChannelPreview];
			[self updateRecordDeviceControls:self];
		}
		
		[curDevUID release];
    }
bail:
    return;
}

-(IBAction)reportDevice:(id)sender
{
NSLog(@"reportDevice: %@", [sender titleOfSelectedItem]);
{
    NSArray *       deviceList = [SoundKanal deviceList];
    NSDictionary *  devDict = nil;
    OSStatus        err = noErr;
    
    devDict = [deviceList objectAtIndex:[(NSMenuItem*)[sender selectedItem] tag]];
   // NSLog(@"selectRecordDevice: %@",[devDict description]);
    if (devDict)
    {
        NSString * uid = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceUIDKey];
		NSLog(@"selectRecordDevice: uid: %@",uid);
		NSString *		curDevUID = nil;
		
		BAILSETERR( [SoundKanal getPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
											 id: kQTSGAudioPropertyID_DeviceUID 
										   size: sizeof(curDevUID) 
										address: &curDevUID 
									   sizeUsed: NULL] );
		
		if ( NO == [curDevUID isEqualToString: uid] )
		{
			[self stopChannelPreview];
			
			BAILSETERR( [self setSGAudioPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice
												 id: kQTSGAudioPropertyID_DeviceUID
											   size: sizeof(uid)
											address: &uid] );
											
			// make sure we start off totally fresh, namely
			// 1. nuke record device layout
			// 2. nuke output layout
			// 3. nuke output magic cookie
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
									id: kQTSGAudioPropertyID_ChannelLayout 
								  size: 0  address:NULL] );
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudio 
									id: kQTSGAudioPropertyID_ChannelLayout
								  size: 0  address:NULL] );
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudio 
									id: kQTSGAudioPropertyID_MagicCookie
								  size: 0  address:NULL] );
			
			
//			[self startChannelPreview];
			[self updateRecordDeviceControls:self];
		}
		
		[curDevUID release];
    }
bail:
    return;
}

}


- (void)updateRecordDeviceControls:(id)sender
{
    [self updateRecordDevicesPopup:sender];
    [self updateRecordDeviceInputPopUp:sender];
    [self updateRecordDeviceFormatPopUp:sender];
    //[self updateUseHardwareGainControls:sender];
    //[self updateRecordDeviceMasterGainSlider:self];
    //[self updateRecordDeviceChannelsBox:self];
}


- (IBAction)reportRecordDevice:(id)sender
{
    NSArray *       deviceList = [SoundKanal deviceList];
    NSDictionary *  devDict = nil;
    OSStatus        err = noErr;
    
    devDict = [deviceList objectAtIndex:[(NSMenuItem*)[sender selectedItem] tag]];
   // NSLog(@"selectRecordDevice: %@",[devDict description]);
    if (devDict)
    {
        NSString * uid = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceUIDKey];
		NSLog(@"selectRecordDevice: uid: %@",uid);
		NSString *		curDevUID = nil;
		NSLog(@"selectRecordDevice: uid: %@",uid);
		BAILSETERR( [SoundKanal getPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
											 id: kQTSGAudioPropertyID_DeviceUID 
										   size: sizeof(curDevUID) 
										address: &curDevUID 
									   sizeUsed: NULL] );
		
		if ( NO == [curDevUID isEqualToString: uid] )
		{
			[self stopChannelPreview];
			
			BAILSETERR( [self setSGAudioPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice
												 id: kQTSGAudioPropertyID_DeviceUID
											   size: sizeof(uid)
											address: &uid] );
											
			// make sure we start off totally fresh, namely
			// 1. nuke record device layout
			// 2. nuke output layout
			// 3. nuke output magic cookie
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice 
									id: kQTSGAudioPropertyID_ChannelLayout 
								  size: 0  address:NULL] );
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudio 
									id: kQTSGAudioPropertyID_ChannelLayout
								  size: 0  address:NULL] );
			BAILSETERR( [SoundKanal setPropertyWithClass: kQTPropertyClass_SGAudio 
									id: kQTSGAudioPropertyID_MagicCookie
								  size: 0  address:NULL] );
			
			
//			[self startChannelPreview];
			[self updateRecordDeviceControls:self];
		}
		
		[curDevUID release];
    }
bail:
    return;
}

- (void)updateDevicesPopUp:(NSPopUpButton*)sender withClass:(ComponentPropertyClass)theClass
{
	OSStatus err = noErr;
	NSString * selectedDeviceUID = nil;
    NSArray * deviceList = nil;
	UInt32 i;
	
        // get the device list.  Note, device list contains _all_ devices, 
        // not just record-capable ones
    BAILSETERR( [SoundKanal getPropertyWithClass: kQTPropertyClass_SGAudio 
                                         id: kQTSGAudioPropertyID_DeviceListWithAttributes 
                                       size: sizeof(NSArray*) 
                                    address: &deviceList
                                   sizeUsed: NULL] );
									   
        // get the currently selected rec/prev device
	BAILSETERR( [SoundKanal getPropertyWithClass: theClass 
										 id: kQTSGAudioPropertyID_DeviceUID 
									   size: sizeof(NSArray*) 
									address: &selectedDeviceUID
								   sizeUsed: NULL] );
		
		
	[sender removeAllItems];
	for (i = 0; i < [deviceList count]; i++)
	{
		NSNumber * number;
		BOOL disableIt = NO;
		NSDictionary * devDict = [deviceList objectAtIndex:i];
        UInt32 key = (theClass == kQTPropertyClass_SGAudioRecordDevice)
                      ? kQTAudioDeviceAttribute_DeviceCanRecordKey
                      : kQTAudioDeviceAttribute_DeviceCanPreviewKey;
		
		NSString * curUID = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceUIDKey];
		NSString * curName = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceNameKey];
		
			// skip it if it's not a recording device
		number = [devDict objectForKey:(id)key];
		if (number && [number boolValue] == false)
			continue;
		
			// if it's dead, add it, but disable it
		number = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceAliveKey];
		if (number && [number boolValue] == false)
		{
			disableIt = YES;
			goto addItem;
		}		

			// if it's hogged, add it, and don't disable it, but indicate that it's hogged
		number = [devDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceHoggedKey];
		if (number && [number longValue] != -1 && [number longValue] != getpid())
		{
			curName = [NSString stringWithFormat:@"%@ [hogged by %ld]", curName, [number longValue]];
			goto addItem;
		}
		
addItem:		
		[sender addItemWithTitle:curName];
            // record the index of the device in the item tag
        [[sender lastItem] setTag:i];
		
		if (disableIt)
			[[sender lastItem] setEnabled:NO];
		if ([curUID isEqualToString:selectedDeviceUID])
			[sender selectItem:[sender lastItem]];		
	}

bail:
    if (err)
        NSRunAlertPanel(@"WhackedTV", 
			[NSString stringWithFormat:@"Trouble updating device list (Error %ld)", err], 
			nil, nil, nil);
	[selectedDeviceUID release];
    [deviceList release];
	return;
}

- (void)updateRecordDevicesPopup:(id)sender
{
//updateRecordDevicesPopUp Button: mRecDevicesPopUp
#pragma unused(sender)
    [self updateDevicesPopUp:DevicePopKnopf withClass:kQTPropertyClass_SGAudioRecordDevice];
}

- (void)updateRecordDeviceInputPopUp:(id)sender
{
//updateRecordDeviceInputPopUp	Button:mRecDeviceInputsPopUp
#pragma unused(sender)
    [self updateInputOutputPopUp:InputPopKnopf 
        withClass:kQTPropertyClass_SGAudioRecordDevice];
}

- (void)updateInputOutputPopUp:(NSPopUpButton*)sender withClass:(ComponentPropertyClass)theClass
{
    OSType selected = 0;
    NSArray * theList = nil;
    OSStatus err = noErr;
    BOOL isInput = (theClass == kQTPropertyClass_SGAudioRecordDevice);
    ComponentPropertyID theID;
    
    [sender removeAllItems];
    
    theID = (isInput ? kQTSGAudioPropertyID_InputSelection : kQTSGAudioPropertyID_OutputSelection);
    
	if (noErr ==[SoundKanal getPropertyWithClass: theClass 
										 id: theID
									   size: sizeof(selected) 
									address: &selected
								   sizeUsed: NULL] )
    {
        int i;
        theID = (isInput ? kQTSGAudioPropertyID_InputListWithAttributes 
                             : kQTSGAudioPropertyID_OutputListWithAttributes);
                             
		BAILSETERR( [SoundKanal getPropertyWithClass: theClass 
										 id: theID 
									   size: sizeof(NSArray*) 
									address: &theList
								   sizeUsed: NULL] );
        [sender setEnabled:YES];
        
        for (i = 0; i < [theList count]; i++)
        {
            NSDictionary * d = [theList objectAtIndex:i];
			
            theID = (isInput ? kQTAudioDeviceAttribute_DeviceInputDescription 
                             : kQTAudioDeviceAttribute_DeviceOutputDescription);
            
            [sender addItemWithTitle:
				[d objectForKey:(id)theID]];
                
            theID = (isInput ? kQTAudioDeviceAttribute_DeviceInputID 
                             : kQTAudioDeviceAttribute_DeviceOutputID);
				
            if (selected == 
				 [(NSNumber*)[d objectForKey:(id)theID] unsignedLongValue])
			{
                [sender selectItemAtIndex:i];
			}
        }   
    }
    else {
        // this device doesn't support inputs/outputs.
        // disable the menu
        [sender addItemWithTitle:@"None"];
        [sender setEnabled:NO];
    }   
    
bail:
    if (err)
        NSRunAlertPanel(@"WhackedTV", 
			[NSString stringWithFormat:@"Trouble updating input list (Error %ld)", err], 
			nil, nil, nil);
    [theList release];
    return;
}


/*________________________________________________________________________________________
*/






- (IBAction)reportRecordInput:(id)sender
{
    OSStatus err = noErr;
    NSArray * list = nil;
    
    BAILSETERR([SoundKanal getPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice
                             id: kQTSGAudioPropertyID_InputListWithAttributes
                           size: sizeof(list)
                        address: &list 
                       sizeUsed: NULL]);
                       
    if (list)
    {
        NSDictionary * selDict = [list objectAtIndex:[sender indexOfSelectedItem]];
        UInt32 newSel = 
            [(NSNumber*)[selDict objectForKey:(id)kQTAudioDeviceAttribute_DeviceInputID] 
                unsignedIntValue];
        
        BAILSETERR( 
            [self setSGAudioPropertyWithClass: kQTPropertyClass_SGAudioRecordDevice
                                         id: kQTSGAudioPropertyID_InputSelection
                                       size: sizeof(newSel)
                                    address: &newSel] );
    }
    
bail:
    [list release];
    return;
}





- (void)showPanel:(id)sender
{

}
@end

/*
 *  rRecorder.cpp
 *  RecPlayC
 *
 *  Created by Ruedi Heimlicher on Fri Aug 06 2004.
 *  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
 *
 */
#include "rRecorder.h"

static pascal Boolean SeqGrabberModalFilterProc (DialogPtr theDialog, const EventRecord *theEvent,short *itemHit, long refCon);

//*******************************************************************************
rRecorder::rRecorder()
{
	Grabber =0L;
	Soundkanal=0L;
	recordingOK=0;
	GrabberOK=0;
	RecPlayMovie=0L;
	playingOK=0;
	Durchlauf=0;
	Abspieldauerfeld=0;
	ClockDescriptor.componentType='    ';          //* A unique 4-byte code indentifying the command set */
	ClockDescriptor.componentSubType=0L;       //* Particular flavor of this instance */
	ClockDescriptor.componentManufacturer='appl';  //* Vendor indentification */
	ClockDescriptor.componentFlags=0L;         //* 8 each for Component,Type,SubType,Manuf/revision */
	ClockDescriptor.componentFlagsMask=0L;
}
//*******************************************************************************
//*******************************************************************************
rRecorder::~rRecorder()
{
	
}

//*******************************************************************************
OSErr	rRecorder::terminate()
{
	OSErr err=CloseComponent(Grabber);
	return err;
}

//*******************************************************************************
//*******************************************************************************
void	rRecorder::setParameter(SInt32	dieFileRefNum,SInt32 dieVolRefNum,SInt32 dieParentDirID)
{
	//fileRefNum=dieFileRefNum;
	volRefNum=dieVolRefNum;
	ParentDirID=dieParentDirID;
	EinstellungenH=NewHandle(sizeof(UserData));
}
//*******************************************************************************

short rRecorder::getGrabberStatus()
{
return !(Grabber==0L);
}

//*******************************************************************************
OSErr 	rRecorder::setGrabber()
{
	//ComponentDescription	Descriptor;
	ComponentResult		result = noErr;
	GrafPtr				savedPort;
	Component			sgCompID;
	short hit;
	
	//printf("SGNewChannel setRecorder\n\n");
	// Find and open a sequence grabber
	GrabberDescriptor.componentType = SeqGrabComponentType;
	GrabberDescriptor.componentSubType = 0L;
	GrabberDescriptor.componentManufacturer = 'appl';
	GrabberDescriptor.componentFlags = 0L;
	GrabberDescriptor.componentFlagsMask = 0L;	
	sgCompID = FindNextComponent (NULL, &GrabberDescriptor);
	if (sgCompID == 0L)
	{
	return 1;
	}
	Grabber = OpenComponent (sgCompID);
	if (Grabber == 0L)													// If we got a sequence grabber, set it up
	{
	return 1;
	}
		GrabberOK=true;
		result = ::SGInitialize (Grabber);
		if (result)
		{
			//hit=RecFehler(gRecfehlerID,gRecfehlerstringlist,gSetUsageErr);
			printf("SGInitialize: Kein Grabber\n");
			OSErr err=CloseComponent(Grabber);
					}						
		
		
		result = ::SGNewChannel (Grabber, SoundMediaType, &Soundkanal);					// Get a sound channel
		if (result)
		{
			//hit=RecFehler(gRecfehlerID,gRecfehlerstringlist,gSndChannelErr);
			printf("SGNewChannel: Kein SoundChannel\n");
			OSErr err=CloseComponent(Grabber);
			
		}
		GrabberOK=(Grabber != 0L);
				if (Soundkanal != NULL&& (result == noErr))
		{
			sndInputDriverRef = ::SGGetSoundInputDriver(Soundkanal);
			OSErr err=0;
			
			ComponentResult CompResultat=0;
			
			short meterState = 1;												// IntputLevelmeter: turn it on
			result = SPBSetDeviceInfo(sndInputDriverRef, siLevelMeterOnOff, (char *)&meterState);
			if (result)
			{
				printf("SPBSetDeviceInfo.siLevelMeterOnOff misslungen:%d \n",result);
				return result;
			}
			
			result = ::SGSetChannelUsage (Soundkanal, seqGrabPreview | seqGrabRecord);	//Set ChannelUsage
			//result = ::SGSetChannelUsage (Soundkanal,  seqGrabRecord);	//Set ChannelUsage
			if (result)
			{
				printf("SGSetChannelUsage misslungen:%d \n",result);
				return result;
			}	
			
			Fixed newGainValue = Long2Fix(2);     /* input gain may range from 0.5 - 1.5 */	
			newGainValue=0;
			//result = SPBSetDeviceInfo(sndInputDriverRef, siInputGain, (void *)newGainValue);
			result = SPBGetDeviceInfo(sndInputDriverRef, siInputGain, (Ptr)&gain);
			//gain=newGainValue;
			printf("Gain Value gelesen: %d \n",gain);
			if (result)
			{
				printf("SPBGetDeviceInfo.siInputGain misslungen:%d \n",result);
				return result;
			}
			
									/*						
			if (neu)
			{
				result = SGSetSoundInputParameters(Soundkanal, 8,1,'raw ');
				printf("**********			SGSetSoundInputParameters gesetzt: %d,\n",result);
				if (result)
				{
					printf("Error nach SGSetSoundInputParameters: %d,\n",result);
				}
				
			}//if neu
			
			*/
			
			result = ::SGSetChannelVolume (Soundkanal, 0x0010);
			// Set the volume low to prevent feedback when we start the preview,
			// in case the mic is anywhere near the speaker.
			if (result)
			{
				printf("SGSetChannelVolume misslungen:%d \n",result);
				return result;
			}			

			Handle sampleRates = NULL;
			sampleRates = NewHandleClear(5*sizeof(Fixed));
			if(sampleRates) 
			{
				OSErr tempErr=0;
				*(long*)(*sampleRates) = 8000<<16; // add 8kHz rate
				*((long*)(*sampleRates)+1) = 11025<<16; // add 11kHz rate
				*((long*)(*sampleRates)+2) = 16000<<16; // add 16kHz rate
				*((long*)(*sampleRates)+3) = 22050<<16; // add 22kHz rate
				*((long*)(*sampleRates)+4) = 32000<<16; // add 32kHz rate
				
				//((long*)(*sampleRates)) = 22050<<16; // add 22kHz rate
				
				tempErr = ::SGSetAdditionalSoundRates(Soundkanal,sampleRates);
				if (tempErr)
				{
					printf("SGSetAdditionalSoundRates misslungen:%d \n",tempErr);
					//hit=RecFehler(gRecfehlerID,gRecfehlerstringlist,gSetSampleRatesErr);
					return result;
				}						
				DisposeHandle(sampleRates);
			}	
		}//SoundKanal ist OK
	result = ::SGStartPreview (Grabber);
	printf("setRecorder SGStartPreview: %d\n",result);
printf("setGrabber: result: %d\n",result);
return (result==0);
}
//*******************************************************************************

//*******************************************************************************
SInt32	rRecorder::getGain()
{
	return gain;
}
//*******************************************************************************
short	rRecorder::DeviceAbfragen()
{
	OSErr err;
	short recordingStatus = 0;						// status of recording session
	short Level=0;							// current meter level
	unsigned long totalSamplesToRecord = 0;			// total number of samples
	unsigned long numberOfSamplesRecorded = 0;		// number of samples recorded
	unsigned long totalMsecsToRecord;
	
	unsigned long  numberOfMsecsRecorded;
	// turn it on
	//UInt32 tempZeit=0;
	short meterStatus = 1;
	err = SPBSetDeviceInfo(sndInputDriverRef, siLevelMeterOnOff,(char *)&meterStatus);
	if (err)
	printf("SPBSetDeviceInfo: er: %d",err);
	//err = SPBGetDeviceInfo(sndInputDriverRef, siLevelMeterOnOff,&meterStatus);
	
	/* get the sound input status	*/
	
	err = SPBGetRecordingStatus(sndInputDriverRef,
								&recordingStatus,
								&Level,
								&totalSamplesToRecord,
								&numberOfSamplesRecorded,
								&totalMsecsToRecord,
								&numberOfMsecsRecorded);
	
	//Laufzeit=GetMovieTime(RecPlayMovie,nil);
	
	
	if (err==noErr)
	{
		//printf("numberOfMsecsRecorded:%dl \n",numberOfMsecsRecorded);
	}
	else
	{
	printf("SPBGetRecordingStatus: er: %d",err);
		Level=-1;
	}
	
	//meterStatus = 0;
	//err = SPBGetDeviceInfo(sndInputDriverRef, siLevelMeterOnOff,&meterStatus);
	//err = SPBGetDeviceInfo(sndInputDriverRef, siLevelMeterOnOff,&meterStatus);
	//printf("numberOfSamplesRecorded:%d\n",numberOfSamplesRecorded);
	return Level;						
}

//*******************************************************************************
OSErr	rRecorder::StartRecord(FSSpec dieAufnahmeFFSpec,bool mitDialog)
{
	OSErr err=noErr;
	if (recordingOK)
		err=SGStop(Grabber);
	AufnahmeFilespec=dieAufnahmeFFSpec;
	if (mitDialog)
	{
		err=EinstellungenDialog();
	}
				
	AliasHandle		Aufnahmealias;
	//SGOutput	theOutput;
	
	if (err)
		return err;
	err = QTNewAlias(&dieAufnahmeFFSpec, &Aufnahmealias, true);
	if (err) 
	{
		printf("err nach QTNewAlias: %d \n",err);
		return err;
	}
	if (Grabber)
	{
		err=::SGSetDataOutput(Grabber, &dieAufnahmeFFSpec, seqGrabToDisk);
		if (err)
		{
			printf("err nach SGSetDataOutput: %d \n",err);
			return err;
		}	
		
		err = ::SGNewOutput(Grabber, (Handle)Aufnahmealias, rAliasType, seqGrabToDisk, &Output);
		if (err) 
		{
			printf("err nach SGNewOutput: %d \n",err);
			return err;
		}
		
		if (Soundkanal)
		{
			err = ::SGSetChannelOutput(Grabber, Soundkanal, Output);
			if (err)
			{			
				printf("err nach SGSetChannelOutput: %d\n",err);
				return err;
			}
			wide	maxOffset;
			maxOffset.lo = 50000 * 1024;
			maxOffset.hi = 0;
			err=::SGSetOutputMaximumOffset(Grabber, Output, &maxOffset);
			if (err) 
			{			
				printf("err nach SGSetOutputMaximumOffsetOutput: %d\n",err);
				return err;
			}
			
			//SGSetChannelUsage(Soundkanal, 0);
			//if (err) return err;
			
			TimeBase GrabberTimeBase = NULL;
			TimeBase soundTimeBase = NULL;
			long channelUsage;
			
			
			err = ::SGGetTimeBase(Grabber, &GrabberTimeBase);
			//printf("Timebase: %d err: %d  \n",GrabberTimeBase,err);
			
			if (err) return err;
			err = GetComponentInfo((Component)GetTimeBaseMasterClock(GrabberTimeBase), &ClockDescriptor, NULL, NULL, NULL);
			if (err) return err;
			if(!err) {
				err = SGGetChannelTimeBase(Soundkanal, &soundTimeBase);
				if (err)
				{			
				printf("err nach SGGetChannelTimeBase: %d\n",err);
				return err;
			}

				//CheckError(err,"SGGetChannelTimeBase ");
			}
			if ((err==noErr) && soundTimeBase)
				SetTimeBaseMasterClock(GrabberTimeBase, (Component)GetTimeBaseMasterClock(soundTimeBase), NULL);
			if (err)
				{			
				printf("err nach SetTimeBaseMasterClock: %d\n",err);
				return err;
			}

			//CheckError(err,"SetTimeBaseMasterClock ");
			
			
			//SGGetChannelUsage(Soundkanal, &channelUsage);
			
			// Startup the grab
			err=SGPause(Grabber, seqGrabUnpause);
			if (err)
			{			
				printf("err nach SGPause(UnPause): %d\n",err);
				return err;
			}
			
			// Make the movie file
			short MovieRef=-1 ;
			DeleteMovieFile(&dieAufnahmeFFSpec);
			err = CreateMovieFile(&dieAufnahmeFFSpec, 'TVOD', smSystemScript,
								  createMovieFileDontOpenFile | createMovieFileDontCreateMovie | createMovieFileDontCreateResFile ,
								  &MovieRef, NULL);
			printf("Nach CreateMovieFile: MovieRef: %d Fehler: %d GetMoviesError: %d\n ",MovieRef ,err,GetMoviesError());
			if (err)
				{			
				printf("err nach CreateMovieFile: %d\n",err);
				return err;
			}
			unsigned long l=0;
			
			//err=SGGetStorageSpaceRemaining(Grabber, &l);
			//err=SGGetTimeRemaining(Grabber,&l);
			//printf("SGGetStorageSpaceRemaining:err: %d  \n",err);

			//printf("SGGetTimeRemaining: %d\n",Abspieldauerfeld/60);
			//if (err)
			{			
				//printf("err nach SGGetTimeRemaining(UnPause): %d\n",err);
				//return err;
			}
			err=SGSetMaximumRecordTime(Grabber, 0);
			printf("err nach SGSetMaximumRecordTime: %d\n",err);
			err = ::SGStartRecord(Grabber);
			printf("err nach SGStartRecord: %d\n",err);
			//err=SGGetTimeRemaining(Grabber,&Abspieldauerfeld);
			//printf("err nach SGGetTimeRemaining: %d\n",err);
			//printf("SGGetTimeRemaining: %d\n",Abspieldauerfeld/60);
			recordingOK=true;


		}//if Soundkanal
	}//Grabber
	
	return err;
}
//*******************************************************************************
//*******************************************************************************
OSErr	rRecorder::FinishRecord()
{
	OSErr err=noErr;
	//if (RecPlayMovie==0)
	  {
		RecPlayMovie=NewMovie(newMovieActive);
	  }
	if (RecPlayMovie && Grabber)
	  {
		RecPlayMovie=SGGetMovie(Grabber);
		err=GetMoviesError();
		if (err)
		  {
			return err;
		  }
		TimeValue l=GetMovieDuration(RecPlayMovie);
		if (l>0)
		  {
			FlattenMovieData(RecPlayMovie,
							 flattenAddMovieToDataFork,
							 &AufnahmeFilespec,'TVOD',
							 smSystemScript,
							 createMovieFileDeleteCurFile|createMovieFileDontCreateResFile);
			err=GetMoviesError();
			//|flattenForceMovieResourceBeforeMovieData,
			
		  }
	  }
	return err;	
}

//*******************************************************************************
OSErr	rRecorder::StopRecord()
{
	OSErr err=noErr;
	if (recordingOK)
	{
		err=SGStop(Grabber);
		recordingOK=false;
		//err=SGStartPreview(Grabber);
		//err=FinishRecord();
	}
	
	return err;
}
//*******************************************************************************
OSErr rRecorder::DeviceSchliessen()
{	

	ComponentResult result=0;
	// Clean up
	if (Grabber != 0L)
	{	
		if (Soundkanal)
			result=SGDisposeChannel(Grabber,Soundkanal);
		result = CloseComponent (Grabber);
		Grabber = 0L;
	}	
	return result;
}

long rRecorder::GetSamplerate()
{
SInt32 rate;
if (Grabber)
{
			int result = SPBGetDeviceInfo(sndInputDriverRef, siSampleRate, (Ptr)&rate);

}
return rate;
}

//*******************************************************************************
Handle rRecorder::GetEinstellungen()
{
	OSErr err=0;
	Handle SettingsHandle;
	UserData GrabberEinstellungen=0;
	//err=EinstellungenDialog();
	//printf("GetEinstellungen; err nach EinstellungenDialog : %d \n",err);
	
	err=NewUserData(&GrabberEinstellungen);
	if (err)
	{
		printf("GetEinstellungen: Alloc von Userdata misslungen\n");
		return NULL;
	}
	//printf("GetEinstellungen: Alloc von Userdata gelungen\n");
	err=SGGetChannelSettings(Grabber, Soundkanal, &GrabberEinstellungen,0);
	if (err)
	{
		printf("GetEinstellungen: SGGetChannelSettings misslungen\n");
		return NULL;
	}
	SettingsHandle=NewHandle(0);
	
	if (MemError())
	{
		printf("GetEinstellungen: NewHandle misslungen\n");
		return NULL;
	}
	//printf("NewHandle gelungen\n");
	//HLock(SettingsHandle);
	err=PutUserDataIntoHandle(GrabberEinstellungen, SettingsHandle);
	if (err)
	{
		printf("GetEinstellungen: PutUserDataIntoHandle misslungen\n");
		return NULL;
	}
	//HUnlock(SettingsHandle);
	printf("Recorder: err aus GetEinstellungen: %d \n",err);
	return SettingsHandle;
}
//*******************************************************************************
//*******************************************************************************
OSErr rRecorder::SetEinstellungen(Handle dieEinstellungenH)
{
	OSErr err=0;
	//Handle SettingsHandle, testHandle=0;
	UserData GrabberEinstellungen=0;
	err=NewUserData(&GrabberEinstellungen);
	if (err)
	{
		printf("Alloc von Userdata misslungen\n");
		return err;
	}
	//printf("Alloc von Userdata gelungen\n");
	HLock(dieEinstellungenH);
	err=NewUserDataFromHandle( dieEinstellungenH,&GrabberEinstellungen);
	if (err)
	{
		printf("NewUserDataFromHandle misslungen\n");
		return err;
	}
	HUnlock(dieEinstellungenH);
	//printf("NewUserDataFromHandle gelungen\n");
	err=SGSetChannelSettings(Grabber,Soundkanal, GrabberEinstellungen,0);
	if (err)
	{
		printf("SGSetSettings misslungen: %d \n",err);
		return err;
	}
	//printf("SGSetSettings gelungen\n");
	return err;
}
//*******************************************************************************
OSErr rRecorder::Einstellungentest()
{
	OSErr err=0;
	UserData GrabberEinstellungen1=0;
	err=NewUserData(&GrabberEinstellungen1);
	UserData GrabberEinstellungen2=0;
	err=NewUserData(&GrabberEinstellungen2);

	
	Handle Recordereinstellungen1;
	Recordereinstellungen1=NewHandle(0);
	Handle Recordereinstellungen2;
	Recordereinstellungen2=NewHandle(0);

	err=SGGetSettings(Grabber, &GrabberEinstellungen1, 0);
	printf("GetSettings 1:,%d\n",err);
	err=EinstellungenDialog();
	//printf("EinstellungenDialog 1:,%d\n",err);
	//err=SGGetSettings(Grabber, &GrabberEinstellungen2, 0);
	//printf("GetSettings 2:,%d\n",err);
	//err=EinstellungenDialog();
	//printf("EinstellungenDialog 2:,%d\n",err);
	err=SGSetSettings(Grabber, GrabberEinstellungen1, 0);
	printf("SetSettings nach Dialog:,%d\n",err);
	//err=EinstellungenDialog();
	//printf("EinstellungenDialog 1:,%d\n",err);
	//err=SGSetSettings(Grabber, GrabberEinstellungen2, 0);
	//printf("GetSettings 2:,%d\n",err);
	//err=EinstellungenDialog();
	//printf("EinstellungenDialog 1:,%d\n",err);
	return err;
	
};
//*******************************************************************************
OSErr rRecorder::StartPlay()
{
	OSErr err=noErr;
	if (RecPlayMovie==0)
	{
		RecPlayMovie=NewMovie(newMovieActive);
	}
	if (RecPlayMovie && Grabber)
	{
		//err=SGPrepare(Grabber,1,1);
		if (Durchlauf==0)
		RecPlayMovie=SGGetMovie(Grabber);
		TimeValue l=GetMovieDuration(RecPlayMovie);
		
		//short v=GetMovieVolume(Mov);
		if (l>0)
		{
			StartMovie(RecPlayMovie);
			playingOK=true;
			Durchlauf++;
		}
	}
	//von CircleView
	// We schedule a timer with a 0 time interval so that it will be called
    // as often as possible.  In performAnimation: we determine exactly
    // how much time has elapsed and animate accordingly.
//    timer = [[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(performAnimation:) userInfo:nil repeats:YES] retain];
	
	return err;
};

//*******************************************************************************
OSErr rRecorder::StopPlay()
{
	OSErr err=noErr;
	
	if (RecPlayMovie&&Grabber)
	{
		StopMovie(RecPlayMovie);
		playingOK=false;
	}
	return err;
};


//*******************************************************************************
bool rRecorder::PlayingTask()
{
	bool fertig =true;
	if (RecPlayMovie)
	{
		fertig=IsMovieDone(RecPlayMovie);
		if (!fertig)
		{
			MoviesTask(RecPlayMovie,5000);
		}
	}
	return fertig;
}
//*******************************************************************************

//*******************************************************************************
OSErr	rRecorder::EinstellungenDialog()
{
	OSErr err=noErr;
	SGModalFilterUPP	seqGragModalFilterUPP;
	short v=0;
	UserData GrabberEinstellungen=0;
	if (GrabberOK)
	{
		
		//err = ::SGGetChannelVolume (Soundkanal, &v);				
		
		//long sndInputDriverRef = SGGetSoundInputDriver(Soundkanal);
		//short chan =0;
		//err = SPBGetDeviceInfo(sndInputDriverRef,siNumberChannels,(Ptr)&chan);
		
		if (recordingOK)
		{
			::SGStop(Grabber);
			recordingOK=false;
			if (Soundkanal)
				::SGSetChannelUsage(Soundkanal, 0);
		}
		seqGragModalFilterUPP = (SGModalFilterUPP)::NewSGModalFilterUPP(SeqGrabberModalFilterProc);
		int gg=0;
		gg=getGain();
		//printf("Gain vor Einstellungendialog: %d \n",gg);
		if (seqGragModalFilterUPP)
		{
			if (GrabberEinstellungen)
			{
				//err=::SGSetChannelSettings(Grabber, Soundkanal, GrabberEinstellungen, 0);
			}
			err = ::SGSettingsDialog (Grabber, Soundkanal, 0,
									  NULL, 0L, seqGragModalFilterUPP, 0);
			//printf("err nach SGSettingsDialog: %d \n",err);
			::DisposeSGModalFilterUPP(seqGragModalFilterUPP);
			if (err==noErr)
			{
				if (GrabberEinstellungen)
				{
					//DisposeUserData(GrabberEinstellungen);
					//err=NewUserData(&GrabberEinstellungen);
					if (err)
					{
						printf("GetEinstellungen: Alloc von Userdata misslungen\n");
						return -1;
					}
					
					//err = SGGetChannelSettings(Grabber, Soundkanal, &GrabberEinstellungen, 0);
				}
			}
		}
		else
		{
			printf("Mit seqGragModalFilterUPP ist etwas schiefgegangen\n");
		}
		gg=getGain();
		//printf("Gain nach Einstellungendialog: %d \n",gg);
	}
	//err = ::SGGetChannelVolume (Soundkanal, &v);			
	return err;
	
}
//*******************************************************************************
//*******************************************************************************
OSErr rRecorder::Idlefunktion()
{
	OSErr err=0;
	if (Grabber)
	{	
		Level=DeviceAbfragen();

		if(recordingOK)
		{
		err=SGIdle(Grabber);
		
		}
		
	}
	return err;
}
//*******************************************************************************
//*******************************************************************************
//*******************************************************************************
//*******************************************************************************
//*******************************************************************************
// ********************************************************* 


/* ---------------------------------------------------------------------- */

static pascal Boolean
SeqGrabberModalFilterProc (DialogPtr theDialog, const EventRecord *theEvent,
						   short *itemHit, long refCon)
{
	// Ordinarily, if we had multiple windows we cared about, we'd handle
	// updating them in here, but since we don't, we'll just clear out
	// any update events meant for us
	
	Boolean	handled = false;
	
	return (handled);
}

/* ---------------------------------------------------------------------- */


// SGNewChannel coding example
// See "Discovering QuickTime," page 263
void MakeMyGrabChannels (SeqGrabComponent    seqGrab, 
						 SGChannel        *sgchanVideo, 
						 SGChannel        *sgchanSound,
						 const Rect       *rect, 
						 Boolean          bWillRecord)
{
	OSErr           nErr;
	long            lUsage;
	// figure out the usage
	lUsage = seqGrabPreview;                // always previewing
	if (bWillRecord)
		lUsage |= seqGrabRecord;            // sometimes recording
											// create a video channel
											// create a sound channel
	nErr = SGNewChannel(seqGrab, SoundMediaType, sgchanSound);
	if (nErr == noErr) {
		// set usage of new sound channel
		nErr = SGSetChannelUsage(*sgchanSound, lUsage);
		if (nErr != noErr) {
			// clean up on failure
			SGDisposeChannel(seqGrab, *sgchanSound);
			*sgchanSound = nil;
		}
	}
}



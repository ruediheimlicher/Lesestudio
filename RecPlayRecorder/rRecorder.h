/*
 *  rRecorder.h
 *  RecPlayC
 *
 *  Created by Ruedi Heimlicher on Fri Aug 06 2004.
 *  Copyright (c) 2004 __Ruedi Heimlicher__. All rights reserved.
 *
 */


#ifndef __rRecorder_h__
#define __rRecorder_h__
#include "Quicktime/Quicktime.h"
#include <Carbon/Carbon.h>

				



class rRecorder
{
public:
	rRecorder();
	~rRecorder();
	//OSErr			setRecorder(bool neu);
	OSErr			setGrabber();
	short			getGrabberStatus();

	OSErr			terminate();
	void			setParameter(SInt32	dieFileRefNum,SInt32 dieVolRefNum,SInt32 dieParentDirID);
	OSErr			EinstellungenDialog();
	short			DeviceAbfragen();	
	OSErr 			StartRecord(FSSpec dieAufnahme,bool mitDialog);				
	OSErr 			StopRecord();
	OSErr 			StartPlay();
	OSErr			StopPlay();
	bool 			PlayingTask();
	OSErr			Idlefunktion();
	OSErr 			DeviceSchliessen();
	Handle			GetEinstellungen();
	long			GetSamplerate();
	OSErr			SetEinstellungen(Handle dieEinstellungenH);
	OSErr			Einstellungentest();
	void			Zeitformatieren(long dieSekunden,Str255 * dieZeit);
	SInt32			getGain();
	OSErr			FinishRecord();	
	
	FSSpec  		AufnahmeFilespec;
	SInt32			volRefNum;
	SInt32			ParentDirID;
	StringPtr		nameString;	
	bool			GrabberOK;
	Component		SGComponentID;
	SGOutput		Output;
	UInt32			sndInputDriverRef;
	int				Level;
	ComponentDescription 	GrabberDescriptor;
	ComponentDescription 	ClockDescriptor;
	SeqGrabComponent		Grabber;
	//UserData				GrabberEinstellungen;
	SGChannel				Soundkanal;
	bool					recordingOK;
	Movie 					RecPlayMovie;
	bool 					playingOK;
	UInt32					Startzeit;
	long					Abspieldauerfeld;
	Handle					EinstellungenH;
	int						Durchlauf;
	int						gain;
	TimeValue				Laufzeit;
}	
;
#endif

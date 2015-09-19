//
//  ViewController+AVRecorder.m
//  Lesestudio
//
//  Created by Ruedi Heimlicher on 19.08.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#import "ViewController+AVRecorder.h"

@implementation ViewController (AVRecorder)

- (void)AufnahmeTimerFunktion:(NSTimer*)derTimer
{
  // NSLog(@"AufnahmeTimerFunktion");
   if (aufnahmetimerstatus)
   {
      AufnahmeZeit++;
      
      int Minuten = AufnahmeZeit/60;
      int Sekunden =AufnahmeZeit%60;
      
      NSString* MinutenString;
      
      NSString* SekundenString;
      if (Sekunden<10)
      {
         SekundenString=[NSString stringWithFormat:@"0%d",Sekunden];
      }
      else
      {
         SekundenString=[NSString stringWithFormat:@"%d",Sekunden];
      }
      if (Minuten<10)
      {
         MinutenString=[NSString stringWithFormat:@"0%d",Minuten];
      }
      else
      {
         MinutenString=[NSString stringWithFormat:@"%d",Minuten];
      }
 //     [self.Zeitfeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   }
   
}

- (IBAction)trim:(id)sender
{
   [AVRecorder trim];
}

- (IBAction)cut:(id)sender
{
   [AVRecorder cut];
}

- (IBAction)startAVRecord:(id)sender
{
   if ([AVRecorder isRecording])
   {
      NSLog(@"ViewController Aufnahme in Gang");
      return;
   }
   if ([self.ArchivnamenPop indexOfSelectedItem]==0)
   {
      [self.StartStopString setStringValue:@"START"];
      NSAlert *NamenWarnung = [[NSAlert alloc] init];
      [NamenWarnung addButtonWithTitle:@"Mache ich"];
      //[RecorderWarnung addButtonWithTitle:@"Cancel"];
      [NamenWarnung setMessageText:@"Wer bist du?"];
      [NamenWarnung setInformativeText:@"Du musst einen Namen auswählen, bevor du aufnehmen kannst."];
      [NamenWarnung setAlertStyle:NSWarningAlertStyle];
      
      [NamenWarnung runModal];
      
      [self.StartStopKnopf setState:0];
      
      return;
   }
  [self.view  becomeFirstResponder];
   NSImage* StopRecordImg=[NSImage imageNamed:@"stopicon_w.gif"];
   //self.StartStopKnopf.image=StopRecordImg;

   //NSLog(@"recording Datum %@",heuteDatumString);
   NSDate *now = [[NSDate alloc] init];
   startzeit = (int)now.timeIntervalSince1970;
   //NSLog(@"setRecording startzeit: %ld",startzeit);
   if ([AufnahmeTimer isValid])
   {
      
   }
   else
   {
      AufnahmeTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(AufnahmeTimerFunktion:)
                                                   userInfo:nil
                                                    repeats:YES];
   }
   aufnahmetimerstatus=0;
   
   
   if ([self.playBalkenTimer isValid])
   {
      [self.playBalkenTimer invalidate];
   }
   
   //[playBalkenTimer invalidate];
   self.istNeueAufnahme=1;
   OSErr err=0;
   
  
   if (!(AVRecorder))
   {
      AVRecorder = [[rAVRecorder alloc]init];
   }
   
   [self.Zeitfeld setStringValue:@"00:00"];
   
   [self.Abspieldauerfeld setStringValue:@"00:00"];
   [Abspielanzeige setLevel:0];
   [Abspielanzeige setNeedsDisplay:YES];
   
   self.Pause=0;
   
   //int erfolg=[[self RecPlayFenster]makeFirstResponder:[self RecPlayFenster]];
   
   
   [[self.TitelPop cell] addItemWithObjectValue:[[[self.TitelPop cell]stringValue]stringByDeletingPathExtension]];
   [[self.TitelPop cell] setEnabled:NO];
   self. Aufnahmedauer=0;
   
   
   self.Leser=[self.ArchivnamenPop titleOfSelectedItem];
   long n=[self.ArchivnamenPop indexOfSelectedItem];
   //NSLog(@"Selected Item: %ld",n);
   //NSLog(@"startRecord:Selected Item: %ld		Leser: %@",n,self.Leser);
   
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   BOOL sauberOK=0;
   //NSLog(@"startAVRecord neueAufnahmePfad: %@",neueAufnahmePfad);
   NSError* startErr;
   //[self.StartPlayQTKitKnopf setEnabled:NO];
   //NSImage* StopRecordImg=[NSImage imageNamed:@"stopicon.gif"];
   //self.StartStopKnopf.image = StopRecordImg;
   [self.StartStopString setStringValue:@"STOP"];

   
  // [self.StopPlayQTKitKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];

   [self.BackKnopf setEnabled:NO];
   
   if (AVRecorder)
   {
      // AVRecorder.RecorderFenster = [self.view window];
      [AVRecorder setRecording:YES mitLeserPfad:self.LeserPfad];
      // if AVRecorder
      AufnahmeZeit=0;
      [AVRecorder setstartzeit:startzeit];
      [Utils stopTimeout];
   }

   
}



- (IBAction)stopAVRecord:(id)sender
{
   NSLog(@"stopAVRecord");

  [AVRecorder setRecording:NO mitLeserPfad:self.LeserPfad];
   

//   [self.TitelPop selectItemAtIndex:0];
 //  [self.TitelPop setEnabled:YES];
//   [self.TitelPop setEditable:TitelEditOK];//Nur wenn Titel editierbar
//   [self.TitelPop setSelectable:TitelEditOK];
//   [self.TitelPop   becomeFirstResponder];

   /*
   [self.StartPlayQTKitKnopf setEnabled:YES];
   [self.TitelPop  setEnabled:YES];
   [self.TitelPop  setSelectable:YES];
   [[self.TitelPop cell] setEnabled:YES];
   [[self.TitelPop cell] setEnabled:YES];
   
   //[self MovieFertigmachen];
   
   [self.StartPlayKnopf setEnabled:YES];
   [self.SichernKnopf setEnabled:YES];
   [self.WeitereAufnahmeKnopf setEnabled:YES];
   */
   //[RecordQTKitPlayer setMovie:[mCaptureMovieFileOutput movie]];
   
   
}

- (BOOL)isRecording
{
   return [AVRecorder isRecording];//([mCaptureMovieFileOutput outputFileURL] != nil);
}

#pragma mark startAVStop
- (IBAction)startAVStop:(id)sender
{
   
   NSLog(@"startAVStop state: %d",[sender state]);
   NSImage* StartRecordImg=[NSImage imageNamed:@"recordicon_k.gif"];//
   
   
   if ([AVRecorder isRecording])
	  {
        NSImage* StartRecordImg=[NSImage imageNamed:@"recordicon_k.gif"];     //
       // [[self.StartStopKnopf cell]setImage:StartRecordImg];
        //self.StartStopKnopf.image=StartRecordImg;
        [self.StartStopString setStringValue:@"START"];
        [self stopAVRecord:sender];
        //[AVRecorder setRecording:NO];
        
     }
	  
	  else
     {
        // Namen checken
        [self startAVRecord:sender];
        
        // Aufnahme starten
       // NSImage* StopRecordImg=[NSImage imageNamed:@"StopRecordImg.tif"];
       // self.StartStopKnopf.image = StopRecordImg;
       // [self.StartStopString setStringValue:@"STOP"];
       //[AVRecorder setRecording:YES];
        
     }
   
}

- (void)updateAudioLevels:(float)level
{
   // Get the mean audio level from the movie file output's audio connections
   
   
   //NSLog(@"Level: %2.2f",level);


   if (level > 0)
   {
      [self.audioLevelMeter setFloatValue:level];
   }
   else
   {
      [self.audioLevelMeter setFloatValue:0];
   }
   
   float l=0;
   
   
   
   
}

- (IBAction)stop:(id)sender
{
   NSLog(@"startAVPlay");
   [AVRecorder stop:nil];
   [Utils startTimeout:self.TimeoutDelay];
}


- (IBAction)startAVPlay:(id)sender
{
  
   NSLog(@"startAVPlay hiddenaufnahmepfad: %@",self.hiddenAufnahmePfad);
   if ([[NSFileManager defaultManager]fileExistsAtPath:self.hiddenAufnahmePfad ])
   {
      NSLog(@"startAVPlay Aufnahmeda");
   }
  // [AVRecorder setPlaying:YES];
   [self.StartRecordKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self.StopRecordKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:YES];
   [self.StopPlayKnopf setEnabled:YES];
   [self.RewindKnopf setEnabled:YES];
   [self.ForewardKnopf setEnabled:YES];

   [self.Abspieldauerfeld setStringValue:@"00:00"];
  
   [AVAbspielplayer playAufnahme];
   float dur = ([AVAbspielplayer duration]);
   [Abspielanzeige setMax:dur];
   NSLog(@"startAVPlay dur: %f",dur);
   [Abspielanzeige setNeedsDisplay:YES];
   [self.ArchivAbspielanzeige setMax:dur];
   
//   [self.Fortschritt setDoubleValue:0];
   //[Utils startTimeout:self.TimeoutDelay];
}

- (IBAction)stopAVPlay:(id)sender
{
   NSLog(@"stopAVPlay");
   [AVAbspielplayer stopTempAufnahme];
   [self.StartRecordKnopf setEnabled:YES];
   [self.SichernKnopf setEnabled:YES];
   [self.WeitereAufnahmeKnopf setEnabled:YES];
   [self.StopRecordKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:YES];
  // [self.StopPlayKnopf setEnabled:NO];

   [Utils startTimeout:self.TimeoutDelay];
}

- (IBAction)backAVPlay:(id)sender
{
   NSLog(@"backAVPlay");
   [AVAbspielplayer toStartTempAufnahme];
   [self.SichernKnopf setEnabled:YES];
   [self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:YES];
   
   [Utils stopTimeout];
}

- (IBAction)rewindAVPlay:(id)sender
{
   NSLog(@"backAVPlay");
   [AVAbspielplayer rewindTempAufnahme];
   //[self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:YES];
   [Utils stopTimeout];
}

- (IBAction)forewardAVPlay:(id)sender
{
   NSLog(@"backAVPlay");
   [AVAbspielplayer forewardTempAufnahme];
   //[self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:YES];
   [Utils stopTimeout];
}



- (void)RecordingAktion:(NSNotification*)note
{
   //NSLog(@"RecordingAktion note: %@",[note description]);
   if ([[note userInfo ]objectForKey:@"record"])
   {
      switch([[[note userInfo ] objectForKey:@"record"]intValue])
      {
         case 0:
         {
            NSLog(@"RecordingAktion Aufnahme stop");
            aufnahmetimerstatus=0;
            
            // erfolg checken
            if ([[[note userInfo ] objectForKey:@"recorderfolg"]intValue])
            {
               [Utils startTimeout:self.TimeoutDelay];
               // Tastenstatus setzen
               [self.TitelPop  setEnabled:YES];
               [self.TitelPop  setSelectable:YES];
               [[self.TitelPop cell] setEnabled:YES];
               [[self.TitelPop cell] setEnabled:YES];
               
               [self.StartPlayKnopf setEnabled:YES];
               [self.SichernKnopf setEnabled:YES];
               //[self.ForewardKnopf setEnabled:YES];
               //[self.RewindKnopf setEnabled:YES];
               [self.WeitereAufnahmeKnopf setEnabled:YES];
               
               // Player vorbereiten
               if ([[note userInfo ] objectForKey:@"desturl"] && [[[[note userInfo ] objectForKey:@"desturl"]path]length])
               {
                  NSLog(@"RecordingAktion desturl: %@",[[note userInfo ]objectForKey:@"desturl"]);
                  NSURL* destURL = [[note userInfo ] objectForKey:@"desturl"];
                  self.hiddenAufnahmePfad = [destURL path];
                  [AVAbspielplayer prepareAufnahmeAnURL:destURL];
                  //NSLog(@"RecordingAktion nach prepare");
               }
               
               if ([[note userInfo ] objectForKey:@"aufnahmezeit"] )
               {
                  self.Aufnahmedauer = [[[note userInfo ] objectForKey:@"aufnahmezeit"]intValue];
                  //NSLog(@"RecordingAktion self.Aufnahmedauer: %d",self.Aufnahmedauer);
               }
               
               
            } // if recorderfolg
            else
            {
               // record fehler
               //self.StartStopKnopf.image=StartRecordImg;
               
               [self.SichernKnopf setEnabled:YES];
               
               [self.BackKnopf setEnabled:NO];
               [self.Zeitfeld setStringValue:@"00:00"];
               
               [self.Abspieldauerfeld setStringValue:@"00:00"];
               [self->Abspielanzeige setLevel:0];
               [self->Abspielanzeige setNeedsDisplay:YES];
               
               [Utils startTimeout:self.TimeoutDelay];
               
               NSAlert *Warnung = [[NSAlert alloc] init];
               [Warnung addButtonWithTitle:@"OK"];
               // [Warnung setMessageText:NSLocalizedString(@"No Marked Records",@"Keine markierten Aufnahmen")];
               [Warnung setMessageText:@"Fehler beim Sichern der Aufnahme"];
               
               [Warnung setAlertStyle:NSWarningAlertStyle];
               
               //[Warnung setIcon:RPImage];
               int antwort=[Warnung runModal];
               
               NSLog(@"Fehler beim Sichern der Aufnahmen");
               
               
               
               
            }
         }break;
            
         case 1:
         {
            NSLog(@"RecordingAktion Aufnahme gestartet");
            aufnahmetimerstatus=1;
            AufnahmeZeit = 0;
            [Utils stopTimeout];
         }break;
      }// switch
   }
   
}

- (void)LevelmeterAktion:(NSNotification*)note
{
   //NSLog(@"LevelmeterAktion");
   
   if ([[note userInfo]objectForKey:@"level"])
   {
      NSNumber* LevelNumber=[[note userInfo]objectForKey:@"level"];
      float Level=[LevelNumber floatValue];
      //NSLog(@"Level: %2.2f",Level);
      // [self.Levelmeter setLevel:4*Level];
      [self updateAudioLevels:Level];
      
   }
   if ([[note userInfo]objectForKey:@"duration"] && [self isRecording])
   {
      NSNumber* durationNumber=[[note userInfo]objectForKey:@"duration"];
      AufnahmeZeit=[durationNumber intValue];
      //NSLog(@"duration: %2.2d",AufnahmeZeit);
      int Minuten = AufnahmeZeit/60;
      int Sekunden =AufnahmeZeit%60;
      
      NSString* MinutenString;
      
      NSString* SekundenString;
      if (Sekunden<10)
      {
         SekundenString=[NSString stringWithFormat:@"0%d",Sekunden];
      }
      else
      {
         SekundenString=[NSString stringWithFormat:@"%d",Sekunden];
      }
      if (Minuten<10)
      {
         MinutenString=[NSString stringWithFormat:@"0%d",Minuten];
      }
      else
      {
         MinutenString=[NSString stringWithFormat:@"%d",Minuten];
      }
      
      [self.Zeitfeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];

      
   }
//   self.TimeoutFeld.intValue = sel
}

- (void)AbspielPosAktion:(NSNotification*)note
{
   
   double pos;
   double dur;
   int posint;
   if ([[note userInfo]objectForKey:@"pos"])
   {
      NSNumber* posNumber=[[note userInfo]objectForKey:@"pos"];
      pos=[posNumber doubleValue];
      posint =[posNumber intValue];
      
   }
   if ([[note userInfo]objectForKey:@"dur"])
   {
      NSNumber* durNumber=[[note userInfo]objectForKey:@"dur"];
      dur=[durNumber doubleValue];
   }
//   NSLog(@"dur: %2.2f pos: %2.2f",dur,pos);
   if (dur - pos < 0.1)
   {
      NSLog(@"Ende erreicht");
      [self.SichernKnopf setEnabled:YES];
      //[AVAbspielplayer resetTimer];
   }
   NSNumber* durationNumber=[[note userInfo]objectForKey:@"duration"];
   
   WiedergabeZeit=[durationNumber intValue];
   //NSLog(@"duration: %2.2d",AufnahmeZeit);
   int Minuten = posint/60;
   int Sekunden =posint%60;
   //NSLog(@"Minuten: %d Sekunden: %d",Minuten,Sekunden);
   NSString* MinutenString;
   
   NSString* SekundenString;
   if (Sekunden<10)
   {
      SekundenString=[NSString stringWithFormat:@"0%d",Sekunden];
   }
   else
   {
      SekundenString=[NSString stringWithFormat:@"%d",Sekunden];
   }
   if (Minuten<10)
   {
      MinutenString=[NSString stringWithFormat:@"0%d",Minuten];
   }
   else
   {
      MinutenString=[NSString stringWithFormat:@"%d",Minuten];
   }
   [self.Abspieldauerfeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   
   [self.ArchivAbspieldauerFeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   
   
   
   //   int max =[self.Fortschritt maxValue];
   //NSLog(@"AbspielPosAktion pos: %f dur: %f wert: %f",pos,dur,pos/dur*1024 );
   //  [self.Abspielanzeige setMax:dur];
   [Abspielanzeige setLevel:pos];
   [Abspielanzeige display];
   [self.ArchivAbspielanzeige setMax:dur];
   [self.ArchivAbspielanzeige setLevel:pos];
   [self.ArchivAbspielanzeige display];
   
   
   
   
   //   [self.Fortschritt setDoubleValue:(pos+1)/dur*max];
}

- (IBAction)saveRecord:(id)sender
{
   [AVAbspielplayer invalTimer];
   [Utils stopTimeout];
   BOOL erfolg=YES;
   NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
//   [mainMenu setDelegate:self];
   NSMenu *appMenu = [[mainMenu itemWithTitle:@"Modus"] submenu];
  //[appMenu setAutoenablesItems:NO];
//   NSLog(@"saveRecord MenuItem: Modus: %@",[[appMenu itemWithTitle:@"Admin"]title]);
//   [appMenu setDelegate:self];
   
   for (NSMenuItem *item in [appMenu itemArray])
   {
//      [item setEnabled:YES];
   }
  

   NSLog(@"saveRecord tag: %ld Leser: %@ ",(long)[sender tag],self.Leser);
   
   NSLog(@"anzProjekte vor: %d",[[self.ProjektArray valueForKey:@"projekt"]count]);

   //NSLog(@"saveRecord hiddenAufnahmePfad: %@",self.hiddenAufnahmePfad);
   if ([self.Leser length]==0)
   {
      long Antwort=NSRunAlertPanel(@"Wer hat gelesen?", @"Vor dem Sichern muss ein Name ausgewählt sein",@"OK", NULL,NULL);
      
      return;
   }
   
   if ((self.Aufnahmedauer==0)&&([self.Leser length]==0))
   {
      NSLog(@"Save ohne Aufnahme");
      NSAlert *Warnung = [[NSAlert alloc] init];
      [Warnung addButtonWithTitle:@"OK"];
      //[Warnung addButtonWithTitle:@"Cancel"];
      [Warnung setMessageText:@"Keine Aufnahme"];
      [Warnung setInformativeText:@"Keine Aufnahme oder schon gesichert"];
      [Warnung setAlertStyle:NSWarningAlertStyle];
      [Warnung runModal];
      
      [self.ArchivnamenPop selectItemAtIndex:0];
      [self.Leserfeld setStringValue:@""];
      [self resetRecPlay];
      [Utils stopTimeout];
      return;
   }
   
   [self.Abspieldauerfeld setStringValue:@""];
   [self.Zeitfeld setStringValue:@""];
   [Abspielanzeige setLevel:0];
   [Abspielanzeige setNeedsDisplay:YES];
   
   //NSLog(@"saveRecord: QTKitGesamtAufnahmezeit: %2.2f",QTKitGesamtAufnahmezeit);
   NSString* tempAufnahmePfad;
   //tempLeserPfad=[NSString stringWithString:@""];
   NSFileManager *Manager = [NSFileManager defaultManager];
   if (self.Aufnahmedauer)
   {
      NSString* Leserinitialen=[self Initialen:self.Leser];
      Leserinitialen=[Leserinitialen stringByAppendingString:@" "];
      if ([Manager fileExistsAtPath: self.hiddenAufnahmePfad])		//neueAufnahme ist vorhanden
      {
         NSMutableArray * tempAufnahmeArray=[[Manager contentsOfDirectoryAtPath:self.LeserPfad error:NULL]mutableCopy];
         long AnzAufnahmen=[tempAufnahmeArray count];
         if (AnzAufnahmen&&[[tempAufnahmeArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
         {
            [tempAufnahmeArray removeObjectAtIndex:0];
            AnzAufnahmen--;
         }
         
         //NSString* Aufnahmenliste=[tempAufnahmeArray description];
         //NSLog(@"tempAufnahmeListe: %@", Aufnahmenliste);
         NSMutableString* tempNummerString=[NSMutableString stringWithCapacity:0];
         NSNumber* tempNummer;
         int maxNummer=0;
         int i;
         if (AnzAufnahmen)
         {
            
            for (i=0;i<AnzAufnahmen;i++)
            {
               int posLeerstelle1=0;
               int posLeerstelle2=0;
               int Leerstellen=0;
               NSString* loopNummerString=[NSString stringWithString:[tempAufnahmeArray objectAtIndex:i]];
               //int n=0;
               int charpos=0;
               while ((Leerstellen<2)&&(charpos<[loopNummerString length]))
               {
                  if ([loopNummerString characterAtIndex:charpos]==' ')
                  {
                     
                     Leerstellen++;
                     if (Leerstellen==1)
                     {
                        posLeerstelle1=charpos;
                     }
                     if (Leerstellen==2)
                     {
                        posLeerstelle2=charpos;
                     }
                     
                     
                  }
                  charpos++;
               }//while pos
               if (posLeerstelle1 && posLeerstelle2)
               {
                  //NSLog(@"loopNummerString: %@   pos Leerstelle1:%d pos Leerstelle2:%d",loopNummerString,posLeerstelle1,posLeerstelle2);
                  NSRange tempRange=NSMakeRange(posLeerstelle1+1,(posLeerstelle2-posLeerstelle1));
                  tempNummerString=(NSMutableString*)[loopNummerString substringWithRange:tempRange];
                  //NSLog(@"loopNummerString: %@   pos Leerstelle1:%d pos Leerstelle2:%d",loopNummerString,posLeerstelle1,posLeerstelle2);
                  
                  int loopNummer=[tempNummerString intValue];
                  if (loopNummer>maxNummer)
                     maxNummer=loopNummer;
               }
               //NSLog(@"neue maxNummer: %d",maxNummer);
               //[loopNummerString release];
            }
         }
         maxNummer++;
         tempNummer=[NSNumber numberWithInt:maxNummer];
         if ( maxNummer<10)
         {
            tempNummerString=@"";
            tempNummerString=(NSMutableString*)[tempNummerString stringByAppendingString:[tempNummer stringValue]];
         }
         else
         {
            tempNummerString=[NSString stringWithString:[tempNummer stringValue]];
         }
         
         Leserinitialen=[Leserinitialen stringByAppendingString:tempNummerString];
         Leserinitialen=[Leserinitialen stringByAppendingString:@" "];
         NSString* titel =  [[[self.TitelPop cell]stringValue]stringByDeletingPathExtension];
         
         
         if (([titel length]==0)||([titel isEqualToString:@"neue Aufnahme"]))
         {
            NSString* s1=@"Titel für Aufnahme";
            NSString* s2=@"Noch kein passender Titel";
            NSString* s3=@"Titel eingeben";
            NSString* s4=@"Weiter";
            
            int Antwort=NSRunAlertPanel(s1, s2, s3, s4,NULL);
            if (Antwort==1)
            {
               [self.TitelPop setEnabled:YES];
             //  [self.TitelPop selectItemWithObjectValue:[[self.TitelPop cell]stringValue]];
               
               return;
            }
         }
         
         
         NSString* AufnahmeTitel=[Leserinitialen stringByAppendingString:titel];
         if ([tempAufnahmeArray containsObject:AufnahmeTitel])
         {
            NSLog(@"Die Nummer ist schon vorhanden: %d",AnzAufnahmen+1);
            return;
         }
         
         
         tempAufnahmePfad=[self.LeserPfad stringByAppendingPathComponent:[AufnahmeTitel stringByDeletingPathExtension]];//Pfad im Ordner in der Lesebox
         
         NSLog(@"saveRecord tempAufnahmePfad : %@", tempAufnahmePfad);
         //[Manager movePath: neueAufnahmePfad toPath:tempAufnahmePfad handler:NULL];
         
         // Kommentar einfuegen
         OSErr err=0;
         BOOL createKommentarOK=[Utils createKommentarFuerLeser:self.Leser FuerAufnahmePfad:[tempAufnahmePfad stringByAppendingPathExtension:@"txt"]];
         if (createKommentarOK)
         {
            // suffix anfuegen fuer Aufnahme
            NSRange extensionpos = [tempAufnahmePfad rangeOfString:@"m4a"];
            if (extensionpos.location == NSNotFound)// noch keine extension
            {
               tempAufnahmePfad = [tempAufnahmePfad stringByAppendingPathExtension:@"m4a"];
            }
            
            NSError *error = nil;
            if ([[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:self.hiddenAufnahmePfad] toURL:[NSURL fileURLWithPath:tempAufnahmePfad] error:&error]) // move OK
            {
               [self updateProjektArray];
              // [self.ArchivDaten resetArchivDaten];
               [self.ArchivDaten insertAufnahmePfad:[AufnahmeTitel stringByDeletingPathExtension] forRow:0];
               
               [self.ArchivView reloadData];
               self.ArchivZeilenhit=NO;
               
               NSError* err;
 
               NSMutableArray* tempArray =(NSMutableArray*)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.LeserPfad error:&err];
               NSLog(@"tempArray: %@",[tempArray description]);
               
               if ([[tempArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
               {
                  [tempArray removeObjectAtIndex:0];
               }
               [tempArray removeObject:@"Anmerkungen"];
               double anz = [tempArray count];
               
               
               self.aktuellAnzAufnahmen = anz;
               NSLog(@"move 1 anz: %f tempAufnahmePfad: %@",anz, tempAufnahmePfad);
               
               // Platz machen
               [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.hiddenAufnahmePfad] error:nil];
               
               // Movie abspielen
               //   [[NSWorkspace sharedWorkspace] openURL:[savePanel URL]];
            }
            else // Fehler mit move
            {
               NSAlert *Warnung = [[NSAlert alloc] init];
               [Warnung addButtonWithTitle:@"OK"];
               // [Warnung setMessageText:NSLocalizedString(@"No Marked Records",@"Keine markierten Aufnahmen")];
               [Warnung setMessageText:@"Fehler beim Sichern der Aufnahmen"];
               
               [Warnung setAlertStyle:NSWarningAlertStyle];
               
               //[Warnung setIcon:RPImage];
               double antwort=[Warnung runModal];
               
               NSLog(@"Fehler beim Sichern der Aufnahmen");
               [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.hiddenAufnahmePfad] error:nil];
            }
            
            //NSLog(@"err nach move: %d",err);
            if (err)
            {
               //NSLog(@"err nach move: %d",err);
               NSAlert *Warnung = [[NSAlert alloc] init];
               [Warnung addButtonWithTitle:@"OK"];
               //[Warnung addButtonWithTitle:@"Cancel"];
               [Warnung setMessageText:@"Fehler beim Sichern:"];
               [Warnung setInformativeText:@"Die Aufnahme konte nicht gesichert werden"];
               [Warnung setAlertStyle:NSWarningAlertStyle];
               [Warnung runModal];
                [self resetRecPlay];
               return;
               
            }
         } // if saveKommentarOK
         //SessionLeserArray aktualisieren
         
         //NSCalendarDate* creatingDatum=[NSCalendarDate calendarDate];
         //NSLog(@"Projekt: %@ creatingDatum: %@",[ProjektPfad lastPathComponent],creatingDatum);
         
         NSString* tempLeser=[self.ArchivnamenPop titleOfSelectedItem];
         //NSLog(@"saveRecord Projekt: %@ tempLeser: %@",[ProjektPfad lastPathComponent],tempLeser);
         
         
         //Leser zur Sessionliste zufügen
         NSLog(@"anzProjekte nach: %lu",(unsigned long)[[self.ProjektArray valueForKey:@"projekt"]count]);
         
         double ProjektIndex=[[self.ProjektArray valueForKey:@"projekt"] indexOfObject:[self.ProjektPfad lastPathComponent]];
         //NSLog(@"ProjektIndex: %d",ProjektIndex);
         if (ProjektIndex<NSNotFound)
         {
            //NSLog(@"Projekt da: ");
            NSMutableDictionary* tempProjektDic=(NSMutableDictionary*)[self.ProjektArray objectAtIndex:ProjektIndex];
            
            NSMutableArray* SessionLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
            
            if ([tempProjektDic objectForKey:@"sessionleserarray"])//Array ist vorhanden
            {
               //NSLog(@"SessionLeserArray da: ");
               [SessionLeserArray addObjectsFromArray:[tempProjektDic objectForKey:@"sessionleserarray"]];
               
               //NSLog(@"SessionLeserArray da2");
            }
            if (![SessionLeserArray containsObject:tempLeser])//tempLeser einsetzen
            {
               [SessionLeserArray addObject:tempLeser];
            }
            //NSLog(@"vor setArchivNamenPop");
            [tempProjektDic setObject:SessionLeserArray forKey:@"sessionleserarray"];
            
            //SessionListe in der PList sichern
            
            [self saveSessionForUser:self.Leser inProjekt:[self.ProjektPfad lastPathComponent]];
            
            
            if ([sender tag])
            {
               [self setArchivNamenPop];
            }
            //NSLog(@"nach setArchivNamenPop");
         }//projektIndex
         else
         {
            NSLog(@"Projekt noch nicht da: ");
         }
         //BOOL erfolg=[Manager removeFileAtPath:neueAufnahmePfad handler:nil];
         if (!erfolg)
         {
            NSLog(@"erfolg nach removeFileAtPath: %d",err);
            NSAlert *Warnung = [[NSAlert alloc] init];
            [Warnung addButtonWithTitle:@"OK"];
            //[Warnung addButtonWithTitle:@"Cancel"];
            [Warnung setMessageText:@"Fehler beim Sichern:"];
            [Warnung setInformativeText:@"Die Aufnahme noch im Ordner 'Archiv' in der Lesebox und muss manuell entfernt werden"];
            [Warnung setAlertStyle:NSWarningAlertStyle];
            [Warnung runModal];
            return;
         }
         
      }
      else
      {
         NSAlert *Warnung = [[NSAlert alloc] init];
         [Warnung addButtonWithTitle:@"OK"];
         //[Warnung addButtonWithTitle:@"Cancel"];
         [Warnung setMessageText:@"Fehler beim Sichern:"];
         NSString* s1=@"Das File  fuer die Aufnahme konnte nicht erstellt werden.";
         [Warnung setInformativeText:s1];
         [Warnung setAlertStyle:NSWarningAlertStyle];
         [Warnung runModal];
         [self resetRecPlay];
         return;
      }
   }
   
   
   
   //NSLog(@" vor     SaveAufnahmeTimer");
   
   switch  ([sender tag])
   {
      case 1:
      {
         NSTimer*	SaveAufnahmeTimer=[NSTimer scheduledTimerWithTimeInterval:0.5
                                                                     target:self
                                                                   selector:@selector(SaveAufnahmeTimerFunktion:)
                                                                   userInfo:[NSNumber numberWithDouble:[sender tag]]
                                                                    repeats:NO];
         //NSLog(@"   set        SaveAufnahmeTimer");
      }break;
      case 0:
      {
         
         [self.StartRecordKnopf setEnabled:YES];
         [self.StartPlayKnopf setEnabled:NO];
         [self.StopPlayKnopf setEnabled:NO];
         [self.ForewardKnopf setEnabled:NO];
         [self.RewindKnopf setEnabled:NO];
         [self.BackKnopf setEnabled:NO];
         [self.SichernKnopf setEnabled:NO];
         [self.WeitereAufnahmeKnopf setEnabled:NO];
         [self.LogoutKnopf setEnabled:NO];
         [self.RewindKnopf setEnabled:NO];
         [self.ForewardKnopf setEnabled:NO];
         [self.KommentarView setString:@""];
         [self.KommentarView setEditable:NO];
     
         self.QTKitGesamtAufnahmezeit=0;
         
      }break;
   }//switch
   
 
}

-(void)onTick:(NSTimer *)timer {
   NSLog(@"AufnahmeTimerFunktion");
}
@end

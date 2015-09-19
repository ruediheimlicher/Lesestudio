#import "rProjektStart.h"

extern const int StartmitRecPlay;//=0;
extern const int StartmitAdmin;//=1;
extern const int StartmitDialog;//=2;

@implementation rProjektStart
- (id) init
{
   //if ((self = [super init]))
   self = [super initWithWindowNibName:@"RPProjektStart"];
   {
      ProjektArray=[[NSMutableArray alloc] initWithCapacity: 0];
   }
   ProjektPfad=[NSString string];
   NSNotificationCenter * nc;
   nc=[NSNotificationCenter defaultCenter];
   [nc addObserver:self
          selector:@selector(EnterKeyNotifikationAktion:)
              name:@"EnterTaste"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(EingabeChangeNotificationAktion:)
              name:@"NSTextDidChangeNotification"
            object:EingabeFeld];
   
   return self;
}

- (void) awakeFromNib
{
   //	NSLog(@"ProjektStart awake start");
   
	ProjektDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	ProjektArray=[[NSMutableArray alloc] initWithCapacity:0];
	
	[ProjektTable setDataSource:self];
	[ProjektTable setDelegate: self];
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 36];
	NSColor * RecPlayFarbe=[NSColor cyanColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	
	
	[StartString setTextColor: RecPlayFarbe];
	NSFont* Startfont=[NSFont fontWithName:@"Helvetica" size: 18];
	[StartString setFont: RecPlayfont];
	
	NSFont* Titelfont;
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	[EingabeFeld setDelegate:self];
	[[self window]makeFirstResponder:ProjektTable];
	[AufnehmenTaste setToolTip:NSLocalizedString(@"Perform new Record",@"Eine neue Aufnahme beginnen")];
	[AdminTaste setToolTip:NSLocalizedString(@"With password only:\nOpen administrator window.",@"Nur mit Passwort:\nAdministratorfenster šffnen.")];
	[CancelTaste setToolTip:NSLocalizedString(@"Quit application.",@"Programm beenden.")];
	[ProjektTable setToolTip:NSLocalizedString(@"List of available project folders.",@"Liste der vorhandenen Projektordner.")];
	[NeuesProjektTaste setToolTip:NSLocalizedString(@"Create a new project.",@"Neues Projekt.")];
	//NSLog(@"ProjektStart awake end");
}
/*
 - (void)EnterKeyNotifikationAktion:(NSNotification*)note
 {
 //NSLog(@"Projektliste    EnterKeyNotifikationAktion: note: %@",[note object]);
 NSString* Quelle=[[note object]description];
 //NSLog(@"EnterKeyNotifikationAktion: Quelle: %@",Quelle);
 BOOL erfolg;
 //[self reportNeuesProjekt:NULL];
 }
 */
- (long) anzOrdner
{
   return [ProjektArray count];
}

- (void)selectProjekt:(NSString*)dasProjekt
{
   long index=[[ProjektArray valueForKey:@"projekt"]indexOfObject:dasProjekt];
   if (index<(int)NSNotFound)
   {
      [ProjektTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
      [ProjektTable  reloadData];
      [ProjektTable scrollRowToVisible:index];
      
   }
   
}
- (IBAction)neueZeile:(id)sender
{
}


- (IBAction)reportSegmentClose:(id)sender
{
   
	int ProjektIndex=[ProjektTable selectedRow];
	//NSLog(@"reportClose");
	
	if (ProjektIndex>=0)
   {
      NSString* ProjektString=[ProjektArray objectAtIndex:ProjektIndex];
      NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"projektwahl"];
      [NotificationDic setObject:ProjektArray forKey:@"projektarray"];
      [NotificationDic setObject:[NSNumber numberWithInt:4] forKey:@"aktion"];
      
      //int index=[SegmentTaste selectedSegment];
      // String* UmgebungString=[SegmentTaste Segment]label];
      //NSLog(@"label: %@",[SegmentTaste labelForSegment:index]);
      //[NotificationDic setObject:[NSNumber numberWithInt:index] forKey:@"umgebung"];
      //[NotificationDic setObject:[SegmentTaste labelForSegment:index] forKey:@"umgebunglabel"];
      NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
      [nc postNotificationName:@"ProjektStart" object:self userInfo:NotificationDic];
      
      [NSApp stopModalWithCode:0];
      [[self window] orderOut:NULL];
   }//if ProjektIndex
	else
      NSBeep;
   
}
- (IBAction)reportClose:(id)sender
{
   
   long ProjektIndex=[ProjektTable selectedRow];
   //NSLog(@"reportClose");
   
   if (ProjektIndex>=0)
	{
      NSString* ProjektString=[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"projekt"];
      //NSLog(@"reportClose	ProjektString: %@",ProjektString);
      NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"projektwahl"];
      [NotificationDic setObject:ProjektArray forKey:@"projektarray"];
      BOOL mitUserPW=YES;
      if ([[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"mituserpw"])
      {
         mitUserPW=[[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"mituserpw"]boolValue];
      }
      [NotificationDic setObject:[NSNumber numberWithBool:mitUserPW] forKey:@"mituserpw"];
      
      // String* UmgebungString=[SegmentTaste Segment]label];
      
      [NotificationDic setObject:[NSNumber numberWithLong:0] forKey:@"umgebung"];	// Aufnehmen: 0, Admin: 1
      [NotificationDic setObject:[NSNumber numberWithInt:3] forKey:@"aktion"];
      NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
      [NotificationDic setObject:ProjektString forKey:@"projekt"];
      //NSLog(@"Projektstart reportClose1: NotificationDic: \n%@",[NotificationDic description]);
      [nc postNotificationName:@"ProjektStart" object:self userInfo:NotificationDic];
      
      [NSApp stopModalWithCode:0];
      [[self window] orderOut:NULL];
      
   }//if ProjektIndex
   else
      NSBeep();
   
}

- (IBAction)reportAdmin:(id)sender
{
   long ProjektIndex=[ProjektTable selectedRow];
   if (ProjektIndex>=0)
   {
      NSString* ProjektString=[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"projekt"];

      NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektArray forKey:@"projektarray"];
       BOOL mitUserPW=YES;
      if ([[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"mituserpw"])
      {
         mitUserPW=[[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"mituserpw"]boolValue];
      }
      [NotificationDic setObject:[NSNumber numberWithBool:mitUserPW] forKey:@"mituserpw"];
      
      // String* UmgebungString=[SegmentTaste Segment]label];
      
      [NotificationDic setObject:[NSNumber numberWithLong:1] forKey:@"umgebung"];	// Aufnehmen: 0, Admin: 1
      [NotificationDic setObject:[NSNumber numberWithInt:3] forKey:@"aktion"];
      NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
      [NotificationDic setObject:ProjektString forKey:@"projekt"];
      NSLog(@"Projektstart reportAdmin: NotificationDic: \n%@",[NotificationDic description]);
      [nc postNotificationName:@"adminstart" object:self userInfo:NotificationDic];
      
      [NSApp stopModalWithCode:1];
      [[self window] orderOut:NULL];
   }//if ProjektIndex
   else
      NSBeep();
   
   
}



- (IBAction)reportNeuesProjekt:(id)sender
{
 	NSLog(@"ProjektStart reportNeuesProjekt  start");
	[AufnehmenTaste setEnabled:YES];
   if (ProjektArray&&[ProjektArray count])
   {
      [AufnehmenTaste setEnabled:[ProjektArray count]];
   }
	[AdminTaste setEnabled:YES];
   //NSLog(@"ProjektStart reportNeuesProjekt  B");
   
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:2] forKey:@"aktion"]; //Neues Projekt anlegen
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"umgebung"];	// mit Admin beginnen
	int index=[ProjektTable selectedRow];
   if (ProjektArray&&[ProjektArray count])
   {
      NSString* tempProjektString=[[ProjektArray objectAtIndex:index]objectForKey:@"projekt"];
      NSLog(@"ProjektStart reportNeuesProjekt  tempProjektString: %@",tempProjektString);
      if (tempProjektString)
      {
         [NotificationDic setObject:tempProjektString forKey:@"projektwahl"];
         
      }
   }
   
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"ok"];
	[NotificationDic setObject:[NSNumber numberWithInt:0] forKey:@"mituserpw"];
	[NotificationDic setObject:[NSNumber numberWithInt:0] forKey:@"fix"];
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"umgebung"];
   
   NSLog(@"ProjektStart reportNeuesProjekt NotificationDic: %@",[NotificationDic description]);
   
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[NSApp stopModalWithCode:0];
	[[self window]orderOut:NULL];
	
  // [nc postNotificationName:@"ProjektStart" object:self userInfo:NotificationDic];
	[nc postNotificationName:@"neuesProjektVomStart" object:self userInfo:NotificationDic];
   
	
}

- (IBAction)reportCancel:(id)sender
{
   NSString* ProjektString=[NSString string];
   NSMutableDictionary* NotificationDic=[NSMutableDictionary dictionaryWithObject:ProjektString forKey:@"projekt"];
   [NotificationDic setObject:[NSNumber numberWithInt:13] forKey:@"aktion"];
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"ProjektStart" object:self userInfo:NotificationDic];
   [NSApp stopModalWithCode:0];
   [[self window]orderOut:NULL];
   
   
   
   //Beenden
   {
      NSMutableDictionary* BeendenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
      [BeendenDic setObject:[NSNumber numberWithInt:1] forKey:@"beenden"];
      NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
      //8.11.06	[nc postNotificationName:@"externbeenden" object:self userInfo:BeendenDic];
   }
}


- (void)setProjektArray:(NSArray*)derProjektArray
{
   //NSLog(@"ProjektStartPanel setProjektArray:derProjektArray: %@",[derProjektArray description]);
   
   if ([derProjektArray count])
	{
		//NSLog(@"ProjektStartPanel setProjektArray:ProjektArray vor: %@",[ProjektArray description]);
      
      NSEnumerator* ProjektEnum=[derProjektArray objectEnumerator];
      id einProjektDic;
      int i=0;
      for (i=0;i<[derProjektArray count];i++)
         //while(einProjektDic=[ProjektEnum nextObject])
      {
         einProjektDic = [derProjektArray objectAtIndex:i];
         NSString* tempProjektString=[einProjektDic objectForKey:@"projekt"];
         //NSLog(@"setProjektArray: tempProjektString: %@",tempProjektString);
         if ([einProjektDic objectForKey:@"projekt"])
            if ([[einProjektDic objectForKey:@"projekt"]length])
            {
               // OK ist in PList klein geschrieben
               if (([einProjektDic objectForKey:@"OK"]&&[[einProjektDic objectForKey:@"OK"]boolValue])
                   ||([einProjektDic objectForKey:@"ok"]&&[[einProjektDic objectForKey:@"ok"]boolValue]))
               {
                  [ProjektArray addObject:[einProjektDic copy]];
               }
            }
      }//while
		//NSLog(@"ProjektStartPanel setProjektArray:ProjektArray nach: %@",[ProjektArray description]);
      
      [AufnehmenTaste setEnabled:YES];
      [AdminTaste setEnabled:YES];
      [ProjektTable reloadData];
	}//count
}


- (void)setRecorderTaste:(int)derStatus
{
	//NSLog(@"ProjektStart setRecordertaste: derStatus: %d",derStatus);
	[AufnehmenTaste setEnabled:derStatus];
	switch (derStatus)
	{
		case 0://Kein Recorder:
		{
			[AdminTaste setKeyEquivalent:@"\r"];
			[AufnehmenTaste setKeyEquivalent:@""];
			
			
		}break;
		case 1://Recorder ist OK:
		{
			[AufnehmenTaste setKeyEquivalent:@"\r"];
			[AdminTaste setKeyEquivalent:@""];
			
		}break;
	}//switch
}
#pragma mark -
#pragma mark ProjectTable delegate:

- (void)EingabeChangeNotificationAktion:(NSNotification*)note
{
   //NSLog(@"ProjektListe NSTextDidChangeNotification");
   if ([note object]==EingabeFeld)
	{
      NSLog(@"ProjektListe: Eingabefeld");
	}
   
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
   NSLog(@"controlTextDidBeginEditing: %@",[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]);
   [[self window]makeFirstResponder:InListeTaste];
   [InListeTaste setKeyEquivalent:@"\r"];
   [InListeTaste setEnabled:YES];
}
#pragma mark -
#pragma mark ProjectTable Data Source:


- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
   return [ProjektArray count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(long)rowIndex
{
   NSDictionary *einProjektDic;
	if (rowIndex<[ProjektArray count])
	{
      einProjektDic = [ProjektArray objectAtIndex: rowIndex];
      //NSLog(@"einProjektDic: %@",[einProjektDic description]);
	}
	//NSLog(@"identifier: %@",[aTableColumn identifier]);
	return [einProjektDic objectForKey:[aTableColumn identifier]];;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(int)rowIndex
{
   NSMutableDictionary* einProjektDic;
   if (rowIndex<[ProjektArray count])
	{
		einProjektDic=[ProjektArray objectAtIndex:rowIndex];
		[einProjektDic setObject:anObject forKey:[aTableColumn identifier]];
	}
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
	{
		//NSLog(@"shouldSelectRow im Bereich: row %d",row);
		//[HomeKnopf setState:0];
		if ([[ProjektArray objectAtIndex:row]objectForKey:@"anznamen"])
		{
			if ([[[ProjektArray objectAtIndex:row]objectForKey:@"anznamen"]intValue])
			{
				[AufnehmenTaste setEnabled:YES];
			}
			else
			{
				[AufnehmenTaste setEnabled:NO];
			}
		}
		//[Kopierentaste setKeyEquivalent:@""];
		//[AufnehmenTaste setEnabled:YES];
		[AdminTaste setEnabled:YES];
		//[OKKnopf setKeyEquivalent:@"\r"];
		
	}
   return YES;
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
   if ([ProjektTable numberOfSelectedRows]==0)
	{
      //[OKKnopf setEnabled:NO];
      //[OKKnopf setKeyEquivalent:@""];
      //[HomeKnopf setKeyEquivalent:@"\r"];
	}
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSFont* Tablefont;
	Tablefont=[NSFont fontWithName:@"Helvetica" size: 14];
	[cell setFont:Tablefont];
	if ([[tableColumn identifier] isEqualToString:@"anznamen"])
	{
		if ([[[ProjektArray objectAtIndex:row]objectForKey:@"anznamen"]intValue])
		{
			NSColor * TextFarbe=[NSColor blackColor];
			[cell setTextColor:TextFarbe];
		}
		else
		{
			NSColor * TextFarbe=[NSColor redColor];
			[cell setTextColor:TextFarbe];
		}
	}
}
@end

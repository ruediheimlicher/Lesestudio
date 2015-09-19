#import "rProjektListe.h"

@implementation rProjektListe
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPProjektListe"];
	{
      ProjektArray=[[NSMutableArray alloc] initWithCapacity: 0];
      neueProjekteArray=[[NSMutableArray alloc] initWithCapacity: 0];
	  
	}
	neuesProjektDic=[[NSMutableDictionary alloc]init];
	
	aktuellesProjekt=[NSString string];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	vomStart=NO;
/*
	[nc addObserver:self
		   selector:@selector(EnterKeyNotifikationAktion:)
			   name:@"EnterTaste"
			 object:nil];
*/	
	[nc addObserver:self
		   selector:@selector(EingabeChangeNotificationAktion:)
			   name:@"NSTextDidChangeNotification"
			 object:EingabeFeld];
	
	return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
  int nr=[theEvent keyCode];
  NSString* Taste=[theEvent characters];
  NSLog(@"Projektliste endlich keyDown: %@   %@",[theEvent characters],Taste);	
  [super keyDown:theEvent];
}

- (void) awakeFromNib
{
	neuesProjektDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	ProjektArray=[[NSMutableArray alloc] initWithCapacity:0];

	[ProjektTable setDataSource:self];
	[ProjektTable setDelegate: self];
	[[[ProjektTable tableColumnWithIdentifier:@"ok"]dataCell]setAction:@selector(okAktion:)];
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 32];
	NSColor * RecPlayFarbe=[NSColor grayColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	[StartString setFont: RecPlayfont];
	NSFont* Titelfont;
	[StartString setTextColor: RecPlayFarbe];
	Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[TitelString setFont: Titelfont];
	[TitelString setTextColor: TitelFarbe];
	[EingabeFeld setDelegate:self];
	[FixTaste setState:NO];
	[PWTaste setState:NO];
	[[self window]makeFirstResponder:EingabeFeld];
	//[SchliessenTaste setKeyEquivalent:@"\r"];
	[ProjektTable setToolTip:NSLocalizedString(@"List of all projects.\nActive projects can be choosen by the reader.\nFixed Titles cannot be edited by the reader.",@"Projeltliste")];
	[EingabeFeld setToolTip:NSLocalizedString(@"Name for new project.",@"Name des neuen Projekts")];
	[FixTaste setToolTip:NSLocalizedString(@"Fix the titles of new records.\nThe list of titles can be changed in menu 'Admin->Change Nameliste'.",@"Titel fixieren")];
	[InListeTaste setToolTip:NSLocalizedString(@"Create a new project folder and insert it into the list.",@"Einen neuen Projektordner einrichten und in der Liste einsetzen.")];
	[AuswahlenTaste setToolTip:NSLocalizedString(@"Choose the clicked project.",@"Das angeklickte Projekt auswŠhlen")];
	[EntfernenTaste setToolTip:NSLocalizedString(@"Remove the clicked project with various options.",@"Das angeklickte Projekt mit verschiedenen Optionen entfernen.")];




}

- (IBAction)okAktion:(id)sender
{
double z=[sender selectedRow];
NSString* tempProjektString=[[ProjektArray objectAtIndex:z]objectForKey:@"projekt"];
BOOL istProjektZeile=[tempProjektString isEqualToString:aktuellesProjekt];
BOOL istAktiviert=[[[ProjektArray objectAtIndex:z]objectForKey:@"ok"]boolValue];

[AuswahlenTaste setEnabled:!istProjektZeile&&!istAktiviert];

[EntfernenTaste setEnabled:!(istProjektZeile)];
[[ProjektArray objectAtIndex:z]setObject:[NSNumber numberWithBool:!istAktiviert] forKey:@"ok"];
[ProjektTable reloadData];
NSLog(@"okAktion: Zeile %d    istAktiviert: %d",z,istAktiviert);

}


- (void)EnterKeyNotifikationAktion:(NSNotification*)note
{
	NSLog(@"Projektliste    EnterKeyNotifikationAktion: note: %@",[note object]);
	NSString* Quelle=[[note object]description];
	NSLog(@"EnterKeyNotifikationAktion: Quelle: %@",Quelle);
	BOOL erfolg;
	[self reportNeuesProjekt:NULL];
	
	  
	
	
}

- (int) anzVolumes
{
	return [ProjektArray count];
}

- (IBAction)neueZeile:(id)sender
{
	NSString* neueZeileString=@"neues Projekt:";
	NSMutableDictionary* tempneuesProjektDic=[NSMutableDictionary dictionaryWithObject:neueZeileString forKey:@"projekt"];
	[tempneuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"ok"];
	[ProjektArray addObject: tempneuesProjektDic];
	[ProjektTable reloadData];
	[[[ProjektTable tableColumnWithIdentifier:@"projekt"]dataCellForRow:0]setPlaceholderString:@"projekt"];
	//NSString* s=[[ProjektTable tableColumnWithIdentifier:@"projekt"]dataCellForRow:0]selectAll:NULL];
	int n=[ProjektTable columnWithIdentifier:@"projekt"];
	//NSLog(@"n: %d %@",n ,	s);
	
}

- (IBAction)reportCancel:(id)sender
{
if ([ProjektArray count])
{
//	NSString* ProjektString=[NSString string];
	NSLog(@"ProjektListe reportCancel");
	NSString* ProjektString=@"";
	[EingabeFeld setStringValue:@""];
	[InListeTaste setEnabled:NO];
	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];
	
}
	else//noch kein Projekt vorhanden
	{
	
	[NSApp stopModalWithCode:0];
	[[self window]orderOut:NULL];

	}
vomStart=NO;
}

- (IBAction)reportAuswahlen:(id)sender
{
	NSLog(@"reportAuswahlen");
	int ProjektIndex=[ProjektTable selectedRow];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	if ([ProjektTable selectedRow]>=0)
	{
		NSString* ProjektString=[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"projekt"];//Name des neuen Projekts
																								   //[[self window]makeFirstResponder:ProjektTable];
																								   //NSLog(@"reportAuswahlen ProjektString: %@",ProjektString);
		[NotificationDic setObject:ProjektArray forKey:@"projektarray"];//Eventuelle €nderungen mitgeben
		[NotificationDic setObject:ProjektString forKey:@"projekt"];//AusgewŠhltes Projekt
																	//neus Projekt eingerichtet?
		if ([[neuesProjektDic objectForKey:@"definitiv"]intValue])
		{
			//Namen des neuen Projekts mitgeben
			[NotificationDic setObject:[[neuesProjektDic objectForKey:@"projekt"]copy] forKey:@"neuesprojekt"];
			[neuesProjektDic setObject:[NSNumber numberWithInt:0]forKey:@"definitiv"];//zurŸcksetzen
		}
			
	}//if ProjektIndex
	
	[EingabeFeld setStringValue:@""];
	[InListeTaste setEnabled:NO];
	vomStart=NO;
	[NSApp stopModalWithCode:1];
	[[self window] orderOut:NULL];
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	
	[nc postNotificationName:@"anderesProjekt" object:self userInfo:NotificationDic];
	
	[nc postNotificationName:@"Utils" object:self userInfo:NotificationDic];
	
}

- (IBAction)reportEntfernen:(id)sender
{
  double ProjektIndex=[ProjektTable selectedRow];
  
  NSLog(@"reportEntfernen");
  if ([ProjektTable selectedRow]>=0)
  {
	  NSString* ProjektEntfernenString=[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"projekt"];//Name des neuen Projekts
	  NSLog(@"reportEntfernen ProjektEntfernenString: %@",ProjektEntfernenString);
	  NSAlert *Warnung = [[NSAlert alloc] init];
	  NSString* s3=@"Was soll mit dem  Projektordner %@ geschehen?";
	  [Warnung addButtonWithTitle:@"> Papierkorb"];
	  [Warnung addButtonWithTitle:@"> Magazin"];
	  [Warnung addButtonWithTitle:@"Sofort lšschen"];
	  [Warnung addButtonWithTitle:@"Abbrechen"];
	  [Warnung setMessageText:[NSString stringWithFormat:s3,ProjektEntfernenString]];
	  
	  NSString* s1=NSLocalizedString(@"It can be moved into trash or into the folder 'Magazin' in the lecturebox",@"Er kann in den Papierkorb oder in den Ordner 'Magazin' in der Lesebox verschoben werden.");
	  NSString* s2=NSLocalizedString(@"It can also be removed immediatly. This action cannot be reversed.",@"Er kann auch sofort entfernt werden. Diese Aktion ist aber nicht rŸckgŠngig zu machen.");
	  NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s1,s2];
	  [Warnung setInformativeText:InformationString];
	  [Warnung setAlertStyle:NSWarningAlertStyle];
	  
	  //[Warnung setIcon:RPImage];
	  int antwort=[Warnung runModal];
	  NSNumber* EntfernenNumber=[NSNumber numberWithInt:antwort-1000];
	  
	  switch (antwort)
	  {
		  case NSAlertFirstButtonReturn://In Papierkorb
		  { 
			  NSLog(@"ProjektListe Papierkorb");
		  }
			  
		  case NSAlertSecondButtonReturn://Magazin
		  {
			  NSLog(@"ProjektListe Magazin");
		  }
		  case NSAlertThirdButtonReturn://ex		
		  {
			  //NSLog(@"ProjektListe ex");
			  NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			  [ProjektArray removeObjectAtIndex:ProjektIndex];
			  [ProjektTable reloadData];
			  if ([ProjektArray count]==1)
			  {
				  [EntfernenTaste setEnabled:NO];
				  [AuswahlenTaste setEnabled:NO];
				  
			  }
			  
			  [EingabeFeld setStringValue:@""];
			  [InListeTaste setEnabled:NO];
			  [SchliessenTaste setEnabled:YES];
			  
			  [NotificationDic setObject:ProjektEntfernenString forKey: @"projekt"];
			  [NotificationDic setObject:EntfernenNumber forKey: @"wohin"];
			  NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			  [nc postNotificationName:@"ProjektEntfernen" object:self userInfo:NotificationDic];
			  
		  }break;
		  case NSAlertThirdButtonReturn+1://ex		
		  {
			  NSLog(@"Cancel");
		  }break;
	  }//switch
	  
  }//if
	
  //[NSApp stopModalWithCode:1];
 // [[self window] orderOut:NULL];

}

- (IBAction)reportClose:(id)sender
{ 

  NSLog(@"\n\nProjektliste reportClose: ProjektArray: %@",[ProjektArray description]);
  NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];

	[NotificationDic setObject:ProjektArray forKey:@"projektarray"];//eventuell sind Aktivierungen geŠndert
	
	int ProjektIndex=[ProjektTable selectedRow];
	if ([ProjektTable selectedRow]>=0)
	{
		NSString* ProjektString=[[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"projekt"];//Name des neuen Projekts
		//[[self window]makeFirstResponder:ProjektTable];
		//NSLog(@"reportAuswahlen ProjektString: %@",ProjektString);
		
      [NotificationDic setObject:ProjektArray forKey:@"projektarray"];//Eventuelle €nderungen mitgeben
		[NotificationDic setObject:ProjektString forKey:@"projekt"];//AusgewŠhltes Projekt
																	//neus Projekt eingerichtet?
		if ([[neuesProjektDic objectForKey:@"definitiv"]intValue])
		{
			//Namen des neuen Projekts mitgeben
			[NotificationDic setObject:[[neuesProjektDic objectForKey:@"projekt"]copy] forKey:@"neuesprojekt"];
			[neuesProjektDic setObject:[NSNumber numberWithInt:0]forKey:@"definitiv"];//zurŸcksetzen
		}
			
	}//if ProjektIndex

//	[NotificationDic setObject:neueProjekteArray forKey:@"neueprojektearray"];

	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ProjektWahl" object:self userInfo:NotificationDic];
	[neueProjekteArray removeAllObjects];
	[EingabeFeld setStringValue:@""];
	[InListeTaste setEnabled:NO];
	//[NSApp abortModal];
	NSLog(@"reportClose ende");
	vomStart=NO;
	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];
	

}

- (IBAction)reportNeuesProjekt:(id)sender //
{
  if ([[EingabeFeld stringValue]length])
  {
     NSLog(@"Eingabe da: %@",[EingabeFeld stringValue]);
     NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
     
     NSMutableIndexSet* neuerProjektNameIndex=[NSMutableIndexSet indexSet];
     //NSMutableDictionary* neuesProjektDic=[NSMutableDictionary dictionaryWithObject:[EingabeFeld stringValue] forKey:@"projekt"];
     [neuesProjektDic setObject:[EingabeFeld stringValue] forKey:@"projekt"];
     [neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"ok"];
     [neuesProjektDic setObject: [NSNumber numberWithInt:[FixTaste state]] forKey:@"fix"];
     [neuesProjektDic setObject: [NSNumber numberWithInt:[PWTaste state]] forKey:@"mituserpw"];
     [neuesProjektDic setObject: [NSNumber numberWithInt:0] forKey:@"definitiv"];
     [neueProjekteArray addObject:neuesProjektDic];
     //[NotificationDic setObject:ProjektArray forKey:@"projektarray"];
     [NotificationDic setObject:neuesProjektDic forKey:@"neuesprojektdic"];
     NSLog(@"***\n   ProjektListe reportNeuesProjekt");
     NSLog(@"neuesProjektDic: %@",[neuesProjektDic description]);
     
     NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
     [nc postNotificationName:@"neuesProjekt" object:self userInfo:NotificationDic];
     //Bearbeitung in RecPlayController -> neuesProjektAktion
     
     
     
     
     
     //[neueProjekteArray removeAllObjects];
     [EingabeFeld setStringValue:@""];
     [InListeTaste setEnabled:NO];
     [FixTaste setState:NO];
     [FixTaste setEnabled:NO];
     [PWTaste setEnabled:NO];
     [InListeTaste setKeyEquivalent:@""];
     [SchliessenTaste setKeyEquivalent:@""];
     //[EingabeFeld setEditable:NO];
     [CancelTaste setEnabled:NO];
     [[self window]makeFirstResponder:ProjektTable];
  }
  else
  {
     NSLog(@"Eingabe leer");
  }
		
}

- (void)resetPanel
{
	[EingabeFeld setStringValue:@""];
	[EingabeFeld selectText:NULL];
	[InListeTaste setEnabled:NO];
	[CancelTaste setEnabled:YES];
	[InListeTaste setKeyEquivalent:@""];
	[SchliessenTaste setKeyEquivalent:@""];
	if (([ProjektArray count]>1) && [ProjektTable numberOfSelectedRows])
	{
      [EntfernenTaste setEnabled:YES];
	}
	if ([ProjektArray count])
	{
	[AuswahlenTaste setEnabled:YES];
	[AuswahlenTaste setKeyEquivalent:@"\n"];
	[ProjektTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];

	}
	else
	{
	[AuswahlenTaste setEnabled:NO];
	[AuswahlenTaste setKeyEquivalent:@""];
	}
	//vomStart=NO;
}

-(void)setNeuesProjekt
{
	
	NSMutableIndexSet* neuerProjektNameIndex=[NSMutableIndexSet indexSet];
	[CancelTaste setEnabled:NO];
	/*
	 NSMutableDictionary* neuesProjektDic=[NSMutableDictionary dictionaryWithObject:[EingabeFeld stringValue] forKey:@"projekt"];
	 
	 [neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:OK];
	 [neuesProjektDic setObject: [NSNumber numberWithInt:[FixTaste state]] forKey:fix];
	 [neuesProjektDic setObject: [NSNumber numberWithInt:[PWTaste state]] forKey:mituserpw];
	 */
	[neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"definitiv"];
	[neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"ok"];
	
	[ProjektArray insertObject: neuesProjektDic atIndex:[ProjektArray count]];
	[neuerProjektNameIndex addIndex:[ProjektArray count]-1];
	//NSLog(@"setNeuesProjekt neuesProjektDic: %@     vomStart: %d",[neuesProjektDic description],vomStart);
	
	[EingabeFeld setStringValue:@""];
	[InListeTaste setEnabled:NO];
	
	[InListeTaste setKeyEquivalent:@""];
	if (vomStart)
	{
		[SchliessenTaste setEnabled:NO];
		[CancelTaste setEnabled:NO];
	}
	else
	{
		[SchliessenTaste setEnabled:YES];
	}
	
	[SchliessenTaste setKeyEquivalent:@""];
	
	if ([ProjektArray count]>1)
	{
		[EntfernenTaste setEnabled:YES];
	}
	[AuswahlenTaste setEnabled:YES];
	
	[AuswahlenTaste setKeyEquivalent:@"\n"];	
	[ProjektTable reloadData];
	
	
	//[EingabeFeld setEditable:NO];
	if ([EingabeFeld resignFirstResponder])
	{
		
		//NSLog(@"Responder ok");
		
		[[self window]makeFirstResponder:ProjektTable];
		[ProjektTable scrollRowToVisible:[ProjektArray count]-1];
		[ProjektTable selectRowIndexes:neuerProjektNameIndex byExtendingSelection:NO];
		
		[ProjektTable setNeedsDisplay:YES];
	}
	else
		NSLog(@"kein Responder");
	
	//[EingabeFeld setEditable:YES];
	[ProjektTable scrollRowToVisible:[ProjektArray count]-1];
	[ProjektTable selectRowIndexes:neuerProjektNameIndex byExtendingSelection:NO];
	
	[ProjektTable setNeedsDisplay:YES];
//	[[self window]makeFirstResponder:ProjektTable];
   [[self window]makeFirstResponder:EingabeFeld];
	[ProjektTable setEnabled:YES];
	
}

- (void)setProjektListeLeer
{
[EntfernenTaste setEnabled:NO];
[AuswahlenTaste setEnabled:NO];
[CancelTaste setEnabled:YES];
}

- (void)setProjektListeArray:(NSArray*)derArray inProjekt:(NSString*)dasProjekt
{
[[self window]setInitialFirstResponder:ProjektTable];

  [ProjektArray removeAllObjects];
  NSEnumerator* ProjektEnum=[derArray objectEnumerator];
  id einProjektDic;
  //NSLog(@"setProjektListeArray: derArray: %@ \ndasProjekt: %@",[derArray description],dasProjekt);
  int index=0;
  NSMutableIndexSet* ProjektNameIndex=[NSMutableIndexSet indexSet];
  while (einProjektDic=[ProjektEnum nextObject])
  {
	  //NSLog(@"ProjektPfad: %@",[einProjektDic objectForKey:projektpfad]);
	  
	  NSString* tempTitel=[einProjektDic objectForKey:@"projekt"];
	  if (tempTitel)//das Projekt hat einen Namen
	  {
		  if ([tempTitel isEqualToString:dasProjekt])
		  {
			  [ProjektNameIndex addIndex:index];
		  }	
		  NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		  
		  NSNumber* tempOK=[einProjektDic objectForKey:@"ok"];
		  if (tempOK)
		  {
			  [tempDic setObject:tempOK forKey:@"ok"];
		  }
		  else
		  {
			  [tempDic setObject:[NSNumber numberWithBool:YES] forKey:@"ok"]; // default ist: Projekt aktiviert
		  }
		  [tempDic setObject:tempTitel forKey:@"projekt"];
		  
		  NSNumber* tempFix=[einProjektDic objectForKey:@"fix"];
		  if (tempFix)
		  {
			  [tempDic setObject:tempFix forKey:@"fix"];
		  }
		  else
		  {
			  [tempDic setObject:[NSNumber numberWithBool:NO] forKey:@"fix"]; // default ist: Titel sind nicht fixiert
		  }

		  NSNumber* tempMitUserPW=[einProjektDic objectForKey:@"mituserpw"];
		  if (tempMitUserPW)
		  {
			  [tempDic setObject:tempMitUserPW forKey:@"mituserpw"];
		  }
		  else
		  {
			  [tempDic setObject:[NSNumber numberWithBool:NO] forKey:@"mituserpw"];// default ist: userpasswort ist nicht aktiviert
		  }
		  
		  [tempDic setObject:tempTitel forKey:@"projekt"];
		  
		  NSArray* tempTitelArray=[einProjektDic objectForKey:@"titelarray"];
		  if (tempTitelArray)
		  {
		  [tempDic setObject:tempTitelArray forKey:@"titelarray"];
		  }
		  else
		  {
		  [tempDic setObject:[NSArray array] forKey:@"titelarray"]; // leerer Array

		  }

		  NSArray* tempSessionLeserArray=[einProjektDic objectForKey:@"sessionleserarray"];
		  if (tempSessionLeserArray)
		  {
		  [tempDic setObject:tempSessionLeserArray forKey:@"sessionleserarray"];
		  }
		  else
		  {
		  [tempDic setObject:[NSArray array] forKey:@"sessionleserarray"];// leerer Array

		  }

		  NSString* tempSessionDatum=[einProjektDic objectForKey:@"sessiondatum"];
		  if (tempSessionDatum)
		  {
           [tempDic setObject:tempSessionDatum forKey:@"sessiondatum"];
		  }
		  else
		  {
		  [tempDic setObject:[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle] forKey:@"sessiondatum"]; // heute

		  }



		  NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
		  if (tempProjektPfad)
		  {
		  [tempDic setObject:tempProjektPfad forKey:@"projektpfad"];
		  }
		  else
		  {
		  [tempDic setObject:[NSString string] forKey:@"projektpfad"];

		  }
		  
		  [ProjektArray addObject:tempDic];
		  
	  }
	  index++;
  }//while
	 //NSLog(@"derArray: %@",[ProjektArray description]);
  //NSLog(@"ProjektNameIndex: %@",[ProjektNameIndex description]);
  [ProjektTable reloadData];
  [AuswahlenTaste setEnabled:YES];
  [CancelTaste setEnabled:YES];
  [ProjektTable selectRowIndexes:ProjektNameIndex byExtendingSelection:NO];
  	if ([ProjektArray count]>1)
	{
	//[EntfernenTaste setEnabled:YES];
	 
	}
[ProjektTable scrollRowToVisible: [ProjektNameIndex firstIndex]];

  [AuswahlenTaste setKeyEquivalent:@""];
  [SchliessenTaste setKeyEquivalent:@""];
//  [SchliessenTaste setEnabled:YES];
//  [[self window]makeFirstResponder:EingabeFeld];
  aktuellesProjekt=[NSString stringWithString:dasProjekt];
}

- (void)setMitUserPasswort:(int)derStatus
{
[PWTaste setState:derStatus];
}

- (void)setTitelFix:(int)derStatus
{
[FixTaste setState:derStatus];
}

- (void)setVomStart:(BOOL)derStatus
{
NSLog(@"setVomStart: %d",derStatus);
vomStart=derStatus;
[SchliessenTaste setEnabled:!vomStart];
}



#pragma mark -
#pragma mark ProjectTable delegate:

- (void)EingabeChangeNotificationAktion:(NSNotification*)note
{
	//NSLog(@"ProjektListe NSTextDidChangeNotification");
	if ([note object]==EingabeFeld)
	  {
		//NSLog(@"ProjektListe: Eingabefeld");
	  }
	
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidBeginEditing: %@",[[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]description]);
	//[InListeTaste setKeyEquivalent:@"\r"];
	[EntfernenTaste setEnabled:NO];
	[AuswahlenTaste setEnabled:NO];
	[FixTaste setEnabled:YES];
	[FixTaste setState:NO];
	[PWTaste setEnabled:YES];
	[CancelTaste setEnabled:YES];
//	[PWTaste setState:YES];

	//[EingabeFeld selectText:NULL];
	[InListeTaste setEnabled:YES];
	[InListeTaste setKeyEquivalent:@"\r"];
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
	//if (rowIndex<[ProjektArray count])
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
		NSLog(@"setObjectValue: einProjektDic: %@",[einProjektDic description]);
	}
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
  //NSLog(@"shouldSelectRow");
		//if(tableView ==[window firstResponder])
  NSString* tempProjektString=[[ProjektArray objectAtIndex:row]objectForKey:@"projekt"];
  BOOL istAktiviert=[[[ProjektArray objectAtIndex:row]objectForKey:@"ok"]boolValue];
  //NSLog(@"istAktiviert: %d",istAktiviert);
  BOOL istProjektZeile=[tempProjektString isEqualToString:aktuellesProjekt];
  if ([tableView numberOfSelectedRows]&&(!istProjektZeile))
  {
	  [EntfernenTaste setEnabled:YES];
	  //[SchliessenTaste setEnabled:YES];
	  if (istAktiviert)
	  {
		  [AuswahlenTaste setEnabled:YES];
		  [AuswahlenTaste setKeyEquivalent:@"\r"];
		  [SchliessenTaste setKeyEquivalent:@""];
	  }
	  else
	  {//Projekt nicht aktiviert
		if (!vomStart)
		{
		  [AuswahlenTaste setEnabled:NO];
		  }
		  [SchliessenTaste setKeyEquivalent:@"\r"];
		  
	  }
  }
		  else
			{//ist Projektzeile
			//			5.5.08	[AuswahlenTaste setEnabled:NO];
			[EntfernenTaste setEnabled:NO];

			[AuswahlenTaste setKeyEquivalent:@""];
			[SchliessenTaste setKeyEquivalent:@"\r"];
			
			}
		  
  
  
  return YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	//NSLog(@"ProjektListe willDisplayCell Zeile: %d, numberOfSelectedRows:%d", row ,[tableView numberOfSelectedRows]);
	NSString* tempProjektString=[[ProjektArray objectAtIndex:row]objectForKey:@"projekt"];
	BOOL istProjektZeile=[tempProjektString isEqualToString:aktuellesProjekt];
	if ([[tableColumn identifier] isEqualToString:@"ok"])
	{
		//[cell setEnabled:!istProjektZeile];
		
	}
	if ([[tableColumn identifier] isEqualToString:@"projekt"])
	{
		[cell setEnabled:!istProjektZeile];
		
		if (istProjektZeile)
		{
			[cell setTextColor:[NSColor lightGrayColor]];
		}
		else
		{
			[cell setTextColor:[NSColor blackColor]];
		}
	}
}//willDisplayCell
  
  
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([ProjektTable numberOfSelectedRows]==0)
	{
		//[OKKnopf setEnabled:NO];
		//[OKKnopf setKeyEquivalent:@""];
		//[HomeKnopf setKeyEquivalent:@"\r"];
	}
}

- (BOOL)acceptsFirstResponder
{
  //NSLog(@"Accepting firstResponder");
	 return YES;
}
- (BOOL)resignFirstResponder
{
  //NSLog(@"Resign firstResponder");
	 return YES;
}
- (BOOL)becomeFirstResponder
{
  //NSLog(@"AdminListe Becoming firstResponder");
  //[self setNeedsDisplay:YES];
  return YES;
}

@end

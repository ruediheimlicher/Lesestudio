#import "rNamenListe.h"
@implementation rNamenListe
- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPNamenListe"];
	{
		NamenArray=[[NSMutableArray alloc] initWithCapacity: 0];
	  neueNamenArray=[[NSMutableArray alloc] initWithCapacity: 0];
	}
	aktuellesProjekt=[NSString string];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
/*
	[nc addObserver:self
		   selector:@selector(EnterKeyNotifikationAktion:)
			   name:@"EnterTaste"
			 object:nil];
*/	
	[nc addObserver:self
		   selector:@selector(EingabeChangeNotificationAktion:)
			   name:@"NSTextDidChangeNotification"
			 object:NameFeld];
	
	[nc addObserver:self
		   selector:@selector(NameIstEntferntNotificationAktion:)
			   name:@"NameIstEntfernt"
			 object:NameFeld];
	
	[nc addObserver:self
		   selector:@selector(NameIstEingesetztNotificationAktion:)
			   name:@"NameIstEingesetzt"
			 object:NameFeld];

	[nc addObserver:self
		   selector:@selector(NamenAusKlassenlisteNotificationAktion:)
			   name:@"NamenAusKlassenliste"
			 object:NameFeld];

	return self;
}
/*
- (void)keyDown:(NSEvent *)theEvent
{
  int nr=[theEvent keyCode];
  NSString* Taste=[theEvent characters];
  NSLog(@"NamenListe endlich keyDown: %@   %@",[theEvent characters],Taste);
  [super keyDown:theEvent];
}
*/
- (void) awakeFromNib
{
	NamenDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	NamenArray=[[NSMutableArray alloc] initWithCapacity:0];

	[NamenTable setDataSource:self];
	[NamenTable setDelegate: self];
	[NamenTable deselectAll:nil];

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
	[NameFeld setDelegate:self];
	[[self window]makeFirstResponder:VornameFeld];
	//[NamenTable selectRowIndexes: [NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	[SchliessenTaste setKeyEquivalent:@"\r"];
	
	[VornameFeld setToolTip:@"Vorname des neuen Lesers. Nur ein Wort, kein Leerschlag"];
	[NameFeld setToolTip:@"Nachname des neuen Lesers. Nur ein Wort, kein Leerschlag"];
	[ImportTaste setToolTip:@"NamenListe im Finder suchen"];
	[EinsetzenVariante setToolTip:@"Varianten für den Import neuer Namen."];
	[NameInListeTaste setToolTip:@"Neue Namen in die Liste einsetzen."];
	[UbernehmenTaste setToolTip:@"Neue Namen in die Liste übernehmen.\nDoppelte Namen werden ignoriert."];
   
   [NamenTab setDelegate:self];
}

- (void)EnterKeyNotifikationAktion:(NSNotification*)note
{
	NSLog(@"NamenListe    EnterKeyNotifikationAktion: note: %@",[note object]);
	NSString* Quelle=[[note object]description];
	NSLog(@"EnterKeyNotifikationAktion: Quelle: %@",Quelle);
	[self reportEinsetzenVariante:NULL];
	
}

- (int) anzNamen
{
	return [NamenArray count];
}


- (IBAction)reportCancel:(id)sender
{
	[NameFeld setStringValue:@""];
	[VornameFeld setStringValue:@""];

	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];

}

- (IBAction)reportEntfernen:(id)sender
{
	int NamenIndex=[NamenTable selectedRow];
	
	//NSLog(@"\n\nreportEntfernen	Zeile: %d",NamenIndex);
	if ([NamenTable selectedRow]>=0)
	{
		int selektierteZeile=[NamenTable selectedRow];
		if ([[[NamenArray objectAtIndex:selektierteZeile]objectForKey:@"neuername"]boolValue])
		{
			//neuer Name, noch nicht eingesetzt, nur aus Namenarray löschen
			[NamenArray removeObjectAtIndex:selektierteZeile];
			[NamenTable reloadData];
			return;
		}
		
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		//NSLog(@"reportEntfernen NamenArray: %@\n",NamenArray);
		NSString* NamenEntfernenString=[[NamenArray objectAtIndex:NamenIndex]objectForKey:@"namen"];//Name entf
																									//NSLog(@"NamenEntfernenString: %@",NamenEntfernenString);
			
			[NotificationDic setObject:NamenEntfernenString forKey: @"namen"];
			NSNumber* EntfernenNumber=[NSNumber numberWithInt:[[EntfernenVariante selectedCell]tag]];
			[NotificationDic setObject:EntfernenNumber forKey: @"wohin"];
			
			NSNumber* AusAllenProjektenCheckNumber=[NSNumber numberWithInt:[AusAllenProjektenCheck state]];
			[NotificationDic setObject:AusAllenProjektenCheckNumber forKey: @"ausallenprojekten"];
			//NSLog(@"	NotificationDic: %@\n",[NotificationDic description]);
			
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"NamenEntfernen" object:self userInfo:NotificationDic];
			
			[NameFeld setStringValue:@""];
			[VornameFeld setStringValue:@""];

	}//if
	
	
}

- (void)NameIstEntferntNotificationAktion:(NSNotification*)note
{
	NSLog(@"NameIstEntferntNotificationAktion: %@",[[note userInfo]description]);
	//NSLog(@"NamenArray: %@",[NamenArray description]);
	int EntfernenOK=[[[note userInfo]objectForKey:@"entfernenOK"]intValue];	
	if (EntfernenOK==0)
	{
		NSString* EntfernenName=[[note userInfo]objectForKey:@"namen"];
		if(EntfernenName)
		{
			NSArray* tempNamenArray=[NamenArray valueForKey:@"namen"];
			int deleteIndex=[tempNamenArray indexOfObject:EntfernenName];
			
			if (deleteIndex>=0)//EntfernenName ist vorhanden
			{
				[NamenArray removeObjectAtIndex:deleteIndex];
				[NamenTable reloadData];
			}
		}//if
	}
}

- (void)NameIstEingesetztAktion:(NSNotification*)note
{
   NSLog(@"NameIstEingesetztNotificationAktion: %@",[note description]);
   if ([[note userInfo]objectForKey:@"einsetzenOK"])
   {
      int EinsetzenOK=[[[note userInfo]objectForKey:@"einsetzenOK"]intValue];
      if (EinsetzenOK)
      {
       //  [NamenArray addObject:]
         //[self setAdminPlayer:AdminLeseboxPfad inProjekt:[AdminProjektPfad lastPathComponent]];
      }//if 
   }//note
}

- (IBAction)reportClose:(id)sender
{ 
  //NSLog(@"\n	  NamenListe reportClose");
  NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];

	[NotificationDic setObject:NamenArray forKey:@"namenarray"];//eventuell sind Namen geändert
	
	//[NotificationDic setObject:neueNamenArray forKey:@"neueprojektearray"];

	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"NamenWahl" object:self userInfo:NotificationDic];
	[neueNamenArray removeAllObjects];
	[NameFeld setStringValue:@""];
	[VornameFeld setStringValue:@""];

	//[NSApp abortModal];
	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];
	
 
}

- (NSString*)stringSauberVon:(NSString*)derString
{
	NSMutableString* tempString=[[NSMutableString alloc]initWithCapacity:0];
	tempString=[derString mutableCopy];
	BOOL LeerschlagAmAnfang=YES;
	BOOL LeerschlagAmEnde=YES;
	int index=[tempString length];
	while ((LeerschlagAmAnfang || LeerschlagAmEnde) &&[tempString length]&&index)
	{
		if ([tempString characterAtIndex:0]==' ')
		{
			[tempString deleteCharactersInRange:NSMakeRange(0,1)];
		}
		else
		{
			LeerschlagAmAnfang=NO;
		}
		if ([tempString characterAtIndex:[tempString length]-1]==' ')
		{
			[tempString deleteCharactersInRange:NSMakeRange([tempString length]-1,1)];
		}
		else
		{
			LeerschlagAmEnde=NO;
		}
		index --;
	}//while
	NSLog(@"stringSauber: resultString: *%@*",tempString);
	NSCharacterSet* kleinbuchstabenSet=[NSCharacterSet lowercaseLetterCharacterSet];
	NSLog(@"kleinbuchstabenSet: %@ char: %c",[kleinbuchstabenSet description],[tempString characterAtIndex:0]);
	if ([kleinbuchstabenSet characterIsMember:[tempString characterAtIndex:0]])
	{
		NSLog(@"Kleiner Anfangsbuchstabe: %c",[tempString characterAtIndex:0]);
		NSString* kleinString=[tempString substringToIndex:1];
		[tempString replaceCharactersInRange:NSMakeRange(0,1) withString:[kleinString uppercaseString]];
	}
	NSLog(@"stringSauber upperCase: resultString: *%@*",tempString);

	return tempString;
}

- (IBAction)reportNameAusListe:(id)sender
{
	//Neuer Name, nur aus NamenArray entfernen
	int selektierteZeile=[NamenTable selectedRow];
	if ([[[NamenArray objectAtIndex:selektierteZeile]objectForKey:@"neuername"]boolValue])
	{
      NSString* tempString=[[NamenArray objectAtIndex:selektierteZeile]objectForKey:@"namen"];
		//neuer Name, noch nicht eingesetzt, nur aus Namenarray löschen
		[NamenArray removeObjectAtIndex:selektierteZeile];
		[NamenTable reloadData];
		if ([neueNamenArray containsObject:tempString])
		{
		//NSLog(@"neueNamenArray enthält tempString");
		[neueNamenArray removeObject:tempString];
         
		}
	}
	
}

- (IBAction)reportNameInListe:(id)sender
{
	//Neuer Name in Liste übernehmen
	NSString* NamenStringSauber;
	NSString* VornamenStringSauber;
	NSString* neuerName;
	if (![[NameFeld stringValue]length]||![[VornameFeld stringValue]length])
	{
	return;
	}
	if ([[NameFeld stringValue]length])
	{
		//NSLog(@"reportNeuerName: \nNamen vorher: x%@x",[NameFeld stringValue]);
		NamenStringSauber=[self stringSauberVon:[[NameFeld stringValue]copy]];
		//NSLog(@"Namen nachher: x%@x",NamenStringSauber);
	}
	if ([[VornameFeld stringValue]length])
	{
		//NSLog(@"reportNeuerName: \nNamen vorher: x%@x",[VornameFeld stringValue]);
		VornamenStringSauber=[self stringSauberVon:[[VornameFeld stringValue]copy]];
		//NSLog(@"Vornamen nachher: x%@x",VornamenStringSauber);
	}
	
	neuerName=[NSString stringWithFormat:@"%@ %@",VornamenStringSauber,NamenStringSauber];
	//NSLog(@"neuerName: x%@x",neuerName);
	[neueNamenArray addObject: neuerName];
	NSMutableDictionary* tempNamenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[tempNamenDic setObject:neuerName forKey:@"namen"];
	[tempNamenDic setObject:[NSNumber numberWithBool:YES] forKey:@"neuername"];
	if (![NamenArray containsObject: tempNamenDic])
				{
		[NamenArray addObject: tempNamenDic];
		
				}
	NSSortDescriptor* namenSort=[[NSSortDescriptor alloc]initWithKey:@"namen" ascending:YES];
	[NamenArray sortUsingDescriptors:[NSArray arrayWithObjects:namenSort, nil]];
	[UbernehmenTaste setEnabled:YES];
	[UbernehmenTaste setKeyEquivalent:@"\r"];
	[NameAusListeTaste setEnabled:YES];

	[NameInListeTaste setEnabled:NO];
	[NamenTable reloadData];
}

- (IBAction)reportNamenUbernehmen:(id)sender
{
   long tempEinsetzenVariante=[[EinsetzenVariante selectedCell]tag];
	
	
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	NSNumber* EinsetzenVarianteNumber=[NSNumber numberWithLong:tempEinsetzenVariante];
	[NotificationDic setObject:EinsetzenVarianteNumber forKey: @"einsetzenVariante"];
	[NotificationDic setObject:neueNamenArray forKey:@"neueNamenArray"]; //Namen aus der NamenListe
	//NSLog(@"*reportNamenUbernehmen	neueNamenArray: %@",[neueNamenArray description]);
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"NamenEinsetzen" object:self userInfo:NotificationDic];
	[PfadFeld setStringValue:@""];
	NSEnumerator* NamenEnum=[NamenArray objectEnumerator];
	id einNamenDic;
	while (einNamenDic=[NamenEnum nextObject])//neue Namen zu alten machen, da sie übernommen wurden
	{
	[einNamenDic setObject:[NSNumber numberWithBool:NO]forKey:@"neuername"];
	}//while
	[NamenTable reloadData];
	[NameFeld setStringValue:@""];
	[[self window]makeFirstResponder:VornameFeld];
	[NameFeld setNextKeyView:VornameFeld];
	[VornameFeld setStringValue:@""];
	[UbernehmenTaste setEnabled:NO];
	[UbernehmenTaste setKeyEquivalent:@""];
	[NameAusListeTaste setEnabled:NO];
	
}










- (void)NameIstEingesetztNotificationAktion:(NSNotification*)note
{
	NSLog(@"NameIstEingesetztNotificationAktion: %@",[[note userInfo] description]);

	if ([[note userInfo]objectForKey:@"einsetzenOK"])
   {
      int EinsetzenOK=[[[note userInfo]objectForKey:@"einsetzenOK"]intValue];
      if (EinsetzenOK)
      {
         
         if([[note userInfo]objectForKey:@"neuerName"])
         {
            
            NSString* EinsetzenName=[[note userInfo]objectForKey:@"neuerName"];
            NSLog(@"nur ein neuer Name: %@",EinsetzenName);
            NSMutableDictionary*tempDic=[NSMutableDictionary dictionaryWithObject:EinsetzenName forKey:@"namen"];
            [tempDic setObject:[NSNumber numberWithBool:YES] forKey:@"neuername"];
            
            if (![NamenArray containsObject: tempDic])
            {
               [NamenArray addObject: tempDic];
               [NamenTable reloadData];
            }
         }//if
         
         if([[note userInfo]objectForKey:@"neueNamenArray"])
         {
            NSArray* tempNamenArray = [[note userInfo]objectForKey:@"neueNamenArray"];
            NSLog(@"tempNamenArray: %@",[tempNamenArray description]);
            for (int  index=0;index < [tempNamenArray count];index++)
            {
               NSMutableDictionary*tempDic=[NSMutableDictionary dictionaryWithObject:[tempNamenArray objectAtIndex:index] forKey:@"namen"];
               [tempDic setObject:[NSNumber numberWithBool:YES] forKey:@"neuername"];
               if (![NamenArray containsObject: tempDic])
               {
                  [NamenArray addObject: tempDic];
                  [NamenTable reloadData];
               }
            }
         }
         
         
      }//if 
   }//note
	[UbernehmenTaste setEnabled:NO];
//NSLog(@"NameIstEingesetztNotificationAktion:			ende");
}

- (IBAction)reportImportieren:(id)sender
{
	//NSLog(@"reportImportieren");
   
   NSAlert *Warnung = [[NSAlert alloc] init];
   [Warnung addButtonWithTitle:@"OK"];
   [Warnung setMessageText:@"Import aus Klassenliste"];
   [Warnung setInformativeText:@"Die Klassenliste muss im Format 'txt oder 'doc' vorliegen\nDie Namen duerfen keine Ziffern oder Sonderzeichen enthalten und muessen aus je einem Vornamen und einem Nachnamen bestehen, getrennt durch Leerschlag oder Tabulator."];
   [Warnung setAlertStyle:NSInformationalAlertStyle];
   
   NSModalResponse antwort = [Warnung runModal];

	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"NamenAusListe" object:self userInfo:NotificationDic];
		
}

- (void)NamenAusKlassenlisteNotificationAktion:(NSNotification*)note
{
	NSLog(@"NamenAusKlassenlisteNotificationAktion: %@",[note description]);
	if([[note userInfo]objectForKey:@"NamenDicAusKlassenliste"])
	{
		NSDictionary* tempNamenAusKlassenlisteDic=[[note userInfo]objectForKey:@"NamenDicAusKlassenliste"];
		if ([tempNamenAusKlassenlisteDic objectForKey:@"KlassenArray"])
		{
			[neueNamenArray setArray:[tempNamenAusKlassenlisteDic objectForKey:@"KlassenArray"]];
			NSLog(@"NamenAusKlassenlisteNotificationAktion  neueNamenArray: \n%@",[neueNamenArray description]);
			if ([neueNamenArray count])
			{
				[UbernehmenTaste setEnabled:YES];
				NSEnumerator* NamenEnum=[neueNamenArray objectEnumerator];
				id einName;
				while (einName=[NamenEnum nextObject])
				{
					//NSLog(@"einName einsetzen?: %@",einName);
					if ([einName length]&&!([einName characterAtIndex:0]=='.'))
					{
						NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:einName forKey:@"namen"];
						[tempDic setObject:[NSNumber numberWithBool:YES] forKey:@"neuername"];

						if(![NamenArray containsObject:tempDic])
						{
						// NSLog(@"einName einsetzen!: %@",einName);
						[NamenArray addObject:tempDic];
						}
						
						
					}
				}//while
				[NamenTable reloadData];
			}
		}
		if ([tempNamenAusKlassenlisteDic objectForKey:@"NamenPfad"])
		{
			NSString* tempNamenPfad=[tempNamenAusKlassenlisteDic objectForKey:@"NamenPfad"];
			[PfadFeld setStringValue:tempNamenPfad];
		}
	}
}

- (IBAction)reportEingebenVariante:(id)sender
{
	//NSLog(@"reportEingebenVariante");
	
	[NameInListeTaste setEnabled:[[sender selectedCell]tag]==0];
	[ImportTaste setEnabled:[[sender selectedCell]tag]==1];
	[NameFeld setEnabled:[[sender selectedCell]tag]==0];
	[VornameFeld setEnabled:[[sender selectedCell]tag]==0];
	if ([[sender selectedCell]tag]==0)
	{
		[[self window]makeFirstResponder:VornameFeld];
	}
}


- (IBAction)reportEinsetzenVariante:(id)sender
{
NSLog(@"reportEinsetzenVariante: tag:%d",[[sender selectedCell]tag]);
switch ([[sender selectedCell]tag])
{
case 0://nur dieses Projekt
{

}break;
case 1://nur aktivierte Projekte
{

}break;
case 2://alle Projekte
{

}break;

}//switch
}

-(void)neuerNameInArray:(NSString*)derName
{
	{
	NSMutableIndexSet* neuerNamenIndex=[NSMutableIndexSet indexSet];
	
	NSMutableDictionary* neuerNameDic=[NSMutableDictionary dictionaryWithObject:[NameFeld stringValue] forKey:@"namen"];
	[NamenArray insertObject: neuerNameDic atIndex:[NamenArray count]];
	[neuerNamenIndex addIndex:[NamenArray count]-1];
	//NSLog(@"neuerProjektNameIndex: %@",[neuerProjektNameIndex description]);
	
	[NameFeld setStringValue:@""];
	[VornameFeld setStringValue:@""];
	[UbernehmenTaste setEnabled:NO];
	[UbernehmenTaste setKeyEquivalent:@""];
	[SchliessenTaste setKeyEquivalent:@""];
	[EntfernenTaste setEnabled:YES];
	[BearbeitenTaste setEnabled:YES];
	
	//[BearbeitenTaste setKeyEquivalent:@"\r"];
	NSSortDescriptor* namenSort=[[NSSortDescriptor alloc]initWithKey:@"namen" ascending:YES];
	[NamenArray sortUsingDescriptors:[NSArray arrayWithObjects:namenSort, nil]];
	[NamenTable reloadData];
	//[NamenFeld setEditable:NO];
	if ([NameFeld resignFirstResponder])
	  {
	  
	  //NSLog(@"Responder ok");
	  
	  [[self window]makeFirstResponder:NamenTable];
	  //[NamenTable selectRowIndexes:neuerNamenIndex byExtendingSelection:NO];
	  [NamenTable setNeedsDisplay:YES];
	  }
	else
	  NSLog(@"kein Responder");
	//[NamenFeld setEditable:YES];
	
	}
		
}

- (void)setNamenListeArray:(NSArray*)derArray vonProjekt:(NSString*)dasProjekt
{
  [NamenArray removeAllObjects];
  NSEnumerator* NamenEnum=[derArray objectEnumerator];
  id einName;
  //NSLog(@"setNamenListeArray: derArray: \n%@ \ndasProjekt: %@",[derArray description],dasProjekt);
  
  NSMutableIndexSet* NamenIndex=[NSMutableIndexSet indexSet];
  while (einName=[NamenEnum nextObject])
	{
	//NSLog(@"einName: %@",einName);
	
	if ([einName length]&&!([einName characterAtIndex:0]=='.'))
	{
		NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:einName forKey:@"namen"];
		[tempDic setObject:[NSNumber numberWithBool:NO] forKey:@"neuername"];
		[NamenArray addObject:tempDic];
		
		
	}
	}//while
	// NSLog(@"NamenArray: %@",[NamenArray description]);
  //NSLog(@"ProjektNameIndex: %@",[ProjektNameIndex description]);
  //[[self window]makeFirstResponder:NamenFeld];
  [NamenTable reloadData];
  [BearbeitenTaste setKeyEquivalent:@""];
  [SchliessenTaste setKeyEquivalent:@""];
  aktuellesProjekt=[NSString stringWithString:dasProjekt];
}
#pragma mark -
#pragma mark ProjectTable delegate:

- (void)EingabeChangeNotificationAktion:(NSNotification*)note
{
	//NSLog(@"ProjektListe NSTextDidChangeNotification");
	if ([note object]==NameFeld)
	  {
		//NSLog(@"ProjektListe: NameFeld");
	  }
	
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	//NSLog(@"controlTextDidBeginEditing: %@",[[aNotification  userInfo]objectForKey:@"NSFieldEditor"]);
	if ([[VornameFeld stringValue]length])
	{
		//[UbernehmenTaste setEnabled:YES];
		//[UbernehmenTaste setKeyEquivalent:@"\r"];
		[EntfernenTaste setEnabled:NO];
		[BearbeitenTaste setEnabled:NO];
		[NameInListeTaste setEnabled:YES];
	}
	else
	{
		[UbernehmenTaste setEnabled:NO];
		[UbernehmenTaste setKeyEquivalent:@""];

	}
}
#pragma mark -
#pragma mark ProjectTable Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [NamenArray count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(long)rowIndex
{
//NSLog(@"objectValueForTableColumn");
    NSDictionary *einName;
	if (rowIndex<[NamenArray count])
	{
		NS_DURING
			einName = [NamenArray objectAtIndex: rowIndex];
			
		NS_HANDLER
			if ([[localException name] isEqual: @"NSRangeException"])
			{
				return nil;
			}
			else [localException raise];
		NS_ENDHANDLER
	}
	//NSLog(@"einName: %@",[einName objectForKey:@"namen"]);
	return [einName objectForKey:@"namen"];
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
//NSLog(@"setObjectValueForTableColumn");

    NSString* einName;
    if (rowIndex<[NamenArray count])
	{
		einName=[[NamenArray objectAtIndex:rowIndex]objectForKey:@"namen"];
	}
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
  //NSLog(@"shouldSelectRow");
		//if(tableView ==[window firstResponder])
  NSString* tempNamenString=[[NamenArray objectAtIndex:row]objectForKey:@"namen"];
	[EntfernenTaste setEnabled:YES];
  if ([[[NamenArray objectAtIndex:row]objectForKey:@"neuername"]boolValue])
  {
  [NameAusListeTaste setEnabled:YES];
  }
  else
  {
    [NameAusListeTaste setEnabled:NO];

  }
  
  return YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	//NSLog(@"ProjektListe willDisplayCell Zeile: %d, numberOfSelectedRows:%d", row ,[tableView numberOfSelectedRows]);
	NSString* tempProjektString=[[NamenArray objectAtIndex:row]objectForKey:@"namen"];
	if([[[NamenArray objectAtIndex:row]objectForKey:@"neuername"]boolValue])//neuer Name
	{
	[cell setTextColor:[NSColor redColor]];
	}
	else//alter Name
	{
	[cell setTextColor:[NSColor blackColor]];
	}
}//willDisplayCell
  
  
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([NamenTable numberOfSelectedRows]==0)
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
  return YES;
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
   NSLog(@"tabView shouldSelectTabViewItem: %@",[[tabViewItem identifier]description]);
   //NSLog(@"shouldSelectTabViewItem: rowData: %@",[[AdminDaten rowData] description]);
   
   //[self.PlayTaste setEnabled:YES];
   //[zurListeTaste setEnabled:NO];
   
   if ([[tabViewItem identifier]intValue]==1)//zurück zu 'Neu'
   {
      NSLog(@"NamenListe shouldSelectTabViewItem zu 1");

      
   }
   else if ([[tabViewItem identifier]intValue]==2)// zu 'Entfernen'
   {
       NSLog(@"NamenListe shouldSelectTabViewItem zu 2");
      [self reportNamenUbernehmen:nil];
   }
   return YES;
}
@end

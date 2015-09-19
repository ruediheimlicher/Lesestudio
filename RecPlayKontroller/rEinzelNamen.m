#import "rEinzelNamen.h"

@implementation rEinzelNamen

- (id) init
{
    //if ((self = [super init]))
	self = [super initWithWindowNibName:@"RPEinzelNamen"];
	
	NamenArray=[[NSMutableArray alloc] initWithCapacity: 0];
	
	aktuellesProjekt=[NSString string];
	NSNotificationCenter * nc;
	return self;
}

- (void)awakeFromNib
{
	NamenDic=[[NSMutableDictionary alloc] initWithCapacity:0];
	NamenArray=[[NSMutableArray alloc] initWithCapacity:0];

	[NamenTable setDataSource:self];
	[NamenListeView setDelegate: self];
	[NamenTable deselectAll:nil];
	[[NamenTable tableColumnWithIdentifier:@"namen"]setEditable:YES];
	NSFont* RecPlayfont;
	RecPlayfont=[NSFont fontWithName:@"Helvetica" size: 32];
	NSColor * RecPlayFarbe=[NSColor grayColor];
	[LesestudioString setFont: RecPlayfont];
	[LesestudioString setTextColor: RecPlayFarbe];
	
	NSFont* Titelfont;
		Titelfont=[NSFont fontWithName:@"Helvetica" size: 18];
	NSColor * TitelFarbe=[NSColor grayColor];
	[StartString setFont: Titelfont];
	[StartString setTextColor: TitelFarbe];
	//[VornamenFeld setDelegate:self];
	//[NamenFeld setDelegate:self];
	//[[[self window]contentView]addSubview:VornamenFeld];
	//[[[self window]contentView]addSubview:NamenFeld];
	[[self window]makeFirstResponder:NamenListeView];
	//[NamenTable selectRowIndexes: [NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	//[SchliessenTaste setKeyEquivalent:@"\r"];
	[SchliessenTaste setEnabled:NO];
}

- (IBAction)reportCancel:(id)sender
{
	//[NamenFeld setStringValue:@""];
	//[VornamenFeld setStringValue:@""];
	[NamenListeView setString:@""];
	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];


}

- (IBAction)reportOK:(id)sender
{
  //NSLog(@"\n	  NamenListe reportClose");
  NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];

	
	
	[NotificationDic setObject:NamenArray forKey:@"namenarray"];//eventuell sind Namen geŠndert
	
	//[NotificationDic setObject:neueNamenArray forKey:@"neueprojektearray"];

	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"EinzelNamen" object:self userInfo:NotificationDic];
	//[NamenFeld setStringValue:@""];
	//[VornamenFeld setStringValue:@""];
	[NamenListeView setString:@""];
	//[NSApp abortModal];
	[NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];

}



- (NSArray*)NamenArray
{
return [NamenArray copy];
}

- (IBAction)reportDelete:(id)sender
{
int index=[NamenTable selectedRow];
if (index>=0)
{
[NamenArray removeObjectAtIndex:index];
[NamenTable reloadData];
}
}


















- (IBAction)reportClose:(id)sender
{
	[NamenArray removeAllObjects];
   NSMutableArray* FehlerNamenArray = [[NSMutableArray alloc]initWithCapacity:0];
	NSMutableString* tempNamenViewString =(NSMutableString*)[NamenListeView string];
	//NSLog(@"Einzelnamen reportClose:	tempNamenViewString: %@",[tempNamenViewString description]);
	int anzCR=[tempNamenViewString replaceOccurrencesOfString:@"\n" 
												   withString:@"\r" 
													  options:NSCaseInsensitiveSearch
														range:NSMakeRange(0, [tempNamenViewString length])];
	//NSLog(@"anzCR: %d",anzCR);

	int nochDoppelteCR=YES;
	while (nochDoppelteCR)//Doppelte CR entfernen
	{
		long anzCR=[tempNamenViewString replaceOccurrencesOfString:@"\r\r"
														 withString:@"\r" 
															options:NSCaseInsensitiveSearch
															  range:NSMakeRange(0, [tempNamenViewString length])];
		//NSLog(@"anzCR: %d",anzCR);
		if (anzCR==0)
		{
		nochDoppelteCR=0;
		}
	}//while

	NSArray* tempNamenViewArray=[tempNamenViewString componentsSeparatedByString:@"\r"];
//	NSArray* tempNamenViewArray=[NSArray arrayWithObjects:@"Hans Meier",@"Fritz Huber",nil];
	//NSLog(@"tempNamenViewArray: %@  %d",[tempNamenViewArray description],[tempNamenViewArray count]);
	NSEnumerator* NamenEnum=[tempNamenViewArray  objectEnumerator];
	
	//NSLog(@"NamenViewArrayEnum: %@",[[NamenEnum allObjects]description]);
	//id eineZeile;
	//while (eineZeile=[NamenEnum nextObject]);
	int i;
	for (i=0;i<[tempNamenViewArray count];i++)
	{
		NSMutableString* tempZeilenstring=[[tempNamenViewArray objectAtIndex:i]mutableCopy];//Namen auf Zeile i
		if ([tempZeilenstring length])
		{
			//NSLog(@"tempZeilenstring  Anfang: %@",tempZeilenstring);
			
			//NSMutableString* tempZeilenstring=(NSMutableString*)eineZeile;
			//NSLog(@"tempZeilenstring: %@  tempZeilenstring Anfang: %@",tempZeilenstring,tempZeilenstring);
			int nochTabs=YES;
			while (nochTabs)//Tabs ersetzen durch Leerschlag
			{
				int anzTabs=[tempZeilenstring replaceOccurrencesOfString:@"\t" 
															  withString:@" " 
																 options:NSCaseInsensitiveSearch
																   range:NSMakeRange(0, [tempZeilenstring length])];
				//NSLog(@"anzTabs: %d",anzTabs);
				if (anzTabs==0)
				{
					nochTabs=0;
				}
			}//while
			int nochDoppelterLeerschlag=YES;
			while (nochDoppelterLeerschlag)//doppelte LeehrschlŠge entfernen
			{
				int anzLeerschlag=[tempZeilenstring replaceOccurrencesOfString:@"  " 
																	withString:@" " 
																	   options:NSCaseInsensitiveSearch
																		 range:NSMakeRange(0, [tempZeilenstring length])];
				//NSLog(@"anzLeerschlag: %d",anzLeerschlag);
				if (anzLeerschlag==0)
				{
					nochDoppelterLeerschlag=0;
				}
			}//while
			//NSLog(@"tempZeilenstring sauber: %@",tempZeilenstring);

         
         
			NSArray* tempArray=[tempZeilenstring componentsSeparatedByString:@" "];
			NSMutableArray* tempNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
			int k;
			for (k=0;k<[tempArray count];k++)
			{
				if ([[tempArray objectAtIndex:k]length])
				{
					[tempNamenArray addObject:[tempArray objectAtIndex:k]];
				}
			}
			//NSLog(@"tempNamenArray : %@",[tempNamenArray description]);
			[tempNamenArray removeObjectIdenticalTo:@" "];
			//NSLog(@"tempNamenArray sauber: %@",[tempNamenArray description]);
			NSString* VornamenString;
			NSString* NamenString;
			if ([tempNamenArray count]>1)
			{
				VornamenString=[self stringSauberVon:[tempNamenArray objectAtIndex:0]];
				NamenString=[self stringSauberVon:[tempNamenArray objectAtIndex:[tempNamenArray count]-1]];
				NSString* VornameNamenString=[NSString stringWithFormat:@"%@ %@",VornamenString,NamenString];
				//NSLog(@"VornameNamenString: %@",VornameNamenString);
				NSMutableDictionary* neuerNameDic=[NSMutableDictionary dictionaryWithObject:VornameNamenString forKey:@"namen"];
				[NamenArray addObject: VornameNamenString];
				
			}//if count
		}//if length
	}//while enumerator
	
	//NSLog(@"NamenArray sauber: %@",[NamenArray description]);
	
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	
	[NotificationDic setObject:[NamenArray copy] forKey:@"namenarray"];//
   
   NSNumber* EinsetzenVarianteNumber=[NSNumber numberWithInt:0];
   [NotificationDic setObject:EinsetzenVarianteNumber forKey: @"einsetzenVariante"];
   [NotificationDic setObject:NamenArray forKey:@"neueNamenArray"]; //Namen aus der NamenListe

	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"EinzelNamen" object:self userInfo:NotificationDic];


	[NSApp stopModalWithCode:1];
	[[self window] orderOut:NULL];

	
	}
	- (IBAction)addNamenZeile:(id)sender
	{
	
	NSDictionary* neuerNamenDic=[NSDictionary dictionaryWithObject:@"neu" forKey:@"namen"];
	[NamenArray addObject:neuerNamenDic];
		[NamenTable reloadData];
		[[self window]makeFirstResponder:NamenTable];
		[NamenTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[NamenArray count]-1]byExtendingSelection:NO];
			
	}
	
	
	
- (IBAction)reportUbernehmen:(id)sender
{
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   NSNumber* EinsetzenVarianteNumber=[NSNumber numberWithInt:0];
   [NotificationDic setObject:EinsetzenVarianteNumber forKey: @"einsetzenVariante"];
   [NotificationDic setObject:NamenArray forKey:@"neueNamenArray"]; //Namen aus der NamenListe
   //NSLog(@"*reportNamenUbernehmen	neueNamenArray: %@",[neueNamenArray description]);
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"NamenEinsetzen" object:self userInfo:NotificationDic];

   
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
			NSLog(@"neuer Name, noch nicht eingesetzt, nur aus Namenarray loeschen");
			//neuer Name, noch nicht eingesetzt, nur aus Namenarray lšschen
			[NamenArray removeObjectAtIndex:selektierteZeile];
			[NamenTable reloadData];
			return;
		}
		
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		NSLog(@"reportEntfernen NamenArray: %@\n",[NamenArray description]);
		NSString* NamenEntfernenString=[[NamenArray objectAtIndex:NamenIndex]objectForKey:@"namen"];//Name entf
																									//NSLog(@"NamenEntfernenString: %@",NamenEntfernenString);
			
			
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			//[nc postNotificationName:@"NamenEinsetzen" object:self userInfo:NotificationDic];
			
			[NamenFeld setStringValue:@""];
			[VornamenFeld setStringValue:@""];

	}//if
	
	
}
- (NSString*)stringSauberVon:(NSString*)derString
{
	NSMutableString* tempString=[[NSMutableString alloc]initWithCapacity:0];
	//[derString release];
	tempString=[derString mutableCopy];
	BOOL LeerschlagAmAnfang=YES;
	BOOL LeerschlagAmEnde=YES;
	int index=[tempString length];
	while (LeerschlagAmAnfang || LeerschlagAmEnde &&[tempString length]&&index)
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
	//NSLog(@"stringSauber: resultString: *%@*",tempString);
	NSCharacterSet* kleinbuchstabenSet=[NSCharacterSet lowercaseLetterCharacterSet];
	//NSLog(@"kleinbuchstabenSet: %@ char: %c",[kleinbuchstabenSet description],[tempString characterAtIndex:0]);
	if ([kleinbuchstabenSet characterIsMember:[tempString characterAtIndex:0]])
	{
		//NSLog(@"Kleiner Anfangsbuchstabe: %c",[tempString characterAtIndex:0]);
		NSString* kleinString=[tempString substringToIndex:1];
		[tempString replaceCharactersInRange:NSMakeRange(0,1) withString:[kleinString uppercaseString]];
	}
	//NSLog(@"stringSauber upperCase: resultString: *%@*",tempString);
	return tempString;
}

#pragma mark -
#pragma mark ProjectTable delegate:

- (void)EingabeChangeNotificationAktion:(NSNotification*)note
{
	NSLog(@"ProjektListe NSTextDidChangeNotification");
	if ([note object]==NamenFeld)
	  {
		NSLog(@"ProjektListe: NamenFeld");
	  }
	
}

- (void)textDidBeginEditing:(NSNotification *)aNotification
{
	NSLog(@"controlTextDidBeginEditing: %d",[[aNotification  object]tag]);
	[SchliessenTaste setEnabled:YES];
	
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
	[DeleteTaste setEnabled:YES];
  
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
  
  
@end

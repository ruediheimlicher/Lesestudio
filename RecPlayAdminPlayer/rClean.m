#import "rClean.h"
enum
{
	zweiAufnahmen=2,
	dreiAufnahmen,
	vierAufnahmen,
	sechsAufnahmen=6,
	alleAufnahmen=99
};
enum
{
	nurMarkierteAufnahmen=0,
	alleBisAufAnzahl=1
};
enum
{
	NamenViewTag=1111,
	TitelViewTag=2222
};


//extern NSString* alle;//=@"alle";
//extern NSString* name;//=@"name";
//extern NSString* titel;//=@"titel";
//extern NSString* anzahl;//=@"anzahl";
//extern NSString* auswahl;//;//=@"auswahl";
//extern NSString* leser;//=@"leser";
//extern NSString* anzleser;//=@"anzleser";

//extern NSString* Optionen;//=@"Optionen...";



@implementation rClean
- (id) initWithRowCount:(int)rowCount
{
	self=[super initWithWindowNibName:@"RPClean"];
	
	NamenArray=[[NSMutableArray alloc]initWithCapacity:rowCount];
	int i;
	for (i=0; i < rowCount; i++)
	  {
		[NamenArray addObject: [NSMutableDictionary dictionary]];
	  }
	
	
	TitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	//for (i=0; i < 2; i++)
	  {
		//[TitelArray addObject: [NSMutableDictionary dictionary]];
	  }
	

	  NamenIndexSet=[NSMutableIndexSet indexSet];
	  AnzahlOK=YES;
	return self;
}

- (void)awakeFromNib
{
	//NSLog(@"Clean awakeFromNib");
	NSString* auswahl=@"auswahl";
	NSColor * TitelFarbe=[NSColor blueColor];
	NSFont* TitelFont;
	TitelFont=[NSFont fontWithName:@"Helvetica" size: 24];
	[TitelString setFont:TitelFont];
	[TitelString setTextColor:TitelFarbe];
	NSFont* TextFont;
	TextFont=[NSFont fontWithName:@"Helvetica" size: 12];
	[TextString setFont:TextFont];
	[EntfernenVariante setFont:TextFont];
	//NSLog(@"Clean awakeFromNib1");
	nurTitelZuNamenOption=0;
	NSButtonCell* NamenCheck=[[NSButtonCell alloc]init];
	[NamenCheck setButtonType:NSSwitchButton];
	[NamenCheck setTitle:@""]; 
	[NamenCheck setRefusesFirstResponder:YES]; 
	[NamenCheck setControlSize:NSSmallControlSize]; 
	[NamenCheck setEnabled:YES];
	[NamenCheck setAction:@selector(NamenCheckAktion:)];
    [NamenCheck setTarget:self];
	[[NamenView tableColumnWithIdentifier:@"name"]setDataCell:(NSCell*)NamenCheck];
	[NamenView setDataSource:self];
	[NamenView setDelegate:self];
	
	NSButtonCell* NamenHeaderCheck=[[NSButtonCell alloc]init];
	[NamenHeaderCheck setButtonType:NSSwitchButton];
	[NamenHeaderCheck setTitle:@""]; 
	[NamenHeaderCheck setRefusesFirstResponder:YES]; 
	[NamenHeaderCheck setControlSize:NSSmallControlSize]; 
	[NamenHeaderCheck setEnabled:YES];
	[NamenHeaderCheck setAction:@selector(NamenHeaderCheckAktion:)];
    [NamenHeaderCheck setTarget:self];
	//[[NamenView tableColumnWithIdentifier:name]setHeaderCell:(NSCell*)NamenHeaderCheck];
	
	NSButtonCell* TitelCheck=[[NSButtonCell alloc]init];
	[TitelCheck setButtonType:NSSwitchButton];
	[TitelCheck setTitle:@""]; 
	[TitelCheck setRefusesFirstResponder:YES]; 
	[TitelCheck setControlSize:NSSmallControlSize]; 
	[TitelCheck setEnabled:YES];
	[TitelCheck setTarget:self];
		
	[TitelCheck setAction:@selector(TitelCheckAktion:)];
    //[Check setTarget:self];
	[[TitelView tableColumnWithIdentifier:auswahl]setDataCell:(NSCell*)TitelCheck];
	//[[TitelView tableColumnWithIdentifier:auswahl]setHeaderCell:(NSCell*)Check];
	[TitelView setDataSource:self];
	[TitelView setDelegate:self];
	ClearBehaltenOption=nurMarkierteAufnahmen;
	//NSLog(@"awake fertig");
	
	//NSArray* FormatArray =[NSArray arrayWithObjects: AIFF,WAVE,MOV,MP3,nil];
	NSArray* FormatArray =[NSArray arrayWithObjects: @"AIFF",@"WAVE",nil];
	[ExportFormatPop removeAllItems];
	[ExportFormatPop addItemsWithTitles:FormatArray];
	NSString* item0=[[TaskTabSeite tabViewItemAtIndex:0]identifier];
	NSString* item1=[[TaskTabSeite tabViewItemAtIndex:1]identifier];
	//NSLog(@"Clean awakeFromNib fertig: item0: %@  item1: %@",item0,item1);
	//[TaskTabSeite selectTabViewItemAtIndex:0];
}



- (void)setTaskTab:(int)dasItem
{
//NSLog(@"Clean setTaskTab: Item: %d",dasItem);
if (dasItem<2)
{
[TaskTabSeite selectTabViewItemAtIndex:dasItem];
}

//[TaskTabSeite selectTabViewItemWithIdentifier:[NSNumber numberWithInt:dasItem]];
}


- (void)setClean:(NSDictionary*)dieSettings
{
	NSString* lastFormat=[dieSettings objectForKey:@"exportformat"];
	[ExportFormatPop selectItemWithTitle:lastFormat];
}

-(IBAction)NamenCheckAktion:(id)sender
{
	//NSString* auswahl=@"auswahl";
	//NSLog(@"A button has been clicked: %d, %d",[sender  selectedRow], [sender selectedColumn]);
	NSNumber* y=[NSNumber numberWithInt:1];
	NSNumber* n=[NSNumber numberWithInt:0];
	int selZeile=[sender  selectedRow];
	//aus: shouldSelectRow
	NSNumber* ZeilenNummer;
	ZeilenNummer=[NSNumber numberWithInt:selZeile];
	NSMutableDictionary* CleanZeilenDic=[NSMutableDictionary dictionaryWithObject:ZeilenNummer forKey:@"ZeilenNummer"];
	[CleanZeilenDic setObject:[NSNumber numberWithInt:NamenViewTag] forKey:@"Quelle"];
	NSString* tempName=[[NamenArray objectAtIndex:selZeile]objectForKey:@"name"];
	//NSLog(@"Clean NamenCheckAktion: Name: %@",tempName);
	if (tempName)
	  {
		[CleanZeilenDic setObject:tempName forKey:@"name"];//Name in Dic
		int NamenWeg=0;
		if (nurTitelZuNamenOption)
		  {
			[NamenIndexSet removeAllIndexes];
			[NamenIndexSet addIndex:selZeile];//Diese Zeile in ClassVar NamenIndexSet vormerken
			[[NamenArray objectAtIndex:selZeile]setObject:[NSNumber numberWithInt:0] forKey:@"auswahl"];
		  }
		else
		  {
			//NSLog(@"shouldSelectRow*** NamenIndexSetvor: %@",[NamenIndexSet description]);
			if ([NamenIndexSet containsIndex:selZeile])
			  {
				[NamenIndexSet removeIndex:selZeile];//Name schon im Set: löschen
				NamenWeg=1;//Löschen anzeigen
				[[NamenArray objectAtIndex:selZeile]setObject:[NSNumber numberWithInt:0] forKey:@"auswahl"];
			  }
			else
			  {
				[NamenIndexSet addIndex:selZeile];//Name noch nicht im Set: vormerken
				[[NamenArray objectAtIndex:selZeile]setObject:[NSNumber numberWithInt:1] forKey:@"auswahl"];
				
			  }
			//NSLog(@"shouldSelectRow*** NamenIndexSet nach: %@  NamenWeg: %d",[NamenIndexSet description],NamenWeg);
			//[NamenView selectRowIndexes:NamenIndexSet byExtendingSelection:YES];
			
		  }
		
		[CleanZeilenDic setObject:[NSNumber numberWithInt:NamenWeg] forKey:@"namenweg"];//Option 'Löschen' vormerken
	  }
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"CleanView" object:self userInfo:CleanZeilenDic];
	
	[NamenView reloadData];
}



-(IBAction)NamenHeaderCheckAktion:(id)sender
{
	NSString* auswahl=@"auswahl";
	//NSLog(@"NamenHeaderCheckAktion:  %d", [sender selectedColumn]);
	//NSNumber* y=[NSNumber numberWithBool:YES];
	NSNumber* y=[NSNumber numberWithInt:1];
	NSNumber* n=[NSNumber numberWithInt:0];
	
	//NSNumber* n=[NSNumber numberWithBool:NO];
	
	//BOOL Check=[[[sender tableColumnWithIdentifier:auswahl]headerCell]state];
	BOOL Check=[sender state];
	//NSLog(@"NamenHeaderCheckAktion Check state: %d",Check);
	NSEnumerator* NamenEnumerator=[NamenArray objectEnumerator];
	id eineZeile;
	if (Check)
	  {
		while(eineZeile=[NamenEnumerator nextObject])
		  {
			[eineZeile setObject:y forKey:auswahl];
			[NamenIndexSet addIndex:[NamenArray indexOfObject:eineZeile]];
		  }//while
		NSLog(@"NamenHeaderCheckAktion Notification zeile: %d",[NamenArray indexOfObject:eineZeile]);
		[NamenView reloadData];
		NSNumber* setAlleTitelNumber =[NSNumber numberWithInt:1];
		NSDictionary* CleanOptionDic=[NSDictionary dictionaryWithObject:setAlleTitelNumber forKey:@"setalletitel"];
		NSNotificationCenter * nc;
		nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"CleanOption" object: self userInfo:CleanOptionDic];
		
	  }
	else
	  {
		[NamenIndexSet removeAllIndexes];
		while(eineZeile=[NamenEnumerator nextObject])
		  {
			[eineZeile setObject:n forKey:auswahl];
		  }//while
		[self TitelListeLeeren];
		[self deselectNamenListe];
		[sender setState:NO];
		
	  }//if
	
	[NamenView reloadData];
	
}

-(IBAction)TitelHeaderCheckAktion:(id)sender
{
	NSString* auswahl=@"auswahl";
	NSString* titel=@"titel";
	//NSLog(@"NamenHeaderCheckAktion:  %d", [sender selectedColumn]);
	//NSNumber* y=[NSNumber numberWithBool:YES];
	NSNumber* y=[NSNumber numberWithInt:1];
	NSNumber* n=[NSNumber numberWithInt:0];
	
	//NSNumber* n=[NSNumber numberWithBool:NO];
	
	//BOOL Check=[[[sender tableColumnWithIdentifier:auswahl]headerCell]state];
	BOOL Check=[sender state];
	NSLog(@"TitelHeaderCheckAktion Check state: %d",Check);
	NSEnumerator* TitelEnumerator=[TitelArray objectEnumerator];
	id eineZeile;
	if (Check)
	  {
		while(eineZeile=[TitelEnumerator nextObject])
		  {
			NSString* s=[eineZeile objectForKey:titel];
			if ([s length])
			//if ([[[eineZeile objectForKey:titel]stringValue]length])
			  {
			[eineZeile setObject:y forKey:auswahl];
			  }
			
			else
			  {
				[eineZeile setObject:n forKey:auswahl];
			  }
		  }//while
	  }
	else
	  {
		while(eineZeile=[TitelEnumerator nextObject])
		  {
			[eineZeile setObject:n forKey:auswahl];
		  }//while
		
		
	  }//if
	
	[TitelView reloadData];
}

-(IBAction)TitelCheckAktion:(id)sender
{
	NSString* auswahl=@"auswahl";
	NSString* titel=@"titel";

	//NSLog(@"A button has been clicked: %d, %d",[sender  selectedRow], [sender selectedColumn]);
	NSNumber* y=[NSNumber numberWithBool:YES];
	NSNumber* n=[NSNumber numberWithBool:NO];
	BOOL Check=[[[TitelArray objectAtIndex:[sender  selectedRow]]objectForKey:auswahl]boolValue];
	//NSLog(@"Check state: %d",Check);
	if (Check)
	  {
		
		NSString* s=[[TitelArray objectAtIndex:[sender  selectedRow]] objectForKey:titel];
		if ([s length])
		  {
		[[TitelArray objectAtIndex:[sender  selectedRow]]setObject:n forKey:auswahl];
		  }
	  }
	else
		[[TitelArray objectAtIndex:[sender  selectedRow]]setObject:y forKey:auswahl];
	//[NamenView reloadData];
}

- (IBAction)NurTitelZuNamenCheckAktion:(id)sender;
{
	
}

- (IBAction)cancelSheet:(id)sender
{
	//NSLog(@"cancelSheet: stopModalWithCode");
	[self NamenListeLeeren];
	[self deselectNamenListe];

    [NSApp stopModalWithCode:0];
	[[self window] orderOut:NULL];
	
}

- (IBAction)CleanOK:(id)sender
{
	[NSApp stopModalWithCode:1];
	int var=[[EntfernenVariante selectedCell]tag];
	//NSLog(@"CleanOK:  stopModalWithCode tag: %d",var);
	NSNumber* VariantenNummer=[NSNumber numberWithInt:var];
	NSMutableDictionary* VariantenDic=[NSMutableDictionary dictionaryWithObject:VariantenNummer forKey:@"EntfernenVariante"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"CleanOption" object:self userInfo:VariantenDic];
	//[TitelArray removeAllObjects];
	//[NamenArray removeAllObjects];
	[self NamenListeLeeren];
	[self deselectNamenListe];
	[[self window] orderOut:NULL];
}

- (IBAction)inMagazin:(id)sender
{
}

- (IBAction)inPapierkorb:(id)sender
{
}

- (IBAction)reportClearAnzahl:(id)sender
{
	NSLog(@"reportAnzahlNamenOption: %d",[[sender selectedItem] tag]);
	ClearAnzahlOption=[[sender selectedCell]tag];
	NSNumber* AnzahlOptionNumber =[NSNumber numberWithInt:ClearAnzahlOption];
	NSDictionary* CleanOptionDic=[NSDictionary dictionaryWithObject:AnzahlOptionNumber forKey:@"AnzahlNamen"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"CleanOption" object: self userInfo:CleanOptionDic];
	
}


- (IBAction)reportAnzahlTitel:(id)sender
{
	NSLog(@"reportAnzahlTitelOption: %d",[[sender selectedItem] tag]);
	ExportAnzahlOption=[[sender selectedCell]tag];
	NSNumber* AnzahlOptionNumber =[NSNumber numberWithInt:ExportAnzahlOption];
	NSDictionary* CleanOptionDic=[NSDictionary dictionaryWithObject:AnzahlOptionNumber forKey:@"AnzahlTitel"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"CleanOption" object: self userInfo:CleanOptionDic];
	
}

- (IBAction)reportEntfernenOption:(id)sender
{
	//NSLog(@"reportEntfernenOption");
}


- (NSArray*)NamenArray
{
	return NamenArray;
}


- (NSArray*)klickNamenArray
{
	NSString* auswahl=@"auswahl";
	NSString* name=@"name";
	
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	if ([nurTitelZuNamenCheck state])
	{
		int klickIndex=[NamenView selectedRow];
		[tempArray addObject:[[NamenArray objectAtIndex:klickIndex]objectForKey:@"name"]];
	}
	else
	{
		NSEnumerator* NamenEnumerator=[NamenArray objectEnumerator];
		id eineZeile;
		while (eineZeile=[NamenEnumerator nextObject])
		{
			//NSLog(@"eineZeile: %@",[eineZeile description]);
			
			if ([nurTitelZuNamenCheck state])
			{
				
			}
			else
			{
				if ([[eineZeile objectForKey:auswahl]intValue])
				{
					[tempArray addObject:[[eineZeile objectForKey:@"name"]description]];
				}
			}
		}//while
	}
	//NSLog(@"[tempArray: %@",[tempArray description]);
	return tempArray;
}


- (NSArray*)klickTitelArray
{
	//NSString* auswahl=@"auswahl";
	NSString* name=@"titel";
	
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSEnumerator* TitelEnumerator=[TitelArray objectEnumerator];
	id eineZeile;
	while (eineZeile=[TitelEnumerator nextObject])
	{
		//NSLog(@"eineZeile: %@",[eineZeile description]);
		if ([[eineZeile objectForKey:@"auswahl"]intValue])
		{
			[tempArray addObject:[[eineZeile objectForKey:name]description]];
		}
	}//while
	return tempArray;
}



- (IBAction)reportClearBehaltenOption:(id)sender
{
	NSLog(@"reportClearBehaltenOption");
	ClearBehaltenOption=[[sender selectedCell]tag];
	NSNumber* ClearBehaltenNumber =[NSNumber numberWithInt:ClearBehaltenOption];
	NSDictionary* CleanOptionDic=[NSDictionary dictionaryWithObject:ClearBehaltenNumber forKey:@"clearbehalten"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"CleanOption" object: self userInfo:CleanOptionDic];
	
}


- (IBAction)reportNamen:(id)sender
{
	NSLog(@"reportNamenOption");
	
}

- (IBAction)reportTitel:(id)sender
{
	NSLog(@"reportTitelOption");
}

- (IBAction)reportNurTitelZuNamenOption:(id)sender
{
	//NSLog(@"Clean reportNurTitelZuNamenOption");
	nurTitelZuNamenOption=[sender state];
	int selZeile =[NamenView selectedRow];
	NSIndexSet* selZeilenSet=[NSIndexSet indexSetWithIndex:selZeile];
	NSString* selektiertenamenzeile=@"selektiertenamenzeile";
	NSNumber* nurTitelZuNamenOptionNumber =[NSNumber numberWithInt:nurTitelZuNamenOption];
	NSMutableDictionary* CleanOptionDic=[NSMutableDictionary dictionaryWithObject:nurTitelZuNamenOptionNumber forKey:@"nurTitelZuNamenOption"];
	if (nurTitelZuNamenOption)
	{
		//[NamenView setAllowsMultipleSelection:NO];
		[CleanOptionDic setObject:[self selektierteNamenZeile] forKey:selektiertenamenzeile];
		[self clearTitelListe:nil];
		//[self NamenHeaderCheckAktion:nil];
		NSTextFieldCell* tempCell=[[NSTextFieldCell alloc]init];
		[tempCell setAction:@selector(NamenCheckAktion:)];
		[[NamenView tableColumnWithIdentifier:@"name"]setDataCell:(NSCell*)tempCell];
		//[self enableNamenAuswahl:NO];
		[alleNamenKlickCheck setEnabled:NO];
		
	}
	else
	{
		NSButtonCell* tempCell=[[NSButtonCell alloc]init];
		
		[tempCell setButtonType:NSSwitchButton];
		[tempCell setAction:@selector(NamenCheckAktion:)];
		[tempCell setTarget:self];
		[[NamenView tableColumnWithIdentifier:@"name"]setDataCell:(NSCell*)tempCell];
		
		//[NamenView setAllowsMultipleSelection:YES];
		//[self enableNamenAuswahl:YES];
		[alleNamenKlickCheck setEnabled:YES];
	}
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"CleanOption" object: self userInfo:CleanOptionDic];
	[NamenIndexSet removeAllIndexes];
	[NamenIndexSet addIndex:selZeile];
	NSEnumerator* NamenEnumerator=[NamenArray objectEnumerator];
	id eineZeile;
	while(eineZeile=[NamenEnumerator nextObject])
	{
		[eineZeile setObject:[NSNumber numberWithInt:0]	forKey:@"auswahl"];
	}
	
	[NamenView selectRowIndexes:selZeilenSet byExtendingSelection:NO];
	
	[NamenView reloadData];
}


- (IBAction)sofortWeg:(id)sender
{
}

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
	long anzahl=0;
	switch([aTableView tag])
	  {
		case NamenViewTag:
		  {
			anzahl= [NamenArray count];
		}break;//NamenViewTag
			
		case TitelViewTag:
		  {
			  anzahl= [TitelArray count];

		}break;//TitelViewTag
			
			
	  }//switch tag
	
	return anzahl;
}

- (void)setData: (NSDictionary *)someData forRow: (int)rowIndex
{
	NSMutableDictionary* dataDic=[NSMutableDictionary dictionaryWithDictionary:someData];
	NSMutableDictionary *aRow;
	NSString* view=@"view";
	switch ([[dataDic objectForKey:view]intValue])
	  {
		case NamenViewTag:
		  {
			  aRow = [NamenArray objectAtIndex: rowIndex];
		  }break;//NamenViewTag
			
		case TitelViewTag:
		  {
			  if (rowIndex>=[TitelArray count])
				{
				  //NSLog(@"neue Titelzeile");
				  [TitelArray addObject: [NSMutableDictionary dictionary]];
				}
			   aRow = [TitelArray objectAtIndex: rowIndex];			  
		  }break;//TitelViewTag
			
			
	  }//switch tag
	
	
    //aRow = [NamenArray objectAtIndex: rowIndex];
	//NSLog(@"setData rowIndex: %d  someData: %@   aRow: %@",rowIndex,[someData description],[aRow description]);
    NS_DURING
       
    NS_HANDLER
        if ([[localException name] isEqual: @"NSRangeException"])
		  {
            return;
		  }
        else [localException raise];
    NS_ENDHANDLER
    
	[dataDic removeObjectForKey:view];
    [aRow addEntriesFromDictionary: dataDic];
	
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(long)rowIndex
{
	id dieZeile, derWert;
	//NSLog(@"objectValueForTableColumn tag: %d",[aTableView tag]);

	switch([aTableView tag])
	  {
		case NamenViewTag:
		  {
			  NSParameterAssert(rowIndex >= 0 && rowIndex < [NamenArray count]);
			  dieZeile = [NamenArray objectAtIndex:rowIndex];
			  derWert = [dieZeile objectForKey:[aTableColumn identifier]];
			  
		}break;//NamenViewTag
			
		case TitelViewTag:
		  {
			  NSParameterAssert(rowIndex >= 0 && rowIndex < [TitelArray count]);
			  dieZeile = [TitelArray objectAtIndex:rowIndex];
			  derWert = [dieZeile objectForKey:[aTableColumn identifier]];
			  
		}break;//TitelViewTag
			
			
	  }//switch tag
	
    
	    return derWert;
}

- (NSDictionary *)dataForRow: (int)rowIndex
{
	NSDictionary *aRow;
	
    NS_DURING
        aRow = [rowData objectAtIndex: rowIndex];
    NS_HANDLER
        if ([[localException name] isEqual: @"NSRangeException"])
		  {
            NSLog(@"Setting data out of bounds.");
            return nil;
		  }
        else [localException raise];
    NS_ENDHANDLER
	
    return [NSDictionary dictionaryWithDictionary: aRow];	
}

- (void)setNamenArray:(NSArray*)derNamenArray
{
	//[NamenArray removeAllObjects];
	NSParameterAssert([derNamenArray count]);
	//NSLog(@"Clean setNamenArray AnzNamen: %d  %@",[derNamenArray count],[derNamenArray description]);	
	NSEnumerator* NamenEnumerator=[derNamenArray objectEnumerator];
	id eineZeile;
	int index=0;
	while (eineZeile=[NamenEnumerator nextObject])
	  {
		//NSLog(@"eineZeile: %@",eineZeile);
		NSMutableDictionary* tempZeilenDic=[NSMutableDictionary dictionaryWithObject:eineZeile forKey:@"name"];
		[tempZeilenDic setObject:[NSNumber numberWithBool:NO] forKey:@"auswahl"];
		[tempZeilenDic setObject:[NSNumber numberWithInt:NamenViewTag] forKey:@"view"];
		[self setData:tempZeilenDic forRow:index];
		index++;
	  }//while eineZeile
	[NamenView reloadData];
   //[NamenListe deselectAll:NULL];
}

- (void)setTitelArray:(NSArray*)derTitelArray
{
	//[TitelArray removeAllObjects];

	NSString* titel=@"titel";
	NSString* anzahl=@"anzahl";
	NSString* leser=@"leser";
	NSString* anzleser=@"anzleser";
	NSParameterAssert([derTitelArray count]);
	//NSLog(@"Clean setTitelArray AnzNamen: %d  %@",[derTitelArray count],[derTitelArray description]);	
	
	NSEnumerator* TitelEnumerator=[derTitelArray objectEnumerator];
	id eineZeile;
	int index=0;
	while (eineZeile=[TitelEnumerator nextObject])
	  {
		//NSLog(@"setTitelArray eineZeile: %@",[eineZeile description]);
		NSMutableDictionary* tempZeilenDic=[NSMutableDictionary dictionaryWithObject:[eineZeile objectForKey:titel]
																			  forKey:titel];
		[tempZeilenDic setObject:[eineZeile objectForKey:anzahl] forKey:anzahl];
		[tempZeilenDic setObject:[eineZeile objectForKey:leser] forKey:leser];
		[tempZeilenDic setObject:[eineZeile objectForKey:anzleser] forKey:anzleser];
		[tempZeilenDic setObject:[NSNumber numberWithBool:NO] forKey:@"auswahl"];
		[tempZeilenDic setObject:[NSNumber numberWithInt:TitelViewTag] forKey:@"view"];
		[self setData:tempZeilenDic forRow:index];
		index++;
	  }//while eineZeile
	[TitelView reloadData];
	[alleTitelKlickCheck setEnabled:YES];
	[clearListeTaste setEnabled:YES];
	//NSLog(@"Clean showClean setTitelArray fertig");
}

-(NSDictionary*)selektierteNamenZeile
{
	long NamenZeile=[NamenView selectedRow];
	if (NamenZeile>=0)
	{
	return[NamenArray objectAtIndex:NamenZeile];
	}
	else
	{
		return [NSDictionary dictionary];
	}
}

- (NSArray*)TitelArray
{
	NSString* titel=@"titel";
	//NSLog(@"TitelArray: TitelArray: %@",[TitelArray description]);
	NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSEnumerator* TitelEnumerator=[TitelArray objectEnumerator];
	id eineZeile;
	while(eineZeile=[TitelEnumerator nextObject])
	  {
		
		NSString* tempName=[eineZeile objectForKey:titel];
		if (tempName&&[tempName length])
		  {
			//NSLog(@"TitelArray: eineZeile: %@ tempName: %@",[eineZeile description],tempName);
			[tempTitelArray addObject:eineZeile];
		  }
		
	  }
	//NSLog(@"Clean TitelArray: return tempTitelArray: %@",[tempTitelArray description]);
return tempTitelArray; 
}

- (void)enableNamenAuswahl:(BOOL)derStatus
{
	NSEnumerator* NamenEnumerator=[NamenArray objectEnumerator];
	id eineZeile;
	while(eineZeile=[NamenEnumerator nextObject])
	  {
		
		[[[NamenView tableColumnWithIdentifier:@"auswahl"]dataCellForRow:[NamenArray indexOfObject: eineZeile]]setEnabled:derStatus];
	  }
	[NamenView reloadData];
}

- (IBAction)clearTitelListe:(id)sender
{
	//NSLog(@"Clean clearTitelListe");
	//NSString* titel=@"titel";
	[TitelArray removeAllObjects];
	[TitelView reloadData];
	[NamenView deselectAll:nil];
	[alleTitelKlickCheck setState:0];
	[alleTitelKlickCheck setEnabled:NO];
	[clearListeTaste setEnabled:NO];
	[self NamenHeaderCheckAktion:nil];
	//[self alleNamenSchwarz];
	//NSEnumerator* clearEnum=[NamenArray objectEnumerator];
	[NamenIndexSet removeAllIndexes];
	
}

- (void)TitelListeLeeren
{
	//NSLog(@"Clean TitelListeLeeren");
	//NSString* titel=@"titel";
	[TitelArray removeAllObjects];
	[TitelView reloadData];
	[alleTitelKlickCheck setState:0];
	[alleTitelKlickCheck setEnabled:NO];
	[clearListeTaste setEnabled:NO];
	

}


- (void)NamenListeLeeren
{
	NSEnumerator* NamenEnumerator=[NamenArray objectEnumerator];
	id eineZeile;
	[NamenIndexSet removeAllIndexes];
		while(eineZeile=[NamenEnumerator nextObject])
		  {
			[eineZeile setObject:[NSNumber numberWithInt:0] forKey:@"auswahl"];
		  }//while
		[self TitelListeLeeren];
		[self deselectNamenListe];
	
	[NamenView reloadData];
	

}


- (void)deselectNamenListe
{
	[NamenView deselectAll:nil];
	//[NamenIndexSet removeAllIndexes];
	//[NamenView setNeedsDisplay:YES];
	[alleNamenKlickCheck setState:NO];
}

- (void)alleNamenSchwarz
{
	NSLog(@"alleNamenSchwarz");
	[NamenIndexSet removeAllIndexes];
	[NamenView setNeedsDisplay:YES];
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode 
		contextInfo:(void *)contextInfo
{
	//NSAlertFirstButtonReturn        = 1000,
	//NSAlertSecondButtonReturn    = 1001,
	//NSAlertThirdButtonReturn        = 1002
	
	NSLog(@"returnCode:%d", returnCode);
	switch (returnCode)
	{
		case NSAlertFirstButtonReturn: //Löschen
		{
			AnzahlOK=YES;
			NSLog(@"alles weg");
		}break;
		case NSAlertSecondButtonReturn: //Abbrechen
		{
			AnzahlOK=NO;
			NSLog(@"nochmals ueberlegen");
			NSMutableDictionary* CleanOptionDic=[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"clearnamen"];
			NSNotificationCenter * nc;
			nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"Clear" object: self userInfo:CleanOptionDic];
			
		}break;
	}//switch
	
	
	
	[[alert window] orderOut:nil];
}

- (IBAction)reportClear:(id)sender
{
	NSLog(@"reportClear");
	NSArray* tempNamenArrray=[self klickNamenArray];
	NSArray* tempTitelArray=[self klickTitelArray];
	if ([tempNamenArrray count])
	{
		if ([tempTitelArray count])
		  {
			NSMutableDictionary* CleanOptionDic=[NSMutableDictionary dictionaryWithObject:tempNamenArrray forKey:@"clearnamen"];
			[CleanOptionDic setObject:tempTitelArray forKey:@"cleartitel"];
			[CleanOptionDic setObject:[NSNumber numberWithInt:[[ClearBehaltenVariante selectedCell]tag]] forKey:@"clearbehalten"];
			[CleanOptionDic setObject:[NSNumber numberWithInt:[[EntfernenVariante selectedCell]tag]] forKey:@"clearentfernen"];
			int rest=[[ClearAnzahlPop selectedItem]tag];
			
			if (rest==0)
			  {
				//NSAlertFirstButtonReturn        = 1000,
				//NSAlertSecondButtonReturn    = 1001,
				//NSAlertThirdButtonReturn        = 1002
				
				NSString* FehlerString=NSLocalizedString(@"Clear all records for this title?",@"Wirklich alle Aufnahmen für diese Titel loeschen?");
				NSAlert *Warnung = [[NSAlert alloc] init];
				[Warnung addButtonWithTitle:NSLocalizedString(@"Clear All",@"Alle löschen")];
				[Warnung addButtonWithTitle:NSLocalizedString(@"Change Count",@"Anzahl ändern")];
				[Warnung setMessageText:NSLocalizedString(@"Warning",@"Warnung")];
				[Warnung setInformativeText:FehlerString];
				[Warnung setAlertStyle:NSWarningAlertStyle];
				//[Warnung beginSheetModalForWindow:[self window]
				//					modalDelegate:self
				//				   didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
				//					  contextInfo:nil];
				int Antwort=[Warnung runModal];
				NSLog(@"Antwort: %d",Antwort);
				if (Antwort==NSAlertSecondButtonReturn)
				{
					return;
				}
			  }
			
			[CleanOptionDic setObject:[NSNumber numberWithInt:[[ClearAnzahlPop selectedItem]tag]] forKey:@"clearanzahl"];
			
			
			NSNotificationCenter * nc;
			nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"Clear" object: self userInfo:CleanOptionDic];
		  }
		else
		{
			NSString* FehlerString=[NSString stringWithFormat:@"Mindestens ein Titel muss angeklickt sein."];
			NSAlert *Warnung = [[NSAlert alloc] init];
			[Warnung addButtonWithTitle:@"OK"];
			//[Warnung addButtonWithTitle:@"Cancel"];
			[Warnung setMessageText:@"Fehler beim Auswählen"];
			[Warnung setInformativeText:FehlerString];
			[Warnung setAlertStyle:NSWarningAlertStyle];
         [Warnung runModal];
			return;
			
		}
	}//if klicknamenarray
	else
	{
		NSLog(@"reportClear: nichts angeklickt");
		NSString* FehlerString=@"Mindestens ein Name muss angeklickt sein.";
		NSAlert *Warnung = [[NSAlert alloc] init];
		[Warnung addButtonWithTitle:@"OK"];
		//[Warnung addButtonWithTitle:@"Cancel"];
		[Warnung setMessageText:@"Fehler beim Löschen:"];
		[Warnung setInformativeText:FehlerString];
		[Warnung setAlertStyle:NSWarningAlertStyle];
		[Warnung runModal];
		
		return;
		
	}
}

- (IBAction)reportExport:(id)sender
{
	NSLog(@"reportExport");
	
	NSArray* tempNamenArrray=[self klickNamenArray];
	NSArray* tempTitelArray=[self klickTitelArray];
	//NSLog(@"reportExport	tempNamenArrray: %@",[tempNamenArrray description]);
	//NSLog(@"reportExport	tempTitelArray: %@",[tempTitelArray description]);
	
	if ([tempNamenArrray count])
	{
		if ([tempTitelArray count])
		{
			NSMutableDictionary* FormatauswahlDic=[[NSMutableDictionary alloc]initWithCapacity:0];
         /*
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeAIFF]
																	  forKey:AIFF];
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeAIFC]
																	  forKey:AIFC];
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeWave]
																	  forKey:WAVE];
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeAVI]
																	  forKey:AVI];
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeMuLaw]
																	  forKey:uLAW];
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeMovie]
																	  forKey:MOV];
			[FormatauswahlDic setObject:[NSNumber numberWithLong:kQTFileTypeAudioCDTrack]
																	  forKey:AudioCDTrack];
			*/
			NSMutableDictionary* CleanOptionDic=[NSMutableDictionary dictionaryWithObject:tempNamenArrray forKey:@"exportnamen"];
			[CleanOptionDic setObject:tempTitelArray forKey:@"exporttitel"];
			[CleanOptionDic setObject:[NSNumber numberWithInt:[[ExportVariante selectedCell]tag]] forKey:@"exportvariante"];
			[CleanOptionDic setObject:[NSNumber numberWithInt:[[ExportFormatVariante selectedCell]tag]] forKey:@"exportformatvariante"];
			[CleanOptionDic setObject:[NSNumber numberWithInt:[[ExportAnzahlPop selectedItem]tag]] forKey:@"exportanzahl"];
			NSString* ExportFormat=[ExportFormatPop titleOfSelectedItem];
			[CleanOptionDic setObject:ExportFormat forKey:@"exportformat"];
			
			
			NSNotificationCenter * nc;
			nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"Export" object: self userInfo:CleanOptionDic];
		}
		else
		{
			NSString* FehlerString=[NSString stringWithFormat:@"Mindestens ein Titel muss angeklickt sein."];
			NSAlert *Warnung = [[NSAlert alloc] init];
			[Warnung addButtonWithTitle:@"OK"];
			//[Warnung addButtonWithTitle:@"Cancel"];
			[Warnung setMessageText:NSLocalizedString(@"Error While Choosing",@"Fehler beim Auswählen")];
			[Warnung setInformativeText:FehlerString];
			[Warnung setAlertStyle:NSWarningAlertStyle];
			[Warnung runModal];
			
			return;
			
		}
	}//if klicknamenarray
	else
	{
		NSLog(@"reportClear: nichts angeklickt");
		NSString* FehlerString=[NSString stringWithFormat:@"Mindestens ein Name muss angeklickt sein."];
		NSAlert *Warnung = [[NSAlert alloc] init];
		[Warnung addButtonWithTitle:@"OK"];
		//[Warnung addButtonWithTitle:@"Cancel"];
		[Warnung setMessageText:NSLocalizedString(@"Error while Exporting",@"Fehler beim Exportieren:")];
		[Warnung setInformativeText:FehlerString];
		[Warnung setAlertStyle:NSWarningAlertStyle];
		[Warnung runModal];
		
		return;
		
	}
	
	[self NamenListeLeeren];
	[self deselectNamenListe];

}




- (IBAction)reportExportAnzahl:(id)sender
{

}

- (IBAction)reportExportOption:(id)sender
{
	//NSLog(@"reportExportOption");
	ExportOption=[[sender selectedCell]tag];
	[ExportAnzahlPop setEnabled:ExportOption];
	[ExportOptionenTaste setEnabled:ExportOption];
	NSNumber* ExportOptionNumber =[NSNumber numberWithInt:ExportOption];
	NSDictionary* CleanOptionDic=[NSDictionary dictionaryWithObject:ExportOptionNumber forKey:@"exportoption"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ExportOption" object: self userInfo:CleanOptionDic];
	
}

- (IBAction)reportExportFormatOption:(id)sender
{
	NSLog(@"reportExportFormatOption: %d",[[sender selectedCell]tag]);
	ExportFormatOption=[[sender selectedCell]tag];

	[ExportFormatPop setEnabled:ExportFormatOption];
	[ExportOptionenTaste setEnabled:ExportFormatOption];
}
- (IBAction)reportExportFormat:(id)sender
{
NSLog(@"reportExportFormat: Format: %@",[sender titleOfSelectedItem]);

}

- (IBAction)reportExportOptionenTaste:(id)sender
{
	//NSLog(@"reportExportOptionenTaste");

	NSDictionary* CleanOptionDic=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"exportformat"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ExportFormatDialog" object: self userInfo:CleanOptionDic];
}


 -(void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
{
	//NSString* auswahl=@"auswahl";

	//NSLog(@"mouseDownInHeaderOfTableColumn");
	if ([[tableColumn identifier]isEqualToString:@"auswahl"])
	  {
		//NSLog(@"NamenHeaderCheckAktion:  %d", [sender selectedColumn]);
		NSNumber* y=[NSNumber numberWithBool:YES];
		NSNumber* n=[NSNumber numberWithBool:NO];
		
		BOOL Check=[[ tableColumn headerCell]state];
		NSLog(@"Check state: %d",Check);
		NSEnumerator* NamenEnumerator=[NamenArray objectEnumerator];
		id eineZeile;
		if (Check)
		  {
			while(eineZeile=[NamenEnumerator nextObject])
			  {
				[eineZeile setObject:n forKey:@"auswahl"];
			  }//while
			//NSLog(@"Check state zu 0: %d",[[ tableColumn headerCell]state]);

			[[ tableColumn headerCell]setNextState];
			//NSLog(@"Check state zu 0: %d",[[ tableColumn headerCell]state]);
			
		  }//if
		else
		  {
			while(eineZeile=[NamenEnumerator nextObject])
			  {
				[eineZeile setObject:y forKey:@"auswahl"];
			  }//while
			//NSLog(@"Check state zu 1: %d",[ [tableColumn headerCell]state]);
			[[ tableColumn headerCell]setNextState];
			//NSLog(@"Check state zu 1: %d",[[ tableColumn headerCell]state]);
		  }	
		
		//[NamenView reloadData];
		
	  }

}


- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)row
{
	//NSLog(@"Clean Delegate aTableView  shouldSelectRow: %d",row);
	//NSString* name=@"name";
	//NSString* titel=@"titel";
	
	NSNumber* ZeilenNummer;
	ZeilenNummer=[NSNumber numberWithInt:row];
	NSMutableDictionary* CleanZeilenDic=[NSMutableDictionary dictionaryWithObject:ZeilenNummer forKey:@"ZeilenNummer"];
	
	switch([aTableView tag])
	  {
		case NamenViewTag:
		  {
			  break;
			  [CleanZeilenDic setObject:[NSNumber numberWithInt:NamenViewTag] forKey:@"Quelle"];
			  NSString* tempName=[[NamenArray objectAtIndex:row]objectForKey:@"name"];
			  //NSLog(@"Clean Delegate aTableView  shouldSelectRow: Name: %@",tempName);
			  if (tempName)
				{
				 [CleanZeilenDic setObject:tempName forKey:@"name"];//Name in Dic
				  int NamenWeg=0;
				  if (nurTitelZuNamenOption)
					{
					  //[NamenIndexSet removeAllIndexes];
					  
					  //[NamenIndexSet addIndex:row];//Diese Zeile in ClassVar NamenIndexSet vormerken
					//[[NamenArray objectAtIndex:row]setObject:[NSNumber numberWithInt:0] forKey:auswahl];
					}
				  else
					{
					  //NSLog(@"shouldSelectRow*** NamenIndexSetvor: %@",[NamenIndexSet description]);
					  if ([NamenIndexSet containsIndex:row])
						{
						  //[NamenIndexSet removeIndex:row];//Name schon im Set: löschen
						  NamenWeg=1;//Löschen anzeigen
							  //[[NamenArray objectAtIndex:row]setObject:[NSNumber numberWithInt:0] forKey:auswahl];
						}
					  else
						{
						  //[NamenIndexSet addIndex:row];//Name noch nicht im Set: vormerken
						  //[[NamenArray objectAtIndex:row]setObject:[NSNumber numberWithInt:1] forKey:auswahl];

						}
					 //NSLog(@"shouldSelectRow*** NamenIndexSet nach: %@  NamenWeg: %d",[NamenIndexSet description],NamenWeg);
					  //[NamenView selectRowIndexes:NamenIndexSet byExtendingSelection:YES];
					  
					}
				  
				  //[CleanZeilenDic setObject:[NSNumber numberWithInt:NamenWeg] forKey:@"namenweg"];//Option 'Löschen' vormerken
					  				}
			  //NSLog(@"NamenIndexSet vor: %@",[NamenIndexSet description]);

			  //NSLog(@"NamenIndexSet nach: %@",[NamenIndexSet description]);
		}break;//NamenViewTag

		case TitelViewTag:
		  {
			  [CleanZeilenDic setObject:[NSNumber numberWithInt:TitelViewTag] forKey:@"Quelle"];
			  if (row<[TitelArray count])
				{
				  NSString* tempTitel=[[TitelArray objectAtIndex:row]objectForKey:@"titel"];
				  //NSLog(@"Clean Delegate aTableView  shouldSelectRow: Name: %@",tempName);
				  
				  if (tempTitel)
					{
					  [CleanZeilenDic setObject:tempTitel forKey:@"titel"];
					}
				}
		  }break;//TitelViewTag
			
		
	  }//switch tag
	//NSLog(@"CleanView  shouldSelectRow: %d  CleanZeilenDic: %@",row,[CleanZeilenDic description]);

	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	//[nc postNotificationName:@"CleanView" object:self userInfo:CleanZeilenDic];
	//NSLog(@"CleanView  shouldSelectRow: %d",row);
	//[[[tableView tableColumnWithIdentifier:@"aufnahmen"]dataCellForRow:row]action];
	return YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	//NSLog(@"AdminDS willDisplayCell Zeile: %d", row);
	if ([[tableColumn identifier] isEqualToString:@"name"])
	{
		NSColor * MarkFarbe=[NSColor redColor];
		NSColor * StandardFarbe=[NSColor blackColor];
		//NSLog(@"Name: %@",[[NamenArray objectAtIndex:row]objectForKey:name]);
		
		//[cell setButtonType:NSToggleButton];
		if (nurTitelZuNamenOption)
		{
			[cell setTitle:[[NamenArray objectAtIndex:row]objectForKey:@"name"]];
			//[cell setButtonType:NSMomentaryPushButton];
			
			//[[NamenArray objectAtIndex:row]setObject:[NSNumber numberWithInt:1] forKey:auswahl];
		}
		else
		{
			[cell setTitle:[[NamenArray objectAtIndex:row]objectForKey:@"name"]];
			if ([NamenIndexSet containsIndex:row])
			{
				[cell setState:YES];
				//[cell setTextColor:MarkFarbe];
				//[[NamenArray objectAtIndex:row]setObject:[NSNumber numberWithInt:1] forKey:auswahl];
			}
			else
			{
				[cell setState:NO];

				//[NamenIndexSet addIndex:row];
				//[cell setTextColor:StandardFarbe];
				//[[NamenArray objectAtIndex:row]setObject:[NSNumber numberWithInt:0] forKey:auswahl];
			}
			//NSLog(@"NamenIndexSet: %@",[NamenIndexSet description]);
			
			//[NamenView selectRowIndexes:NamenIndexSet byExtendingSelection:YES];
			
		}
		
		[NamenView reloadData];
	}
}
		
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	NSLog(@"didClickTableColumn");
	if ([[tableColumn identifier]isEqualToString:@"name"])
	{
		NSLog(@"didClickTableColumn: row: %d",[tableView clickedRow]);
	}
	[tableView reloadData];
}

- (void)dealloc
{
}

@end

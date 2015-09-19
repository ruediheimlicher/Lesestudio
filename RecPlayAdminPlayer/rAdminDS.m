#import "rAdminDS.h"

@implementation rAdminDS

-(id) init
{
    return [self initWithRowCount: 0];
}

- (id)initWithRowCount: (long)rowCount
{
    int i;

    if ((self = [super init]))
    {
        _editable = YES;
    
        rowData = [[NSMutableArray alloc] initWithCapacity: rowCount];
        for (i=0; i < rowCount; i++)
        {
            [rowData addObject: [NSMutableDictionary dictionary]];
       }
		
		AufnahmeFiles=[[NSMutableArray alloc] initWithCapacity: rowCount];
		for (i=0; i < rowCount; i++)
        {
            [AufnahmeFiles addObject: [NSMutableArray array]];
		}

		AuswahlArray=[[NSMutableArray alloc] initWithCapacity: rowCount];
		for (i=0; i < rowCount; i++)
        {
            [AuswahlArray addObject: [NSNumber numberWithInt:0]];
		}
		
		MarkArray=[[NSMutableArray alloc] initWithCapacity: rowCount];
		for (i=0; i < rowCount; i++)
		  {
			NSMutableArray* tempMarkArray=[[NSMutableArray alloc] initWithCapacity: 25];
			int k;
			for (k=0;k<25;k++)
			  {
				NSNumber* tempMark=[NSNumber numberWithBool:0];
				
				[tempMarkArray addObject:tempMark];
			  }
			
            [MarkArray addObject: tempMarkArray];
		  }
		
    }
    return self;
}


- (void) awakeFromNib
{

}

- (void)dealloc
{
}

- (BOOL)isEditable
{
    return _editable;
}

- (void)setEditable:(BOOL)b
{
    _editable = b;
}

#pragma mark -
#pragma mark Accessing Row Data:
- (NSArray*)rowData
{
return rowData;
}

- (NSArray*)AufnahmeFiles
{
   return AufnahmeFiles;
}


- (void)setData: (NSDictionary *)someData forRow: (int)rowIndex
{
    NSMutableDictionary *aRow;
    
    NS_DURING
        aRow = [rowData objectAtIndex: rowIndex];
    NS_HANDLER
        if ([[localException name] isEqual: @"NSRangeException"])
        {
            return;
        }
        else [localException raise];
    NS_ENDHANDLER
    
    [aRow addEntriesFromDictionary: someData];
}

- (NSDictionary *)dataForRow: (int)rowIndex
{
    NSDictionary *aRow;

    NS_DURING
        aRow = [rowData objectAtIndex: rowIndex];
    NS_HANDLER
        if ([[localException name] isEqual: @"NSRangeException"])
        {
            //NSLog(@"Setting data out of bounds.");
            return nil;
        }
        else [localException raise];
    NS_ENDHANDLER

    return [NSDictionary dictionaryWithDictionary: aRow];
}

- (int)ZeileVonLeser:(NSString*)derLeser
{
//NSLog(@"rowData: %@",[rowData description]);
long index=[[rowData valueForKey:@"namen"]indexOfObject:derLeser];
return index;
}

- (void)setAufnahmeFiles:(NSArray*)derArray forRow: (int)dieZeile
{
   

	//NSArray* tempArray=[derArray copy];
	NSMutableArray* eineZeile;
	eineZeile=[AufnahmeFiles objectAtIndex:dieZeile];
	[eineZeile addObjectsFromArray:derArray];
  
}

- (NSArray*)AufnahmeFilesFuerZeile:(int)dieZeile
{
	//NSLog(@"AufnahmeFilesFuerZeile: %d",dieZeile);
	NSMutableArray* eineZeile;
	eineZeile=[AufnahmeFiles objectAtIndex:dieZeile];
	return eineZeile;

}

- (void)deleteZeileMitAufnahme:(NSString*)aufnahme
{
   for (int paket=0;paket < [AufnahmeFiles count];paket++)
   {
      long zeilenindex = [[AufnahmeFiles objectAtIndex:paket]indexOfObject:aufnahme];
      NSLog(@"aufnahme: %@ paket: %d zeilenindex: %ld",aufnahme, paket, zeilenindex);
      if (zeilenindex < NSNotFound) // aufnahme ist da
      {
         
      }
   }
}


#pragma mark -

- (long)rowCount
{
    return [rowData count];
}



#pragma mark -

- (void) insertRowAt:(int)rowIndex
{
    [self insertRowAt: rowIndex withData: [NSMutableDictionary dictionary]];
}

- (void) insertRowAt:(int)rowIndex withData:(NSDictionary *)someData
{
    [rowData insertObject: someData atIndex: rowIndex];
}

- (void) insertZeileAn:(int)rowIndex mitData:(NSDictionary *)dieDaten
{
	if ([dieDaten objectForKey:@"namen"])
	{
		NSDictionary* temprowDic=[NSDictionary dictionaryWithObject:[dieDaten objectForKey:@"namen"] forKey:@"namen"];
		[rowData insertObject: temprowDic atIndex: rowIndex];
		
		if ([dieDaten objectForKey:@"anz"])
		{
			NSDictionary* tempAnzDic=[NSDictionary dictionaryWithObject:[dieDaten objectForKey:@"anz"] forKey:@"anz"];
			[AuswahlArray insertObject: tempAnzDic atIndex: rowIndex];
			
		}
		else
		{
			NSDictionary* tempAnzDic=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"anz"];
			[AuswahlArray insertObject: tempAnzDic atIndex: rowIndex];
			
		}
			
	}//if namen
}

- (void) deleteRowAt:(int)rowIndex
{    
    [rowData removeObjectAtIndex: rowIndex];
	[AufnahmeFiles removeObjectAtIndex: rowIndex];
	[AuswahlArray removeObjectAtIndex: rowIndex];
}


- (void)deleteDataZuName:(NSString*)derName
{
   //NSLog(@"deleteDataZuName: %@  ",derName);
   NSEnumerator* rowEnum=[rowData objectEnumerator];
   id einObject;
   int deleteIndex=-1;
   int index=0;
   while(einObject=[rowEnum nextObject])
   {
      if ([[einObject objectForKey:@"namen"] isEqualToString:derName])
      {
         //NSLog(@"einObject: *%@* derName: +%@+ ",[einObject objectForKey:@"namen"],derName);
         deleteIndex=index;
      }
      index++;
   }//while
   //NSLog(@"deleteDataZuName: %@   deleteIndex: %d",derName,deleteIndex);
   if (deleteIndex>=0)
   {
      [self deleteRowAt:deleteIndex];
   }
}


- (void) deleteAllData
{
	[rowData removeAllObjects];
	[AufnahmeFiles removeAllObjects];
	[AuswahlArray removeAllObjects];
	
}


- (void)setAuswahl:(long)dasItem forRow:(long) rowIndex
{
	NSNumber* tempItem=[NSNumber numberWithLong:dasItem];
	[AuswahlArray replaceObjectAtIndex:rowIndex withObject:tempItem];
}

- (int)AuswahlFuerZeile:(int)dieZeile
{
	return [[AuswahlArray objectAtIndex:dieZeile]intValue];
}

- (void)setMarkArray:(NSArray*)derArray forRow:(int)dieZeile
{
	[MarkArray replaceObjectAtIndex:dieZeile withObject:derArray];
}

- (void)setMark:(BOOL)derStatus forRow:(long)dieZeile forItem:(long)dasItem
{
	NSNumber* statusNumber=[NSNumber numberWithBool:derStatus];
	
	[[MarkArray objectAtIndex:dieZeile]replaceObjectAtIndex:dasItem withObject:statusNumber];
}

- (NSArray*)MarkArrayForRow:(long)dieZeile
{
	return [MarkArray objectAtIndex:dieZeile];
}

- (BOOL)MarkForRow:(long)dieZeile forItem:(long)dasItem
{
	
	return [[[MarkArray objectAtIndex:dieZeile]objectAtIndex:dasItem]boolValue];
}

#pragma mark -
#pragma mark Table Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [rowData count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
    row:(long)rowIndex
{
   //NSLog(@"objectValueForTableColumn");
    NSDictionary *aRow;
        
    NS_DURING
        aRow = [rowData objectAtIndex: rowIndex];
    NS_HANDLER
        if ([[localException name] isEqual: @"NSRangeException"])
        {
            return nil;
        }
        else [localException raise];
    NS_ENDHANDLER
    
    return [aRow objectForKey: [aTableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView 
    setObjectValue:(id)anObject 
    forTableColumn:(NSTableColumn *)aTableColumn 
    row:(long)rowIndex
{
   //NSLog(@"setObjectValue");
    NSString *columnName;
    NSMutableDictionary *aRow;
    
    if ( [self isEditable] )
    {
        NS_DURING
            aRow = [rowData objectAtIndex: rowIndex];
        NS_HANDLER
            if ([[localException name] isEqual: @"NSRangeException"])
            {
                return;
            }
            else [localException raise];
        NS_ENDHANDLER
        
        columnName = [aTableColumn identifier];
        [aRow setObject:anObject forKey: columnName];
    }
}

#pragma mark -
#pragma mark Table Delegate:

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(long)rowIndex
{
	//NSLog(@"shouldEditTableColumn");
    return [self isEditable];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(long)row
{
	////NSLog(@"AdminDS willDisplayCell Zeile: %d, numberOfSelectedRows:%d", row ,[tableView numberOfSelectedRows]);
	
   if ([[tableColumn identifier] isEqualToString:@"aufnahmen"])
	{
		[cell removeAllItems];
		[cell setImagePosition:NSImageRight];
		if ([[AufnahmeFiles objectAtIndex:row]count]) //Der Leser hat Aufnahmen
		{
			NSImage* MarkOnImg=[NSImage imageNamed:@"MarkOnImg.tif"];
			NSImage* MarkOffImg=[NSImage imageNamed:@"MarkOffImg.tif"];
			//[MarkOnImg setBackgroundColor:[NSColor clearColor]];
			//NSLog(@"MarkArrayvon Zeile %d : %@",row,[[MarkArray objectAtIndex:row] description]);
			NSEnumerator* AufnahmenEnumerator=[[AufnahmeFiles objectAtIndex:row] objectEnumerator];
			id eineAufnahme;
			int index=0;
			while(eineAufnahme=[AufnahmenEnumerator nextObject])//Aufnahmen für Menu
         {
            [cell addItemWithTitle:eineAufnahme];
            double menuIndex=[cell indexOfItemWithTitle:eineAufnahme];
            //NSLog(@"eineAufnahme: %@ index: %d  menuIndex: %d",eineAufnahme,index,menuIndex);
            
            if ([[MarkArray objectAtIndex:row]count])
            {
               // NSLog(@"MarkArray count: %d",[[MarkArray objectAtIndex:row] count]);
               if(index<[[MarkArray objectAtIndex:row]count])
               {
                  BOOL tempState=[[[MarkArray objectAtIndex:row]objectAtIndex:index]boolValue];
                  //NSLog(@"tempState:%d",tempState);
                  if (tempState)
						{
                     [[cell itemAtIndex:index]setImage:MarkOnImg];
						}
                  else
						{
                     [[cell itemAtIndex:index]setImage:MarkOffImg];
						}
               }
            }
            //else
            {
               //[[cell itemAtIndex:0]setImage:NULL];
            }
            
            index++;
         }
			
			
			
			//NSFont* cellFont=[NSFont systemFontOfSize: 12];
         
			//[cell setFont:cellFont];
			//[cell addItemsWithTitles:[AufnahmeFiles objectAtIndex:row]];
			
			//NSLog(@"willDisplayCell: AuswahlArray:%@",[AuswahlArray description]);
         
			int hit=[[AuswahlArray objectAtIndex:row]intValue];
			//NSLog(@"willDisplayCell: hit:%d",hit);
			[cell selectItemAtIndex:hit];
			//NSColor * MarkFarbe=[NSColor orangeColor];
			//[cell setTextColor:MarkFarbe];
			//[cell setImagePosition:NSImageLeft];
			//NSImage* StartPlayImg=[NSImage imageNamed:@"StartPlayImg.tif"];
			//[cell setImage:StartPlayImg];
			//[cell setBackgroundColor:[NSColor redColor]];
			[cell setEnabled:YES];
			//[MarkCheckbox setEnabled:YES];
		}
		else
		{
			[cell addItemWithTitle:@"leer"];
			[cell setEnabled:NO];
			//[MarkCheckbox setEnabled:NO];
			
		}
   }
	if ([[tableColumn identifier] isEqualToString:@"namen"])
   {
		//NSLog(@"willDisplayCell: row: %d Dic: %@ ",row, [[rowData objectAtIndex:row]description]);
      
		//NSLog(@"willDisplayCell: row: %d Namen: %@ session: %d",row, [[rowData objectAtIndex:row]objectForKey:@"namen"],[[[rowData objectAtIndex:row] objectForKey:@"insession"]boolValue]);
		if ([[[rowData objectAtIndex:row] objectForKey:@"insession"]boolValue])//Namen ist in SessionArray
		{
         [cell setTextColor:[NSColor greenColor]];
		}
		else
		{
         [cell setTextColor:[NSColor blackColor]];
		}
      
		if ([[AufnahmeFiles objectAtIndex:row]count])
      {
         
      }
		else
      {
			[cell setSelectable:NO];
         
      }
   }
   
	if ([[tableColumn identifier] isEqualToString:@"anz"])
	{
		//[cell setIntValue:[[AufnahmeFiles objectAtIndex:row]count]];
		//if ([[AufnahmeFiles objectAtIndex:row]count])
		{
			//[cell setEnabled:YES];
			
			//if ([tableView isRowSelected :row])
			{
				//[cell setEnabled:YES];
				//[cell setTransparent:NO];
				//[cell setTitle:@">"];
				//[cell setKeyEquivalent:@"\r"];
			}
			//else
			{
				//[cell setTransparent:YES];
				//[cell setTitle:@""];
				//[cell setEnabled:NO];
				//[cell setKeyEquivalent:@""];
			}
		}
		//else
		{
         //	[cell setTitle:@""];
			//[cell setKeyEquivalent:@""];
         //	[cell setEnabled:NO];
         //	[cell setTransparent:YES];
		}
	}
   
   //NSString* s=[[AufnahmeFiles objectAtIndex:row] description];
   //NSString* nach=[[cell itemTitles]description];
   //NSLog(@"      willDisplayCell cell nach: %@",nach);
   
   //NSLog(@"willDisplayCell Liste: %@",s);
	
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(long)row
{
	
	//NSLog(@"**AdminDS tableView  shouldSelectRow: %d  [tableView clickedRow]:%d" ,row,[tableView clickedRow]);
	
	long selektierteZeile=[tableView selectedRow];//vorher selektierte Zeile
   //NSLog(@"**AdminDS tableView  shouldSelectRow: %ld  clickedRow :%d selectedRow: %d" ,row,[tableView clickedRow],[tableView selectedRow]);

	NSString* tempLastLesernamen=[NSString string];//leer wenn zeilennummer=-1 beim ersten Klick
	
	NSMutableDictionary* AdminZeilenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[AdminZeilenDic setObject:@"AdminView" forKey:@"Quelle"];
	NSNumber* 	ZeilenNummer=[NSNumber numberWithLong:selektierteZeile];
	[AdminZeilenDic setObject:ZeilenNummer forKey:@"AdminLastZeilenNummer"];
		
	[AdminZeilenDic setObject:[NSNumber numberWithLong:row] forKey:@"AdminNextZeilenNummer"];
	[AdminZeilenDic setObject:[[rowData objectAtIndex:row]objectForKey:@"namen"] forKey:@"nextLeser"];

	if (selektierteZeile>=0)//schon eine Zeile selektiert, sonst -1
	{
		//NSLog(@"rowData last Zeile: %d  Daten: %@",selektierteZeile, [[rowData objectAtIndex:selektierteZeile]description]);
		tempLastLesernamen= [[rowData objectAtIndex:selektierteZeile]objectForKey:@"namen"];
		[AdminZeilenDic setObject:[[rowData objectAtIndex:selektierteZeile]objectForKey:@"namen"] forKey:@"LasttName"];
		
	}//eine Zeile selektiert, eventuell Kommentar sichern
	
	//NSLog(@"rowData next Zeile: %d  Daten: %@",row, [[rowData objectAtIndex:row]description]);
	
	//NSLog(@"[AuswahlArray: %@",[[AuswahlArray objectAtIndex:row]description]);
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AdminselektierteZeile" object:AdminZeilenDic]; // AdminZeilenNotifikationAktion
	NSLog(@"AdmintableView  shouldSelectRow ende: %d",row);
	//[[[tableView tableColumnWithIdentifier:@"aufnahmen"]dataCellForRow:row]action];
	
	return YES;
}


@end

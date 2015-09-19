//
//  rAufnahmenTableController.m
//  RecPlayII
//
//  Created by Sysadmin on 18.11.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "rAdminPlayer.h"


@implementation rAdminPlayer(rAufnahmenTableController)

- (void)setNamenPop:(NSArray*)derNamenArray
{

}

- (IBAction)reportAuswahlOption:(id)sender;
{
NSLog(@"reportAuswahlOption: row: %d",[sender selectedRow]);
[self setAufnahmenVonLeser:[LesernamenPop titleOfSelectedItem]];

}

- (void)setAdminMark:(BOOL)derStatus fuerZeile:(long)dieZeile
{
   NSNumber* StatusNumber=[NSNumber numberWithBool:derStatus];
   switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
   {
      case 1:
      {
         
      //   [[AufnahmenDicArray objectAtIndex:dieZeile]setObject:[StatusNumber stringValue] forKey:@"adminmark"];
      //   [AufnahmenTable reloadData];

      }break;
      case 2:
      {
         BOOL mark = [AdminDaten MarkForRow:[LesernamenPop indexOfSelectedItem] forItem:dieZeile ];
         NSLog(@"mark vor row: %ld zeile: %ld mark: %d",(long)[LesernamenPop indexOfSelectedItem],dieZeile,mark);
        
         [AdminDaten setMark:derStatus forRow:[LesernamenPop indexOfSelectedItem] forItem:dieZeile];
         
         mark = [AdminDaten MarkForRow:[LesernamenPop indexOfSelectedItem] forItem:dieZeile ];
         NSLog(@"mark nach row: %ld zeile: %ld mark: %d",(long)[LesernamenPop indexOfSelectedItem],dieZeile,mark);
         [[AufnahmenDicArray objectAtIndex:dieZeile]setObject:[StatusNumber stringValue] forKey:@"adminmark"];
         [self saveAdminMarkFuerLeser:[LesernamenPop titleOfSelectedItem] FuerAufnahme:AdminAktuelleAufnahme mitAdminMark:derStatus];

         
         [AufnahmenTable reloadData];

      }break;
         
         
         
   }
	
   
}


- (IBAction)reportDelete:(id)sender
{
NSString* tempName=[LesernamenPop titleOfSelectedItem];
NSLog(@"tempName: %@",tempName);
[self AufnahmeLoeschen:sender];
[LesernamenPop selectItemWithTitle:tempName];
[self setAufnahmenVonLeser:tempName];

}

- (void)setUserMark:(BOOL)derStatus fuerZeile:(long)dieZeile
{
   NSLog(@"setUserMark zeile: %d",dieZeile);
	NSNumber* StatusNumber=[NSNumber numberWithBool:derStatus];
	[[AufnahmenDicArray objectAtIndex:dieZeile]setObject:[StatusNumber stringValue] forKey:@"usermark"];
	[AufnahmenTable reloadData];
}






- (IBAction)setAufnahmenVonPopLeser:(id)sender
{
[self setAufnahmenVonLeser:[sender titleOfSelectedItem]];

}

- (long)setAufnahmenVonLeser:(NSString*)derLeser
{
   
   [AufnahmenDicArray removeAllObjects];
   self.AdminAktuellerLeser=[derLeser copy];
   NSString* tempLeserPfad=[AdminProjektPfad stringByAppendingPathComponent:derLeser];
   //NSLog(@"tempLeserPfad: %@",tempLeserPfad);
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:tempLeserPfad error:NULL]];
   if (tempAufnahmenArray)
   {
      [tempAufnahmenArray removeObject:@".DS_Store"];
      [tempAufnahmenArray removeObject:@"Anmerkungen"];
   }
   
   //NSLog(@"tempAufnahmenArray: %@",[tempAufnahmenArray description]);
   
   
   NSString* tempLeserKommentarPfad=[tempLeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
   //NSLog(@"tempLeserKommentarPfad: %@",tempLeserKommentarPfad);
   NSMutableArray* tempKommentarArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:tempLeserKommentarPfad error:NULL]];
   if (tempKommentarArray)
   {
      [tempKommentarArray removeObject:@".DS_Store"];
   }
   //NSLog(@"tempKommentarArray: %@",[tempKommentarArray description]);
   
   NSMutableArray* tempAufnahmenDicArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   NSEnumerator* AufnahmenEnum=[tempAufnahmenArray objectEnumerator];
   id eineAufnahme;
   BOOL inPopOK=NO;
   while (eineAufnahme=[AufnahmenEnum nextObject])
   {
      if ([MarkAuswahlOption selectedRow]==0)
      {
         inPopOK=YES;
      }
      NSMutableDictionary* tempAufnahmenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
      
      [tempAufnahmenDic setObject:eineAufnahme forKey:@"aufnahme"];
      
      // Adminmark gesetzt?
      NSString* tempAufnahmePfad=[tempLeserPfad stringByAppendingPathComponent:eineAufnahme];
      BOOL AdminMarkOK=[self AufnahmeIstMarkiertAnPfad:tempAufnahmePfad];
      [AdminMarkCheckbox setEnabled:YES];
      [AdminMarkCheckbox setState:AdminMarkOK];
      
      if (([MarkAuswahlOption selectedRow]==1)&&AdminMarkOK)
      {
         inPopOK=YES;
         
      }
      [tempAufnahmenDic setObject:[NSNumber numberWithBool:AdminMarkOK] forKey:@"adminmark"];
      
      
      // Usermark gesetzt?
      BOOL UserMarkOK=[self AufnahmeIstVomUserMarkiertAnPfad:tempAufnahmePfad];
      [UserMarkCheckbox setEnabled:YES];
      [UserMarkCheckbox setState:UserMarkOK];
      
      if (([MarkAuswahlOption selectedRow]==2)&&UserMarkOK)
      {
         inPopOK=YES;
         
      }
      [tempAufnahmenDic setObject:[NSNumber numberWithBool:UserMarkOK] forKey:@"usermark"];
      
      
      
      
      
      /*
       NSString* tempKommentarString=[self KommentarZuAufnahme:eineAufnahme
       vonLeser:self.AdminAktuellerLeser
       anProjektPfad:AdminProjektPfad];
       BOOL UserMarkOK=[self UserMarkVon:tempKommentarString];
       
       if (([MarkAuswahlOption selectedRow]==2)&&UserMarkOK)
       {
       inPopOK=YES;
       }
       */
      
      if (inPopOK)
      {
         //[tempAufnahmenDic setObject:[NSNumber numberWithBool:UserMarkOK] forKey:@"usermark"];
         [tempAufnahmenDic setObject:[NSNumber numberWithInt:[self AufnahmeNummerVon:eineAufnahme]] forKey:@"sort"];
         AufnahmeDa=YES;
         [tempAufnahmenDicArray addObject:tempAufnahmenDic];
         inPopOK=NO;
      }
      
   }//while
   AufnahmeDa=[tempAufnahmenDicArray count];
   [PlayTaste setEnabled:AufnahmeDa];
   [DeleteTaste setEnabled:AufnahmeDa];
  // [tempAufnahmenDic setObject:[NSNumber numberWithInt:AufnahmeDa] forKey:@"anzahlaufnahme"];
   if ([tempAufnahmenDicArray count])//es hat Aufnahmen
   {
      //	[DeleteTaste setEnabled:YES];
      //	[self.PlayTaste setEnabled:YES];
   }
   else
   {
      //[DeleteTaste setEnabled:NO];
      //[self.PlayTaste setEnabled:NO];
      NSLog(@"keine Aufnahmen für diese Einstellungen");
      NSMutableDictionary* tempAufnahmenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
      
      [tempAufnahmenDic setObject:@"" forKey:@"aufnahme"];
      [tempAufnahmenDicArray addObject:tempAufnahmenDic];
   }
   
   NSSortDescriptor* sorter=[[NSSortDescriptor alloc]initWithKey:@"sort" ascending:NO];
   NSArray* sortDescArray=[NSArray arrayWithObjects:sorter,nil];
   AufnahmenDicArray =[[tempAufnahmenDicArray sortedArrayUsingDescriptors:sortDescArray]mutableCopy];
   //	NSLog(@"AufnahmenDicArray: %@",[AufnahmenDicArray description]);
   AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:0]objectForKey:@"aufnahme"];
   selektierteAufnahmenTableZeile=0;
   NSNumber* ZeilenNummer=[NSNumber numberWithInt:0];
   NSMutableDictionary* tempZeilenDic=[NSMutableDictionary dictionaryWithObject:ZeilenNummer forKey:@"AufnahmenZeilenNummer"];
   [tempZeilenDic setObject:@"AufnahmenTable" forKey:@"Quelle"];
   NSNotificationCenter * nc;
   nc=[NSNotificationCenter defaultCenter];
   //	[nc postNotificationName:@"AdminselektierteZeile" object:tempZeilenDic];
   
   // von AdminZeilenNotifikationAktion
   {
      // NSDictionary* QuellenDic=[note object];
      //NSLog(@"\n\nAdminZeilenNotifikationAktion:  AufnahmenTable  Quelle: %@",Quelle);
      //NSNumber* ZeilenNummer=[tempZeilenDic objectForKey:@"zeilennummer"];
      
      
      [zurListeTaste setEnabled:NO];
      [PlayTaste setEnabled:YES];
      [PlayTaste setKeyEquivalent:@"\r"];
      
      [AdminMarkCheckbox setState:NO];
      
      //NSString* tempAktuellerLeser=[tempZeilenDic objectForKey:@"leser"];
     // NSString* tempAktuelleAufnahme=[tempZeilenDic objectForKey:@"aufnahme"];
      
      //NSLog(@" row: %d derLeser: %@  AdminAktuelleAufnahme: %@",zeilenNr,derLeser,AdminAktuelleAufnahme);
      if ([derLeser length]&&[AdminAktuelleAufnahme length] && Textchanged)
      {
         //NSLog(@"save in Notification");
         BOOL OK=[self saveKommentarFuerLeser: derLeser FuerAufnahme:AdminAktuelleAufnahme];
         //Textchanged=NO;
      }
      
      //[self backZurListe:nil];
      
      if ([AufnahmenDicArray count]>selektierteAufnahmenTableZeile)//neu selektierte Zeile
      {
         NSDictionary* tempAufnahmenDic=[AufnahmenDicArray objectAtIndex:selektierteAufnahmenTableZeile];
         // NSLog(@"AdminZeilenNotifikationAktion NamenTable neuer AufnahmenDic: %@",[tempAufnahmenDic description]);
         NSString* tempAufnahme=[tempAufnahmenDic objectForKey:@"aufnahme"];
         BOOL OK;
         // NSLog(@"AdminAktuellerLeser: %@ tempAufnahme: %@",self.AdminAktuellerLeser,tempAufnahme);
         OK=[self setPfadFuerLeser: derLeser FuerAufnahme:tempAufnahme];//Movie geladen, wenn OK
         OK=[self setKommentarFuerLeser: derLeser FuerAufnahme:tempAufnahme];
         if([[tempAufnahmenDic objectForKey:@"adminmark"]intValue])
         {
            //[self.MarkCheckbox setState:YES];
            [AdminMarkCheckbox setState:YES];
         }
         else
         {
            //[self.MarkCheckbox setState:NO];
            [AdminMarkCheckbox setState:NO];
            
         }
         [AdminMarkCheckbox setEnabled:AufnahmeDa];
         if([[tempAufnahmenDic objectForKey:@"usermark"]intValue])
         {
            [UserMarkCheckbox setState:YES];
         }
         else
         {
            [UserMarkCheckbox setState:NO];
         }
         
         //[self.PlayTaste setEnabled:YES];
      }//if count
      
      
      [ExportierenTaste setEnabled:NO];
      [LoeschenTaste setEnabled:NO];
      //[self.PlayTaste setEnabled:YES];
      Textchanged=NO;
      //	[self.MarkCheckbox setEnabled:NO];
      
   }//if Quelle==AufnahmenTable
   
   //NSLog(@"AufnahmenTable: %@",[[AufnahmenTable dataSource]description]);
   //NSLog(@"setAufnahmenVonLeser: AufnahmenDicArray: %@",[AufnahmenDicArray description]);
   [AufnahmenTable reloadData];
   [AufnahmenTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0]byExtendingSelection:NO];
   //BOOL OK;
   //	OK=[self setPfadFuerLeser: derLeser FuerAufnahme:AdminAktuelleAufnahme];
   //	OK=[self setKommentarFuerLeser: derLeser FuerAufnahme:AdminAktuelleAufnahme];
   return [tempAufnahmenDicArray count];
}


- (void)setAufnahmenTable:(NSArray*)derAufnahmenArray  fuerLeser:(NSString*)derLeser
{


}

#pragma mark -
#pragma mark TestTable delegate:


#pragma mark -
#pragma mark TestTable Data Source:

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [AufnahmenDicArray count];
}


- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(int)rowIndex
{
   //NSLog(@"objectValueForTableColumn");
    NSMutableDictionary *einAufnahmenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	if (rowIndex<[AufnahmenDicArray count])
	{
      
			einAufnahmenDic = [[AufnahmenDicArray objectAtIndex: rowIndex]mutableCopy];
         //NSLog(@"einAufnahmenDic: %@",[einAufnahmenDic description]);
			if ([[einAufnahmenDic objectForKey:@"adminmark"]intValue]==1)
			{
            [einAufnahmenDic setObject:[NSImage imageNamed:@"MarkOnImg.tif"] forKey:@"adminmark"];
			}
			else
			{
            [einAufnahmenDic setObject:[NSImage imageNamed:@"MarkOffImg.tif"] forKey:@"adminmark"];
			}

	}
	//NSLog(@"einAufnahmenDic: aktiv: %d   Testname: %@",[[einAufnahmenDic objectForKey:@"aktiv"]intValue],[einAufnahmenDic objectForKey:@"name"]);

	return [einAufnahmenDic objectForKey:[aTableColumn identifier]];
	
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
   NSLog(@"setObjectValueForTableColumn");

    NSMutableDictionary* einAufnahmenDic;
    if (rowIndex<[AufnahmenDicArray count])
	{
		//NSLog(@"setObjectValueForTableColumn: anObject: %@ column: %@",[anObject description],[aTableColumn identifier]);
		einAufnahmenDic=[AufnahmenDicArray objectAtIndex:rowIndex];
		NSLog(@"einAufnahmenDic vor: %@",[einAufnahmenDic description]);
		[einAufnahmenDic setObject:anObject forKey:[aTableColumn identifier]];
		NSLog(@"einAufnahmenDic nach: %@",[einAufnahmenDic description]);
		NSString* tempAufnahme=[einAufnahmenDic objectForKey:@"aufnahme"];
		[self saveMarksFuerLeser:self.AdminAktuellerLeser FuerAufnahme:tempAufnahme 
			  mitAdminMark:[[einAufnahmenDic objectForKey:@"adminmark"]intValue]
			   mitUserMark:[[einAufnahmenDic objectForKey:@"usermark"]intValue]];
		
		[AufnahmenTable reloadData];
		//NSLog(@"einAufnahmenDic: %@",[einAufnahmenDic description]);
	}
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
   NSLog(@"AufnahmenTable  shouldSelectRow: %d  selektierteAufnahmenTableZeile: %d, selectedRow: %d" ,row,selektierteAufnahmenTableZeile, (int)[tableView selectedRow]);
   
   long bisherSelektierteZeile=selektierteAufnahmenTableZeile;//bisher selektierte Zeile
   selektierteAufnahmenTableZeile=row;//neu selektierte Zeile
   if ([tableView selectedRow]>=0)
   {
      [self Aufnahmezuruecklegen];
   }
   
   [AdminKommentarView setEditable:YES];
   [AdminKommentarView setSelectable:YES];
   
   AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:row]objectForKey:@"aufnahme"];
   self.AdminAktuellerLeser=[LesernamenPop titleOfSelectedItem];
   [self setPfadFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
   [self setKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
   NSLog(@"AufnahmenTable  shouldSelectRow: %d  AdminAktuelleAufnahme: %@, AdminProjektPfad: %@ AdminPlayPfad. %@" ,row,AdminAktuelleAufnahme, AdminProjektPfad, AdminPlayPfad);
  
  
  [AVAbspielplayer prepareAdminAufnahmeAnURL:[NSURL fileURLWithPath:AdminPlayPfad]];
   
   int posint =  [[NSNumber numberWithDouble:[AVAbspielplayer duration]] intValue];
   
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
   [AufnahmedauerFeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   

   
   [self startAdminPlayer:nil];
   [self setBackTaste:YES];
   Moviegeladen=YES;
   [self.StartPlayKnopf setEnabled:YES];
   
   [ExportierenTaste setEnabled:YES];
   [LoeschenTaste setEnabled:YES];
   [AdminMarkCheckbox setEnabled:YES];
   [AdminBewertungfeld setEnabled:YES];
 
   
   
   
 //     [self Aufnahmebereitstellen];
      
   
   //[self clearKommentarfelder];
   [PlayTaste setEnabled:YES];
   
   return YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	//NSLog(@"ProjektListe willDisplayCell Zeile: %d, numberOfSelectedRows:%d", row ,[tableView numberOfSelectedRows]);
//	NSString* tempTestNamenString=[[AufnahmenDicArray objectAtIndex:row]objectForKey:@"aufnahme"];
	if([[[AufnahmenDicArray objectAtIndex:row]objectForKey:@"usermark"]intValue])//user hat markiert
	{
	//[cell setTextColor:[NSColor redColor]];
	}
	else//alter Name
	{
	//[cell setTextColor:[NSColor blackColor]];
	}
	  if ([[tableColumn identifier] isEqualToString:@"adminmark"])
	  {
		  //[cell setImagePosition:NSImageRight];
		  //NSImage* MarkOnImg=[NSImage imageNamed:@"MarkOnImg.tif"];
		  if ([[[AufnahmenDicArray objectAtIndex:row]objectForKey:@"adminmark"]intValue])
		  {
			  [cell setImage:[NSImage imageNamed:@"MarkOnImg.tif"]];
		  }
		  else
		  {
			  [cell setImage:[NSImage imageNamed:@"MarkOffImg.tif"]];
		  }
	  }
}//willDisplayCell
  
  
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
//[self resetAdminPlayer]; 
	//if ([TestTable numberOfSelectedRows]==0)
	{
		//[OKKnopf setEnabled:NO];
		//[OKKnopf setKeyEquivalent:@""];
		//[HomeKnopf setKeyEquivalent:@"\r"];
	}
}

- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
{
	if ([[tableColumn identifier]isEqualToString:@"usermark"])//Klick in erate Kolonne
	{
		
		BOOL status=[[tableColumn dataCellForRow:[tableView selectedRow]]isEnabled];
		NSLog(@"UserMark: status: %d",status);
		if (status)
		{
		[[tableColumn headerCell]setTextColor:[NSColor greenColor]];
		[[tableColumn headerCell]setTitle:@"X"];
		}
		else
		{
		[[tableColumn headerCell]setTextColor:[NSColor redColor]];
		[[tableColumn headerCell]setTitle:@"OK"];
		}
		[[tableColumn dataCellForRow:[tableView selectedRow]]setEnabled:!status];
		[tableView reloadData];
	}
	
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
   NSLog(@"tabView didSelectTabViewItem");
   if ([[tabViewItem identifier]intValue]==1)//zurück zu 'alle Aufnahmen'
   {
      long zeile=[NamenListe selectedRow];
      NSLog(@"tabView didSelectTabViewItem zeile: %ld",zeile);
      AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:zeile]objectForKey:@"aufnahme"];

       [self setLeserFuerZeile:zeile];
      if ([NamenListe numberOfSelectedRows])
      {
         [PlayTaste setEnabled:YES];
      }
      

   }
   
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"tabView shouldSelectTabViewItem: %@",[[tabViewItem identifier]description]);
	//NSLog(@"shouldSelectTabViewItem: rowData: %@",[[AdminDaten rowData] description]);	
	
		//[self.PlayTaste setEnabled:YES];
		//[zurListeTaste setEnabled:NO];
		
	if ([[tabViewItem identifier]intValue]==1)//zurück zu 'alle Aufnahmen'
   {
      
      NSLog(@"zu 'alle Aufnahmen'");
      
      // Aufräumen
      if ([AufnahmenTable selectedRow]>=0)
      {
         [self Aufnahmezuruecklegen];
      }
      
      NSLog(@"nach Namen vor : AdminAktuelleAufnahme: %@",AdminAktuelleAufnahme);
      
      long Zeile=[AufnahmenTable selectedRow];
      if (Zeile>=0) // eine Zeile aktiviert
      {
         AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:Zeile]objectForKey:@"aufnahme"];
         
 //        AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:0]objectForKey:@"aufnahme"];

         
         NSLog(@"Tab nach Namen: Zeile: %ld AdminAktuelleAufnahme: %@",Zeile,AdminAktuelleAufnahme);
         
         // NSNumber* ZeilenNummer=[NSNumber numberWithDouble:Zeile];
         //NSMutableDictionary* tempZeilenDic=[NSMutableDictionary dictionaryWithObject:ZeilenNummer forKey:@"AufnahmenZeilenNummer"];
         //[tempZeilenDic setObject:@"AufnahmenTable" forKey:@"Quelle"];
         //NSNotificationCenter * nc;
         //nc=[NSNotificationCenter defaultCenter];
         //[nc postNotificationName:@"AdminChangeTab" object:tempZeilenDic];
         //NSLog(@"AdminTabNotifikationAktion:  AdminView  Quelle: %@",Quelle);
         [AdminMarkCheckbox setState:NO];
         [LehrerMarkCheckbox setState:NO];
         [ExportierenTaste setEnabled:NO];
         [LoeschenTaste setEnabled:NO];
         Textchanged=NO;
         
         [self clearKommentarfelder];
         
         NSString* Lesername=[LesernamenPop titleOfSelectedItem];
         int LesernamenIndex=[AdminDaten ZeileVonLeser:Lesername];
         //NSLog(@"Alle Namen: Lesername: %@, LesernamenIndex: %d",Lesername,LesernamenIndex);
         [NamenListe selectRowIndexes:[NSIndexSet indexSetWithIndex:LesernamenIndex]byExtendingSelection:NO];
         
       //  [[[AdminDaten dataForRow:LesernamenIndex]objectForKey:@"aufnahmen"]setIntValue:Zeile];
      //   [AufnahmenTable reloadData];
  /*
         long zeile = [NamenListe selectedRow];
         long col =[NamenListe columnWithIdentifier:@"aufnahmen"];
         NSLog(@"dataCell: %@",[[[NamenListe tableColumnWithIdentifier:@"aufnahmen"]dataCell]description]);
          //[[[NamenListe tableColumnWithIdentifier:@"aufnahmen"]dataCellForRow:1]selectItemAtIndex:zeile];
*/
         
         
        // [self setLeserFuerZeile:LesernamenIndex];
         
  //        [self setLeserFuerZeile:LesernamenIndex];
         
         if ([NamenListe numberOfSelectedRows])
         {
          //  [PlayTaste setEnabled:YES];
         }
      }
      else
      {
         // alles deaktivieren
         [AufnahmenTable deselectAll:nil];
         [NamenListe deselectAll:NULL];
         [PlayTaste setEnabled:NO];
      }
   }
	
	if ([[tabViewItem identifier]intValue]==2)//zu 'Nach Namen'
	{
		NSLog(@"Tab von 'Alle Aufnahmen' zu 'nach Namen'");
      
      // [[AdminDaten AufnahmeFilesFuerZeile:hitZeile]count]
      
      if ([NamenListe selectedRow]>=0)
      {
         [self Aufnahmezuruecklegen];
      }
      else
      {
         NSLog(@"Tab von 'Alle Aufnahmen' zu 'nach Namen': Kein Name ausgewaehlt");
      }

      NSLog(@"AufnahmenDicArray: %@",[AufnahmenDicArray description]);
		if ([NamenListe numberOfSelectedRows])//es ist eine zeile in der NamenListe selektiert
      {
         
         
         long  Zeile=[NamenListe selectedRow];//selektierte Zeile in der NamenListe
         //NSLog(@"nach Namen: Zeile: %d AdminAktuelleAufnahme: %@",Zeile,AdminAktuelleAufnahme);
         
         if (Zeile >=0)
         {
            if (AufnahmeDa)
            {
               
               NSNumber* ZeilenNumber=[NSNumber numberWithLong:Zeile];
               
               NSMutableDictionary* AdminZeilenDic=[NSMutableDictionary dictionaryWithObject:ZeilenNumber forKey:@"zeilennummer"];
               [AdminZeilenDic setObject:@"AdminView" forKey:@"Quelle"];
               
               NSString* Lesername=[[AdminDaten dataForRow:Zeile] objectForKey:@"namen"];
               //NSLog(@"Nach Namen: Lesername: %@",Lesername);
               [AdminZeilenDic setObject:[Lesername copy] forKey:@"leser"];
               
               
               [PlayTaste setEnabled:AufnahmeDa];
               
               // von notific
               
               [AdminMarkCheckbox setState:NO];
               [LehrerMarkCheckbox setState:NO];
               [ExportierenTaste setEnabled:NO];
               [LoeschenTaste setEnabled:NO];
               Textchanged=NO;
               
               [LesernamenPop selectItemWithTitle:Lesername];
               
            }
            else
            {
               NSAlert *NamenWarnung = [[NSAlert alloc] init];
               [NamenWarnung addButtonWithTitle:@"Mache ich"];
               //[RecorderWarnung addButtonWithTitle:@"Cancel"];
               [NamenWarnung setMessageText:@"Welchen Namen?"];
               [NamenWarnung setInformativeText:@"Ein Name muss  ausgewählt sein, um die Aufnahmen zu sehen."];
               [NamenWarnung setAlertStyle:NSWarningAlertStyle];

               return NO;
            }
            
         }
         [[self window]makeFirstResponder:AufnahmenTable];
         
      }
		else
		{
         NSAlert *NamenWarnung = [[NSAlert alloc] init];
         [NamenWarnung addButtonWithTitle:@"Mache ich"];
         //[RecorderWarnung addButtonWithTitle:@"Cancel"];
         [NamenWarnung setMessageText:@"Welchen Namen?"];
         [NamenWarnung setInformativeText:@"Ein Name muss  ausgewählt sein, um die Aufnahmen zu sehen."];
         [NamenWarnung setAlertStyle:NSWarningAlertStyle];
         
         [NamenWarnung runModal];
         

			[LesernamenPop selectItemAtIndex:0];
			[PlayTaste setEnabled:NO];
			[self clearKommentarfelder];
			return NO; // nicht umschalten
		}
	}
	return YES;
}


@end


//
//  rCleanKontroller.m
//  RecPlayC
//
//  Created by sysadmin on 21.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "rAdminPlayer.h"

extern NSString* alle;
//extern NSString* name;
//extern NSString* titel;
//extern NSString* anzahl;
//extern NSString* auswahl;
//extern NSString* leser;
//extern NSString* anzleser;

enum
{
	NamenViewTag=1111,
	TitelViewTag=2222
};


@implementation rAdminPlayer(rCleanKontroller)

- (void)CleanOptionNotificationAktion:(NSNotification*)note 
{
	//Aufgerufen nach √Ñnderungen in den Pops des Cleanfensters
	//NSString* alle=@"alle";
	NSString* selektiertenamenzeile=@"selektiertenamenzeile";

	//NSLog(@"CleanNotifikationAktion note: %@",[note object]);
	NSDictionary* OptionDic=[note userInfo];
	
	//Pop AnzahlNamen
	NSNumber* AnzahlNamenNummer=[OptionDic objectForKey:@"AnzahlNamen"];
	if (AnzahlNamenNummer)
	  {
		NSLog(@"CleanNotifikationAktion: AnzahlNamen: %d",[AnzahlNamenNummer intValue]);
	  }
	
	//Pop AnzahlTitel
	NSNumber* AnzahlTitelNummer=[OptionDic objectForKey:@"AnzahlTitel"];
	if (AnzahlTitelNummer)
	  {
		NSLog(@"CleanNotifikationAktion: AnzahlTitel: %d",[AnzahlTitelNummer intValue]);
	  }
	
	//Radio NamenBehaltenOption
	NSNumber* NamenBehaltenNummer=[OptionDic objectForKey:@"NamenBehalten"];
	if (NamenBehaltenNummer)
	  {
		NSLog(@"CleanNotifikationAktion: NamenBehalten: %d",[NamenBehaltenNummer intValue]);
	  }

	//Radio TitelBehaltenOption
	NSNumber* TitelBehaltenNummer=[OptionDic objectForKey:@"TitelBehalten"];
	if (TitelBehaltenNummer)
	  {
		NSLog(@"CleanNotifikationAktion: TitelBehalten: %d",[TitelBehaltenNummer intValue]);
	  }

	NSNumber* nurTitelZuNamenOptionNummer=[OptionDic objectForKey:@"nurTitelZuNamenOption"];
	if (nurTitelZuNamenOptionNummer)
	{
		//NSLog(@"CleanNotifikationAktion: nurTitelZuNamenOption: %d",[nurTitelZuNamenOptionNummer intValue]);
		nurTitelZuNamenOption=[nurTitelZuNamenOptionNummer intValue];
		//[CleanFenster clearTitelListe:NULL];
		if(nurTitelZuNamenOption>0)
		  {
			NSDictionary* TempNamenDic=[OptionDic objectForKey:selektiertenamenzeile];
			//NSLog(@"**  nurTitelZuNamenOption: TempNamenDic: %@",[TempNamenDic description]);
			if([TempNamenDic objectForKey:@"name"])
			  {
				
				NSString* tempname=[TempNamenDic objectForKey:@"name"];
				//NSLog(@"**  nurTitelZuNamenOption: tempname: %@",[tempname description]);
				
				[self setCleanTitelVonLeser:tempname];
			  }
		  }
	}
	//Alle Titel einsetzen
	NSNumber* alleTitelEinsetzenNummer=[OptionDic objectForKey:@"setalletitel"];
	if (alleTitelEinsetzenNummer)
	{
		NSLog(@"CleanNotifikationAktion: alleTitelEinsetzenNummer: %d",[alleTitelEinsetzenNummer intValue]);
		if ([alleTitelEinsetzenNummer intValue])
		{
			[self setAlleTitel];
		}
		
	}
	
	
}
		
- (void)CleanViewNotificationAktion:(NSNotification*)note 
{
	//Aufgerufen nach √Ñnderungen in den Views des Cleanfensters
	//NSLog(@"												CleanViewNotifikationAktion note: %@",[note object]);
	NSDictionary* OptionDic=[note userInfo];
	//NSNumber* ViewZeilenNumber=[OptionDic objectForKey:@"ZeilenNummer"];
	//int ViewZeilennummer=[ViewZeilenNumber intValue];
	//Pop AnzahlNamen
	NSNumber* ViewTagNumber=[OptionDic objectForKey:@"Quelle"];
	if (ViewTagNumber)
	  {
		switch([ViewTagNumber intValue])
		  {
			case NamenViewTag:
			{
				NSString* tempName=[OptionDic objectForKey:@"name"];//aktueller Name
				int NamenWeg=[[OptionDic objectForKey:@"namenweg"]intValue];//sollen die Titel zum Namen entfernt weden?
				NSMutableArray* CleanTitelDicArray=[[NSMutableArray alloc]initWithCapacity:0];
				//NSLog(@"\n\n-----------------------------CleanViewNotifikationAktion: CleanTitelDicArray: \n%@\n",[CleanTitelDicArray description]);
						//Array mit schon vorhandenen TitelDics in Clean
				NSMutableArray* neueTitelArray=[[NSMutableArray alloc]initWithCapacity:0]; //Kontrollarray nur mit Titeln
				//NSLog(@"CleanTitelDicArray von: %@: \n%@\n",tempName, [CleanTitelDicArray description]);
				NSMutableArray* TitelMitAnzahlArray=[[NSMutableArray alloc]initWithCapacity:0];
				
				[TitelMitAnzahlArray addObjectsFromArray:[self TitelMitAnzahlArrayVon:tempName]];//Titel mit Anzahl von tempName
				//NSLog(@"*TitelMitAnzahlArrayVon: %@   %@",tempName,[TitelMitAnzahlArray description]);
				
				if (nurTitelZuNamenOption)
				{
					//NSLog(@"nurTitelZuNamenOption");
					//[CleanFenster clearTitelListe:NULL];
					[CleanFenster TitelListeLeeren];

					
				}
				else
				  {
					//NSLog(@"nicht TitelZuNamenOption");
					if (NamenWeg>0)//Die Titel von tempName sollen entfernt werden
					  {
						  //NSLog(@"NamenWeg>0");
						[CleanTitelDicArray addObjectsFromArray:[CleanFenster TitelArray]];//vorhandene Titel mit Anzahlen
						NSEnumerator* TitelDicEnum=[TitelMitAnzahlArray objectEnumerator];
						id einTitel;
						int index=0;
						while(einTitel=[TitelDicEnum nextObject])		//neue Titel einf√ºllen
						  {
							[neueTitelArray insertObject:[einTitel objectForKey:@"titel"] atIndex:[neueTitelArray count]];
							index++;
						  }
						NSEnumerator* CleanTitelDicEnum=[CleanTitelDicArray objectEnumerator];	//Array mit Dics  aus Clean
						id eineCleanTitelDicZeile;
						while (eineCleanTitelDicZeile=[CleanTitelDicEnum nextObject])//Abfrage, ob neue Title schon in Cleantitel sind
						  {
							  int gefunden=0;//Abfrage Titel in TitelMitAnzahlArray ?
							  
							  //int neueAnzahl=[[eineZeile objectForKey:anzahl]intValue];
							  //NSLog(@"eineZeile: %@ anzahl: %d",[eineZeile description],n);
							  NSString* tempTitel=[eineCleanTitelDicZeile objectForKey:@"titel"]; //Titel aus Clean
							//NSLog(@"tempTitel: %@\n",[tempTitel description]);
							  
							  
							  if ([neueTitelArray containsObject:tempTitel])
								{
								  //NSLog(@"tempTitel ist schon in neueTitelArray: tempTitel: %@\n",[tempTitel description]);
								  int TitelWegAnzahl=0;
								  
								  NSEnumerator*neueTitelEnum=[TitelMitAnzahlArray objectEnumerator];
								  id eineTitelZeile;
								  double wegTitelIndex=-1;
								  BOOL NameSchonDa=NO;
								  while ((eineTitelZeile=[neueTitelEnum nextObject])&&!gefunden)
									{
									  //NSLog(@"eineTitelZeile: %@  ",[eineTitelZeile description]);
									  if ([[eineTitelZeile objectForKey:@"titel"]isEqualToString:tempTitel])//Zeile in titelDic mit diesem Titel
										{
											if ([[eineCleanTitelDicZeile objectForKey:@"leser"]containsObject:tempName])
											  {
												//NSLog(@"Name schon in Liste 'leser': %@",tempName);
												wegTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
												
												TitelWegAnzahl=[[eineTitelZeile objectForKey:@"anzahl"]intValue];
												NameSchonDa=YES;
												gefunden=1;
											  }
											else
											  {
												//für diesen Titel hat tempLeser keinen Eintrag
												//NSLog(@"Name noch nicht da: %@",tempName);
											  }
										}
									}//while
								  if (NameSchonDa)//Einträge l√∂schen
									{
										
										if (wegTitelIndex>=0)
										  {
											[TitelMitAnzahlArray removeObjectAtIndex:wegTitelIndex];
											[neueTitelArray removeObject:tempTitel];
										  }
									}
								  
								  //NSLog(@"gefunden: %d   neueAnzahl: %d",gefunden,neueAnzahl);//Anzahl Aufnahmen zum titel des neuen Lesers
								  if (gefunden==1)
									{
									  
									  int alteAnzahl=[[eineCleanTitelDicZeile objectForKey:@"anzahl"]intValue];//Anzahl Aufnahmen zum titel in Clean
									  
									  //NSLog(@"alteAnzahl, %d  neueAnzahl: %d",alteAnzahl,neueAnzahl);
									  NSNumber* neueAnzahlNumber=[NSNumber numberWithInt:alteAnzahl-TitelWegAnzahl];
									  [eineCleanTitelDicZeile setObject:neueAnzahlNumber forKey:@"anzahl"];
									  //NSLog(@"eineCleanTitelDicZeile neu: %@",[eineCleanTitelDicZeile description]);
									  
									  //neuen namen aus Liste 'leser' entfernen
									  NSMutableArray* tempArray=[[eineCleanTitelDicZeile objectForKey:@"leser"]mutableCopy];
									  if (tempArray)
										{
										  //NSLog(@"tempArray: %@",[tempArray description]);
										  [tempArray removeObject:tempName];
										  //NSLog(@"tempArray neu: %@",[tempArray description]);
										}
									  [eineCleanTitelDicZeile setObject:tempArray forKey:@"leser"];
									  NSNumber* neueAnzahlLeserNumber=[NSNumber numberWithDouble:[tempArray count]];
									  [eineCleanTitelDicZeile setObject:neueAnzahlLeserNumber forKey:@"anzleser"];
									  
									  //NSLog(@"----- eineCleanTitelDicZeile erweitert: %@",[eineCleanTitelDicZeile description]);
									}//gefunden
								  
								}//if containsObject
						  }//while (eineCleanTitelDicZeile
						//NSLog(@"while (eineCleanTitelDicZeile) fertig");
						BOOL nochZeilenMitNull=YES;
						long schleifenindex=[CleanTitelDicArray count];
						while (nochZeilenMitNull&&(schleifenindex>=0))
						  {
							//NSLog(@"Anzahl: %d  CleanTitelDicArray: %@  schleifenindex: %d",[CleanTitelDicArray count],[CleanTitelDicArray description],schleifenindex);
							NSEnumerator* CleanTitelWegEnum=[CleanTitelDicArray objectEnumerator];	
							//Array mit vebliebenen Dics  aus Clean
							id eineCleanTitelWegZeile;
							int ZeileMitNullGefunden=-1;
							int zeilenIndex=0;
							while ((eineCleanTitelWegZeile=[CleanTitelWegEnum nextObject])&&(ZeileMitNullGefunden<0))//Zeilen mit Anzahl=0 entfernen
							  {
								if ([[eineCleanTitelWegZeile objectForKey:@"anzahl"]intValue]==0)
								  {
									ZeileMitNullGefunden=zeilenIndex;
								  }
								zeilenIndex++;
							  }//while eineCleanTitelWegZeile
						
							if (ZeileMitNullGefunden<0)
							  {
								nochZeilenMitNull=NO;
							  }
							else
							  {//Es hat noch eine Zeile mit Anzahl 0
								[CleanTitelDicArray removeObjectAtIndex:ZeileMitNullGefunden];
							  }
								
							schleifenindex--;
						  }//while nochZeilenMitNull
						[CleanFenster TitelListeLeeren];
						[CleanFenster deselectNamenListe];
					  }//if (NamenWeg>0)
					else
					  {
						//Titel zu tempName zuf√ºgen
						[CleanTitelDicArray addObjectsFromArray:[CleanFenster TitelArray]];
						NSEnumerator* TitelDicEnum=[TitelMitAnzahlArray objectEnumerator];
						id einTitel;
						int index=0;
						while(einTitel=[TitelDicEnum nextObject])		//neue Titel einf√ºllen
						  {
							[neueTitelArray insertObject:[einTitel objectForKey:@"titel"] atIndex:[neueTitelArray count]];
							index++;
						  }
						//NSLog(@"neueTitelArray neu eingef√ºllt aus TitelMitAnzahlArray: \n%@\n",[neueTitelArray description]);
						//NSLog(@"CleanViewNotifikationAktion: NamenView Zeilennummer:%d Name:%@",ViewZeilennummer,tempName);
						
						NSEnumerator* CleanTitelDicEnum=[CleanTitelDicArray objectEnumerator];	//Array mit Dics  aus Clean
						id eineCleanTitelDicZeile;
						while (eineCleanTitelDicZeile=[CleanTitelDicEnum nextObject])//Abfrage, ob neue Title schon in Cleantitel sind
						  {
							  int gefunden=0;//Abfrage Titel in TitelMitAnzahlArray ?
							  
							  //int neueAnzahl=[[eineZeile objectForKey:anzahl]intValue];
							  //NSLog(@"eineZeile: %@ anzahl: %d",[eineZeile description],n);
							  NSString* tempTitel=[eineCleanTitelDicZeile objectForKey:@"titel"]; //Titel aus Clean
																							   //NSLog(@"tempTitel: %@\n",[tempTitel description]);
							  
							  
							  if ([neueTitelArray containsObject:tempTitel])
								{
								  //NSLog(@"tempTitel ist schon in neueTitelArray: tempTitel: %@\n",[tempTitel description]);
								  int neueAnzahl=0;
								  
								  NSEnumerator*neueTitelEnum=[TitelMitAnzahlArray objectEnumerator];
								  id eineTitelZeile;
								  double neuerTitelIndex=-1;
								  BOOL NameSchonDa=NO;
								  while ((eineTitelZeile=[neueTitelEnum nextObject])&&!gefunden)
									{
									  //NSLog(@"eineTitelZeile: %@  ",[eineTitelZeile description]);
									  if ([[eineTitelZeile objectForKey:@"titel"]isEqualToString:tempTitel])//Zeile in titelDic mit diesem Titel
										{
											if ([[eineCleanTitelDicZeile objectForKey:@"leser"]containsObject:tempName])
											  {
												//NSLog(@"Name schon da: %@",tempName);
												neuerTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
												NameSchonDa=YES;
											  }
											else
											  {
												//NSLog(@"Name noch nicht da: %@",tempName);
												neueAnzahl=[[eineTitelZeile objectForKey:@"anzahl"]intValue];
												neuerTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
												gefunden=1;
											  }
										}
									}//while
								  if (NameSchonDa)//Einträge l√∂schen
									{
										
										
										[TitelMitAnzahlArray removeObjectAtIndex:neuerTitelIndex];
										[neueTitelArray removeObject:tempTitel];
									}
								  
								  //NSLog(@"gefunden: %d   neueAnzahl: %d",gefunden,neueAnzahl);//Anzahl Aufnahmen zum titel des neuen Lesers
								  if (gefunden==1)
									{
									  
									  int alteAnzahl=[[eineCleanTitelDicZeile objectForKey:@"anzahl"]intValue];//Anzahl Aufnahmen zum titel in Clean
									  
									  //NSLog(@"alteAnzahl, %d  neueAnzahl: %d",alteAnzahl,neueAnzahl);
									  NSNumber* neueAnzahlNumber=[NSNumber numberWithInt:neueAnzahl+alteAnzahl];
									  [eineCleanTitelDicZeile setObject:neueAnzahlNumber forKey:@"anzahl"];
									  //NSLog(@"eineCleanTitelDicZeile neu: %@",[eineCleanTitelDicZeile description]);
									  
									  //neuen namen in Liste 'leser'
									  NSMutableArray* tempArray=[[eineCleanTitelDicZeile objectForKey:@"leser"]mutableCopy];
									  if (tempArray)
										{
										  //NSLog(@"tempArray: %@",[tempArray description]);
										  [tempArray addObject:tempName];
										  //NSLog(@"tempArray neu: %@",[tempArray description]);
										}
									  [eineCleanTitelDicZeile setObject:tempArray forKey:@"leser"];
									  NSNumber* neueAnzahlLeserNumber=[NSNumber numberWithDouble:[tempArray count]];
									  [eineCleanTitelDicZeile setObject:neueAnzahlLeserNumber forKey:@"anzleser"];
									  
									  //NSLog(@"----- eineCleanTitelDicZeile erweitert: %@",[eineCleanTitelDicZeile description]);
									  if (neuerTitelIndex>=0)
										{
										  [TitelMitAnzahlArray removeObjectAtIndex:neuerTitelIndex];
										  [neueTitelArray removeObject:tempTitel];
										}
									}//gefunden
								  
								  
								}//if containsObject
						  }//while tempEnum
		
					  }//if ! NamenWeg
					
				  }//NOT if nurTitelZuNamen
				
				if	([TitelMitAnzahlArray count]&&(NamenWeg==0)) //es hat noch Titel in TitelMitAnzahlArray
					{
					//NSLog(@"Es hat noch %d  Titel in TitelMitAnzahlArray",[TitelMitAnzahlArray count]);
					NSEnumerator* nochTitelEnum=[TitelMitAnzahlArray objectEnumerator];//Neue Titel in CleanTitelDicArray einsetzen
						id einNeuerTitel;	
						while (einNeuerTitel=[nochTitelEnum nextObject])
						{
							NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:[einNeuerTitel objectForKey:@"titel"]
																							forKey:@"titel"];
							//NSNumber* tempNumber=[einNeuerTitel objectForKey:anzahl];
							[tempDic setObject:[einNeuerTitel objectForKey:@"anzahl"]
										forKey:@"anzahl"];
							//NSArray* tempNamenArray=[NSArray arrayWithObjects:tempName,nil];
							[tempDic setObject:[NSArray arrayWithObjects:tempName,nil]
										forKey:@"leser"];
							[tempDic setObject:[NSNumber numberWithInt:0]
										forKey:@"auswahl"];
							[tempDic setObject:[NSNumber numberWithInt:1]
										forKey:@"anzleser"];

							//NSLog(@"CleanViewNotifikationAktion: tempDic für neuen Titel: %@",[tempDic description]);
							[CleanTitelDicArray insertObject:tempDic 
													 atIndex:[CleanTitelDicArray count]];
							
						}
					
							//NSLog(@"CleanViewNotifikationAktion: 4");
						
						
					}
							
				
				if([CleanTitelDicArray count])
				  {
					//NSLog(@"CleanTitelDicArray neu: %@",[CleanTitelDicArray description]);
					[CleanFenster setTitelArray:CleanTitelDicArray];
				  }//if
				else
				  {
					NSLog(@"CleanTitelDicArray null: %@",[CleanTitelDicArray description]);
					[CleanFenster deselectNamenListe];
									  }
				//[CleanFenster deselectNamenListe];

				
			}break;//NamenViewTag
				
			case TitelViewTag:
			  {
				  //NSLog(@"CleanViewNotifikationAktion: TitelView Zeilennummer:%d",ViewZeilennummer);
				  
			  }break;//TitelViewTag
				
				
		  }//switch tag
	  }
}

- (void)setCleanTitelVonLeser:(NSString*)derLeser
{
	//[CleanFenster TitelListeLeeren];
	NSMutableArray* CleanTitelDicArray=[[NSMutableArray alloc]initWithCapacity:0];

	NSArray* TitelMitAnzahlArray =[NSArray arrayWithArray:[self TitelMitAnzahlArrayVon:derLeser]];
	if	([TitelMitAnzahlArray count]) //es hat noch Titel in TitelMitAnzahlArray
	{
		//NSLog(@"************setCleanTitelVonLeser: %@ *******Es hat noch %d  Titel in TitelMitAnzahlArray",derLeser, [TitelMitAnzahlArray count]);
		NSEnumerator* TitelEnum=[TitelMitAnzahlArray objectEnumerator];//Neue Titel in CleanTitelDicArray einsetzen
			id einNeuerTitel;	
			while (einNeuerTitel=[TitelEnum nextObject])
			{
				NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:[einNeuerTitel objectForKey:@"titel"]
																				forKey:@"titel"];
				//NSNumber* tempNumber=[einNeuerTitel objectForKey:anzahl];
				[tempDic setObject:[einNeuerTitel objectForKey:@"anzahl"]
							forKey:@"anzahl"];
				//NSArray* tempNamenArray=[NSArray arrayWithObjects:derLeser,nil];
				[tempDic setObject:[NSArray arrayWithObjects:derLeser,nil]
							forKey:@"leser"];
				[tempDic setObject:[NSNumber numberWithInt:0]
							forKey:@"auswahl"];
				[tempDic setObject:[NSNumber numberWithInt:1]
							forKey:@"anzleser"];
				
				//NSLog(@"CleanViewNotifikationAktion: tempDic für neuen Titel: %@",[tempDic description]);
				[CleanTitelDicArray insertObject:tempDic 
										 atIndex:[CleanTitelDicArray count]];
				
			}
			
			//NSLog(@"CleanViewNotifikationAktion: 4");
			
			if([CleanTitelDicArray count])
			{
				//NSLog(@"CleanTitelDicArray neu: %@",[CleanTitelDicArray description]);
				[CleanFenster setTitelArray:CleanTitelDicArray];
			}//if
			
	}	
}

- (void)setAlleTitel
{
				NSArray* tempNamenArray=[CleanFenster NamenArray];//Namen der Leser
				[CleanFenster TitelListeLeeren];
				//NSLog(@"Clean tempNamenArray: %@",[tempNamenArray description]);
				NSEnumerator* NamenResetEnum=[tempNamenArray objectEnumerator];
				id einName;
				while (einName=[NamenResetEnum nextObject])
				  {
					//if ([[einName objectForKey:@"auswahl"]intValue])//Name ist angeklickt, also einsetzen
					  {
						  //NSLog(@"Clean NamenResetEnum: einName objectForKey:@"name" : %@",[[einName objectForKey:name] description]);
						  NSString* tempName=[einName objectForKey:@"name"];
						  //[self setCleanTitelVonLeser:[einName objectForKey:@"name"]];
						  NSMutableArray* CleanTitelDicArray=[[NSMutableArray alloc]initWithCapacity:0];
//						  NSLog(@"\n\n-----------------------------Clean");//leerer Array für schon vorhandenen TitelDics in Clean
						  NSMutableArray* neueTitelArray=[[NSMutableArray alloc]initWithCapacity:0]; //Kontrollarray nur mit Titeln
						  NSMutableArray* TitelMitAnzahlArray=[[NSMutableArray alloc]initWithCapacity:0];
						  //Array mit den Aufnahmen in der Lesebox für den Leser tempName
						  [TitelMitAnzahlArray addObjectsFromArray:[self TitelMitAnzahlArrayVon:tempName]];//Titel mit Anzahl von tempName
							{
								//Titel zu tempName zuf√ºgen
								[CleanTitelDicArray addObjectsFromArray:[CleanFenster TitelArray]];
								NSEnumerator* TitelDicEnum=[TitelMitAnzahlArray objectEnumerator];
								id einTitel;
								int index=0;
								while(einTitel=[TitelDicEnum nextObject])		//in neueTitelArray neue Titel(nur String) einf√ºllen
								  {
									[neueTitelArray insertObject:[einTitel objectForKey:@"titel"] atIndex:[neueTitelArray count]];
									index++;
								  }
								//NSLog(@"neueTitelArray neu eingef√ºllt aus TitelMitAnzahlArray: \n%@\n",[neueTitelArray description]);
								
								
								NSEnumerator* CleanTitelDicEnum=[CleanTitelDicArray objectEnumerator];	//Array mit Dics  aus Clean
								id eineCleanTitelDicZeile;
								while (eineCleanTitelDicZeile=[CleanTitelDicEnum nextObject])//Abfrage, ob neue Title schon in Cleantitel sind
								  {
									  int gefunden=0;//Abfrage Titel in TitelMitAnzahlArray ?
									  
									  NSString* tempTitel=[eineCleanTitelDicZeile objectForKey:@"titel"]; //Titel aus Clean
																									   //NSLog(@"tempTitel: %@\n",[tempTitel description]);
									  
									  if ([neueTitelArray containsObject:tempTitel])//tempTitel ist schon in neueTitelArray
										{
											//NSLog(@"tempTitel ist schon in neueTitelArray: tempTitel: %@\n",[tempTitel description]);
											int neueAnzahl=0;
											
											NSEnumerator*neueTitelEnum=[TitelMitAnzahlArray objectEnumerator];
											id eineTitelZeile;
											double neuerTitelIndex=-1;
											BOOL NameSchonDa=NO;
											while ((eineTitelZeile=[neueTitelEnum nextObject])&&!gefunden)
											  {
												//NSLog(@"eineTitelZeile: %@  ",[eineTitelZeile description]);
												if ([[eineTitelZeile objectForKey:@"titel"]isEqualToString:tempTitel])//Zeile in titelDic mit diesem Titel
												  {
													  if ([[eineCleanTitelDicZeile objectForKey:@"leser"]containsObject:tempName])
														{
														  //NSLog(@"Name schon da: %@",tempName);
														  neuerTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
														  NameSchonDa=YES;
														}
													  else
														{
														  //NSLog(@"Name noch nicht da: %@",tempName);
														  neueAnzahl=[[eineTitelZeile objectForKey:@"anzahl"]intValue];
														  neuerTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
														  gefunden=1;
														}
												  }
											  }//while
											if (NameSchonDa)//Einträge l√∂schen
											  {
												  
												  
												  [TitelMitAnzahlArray removeObjectAtIndex:neuerTitelIndex];
												  [neueTitelArray removeObject:tempTitel];
											  }
											
											//NSLog(@"gefunden: %d   neueAnzahl: %d",gefunden,neueAnzahl);//Anzahl Aufnahmen zum titel des neuen Lesers
											if (gefunden==1)
											  {
												
												int alteAnzahl=[[eineCleanTitelDicZeile objectForKey:@"anzahl"]intValue];//Anzahl Aufnahmen zum titel in Clean
												
												//NSLog(@"alteAnzahl, %d  neueAnzahl: %d",alteAnzahl,neueAnzahl);
												NSNumber* neueAnzahlNumber=[NSNumber numberWithInt:neueAnzahl+alteAnzahl];
												[eineCleanTitelDicZeile setObject:neueAnzahlNumber forKey:@"anzahl"];
												//NSLog(@"eineCleanTitelDicZeile neu: %@",[eineCleanTitelDicZeile description]);
												
												//neuen namen in Liste 'leser'
												NSMutableArray* tempArray=[[eineCleanTitelDicZeile objectForKey:@"leser"]mutableCopy];
												if (tempArray)
												  {
													//NSLog(@"tempArray: %@",[tempArray description]);
													[tempArray addObject:tempName];
													//NSLog(@"tempArray neu: %@",[tempArray description]);
												  }
												[eineCleanTitelDicZeile setObject:tempArray forKey:@"leser"];
												NSNumber* neueAnzahlLeserNumber=[NSNumber numberWithInteger:[tempArray count]];
												[eineCleanTitelDicZeile setObject:neueAnzahlLeserNumber forKey:@"anzleser"];
												
												//NSLog(@"----- eineCleanTitelDicZeile erweitert: %@",[eineCleanTitelDicZeile description]);
												if (neuerTitelIndex>=0)
												  {
													[TitelMitAnzahlArray removeObjectAtIndex:neuerTitelIndex];
													[neueTitelArray removeObject:tempTitel];
												  }
											  }//gefunden
											
											
										}//if containsObject
								  }//while tempEnum
									
								}	//Nicht Namenweg
									//NSLog(@"*TitelMitAnzahlArrayVon: %@   %@",tempName,[TitelMitAnzahlArray description]);
								if	([TitelMitAnzahlArray count]) //es hat noch Titel in TitelMitAnzahlArray
								  {
									//NSLog(@"Es hat noch %d  Titel in TitelMitAnzahlArray",[TitelMitAnzahlArray count]);
									NSEnumerator* nochTitelEnum=[TitelMitAnzahlArray objectEnumerator];//Neue Titel in CleanTitelDicArray einsetzen
									id einNeuerTitel;	
									while (einNeuerTitel=[nochTitelEnum nextObject])
									  {
										NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:[einNeuerTitel objectForKey:@"titel"]
																										forKey:@"titel"];
										//NSNumber* tempNumber=[einNeuerTitel objectForKey:anzahl];
										[tempDic setObject:[einNeuerTitel objectForKey:@"anzahl"]
													forKey:@"anzahl"];
										//NSArray* tempNamenArray=[NSArray arrayWithObjects:tempName,nil];
										[tempDic setObject:[NSArray arrayWithObjects:tempName,nil]
													forKey:@"leser"];
										[tempDic setObject:[NSNumber numberWithInt:0]
													forKey:@"auswahl"];
										[tempDic setObject:[NSNumber numberWithInt:1]
													forKey:@"anzleser"];
										
										//NSLog(@"CleanViewNotifikationAktion: tempDic für neuen Titel: %@",[tempDic description]);
										[CleanTitelDicArray insertObject:tempDic 
																 atIndex:[CleanTitelDicArray count]];
										
									  }
									
									//NSLog(@"CleanViewNotifikationAktion: 4");
									
									
								  }//if TitelArray count
								if([CleanTitelDicArray count])
								  {
									//NSLog(@"CleanTitelDicArray neu: %@",[CleanTitelDicArray description]);
									[CleanFenster setTitelArray:CleanTitelDicArray];
								  }//if
								
					  }//if
				  }//while
}

- (void)ClearNotificationAktion:(NSNotification*)note
{
	//Aufgerufen nach √Ñnderungen in den Pops des Cleanfensters
	//NSString* clear=@"clear";
	//NSString* selektiertenamenzeile=@"selektiertenamenzeile";
	
	//NSLog(@"CleanNotifikationAktion note: %@",[note object]);
	NSDictionary* OptionDic=[note userInfo];
	
	//Namen
	NSMutableArray* clearNamenArray=[OptionDic objectForKey:@"clearnamen"];
	if (clearNamenArray)
	{
		//NSLog(@"ClearNotificationAktion*** clearNamenArray: %@",[clearNamenArray description]);
		
	}

	NSMutableArray* clearTitelArray=[OptionDic objectForKey:@"cleartitel"];
	if (clearTitelArray)
	{
		//NSLog(@"ClearNotificationAktion*** clearTitelArray: %@",[clearTitelArray description]);
	}
	[self Clean:OptionDic];
	//NSNumber* AnzahlNamenNummer=[OptionDic objectForKey:@"AnzahlNamen"];
	
}


- (void)Clean:(NSDictionary*)derCleanDic
{
	int var=[[derCleanDic objectForKey:@"clearentfernen"]intValue];
	int behalten=[[derCleanDic objectForKey:@"clearbehalten"]intValue];
	int anzahlBehalten=[[derCleanDic objectForKey:@"clearanzahl"]intValue];
	if (anzahlBehalten<0)
	{
		//NSLog(@"Anzahl nochmals überlegen");
		return;
	}
	NSNumber* FileCreatorNumber=[NSNumber numberWithUnsignedLong:'RPDF'];//Creator der markierten Aufnahmen
	//NSLog(@"Clean:  Variante: %d  behalten: %d  anzahl: %d",var, behalten, anzahl);
	NSMutableArray* clearNamenArray=[derCleanDic objectForKey:@"clearnamen"];
	if (clearNamenArray)
	  {
		//NSLog(@"ClearNotificationAktion*** clearNamenArray: %@",[clearNamenArray description]);

		NSMutableArray* clearTitelArray=[derCleanDic objectForKey:@"cleartitel"];//angeklickte Titel
		if (clearTitelArray)
		  {
			NSLog(@"Clean*** clearTitelArray: %@",[clearTitelArray description]);
			
			NSMutableArray* DeleteTitelPfadArray=[[NSMutableArray alloc]initWithCapacity:0];//Array für zu l√∂schende Aufnahmen

			NSFileManager* Filemanager=[NSFileManager defaultManager];
			NSEnumerator* NamenEnum=[clearNamenArray objectEnumerator];
			id einName;
			while(einName=[NamenEnum nextObject])
			  {		
				
				NSString* tempNamenPfad=[AdminProjektPfad stringByAppendingPathComponent:einName];
				NSLog(@"Clean*** tempNamenPfad %@",tempNamenPfad);
				
				BOOL istOrdner;
				if (([Filemanager fileExistsAtPath:tempNamenPfad isDirectory:&istOrdner])&&istOrdner)
				  {
					NSLog(@"Clean*** Ordner am Pfad %@ ist da",tempNamenPfad);
					NSMutableArray* tempAufnahmenArray=[[Filemanager contentsOfDirectoryAtPath:tempNamenPfad error:NULL]mutableCopy];
					
					if ([tempAufnahmenArray count])
					  {
						if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
						  {
							[tempAufnahmenArray removeObjectAtIndex:0];
						  }
						if ([tempAufnahmenArray containsObject:@"Anmerkungen"]) // Ordner Kommentar entfernen
						  {
							[tempAufnahmenArray removeObject:@"Anmerkungen"];
						  }
						//NSLog(@"Clean*** tempAufnahmenArray: %@",[tempAufnahmenArray description]);
						//tempAufnahmenArray=(NSMutableArray*)[self sortNachNummer:tempAufnahmenArray];
						
						
						tempAufnahmenArray=[[self sortNachABC:tempAufnahmenArray]mutableCopy];
						//NSLog(@"Clean*** tempAufnahmenArray nach sort: %@",[tempAufnahmenArray description]);
						
						switch (behalten) //
						{//
							case 0://nur markierte behalten
							{
								NSEnumerator* AufnahmenEnum=[tempAufnahmenArray objectEnumerator];
								//NSMutableArray* tempDeleteTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
								//int anz=0;
								id eineAufnahme;
								while(eineAufnahme=[AufnahmenEnum nextObject])
								  {
									if ([clearTitelArray containsObject:[self AufnahmeTitelVon:eineAufnahme]])
									{
										NSString* tempLeserAufnahmePfad=[tempNamenPfad stringByAppendingPathComponent:eineAufnahme];
										if ([Filemanager fileExistsAtPath:tempLeserAufnahmePfad])
										{
											BOOL AdminMark=[self AufnahmeIstMarkiertAnPfad:tempLeserAufnahmePfad];
											if (AdminMark)
											{
												NSLog(@"Aufnahme %@ ist markiert",eineAufnahme);
											}
											else
											{
												NSLog(@"Aufnahme %@ ist nicht markiert",eineAufnahme);
												//[DeleteTitelArray addObject:eineAufnahme];
												[DeleteTitelPfadArray addObject:[tempNamenPfad stringByAppendingPathComponent:eineAufnahme]];
												
											}
											
											/*
											 NSMutableDictionary* AufnahmeAttribute=[[[Filemanager fileAttributesAtPath:tempLeserAufnahmePfad traverseLink:YES]mutableCopy]autorelease];
											 if (AufnahmeAttribute )
											 {
											 
											 if([AufnahmeAttribute fileHFSCreatorCode]==[FileCreatorNumber intValue])
											 {
											 //NSLog(@"Aufnahme %@ ist markiert",eineAufnahme);
											 }
											 else
											 {
											 //NSLog(@"Aufnahme %@ ist nicht markiert",eineAufnahme);
											 //[DeleteTitelArray addObject:eineAufnahme];
											 [DeleteTitelPfadArray addObject:[tempNamenPfad stringByAppendingPathComponent:eineAufnahme]];
											 }
											 
											 
											 }//if (AufnahmeAttribute )
											 */
										}//if tempLeserAufnahmePfad
									}//if in clearTitelArray
								  }//while AufnahmeEnum
							}break;
							case 1://alle bis auf anzahlBehalten löschen
							{
								NSArray* tempLeserTitelArray=[self TitelArrayVon:einName anProjektPfad:AdminProjektPfad];//Titel der Aufnahmen für den Leser
								NSEnumerator* LeserTitelEnum=[tempLeserTitelArray objectEnumerator];
								id einLeserTitel;
								while(einLeserTitel=[LeserTitelEnum nextObject])
								  {
									NSEnumerator* AufnahmenEnum=[tempAufnahmenArray objectEnumerator];
									NSMutableArray* tempDeleteTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
									id eineAufnahme;
									while(eineAufnahme=[AufnahmenEnum nextObject])
									  {
									  //NSLog(@"einLeserTitel: %@		  AufnahmeTitelVon:eineAufnahme: %@",einLeserTitel,[self AufnahmeTitelVon:eineAufnahme]);
										if ([clearTitelArray containsObject:[self AufnahmeTitelVon:eineAufnahme]])
										  {
											
											NSString* tempTitel=[self AufnahmeTitelVon:eineAufnahme];
											if ([einLeserTitel isEqualToString:tempTitel])
											  {
												NSString* tempLeserAufnahmePfad=[tempNamenPfad stringByAppendingPathComponent:eineAufnahme];
											  NSLog(@"tempLeserAufnahmePfad: %@",tempLeserAufnahmePfad);
											  
											  if ([Filemanager fileExistsAtPath:tempLeserAufnahmePfad])
												  {
												NSLog(@"tempLeserAufnahmePfad: File da");
													[tempDeleteTitelArray addObject:eineAufnahme ];
													
												  }//if tempLeserAufnahmePfad
											  }
										  }//if in clearTitelArray
									  }//while AufnahmenEnum
									
									NSLog(@"einLeserTitel: %@ * tempDeleteTitelArray: %@",einLeserTitel,[tempDeleteTitelArray description]);
									if ([tempDeleteTitelArray count])
									  {
										tempDeleteTitelArray=[[self sortNachNummer:tempDeleteTitelArray]mutableCopy];
										NSLog(@"			*** *** tempDeleteTitelArray nach sort: %@",[tempDeleteTitelArray description]);
									  }
									
									NSEnumerator* DeleteEnum=[tempDeleteTitelArray objectEnumerator];
									id eineDeleteAufnahme;
									int i=0;
									while(eineDeleteAufnahme=[DeleteEnum nextObject])
									  {
										if (i>=anzahlBehalten)//Anzahl zu behaltende Aufnahmen
										  {
											  //[DeleteTitelArray addObject:eineDeleteAufnahme];
											  [DeleteTitelPfadArray addObject:[tempNamenPfad stringByAppendingPathComponent:eineDeleteAufnahme]];

										  }
										i++;
									  }//while DeleteEnum
										
										
										
								  }//while LeserTitelEnum
								
								
							}break;//case 1
								
								
						}//switch beahlten
						
						
						
					  }//if ([tempTitelArray count])
					
				  }//if fileExists tempNamenPfad
				
			  }//while NamenEnum
			
			//NSLog(@"Clean***				*** DeleteTitelPfadArray: %@",[DeleteTitelPfadArray description]);
			if ([DeleteTitelPfadArray count])
			{
			switch (var)
			  {
				case 0://in den Papierkorb
				  {
					  NSLog(@"Clean in Papierkorb");
					  NSEnumerator* clearEnum=[DeleteTitelPfadArray objectEnumerator];
					  id einClearAufnahmePfad;
					  while (einClearAufnahmePfad=[clearEnum nextObject])
					  {
						  [self inPapierkorbMitPfad:einClearAufnahmePfad];
						  
					  }//while clearEnum
					  
					  //
				  }break;
					
				case 1://ins Magazin
				  {
					  NSLog(@"Clean ins Magazin");
					  NSEnumerator* magEnum=[DeleteTitelPfadArray objectEnumerator];
					  id einMagazinAufnahmePfad;
					  while (einMagazinAufnahmePfad=[magEnum nextObject])
						{
						  [self insMagazinMitPfad:einMagazinAufnahmePfad];
						}//while clearEnum
				  }break;
				case 2://ex und hopp
				  {
					  NSLog(@"Clean ex");
					  NSEnumerator* exEnum=[DeleteTitelPfadArray objectEnumerator];
					  id einExAufnahmePfad;
					  while (einExAufnahmePfad=[exEnum nextObject])
						{
						  [self exMitPfad:einExAufnahmePfad];
						}//while clearEnum
				  }break;
			  }//switch
				[self resetAdminPlayer];
				[self setAdminPlayer:AdminLeseboxPfad inProjekt:[AdminProjektPfad lastPathComponent]];
				
				//TitelArray mit angeklickten Namen neu aufsetzen
				NSArray* tempNamenArray=[CleanFenster NamenArray];//Namen der Leser
				[CleanFenster TitelListeLeeren];
				//NSLog(@"Clean tempNamenArray: %@",[tempNamenArray description]);
				NSEnumerator* NamenResetEnum=[tempNamenArray objectEnumerator];
				id einName;
				while (einName=[NamenResetEnum nextObject])
				  {
					if ([[einName objectForKey:@"auswahl"]intValue])//Name ist angeklickt, also einsetzen
					  {
						//NSLog(@"Clean NamenResetEnum: einName objectForKey:@"name" : %@",[[einName objectForKey:@"name"] description]);
						NSString* tempName=[einName objectForKey:@"name"];
						//[self setCleanTitelVonLeser:[einName objectForKey:@"name"]];
						NSMutableArray* CleanTitelDicArray=[[NSMutableArray alloc]initWithCapacity:0];
//						NSLog(@"\n\n-----------------------------Clean");//leerer Array für schon vorhandenen TitelDics in Clean
						NSMutableArray* neueTitelArray=[[NSMutableArray alloc]initWithCapacity:0]; //Kontrollarray nur mit Titeln
						NSMutableArray* TitelMitAnzahlArray=[[NSMutableArray alloc]initWithCapacity:0];
						//Array mit den Aufnahmen in der Lesebox für den Leser tempName
						[TitelMitAnzahlArray addObjectsFromArray:[self TitelMitAnzahlArrayVon:tempName]];//Titel mit Anzahl von tempName
						  {
							  //Titel zu tempName zuf√ºgen
							  [CleanTitelDicArray addObjectsFromArray:[CleanFenster TitelArray]];
							  NSEnumerator* TitelDicEnum=[TitelMitAnzahlArray objectEnumerator];
							  id einTitel;
							  int index=0;
							  while(einTitel=[TitelDicEnum nextObject])		//in neueTitelArray neue Titel(nur String) einf√ºllen
								{
								  [neueTitelArray insertObject:[einTitel objectForKey:@"titel"] atIndex:[neueTitelArray count]];
								  index++;
								}
							  //NSLog(@"neueTitelArray neu eingef√ºllt aus TitelMitAnzahlArray: \n%@\n",[neueTitelArray description]);
							  
							  
							  NSEnumerator* CleanTitelDicEnum=[CleanTitelDicArray objectEnumerator];	//Array mit Dics  aus Clean
							  id eineCleanTitelDicZeile;
							  while (eineCleanTitelDicZeile=[CleanTitelDicEnum nextObject])//Abfrage, ob neue Title schon in Cleantitel sind
								{
									int gefunden=0;//Abfrage Titel in TitelMitAnzahlArray ?
									
									NSString* tempTitel=[eineCleanTitelDicZeile objectForKey:@"titel"]; //Titel aus Clean
									//NSLog(@"tempTitel: %@\n",[tempTitel description]);
									
									if ([neueTitelArray containsObject:tempTitel])//tempTitel ist schon in neueTitelArray
									  {
										//NSLog(@"tempTitel ist schon in neueTitelArray: tempTitel: %@\n",[tempTitel description]);
										int neueAnzahl=0;
										
										NSEnumerator*neueTitelEnum=[TitelMitAnzahlArray objectEnumerator];
										id eineTitelZeile;
										double neuerTitelIndex=-1;
										BOOL NameSchonDa=NO;
										while ((eineTitelZeile=[neueTitelEnum nextObject])&&!gefunden)
										  {
											//NSLog(@"eineTitelZeile: %@  ",[eineTitelZeile description]);
											if ([[eineTitelZeile objectForKey:@"titel"]isEqualToString:tempTitel])//Zeile in titelDic mit diesem Titel
											  {
												  if ([[eineCleanTitelDicZeile objectForKey:@"leser"]containsObject:tempName])
													{
													  //NSLog(@"Name schon da: %@",tempName);
													  neuerTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
													  NameSchonDa=YES;
													}
												  else
													{
													  //NSLog(@"Name noch nicht da: %@",tempName);
													  neueAnzahl=[[eineTitelZeile objectForKey:@"clearanzahl"]intValue];
													  neuerTitelIndex=[TitelMitAnzahlArray indexOfObject:eineTitelZeile];
													  gefunden=1;
													}
											  }
										  }//while
										if (NameSchonDa)//Einträge l√∂schen
										  {
											  
											  
											  [TitelMitAnzahlArray removeObjectAtIndex:neuerTitelIndex];
											  [neueTitelArray removeObject:tempTitel];
										  }
										
										//NSLog(@"gefunden: %d   neueAnzahl: %d",gefunden,neueAnzahl);//Anzahl Aufnahmen zum titel des neuen Lesers
										if (gefunden==1)
										  {
											
											int alteAnzahl=[[eineCleanTitelDicZeile objectForKey:@"clearanzahl"]intValue];//Anzahl Aufnahmen zum titel in Clean
											
											//NSLog(@"alteAnzahl, %d  neueAnzahl: %d",alteAnzahl,neueAnzahl);
											NSNumber* neueAnzahlNumber=[NSNumber numberWithInt:neueAnzahl+alteAnzahl];
											[eineCleanTitelDicZeile setObject:neueAnzahlNumber forKey:@"clearanzahl"];
											//NSLog(@"eineCleanTitelDicZeile neu: %@",[eineCleanTitelDicZeile description]);
											
											//neuen namen in Liste 'leser'
											NSMutableArray* tempArray=[[eineCleanTitelDicZeile objectForKey:@"leser"]mutableCopy];
											if (tempArray)
											  {
												//NSLog(@"tempArray: %@",[tempArray description]);
												[tempArray addObject:tempName];
												//NSLog(@"tempArray neu: %@",[tempArray description]);
											  }
											[eineCleanTitelDicZeile setObject:tempArray forKey:@"leser"];
											NSNumber* neueAnzahlLeserNumber=[NSNumber numberWithDouble:[tempArray count]];
											[eineCleanTitelDicZeile setObject:neueAnzahlLeserNumber forKey:@"anzleser"];
											
											//NSLog(@"----- eineCleanTitelDicZeile erweitert: %@",[eineCleanTitelDicZeile description]);
											if (neuerTitelIndex>=0)
											  {
												[TitelMitAnzahlArray removeObjectAtIndex:neuerTitelIndex];
												[neueTitelArray removeObject:tempTitel];
											  }
										  }//gefunden
										
										
									  }//if containsObject
								}//while tempEnum
							  
						  }	//Nicht Namenweg
						//NSLog(@"*TitelMitAnzahlArrayVon: %@   %@",tempName,[TitelMitAnzahlArray description]);
						  if	([TitelMitAnzahlArray count]) //es hat noch Titel in TitelMitAnzahlArray
							{
							  //NSLog(@"Es hat noch %d  Titel in TitelMitAnzahlArray",[TitelMitAnzahlArray count]);
							  NSEnumerator* nochTitelEnum=[TitelMitAnzahlArray objectEnumerator];//Neue Titel in CleanTitelDicArray einsetzen
							  id einNeuerTitel;	
							  while (einNeuerTitel=[nochTitelEnum nextObject])
								{
								  NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:[einNeuerTitel objectForKey:@"titel"]
																								  forKey:@"titel"];
								  //NSNumber* tempNumber=[einNeuerTitel objectForKey:anzahl];
								  [tempDic setObject:[einNeuerTitel objectForKey:@"anzahl"]
											  forKey:@"anzahl"];
								  //NSArray* tempNamenArray=[NSArray arrayWithObjects:tempName,nil];
								  [tempDic setObject:[NSArray arrayWithObjects:tempName,nil]
											  forKey:@"leser"];
								  [tempDic setObject:[NSNumber numberWithInt:0]
											  forKey:@"auswahl"];
								  [tempDic setObject:[NSNumber numberWithInt:1]
											  forKey:@"anzleser"];
								  
								  //NSLog(@"CleanViewNotifikationAktion: tempDic für neuen Titel: %@",[tempDic description]);
								  [CleanTitelDicArray insertObject:tempDic 
														   atIndex:[CleanTitelDicArray count]];
								  
								}
							  
							  //NSLog(@"CleanViewNotifikationAktion: 4");
							  
							  
							}//if TitelArray count
						  if([CleanTitelDicArray count])
					  {
						//NSLog(@"CleanTitelDicArray neu: %@",[CleanTitelDicArray description]);
						[CleanFenster setTitelArray:CleanTitelDicArray];
					  }//if

					  }//Auswahl=1
					
				  }
			}
			//else
			//{
			//	NSLog(@"Nichts zu l√∂schen");
			//}
		  }//if (clearTitelArray)
	  }//if (clearNamenArray)
}

@end

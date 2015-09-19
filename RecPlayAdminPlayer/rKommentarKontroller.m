//
//  rKommentarKontroller.m
//  RecPlayC
//
//  Created by sysadmin on 21.05.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "rAdminPlayer.h"

enum
{ausEinemProjektOption= 0,
	ausAktivenProjektenOption,
	ausAllenProjektenOption
};

enum
{lastKommentarOption= 0,
	alleVonNameKommentarOption,
	alleVonTitelKommentarOption
};
enum
{alsTabelleFormatOption=0,
	alsAbsatzFormatOption
};

enum
{zweiAufnahmen=2,
	dreiAufnahmen,
	vierAufnahmen,
	sechsAufnahmen=6,
	alleAufnahmen=99
};

enum
{
	NamenViewTag=1111,
	TitelViewTag=2222
};

enum 
{
DatumReturn=2,
BewertungReturn,
NotenReturn,
UserMarkReturn,
AdminMarkReturn,
KommentarReturn
};

typedef NS_ENUM(NSInteger, A)
{
   Datum = 2,
   Bewertung,
   Noten,
   UserMark,
   AdminMark,
   Kommentar
};



extern NSString* alle;

@implementation rAdminPlayer(rKommentarKontroller)

- (NSString*)OptionA;
{
NSString* OptionString=[KommentarFenster PopAOption];
return OptionString;
}
- (NSString*)OptionB
{
NSString* OptionString=[KommentarFenster PopBOption];
return OptionString;
}

- (BOOL)nurMarkierte
{
return [KommentarFenster nurMarkierte];
}

- (BOOL)mitMarkierungAufnehmenOptionAnPfad:(NSString*)derAufnahmePfad
{
	BOOL AufnehmenOK=YES;
	BOOL nurMarkierteAufnehmenOK=[self nurMarkierte];
	BOOL AufnahmeIstMarkiertOK=[self AufnahmeIstMarkiertAnPfad:derAufnahmePfad];
	if (nurMarkierteAufnehmenOK &&!AufnahmeIstMarkiertOK)
	{
		AufnehmenOK=NO;
	}
	return AufnehmenOK;
}

- (NSView*)KommentarView
{
	return [KommentarFenster KommentarView];
	NSLog(@"AdminPlayer return Kommentar");
}

- (IBAction)showKommentar:(id)sender
{
	//NSString* alle=@"alle";
	//NSLog(@"AdminPlayer showKommentar: AdminProjektArray: %@",[AdminProjektArray description]);
	if (!KommentarFenster)
	  {
		KommentarFenster=[[rKommentar alloc]init];
	  }
	[KommentarFenster showWindow:self];
	[KommentarFenster setAnzahlPopMenu:AnzahlOption];
	if ([self.AdminAktuellerLeser length])
	  {
		AuswahlOption=alleVonNameKommentarOption;
		[KommentarFenster setAuswahlPop:alleVonNameKommentarOption];
		[KommentarFenster setPopAMenu:AdminProjektNamenArray erstesItem:@"alle" aktuell:self.AdminAktuellerLeser];
		NSArray* TitelArray=[self TitelArrayVon:self.AdminAktuellerLeser anProjektPfad:AdminProjektPfad];
		
		if ([AdminAktuelleAufnahme length])
		  {
			[KommentarFenster setPopBMenu:TitelArray erstesItem:@"alle" aktuell:[self AufnahmeTitelVon:AdminAktuelleAufnahme] mitPrompt:@"mit Titel:"];
		  }
	  }
	else
	  {
		AuswahlOption=lastKommentarOption;
		[KommentarFenster setAuswahlPop:lastKommentarOption];
	  }
	nurMarkierteOption=0;
	ProjektPfadOptionString=AdminProjektPfad;
	NSLog(@"AdminProjektArray: %@",[AdminProjektArray description]);
	NSArray* StartProjektArray=[AdminProjektArray valueForKey:@"projekt"];
	NSLog(@"StartProjektArray: %@",[StartProjektArray description]);

	[KommentarFenster setProjektMenu:StartProjektArray mitItem:[AdminProjektPfad lastPathComponent]];
	
	NSArray* startProjektPfadArray=[NSArray arrayWithObject:AdminProjektPfad];
	NSArray* startKommentarStringArray=[self createKommentarStringArrayWithProjektPfadArray:startProjektPfadArray];

	//NSString* startKommentarString=[self createKommentarStringInProjekt:AdminProjektPfad];
	
	NSMutableDictionary* KommentarStringDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	//[KommentarStringDic setObject:startKommentarString forKey:@"kommentarstring"];
	[KommentarStringDic setObject:[AdminProjektPfad lastPathComponent] forKey:@"projekt"];
	[KommentarStringDic setObject:AdminProjektPfad forKey:@"projektpfad"];
	NSArray* startKommentarArray=[NSArray arrayWithObject:KommentarStringDic];
	//NSLog(@"showKommentar KommentarStringDic: %@",[KommentarStringDic description]);
	
	//[KommentarFenster setKommentar:[self createKommentarStringInProjekt:AdminProjektPfad]];
	[KommentarFenster setKommentarMitKommentarDicArray:startKommentarStringArray];

}


- (void)KommentarDrucken
{
	//NSLog(@"\n****************									AdminPlayer KommentarDruckenMitKommentarDicArray");
	NSArray* tempProjektPfadArray=[self ProjektPfadArrayMitKommentarOptionen];
	NSLog(@"tempProjektPfadArray: %@",[tempProjektPfadArray description]);
	
	NSArray* tempKommentarDicArray=[self createDruckKommentarStringDicArrayWithProjektPfadArray:[tempProjektPfadArray valueForKey:@"projektpfad"]];
	
	NSLog(@"AdminPlayer KommentarDrucken nach create: Anzahl Dics: %lu",(unsigned long)[tempKommentarDicArray count]);
	
	[KommentarFenster KommentarDruckenMitProjektDicArray:tempKommentarDicArray];
	NSLog(@"AdminPlayer KommentarDrucken nach KommentarFenster KommentarDruckenMitProjektDicArray\n");
}


- (void)KommentarSichern
{
	NSLog(@"\n								AdminPlayer KommentarSichernMitKommentarDicArray");
	NSArray* tempProjektPfadArray=[self ProjektPfadArrayMitKommentarOptionen];
	NSLog(@"tempProjektPfadArray: %@",[tempProjektPfadArray description]);
	
	NSArray* tempKommentarDicArray=[self createDruckKommentarStringDicArrayWithProjektPfadArray:[tempProjektPfadArray valueForKey:@"projektpfad"]];
	
	NSLog(@"AdminPlayer KommentarSichern nach create: Anzahl Dics: %d",[tempKommentarDicArray count]);	
	
	[KommentarFenster KommentarSichernMitProjektDicArray:tempKommentarDicArray];
	NSLog(@"AdminPlayer KommentarDrucken nach KommentarFenster KommentarSichernMitProjektDicArray\n");
}


/*
- (void)KommentarDruckenVonProjekt:(NSString*)dasProjekt
{
	//NSLog(@"AdminPlayer KommentarDrucken");
	[KommentarFenster KommentarDruckenVonProjekt:dasProjekt];
}

- (void)SaveKommentarVonProjekt:(NSString*)dasProjekt
{
NSLog(@"AdminPlayer SaveKommentar");
[KommentarFenster SaveKommentarVonProjekt:dasProjekt];
}


*/

- (NSArray*)createKommentarStringArrayWithProjektPfadArray:(NSArray*)derProjektPfadArray
{
	NSLog(@"\n\n*********\n			                                     Beginn createKommentarStringArrayWithProjektPfadArray\n\n");
	NSLog(@"\nderProjektPfadArray: %@",[derProjektPfadArray description]);
	NSLog(@"AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,OptionAString,OptionBString);
	NSLog(@"   [self OptionA]: %@  [self OptionB]: %@  AnzahlDics: %d",[self OptionA],[self OptionB],[derProjektPfadArray count]);
	//OptionAString=[[KommentarFenster PopAOption]retain];
	//OptionBString=[[KommentarFenster PopBOption]retain];
	//NSLog(@"AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,OptionAString,OptionBString);
	NSArray* tempProjektPfadArray=[NSArray arrayWithArray:derProjektPfadArray];
	
	NSString* name=NSLocalizedString(@"Name:",@"Name:");
	NSString* datum=NSLocalizedString(@"Date:",@"Datum:");
	NSString* titel=NSLocalizedString(@"Title:",@"Titel:");
	NSString* bewertung=NSLocalizedString(@"Assessment:",@"Bewertung:");
	
	NSString* anmerkungen=NSLocalizedString(@"Comments",@"Anmerkungen:");
	NSString* note=NSLocalizedString(@"Mark:",@"Note:");
	NSString* tabSeparator=@"\t";
	NSString* crSeparator=@"\r";
	//NSString* alle=NSLocalizedString(@"All",@"alle");

	NSArray* TabellenkopfArray=[NSArray arrayWithObjects:name,titel,datum,bewertung,note,anmerkungen,nil];
//	NSArray* TabellenkopfArray=[NSArray arrayWithObjects:name,titel,datum,note,anmerkungen,nil];
	
	NSMutableArray* tempKommentarStringArray=[[NSMutableArray alloc]initWithCapacity:0];


	NSEnumerator* ProjektPfadEnum=[tempProjektPfadArray objectEnumerator];
	id einProjektPfad;
	while (einProjektPfad=[ProjektPfadEnum nextObject])
	{
		//NSLog(@"while einProjektPfad:        einProjektPfad: %@",einProjektPfad);
		//KommentarString enthält den Kopfstring und die Kommentare für einProjektPfad
		NSMutableString* KommentarString=[NSMutableString stringWithCapacity:0];
		
		//tempKommentarArray enthält die Kommentare entsprechend den Einstellungen im Kommentarfenster
		//Er wird nachher zusammen mit dem Kopfstring zu KommentarString zusammengesetzt
		NSMutableArray* tempKommentarArray=[[NSMutableArray alloc]initWithCapacity:0];
		NSLog(@"createKommentarStringArrayWithProjekt AuswahlOption: %d ProjektPfad: %@",AuswahlOption,einProjektPfad);
		
		switch (AuswahlOption) // AusProjekt ( ), aus allen aktiven Projekten, aus allen Projekten
		{
			case ausEinemProjektOption:
			{
				NSLog(@"switch (AuswahlOption): ausEinemProjektOption: einProjektPfad: %@",einProjektPfad);
				tempKommentarArray=(NSMutableArray*)[self lastKommentarVonAllenAnProjektPfad:einProjektPfad]; // OK
			}break;
				
			case ausAktivenProjektenOption:
			{
				NSLog(@"switch (AuswahlOption): ausAktivenProjektenOption");
				NSString* tempLeser=[KommentarFenster PopAOption];
				//NSLog(@"alleVonNameKommentarOption tempLeser: %@",[self OptionA]);
				
				if ([[self OptionA] isEqualToString:@"alle"])
				{
					tempKommentarArray=(NSMutableArray*)[self alleKommentareNachNamenAnProjektPfad:einProjektPfad 
																						 bisAnzahl:AnzahlOption];
					NSLog(@"Projekt: %@	tempKommentarArray: %@",[einProjektPfad lastPathComponent], [tempKommentarArray description]);
					NSLog(@"\n\n\n");																	 
				}
				else
				{
					if ( [[self OptionB] isEqualToString:@"alle"])
					{
						NSLog(@"\n++++++ alleVonNameKommentarOption OptionAString: %@       OptionBString= alle ",[self OptionA]);
						tempKommentarArray=(NSMutableArray*)[self alleKommentareVonLeser :[self OptionA] 
												   anProjektPfad:einProjektPfad
													   bisAnzahl:AnzahlOption];
						//NSLog(@"++	tempKommentarArray:  \n%@  ",[tempKommentarArray description]);	
						
					}
					else //Titel ausgewählt
					{
						NSLog(@"alleVonNameKommentarOption OptionAString: %@ OptionBString:%@ ",[self OptionA],[self OptionB]);
						//NSLog(@"tempKommentarArray: Anz: %d %@",[tempKommentarArray count],[tempKommentarArray description]);
						tempKommentarArray=[[self KommentareVonLeser:[self OptionA]
															mitTitel:[self OptionB]
															 maximal:AnzahlOption
													   anProjektPfad:einProjektPfad]mutableCopy];
						
						
						//NSLog(@"createKomm.String\ntempKommentarArray: Anz: %d %@",[tempKommentarArray count],[tempKommentarArray description]);
						
						
					}
					
				}
				
			}break;
				
			case ausAllenProjektenOption:
			{
				NSLog(@"switch (AuswahlOption): ausAllenProjektenOption");
				//NSLog(@" OptionAString %@	OptionBString: %@",[self OptionA],[self OptionB]);
				if ([[self OptionA] isEqualToString:@"alle"])//Alle Titel
				{
					tempKommentarArray=(NSMutableArray*)[self alleKommentareNachTitelAnProjektPfad:einProjektPfad
																						 bisAnzahl:AnzahlOption];
					//NSLog(@"createKomm.String: OptionAString ist alle  tempKommentarArray: %@",[tempKommentarArray description]);
					if ([[self OptionB] isEqualToString:@"alle"])//alle Namen Zu Titel
					{
						// tempKommentarArray=(NSMutableArray*)[self alleKommentareNachTitel:AnzahlOption];
					}
					else
					{
						//tempKommentarArray=(NSMutableArray*)[self alleKommentareVonLeser :[self OptionB] 
						//												  maximal:AnzahlOption];
					}
					
				}
				else
				{
					if ([self OptionB])
               {
						if ([[self OptionB] isEqualToString:@"alle"])//alle Namen Zu Titel
						{
							//NSLog(@"OptionBString ist alle: -> alleKommentareZuTitel");
							tempKommentarArray=(NSMutableArray*)[self alleKommentareZuTitel:[self OptionA] 
																			  anProjektPfad:einProjektPfad
																					maximal:AnzahlOption];
						}
						else
						{
							tempKommentarArray=(NSMutableArray*)[self KommentareMitTitel:[self OptionA] 
																				vonLeser:[self OptionB]
																		   anProjektPfad:einProjektPfad
																				 maximal:AnzahlOption];
						}
               }
				}
					//NSLog(@"createKommentarString: alleVonTitelKommentarOption**ende");
			}break;
				
		}//switch KommentarOption
		
		 //
		 //tempKommentarArray enthält die Kommentare für einProjektPfad 
				
				NSLog(@"\n******************\n\ntempKommentarArray nach switch: : %@\n\n**********",[tempKommentarArray description]);
				
				//entsprechend den Optionen im Kommentarfenster 
				//	
				if ([tempKommentarArray count])
				{
					switch (AbsatzOption)
					{
						case alsTabelleFormatOption:
						{
							int index;
							//NSLog(@"alleVonTitelKommentarOption 2");
							
							for (index=0;index<[TabellenkopfArray count];index++)
							{
								NSString* tempKopfString=[TabellenkopfArray objectAtIndex:index];
								//NSLog(@"tempKopfString: %@",tempKopfString);
								//Kommentar als Array von Zeilen
								[KommentarString appendFormat:@"%@%@",tempKopfString,tabSeparator];
								//NSLog(@"KommentarString: %@  index:%d",KommentarString,index);
							}
							//NSLog(@"createKommentarString tempKommentarArray  %@  count:%d",[tempKommentarArray description],[tempKommentarArray count]);
							
							if ([tempKommentarArray count]==0)
							{
								NSMutableDictionary* returnDic=[[NSMutableDictionary alloc]initWithCapacity:0];
								[returnDic setObject:[einProjektPfad lastPathComponent] forKey:@"projekt"];
								[returnDic setObject:NSLocalizedString(@"No comments for these settings",@"Keine Kommentare für diese Einstellungen") forKey:@"kommentarstring"];
								
								NSArray* returnArray=[NSArray arrayWithObject: returnDic];
								
								break;
							}
							
							
							[KommentarString appendString:crSeparator];
							
							
							for (index=0;index<[tempKommentarArray count];index++)
							{
								//ganzer Kommentar zu einem Leser als String
								NSString* tempKommentarString=[tempKommentarArray objectAtIndex:index];
								
								//Kommentar als Array von Zeilen
								NSMutableArray* tempKomponentenArray=(NSMutableArray*)[tempKommentarString componentsSeparatedByString:crSeparator];
								int zeile;
								//NSLog(@"++	tempKomponentenArray count: %d   TabellenkopfArray count: %d",[tempKomponentenArray count],[TabellenkopfArray count]);
								if ([tempKomponentenArray count]>[TabellenkopfArray count]+1)
								{
									NSLog(@"Anz Zeilen > als Elemente der Kopfzeile: tempKomponentenArray: %@",[tempKomponentenArray description]);
								}
								if ([tempKomponentenArray count]>8)
								{
									NSLog(@"Zu viele Elemente: %d%@tempKomponentenArray: %@",[tempKomponentenArray count],crSeparator,[tempKomponentenArray description]);
								}
								
								if ([tempKomponentenArray count]==7)//neue Version mit usermark
								{
									[tempKomponentenArray removeObjectAtIndex:UserMark];//UserMark weg

								}
								if ([tempKomponentenArray count]==8)//neue Version mit usermark und AdminMark
								{
									// AdminMark zuerst loeschen, da hoeherer Index
									[tempKomponentenArray removeObjectAtIndex:AdminMark];//AdminMark weg
									[tempKomponentenArray removeObjectAtIndex:UserMark];//UserMark weg

								}
								
								
								
									NSLog(@"index: %d\n           tempKomponentenArray: %@",index, [tempKomponentenArray description]);
								
								if ([tempKomponentenArray count]==6)//korrekte Version mit 6 Zeilen
								{
									NSLog(@"Array hat 6 Zeilen: index: %d",index);
									for (zeile=0;zeile<6;zeile++)
									{
										// Zeile im KomponentenArray
										NSMutableString* tempString=[[tempKomponentenArray objectAtIndex:zeile]mutableCopy];
										if ([[TabellenkopfArray objectAtIndex:zeile]isEqualToString:datum])
										{
											//Zeit loeschen
											NSArray* tempArray=[tempString componentsSeparatedByString:@" "];
											tempString=[tempArray objectAtIndex:0]; // Nur Datum
										}
										if (zeile==5)//Anmerkungen
										{
											
											//Zeilenwechsel entfernen
											NSRange r=NSMakeRange(0,[tempString length]);
											int anzn, anzr;
											//NSLog(@"tempString orig: %s",[tempString cString]);
											anzn=[tempString replaceOccurrencesOfString:@"\n" withString:@" " options:NSBackwardsSearch range:r];
											anzr=[tempString replaceOccurrencesOfString:@"\r" withString:@" " options:NSBackwardsSearch range:r];
											//NSLog(@"Zeilenwechsel in tempString: %s n: %d r: %d",[tempString cString],anzn,anzr);
										}
										[KommentarString appendFormat:@"%@%@",tempString,tabSeparator];
									}
									
								}
								
								else
								{
								NSLog(@"Zuwenig Elemente: tempKommentarString: %@",tempKommentarString);
								}
								
								//for (zeile=0;zeile<[TabellenkopfArray count];zeile++)//Zusätzliche Zeilen werden ignoriert
								
								[KommentarString appendString:crSeparator];
							}//for index
							//NSLog(@"alsTabelleFormatOption ende");
						}break;//alsTabelleFormatOption
							
						case alsAbsatzFormatOption:
						{
							NSLog(@"alsAbsatzFormatOption");
							
							int index;
							for (index=0;index<[tempKommentarArray count];index++)
							{
								//ganzer Kommentar zu einem Leser als String
								NSString* tempKommentarString=[tempKommentarArray objectAtIndex:index];
								//Kommentar als Array von Zeilen
								NSMutableArray* tempKomponentenArray=(NSMutableArray*)[tempKommentarString componentsSeparatedByString:crSeparator];
								
								//NSLog(@"tempKomponentenArray count: %d   TabellenkopfArray count: %d",[tempKomponentenArray count],[TabellenkopfArray count]);
								if ([tempKomponentenArray count]==7)//neue Version mit usermark
								{
//
									[tempKomponentenArray removeObjectAtIndex:5];//UserMark weg
//

								}

								int zeile;
								for (zeile=0;zeile<[tempKomponentenArray count];zeile++)
								{
									NSMutableString* tempString=[[tempKomponentenArray objectAtIndex:zeile]mutableCopy];
									if (zeile==5)//Anmerkungen
									{//Zeilenwechsel entfernen
										NSRange r=NSMakeRange(0,[tempString length]);
										int anz;
										anz=[tempString replaceOccurrencesOfString:@"\n" withString:@" " options:NSBackwardsSearch range:r];
										anz=[tempString replaceOccurrencesOfString:@"\r" withString:@" " options:NSBackwardsSearch range:r];
									}
									
									
									[KommentarString appendFormat:@"%@%@%@",[TabellenkopfArray objectAtIndex:zeile],tabSeparator, tempString];
									[KommentarString appendString:crSeparator];
								}
								[KommentarString appendString:crSeparator];
							}//for index
							
						}break;//alsAbsatzFormatOption
					}//switch FormatOption
					
					NSMutableDictionary* tempKommentarStringDic=[[NSMutableDictionary alloc]initWithCapacity:0];
					
					[tempKommentarStringDic setObject: KommentarString forKey:@"kommentarstring"];
					[tempKommentarStringDic setObject: [einProjektPfad lastPathComponent] forKey:@"projekt"];
					
					// tempKommentarStringDic in Array einsetzen
					[tempKommentarStringArray addObject:tempKommentarStringDic];
					
					//****	
				}//if [tempKommentarArray count]
				//NSLog(@"*createKommentarStringArray  *ende while*");
	}//while einProjektPfad
		//NSLog(@"*createKommentarString **ende*: Anzahl Dics: %d",[tempKommentarStringArray count]);
		//[TabellenkopfArray release];
	//NSLog(@"*createKommentarString **ende*: KommentarString: %@%@%@",@"\r" ,KommentarString,@"\r");


//**********	

	NSMutableArray* returnKommentarStringArray=[[NSMutableArray alloc]initWithCapacity:0];

	NSEnumerator* KommentarEnum=[tempKommentarStringArray objectEnumerator];
	id einKommentarDic;
	while (einKommentarDic =[KommentarEnum nextObject])
	{
		NSString*  tempAlleKommentareString=[einKommentarDic objectForKey:@"kommentarstring"];
		if (tempAlleKommentareString && [tempAlleKommentareString length])
		{
			//NSLog(@"tempAlleKommentareString: %@",[tempAlleKommentareString description]);
			NSMutableArray* neuerKommentarArray=[[NSMutableArray alloc]initWithCapacity:0];
			
			NSArray* tempKommentarArray=[tempAlleKommentareString componentsSeparatedByString:@"\r"];//Einzelne KommentarStrings
				if (tempKommentarArray &&[tempKommentarArray count])
				{
					NSEnumerator* ElementArrayEnum=[tempKommentarArray objectEnumerator];
					id einElement;
					while (einElement=[ElementArrayEnum nextObject])
					{
						NSArray* tempElementArray=[einElement componentsSeparatedByString:@"\t"];//Einzelne KommentarZeilen
						//NSLog(@"tempElementArray: %@",[tempElementArray description]);
						if ([tempElementArray count]>=5)
						{
	//10.12.08					if (!([[tempElementArray objectAtIndex:5]isEqualToString:@"--"]))//leere Kommentare nicht kopieren
						{
							[neuerKommentarArray addObject:[tempElementArray componentsJoinedByString:@"\t"]];
						}
						}
					}//while
					
				}
			if ([neuerKommentarArray count])
				{
				[einKommentarDic setObject:[neuerKommentarArray componentsJoinedByString:@"\r"] forKey:@"kommentarstring"];
				}	
		}//if tempKommentar£String
		[returnKommentarStringArray addObject:einKommentarDic];
	}//while
	
	//if ([tempKommentarStringArray count]==0)
	if ([returnKommentarStringArray count]==0)
	{
		//Keine Kommentare für diese Settings
		NSMutableDictionary* keinKommentarStringDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		NSString* keinKommentarProjektString=NSLocalizedString(@"Empty Comments Folder",@"Leerer Ordner für Anmerkungen");
		NSString* keinKommentarString=NSLocalizedString(@"No comments for these settings ",@"Keine Kommentare für diese Einstellungen");
		
		[keinKommentarStringDic setObject: keinKommentarString forKey:@"kommentarstring"];
		[keinKommentarStringDic setObject: keinKommentarProjektString forKey:@"projekt"];
		//[keinKommentarStringDic setObject: [einProjektPfad lastPathComponent] forKey:@"projekt"];
		
		// tempKommentarStringDic in Array einsetzen
		[returnKommentarStringArray addObject:keinKommentarStringDic];
		//[tempKommentarStringArray addObject:keinKommentarStringDic];

	}
	
//	return tempKommentarStringArray;
	return returnKommentarStringArray;
}

- (NSArray*)ProjektPfadArrayMitKommentarOptionen
{
	NSMutableArray* tempProjektDicArray=[[NSMutableArray alloc]initWithCapacity:0];

	int DruckAuswahlOption=[KommentarFenster AuswahlOption];
	//NSLog(@"createDruckKommentarStringDicArrayWithProjektPfadArray   DruckAuswahlOption: %d",DruckAuswahlOption);
	switch (DruckAuswahlOption)
	{
		case 0://Nur ein Projekt
		{
			
			//NSString* tempProjektPfad=[[AdminProjektArray objectAtIndex:ProjektNamenOption]objectForKey:@"projektpfad"];
			//NSLog(@"tempProjektPfad: %@",tempProjektPfad);
			NSMutableDictionary* tempProjektDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
			[tempProjektDictionary setObject:ProjektPfadOptionString forKey:@"projektpfad"];
			[tempProjektDictionary setObject:[ProjektPfadOptionString lastPathComponent] forKey:@"projekt"];
			[tempProjektDicArray addObject:tempProjektDictionary];
			
		}break;
			
		case 1://Nur aktive Projekte
		{
			NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
			id einProjektDic;
			while (einProjektDic=[ProjektArrayEnum nextObject])
			{
				//NSLog(@"		Nur aktive Projekte: %@",[einProjektDic description]);
				if ([einProjektDic objectForKey:@"ok"])
				{
					if ([[einProjektDic objectForKey:@"ok"]boolValue]&&[einProjektDic objectForKey:@"projektpfad"])
					{
						NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
						NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
						//NSLog(@"Nur aktive Projekte: tempProjektPfad: %@",tempProjektPfad);
						NSMutableDictionary* tempProjektDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
						[tempProjektDictionary setObject:tempProjektPfad forKey:@"projektpfad"];
						[tempProjektDictionary setObject:[tempProjektPfad lastPathComponent] forKey:@"projekt"];
						[tempProjektDicArray addObject:tempProjektDictionary];
						
					}
				}
			}//while enum
			
		}break;
			
		case 2://Alle Projekte
		{
			NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
			id einProjektDic;
			while (einProjektDic=[ProjektArrayEnum nextObject])
			{
				//NSLog(@"		alle Projekte: %@",[einProjektDic description]);
				if ([einProjektDic objectForKey:@"ok"])
				{
					if ([einProjektDic objectForKey:@"projektpfad"])
					{
						NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
						NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
						//NSLog(@"Alle Projekte: tempProjektPfad: %@",tempProjektPfad);
						NSMutableDictionary* tempProjektDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
						[tempProjektDictionary setObject:tempProjektPfad forKey:@"projektpfad"];
						[tempProjektDictionary setObject:[tempProjektPfad lastPathComponent] forKey:@"projekt"];
						[tempProjektDicArray addObject:tempProjektDictionary];
						
					}
				}
			}//while enum
			
		}break;
			
	}
	//NSLog(@"tempProjektDicArray: %@",[tempProjektDicArray description]);	//Array mit ProjektPfaden

return tempProjektDicArray;
}


- (NSArray*)createDruckKommentarStringDicArrayWithProjektPfadArray:(NSArray*)derProjektPfadArray
{
	NSArray* tempProjektDicArray=[self ProjektPfadArrayMitKommentarOptionen];

	//NSLog(@"tempProjektDicArray: %@",[tempProjektDicArray description]);	//Array mit ProjektPfaden
	
	//KommentarstringArray aufbauen
	NSArray* tempKommentarStringDicArray=[self createKommentarStringArrayWithProjektPfadArray:[tempProjektDicArray valueForKey:@"projektpfad"]];
	
	return tempKommentarStringDicArray;
}


- (void)KommentarNotificationAktion:(NSNotification*)note 
{
	//Aufgerufen nach Änderungen in den Pops des Kommentarfensters
	NSString* alle=@"alle";
	NSLog(@"\n\n********				Beginn KommentarNotificationAktion\n\n ");
	NSDictionary* OptionDic=[note userInfo];
	NSLog(@"KommentarNotificationAktion: UserInfo OptionDic: %@",[OptionDic description]);
	NSString* tempProjektName;
	if ([OptionDic objectForKey:@"projektname"])
	{
		tempProjektName=[OptionDic objectForKey:@"projektname"];
	}
	//NSLog(@"tempProjektName: %@ AdminLeseboxPfad: %@ AdminArchivPfad: %@",tempProjektName,AdminLeseboxPfad,AdminArchivPfad);
	//Pop Auswahl
	//Einstellung, welche Auswahl aus den Kommentaren getroffen werden soll.
	//Grundeinstellung ist: lastKommentarOption. Die neuesten Kommentare werden angezeigt
	
	
	NSNumber* AuswahlNummer=[OptionDic objectForKey:@"Auswahl"];
	if (AuswahlNummer)
	{
		AuswahlOption=(int)[AuswahlNummer intValue];
		NSLog(@"KommentarNotificationAktion AuswahlOption: %d",[AuswahlNummer intValue]);
	 	switch (AuswahlOption)
		{
			case lastKommentarOption:
			{
				[KommentarFenster resetPopAMenu];
				[KommentarFenster resetPopBMenu];
				
				
				
			}break;//lastKommentarOption
				
			case alleVonNameKommentarOption:
			{		
				//NSLog(@"alleVonNameKommentarOption: ProjektAuswahlOption: %d",ProjektAuswahlOption);
				switch (ProjektAuswahlOption)
				{
					case 0://Nur ein Projekt
					{
						//NSLog(@"alleVonNameKommentarOption: Nur 1 Projekt AdminProjektPfad: %@ tempProjektName: %@",AdminProjektPfad,tempProjektName);
						
						NSString* tempAdminProjektPfad=[[AdminProjektPfad stringByDeletingLastPathComponent]stringByAppendingPathComponent:tempProjektName];
						//NSLog(@"tempAdminProjektPfad: %@",tempAdminProjektPfad);
						NSArray* tempNamenArray=[self LeserArrayAnProjektPfad:tempAdminProjektPfad];
						//NSLog(@"alleVonNameKommentarOption: Nur 1 Projekt tempNamenArray: %@",[tempNamenArray description]);
						//NSArray* tempNamenArray=[self LeserArrayAnProjektPfad:ProjektPfadOptionString];
						[KommentarFenster setPopAMenu:tempNamenArray erstesItem:@"alle" aktuell:NULL];
						[KommentarFenster resetPopBMenu];
						
					}break;
						
					case 1://Nur aktive Projekte
					{
						//NSLog(@"    ++++++++++++++       alleVonNameKommentarOption	Nur aktive Projekte\n");
						//[KommentarFenster setPopAMenu:NULL erstesItem:alle aktuell:alle];
						NSMutableArray* tempNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
						
						NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
						id einProjektDic;
						while (einProjektDic=[ProjektArrayEnum nextObject])
						{
							//NSLog(@"		Nur aktive Projekte: %@",[einProjektDic description]);
							if ([einProjektDic objectForKey:@"ok"])
							{
								if ([[einProjektDic objectForKey:@"ok"]boolValue]&&[einProjektDic objectForKey:@"projektpfad"])
								{
									NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
									NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
									NSArray* tempProjektNamenArray=[self LeserArrayAnProjektPfad:tempProjektPfad];
									//NSLog(@"tempProjektNamenArray: %@",[tempProjektNamenArray description]);
									//
									//		Namen addieren
									//									
								}
							}
						}//while enum
						//NSLog(@"tempNamenArray: %@",[tempNamenArray description]);
						
						[KommentarFenster setPopAMenu:tempNamenArray erstesItem:@"alle" aktuell:@"alle"];
						[KommentarFenster setPopBMenu:NULL erstesItem:@"alle" aktuell:@"alle" mitPrompt:@"mit Titel:"];
					}break;
						
					case 2://Alle Projekte
					{
						
					}break;
						
				}
				
				
			}break;//alleVonNameKommentarOption
				
			case alleVonTitelKommentarOption:
			{
				NSArray* tempTitelArray= [self TitelArrayVonAllenAnProjektPfad:ProjektPfadOptionString
															 bisAnzahlProLeser:AnzahlOption ];
				//NSLog(@"alleVonTitelKommentarOption tempTitelArray: %@",[tempTitelArray description]); 
				[KommentarFenster setPopAMenu:tempTitelArray erstesItem:@"alle" aktuell:NULL];
				[KommentarFenster resetPopBMenu];
				
			}break;//alleVonTitelKommentarOption
		}//switch AuswahlOption
		
		//NSLog(@"Notifik: AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,[self OptionA],[self OptionB]);
		//OptionAString=[[KommentarFenster PopAOption]retain];
		//OptionBString=[[KommentarFenster PopBOption]retain];
		NSLog(@"AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,[self OptionA],[self OptionB]);
		
		
	}//if (AuswahlNummer)
	
	NSNumber* AbsatzNummer=[OptionDic objectForKey:@"Absatz"];
	if(AbsatzNummer)
	{
		AbsatzOption=(int)[AbsatzNummer intValue];
		//NSLog(@"KommentarNotificationAktion AbsatzOption: %d",[AbsatzNummer intValue]);
	}
	
	//NSNumber* ZusatzNummer=[OptionDic objectForKey:@"Zusatz"];
	//ZusatzOption=(int)[ZusatzNummer intValue];
	//NSLog(@"KommentarNotificationAktion ZusatzOption: %d",[ZusatzNummer intValue]);
	
	NSNumber* AnzahlNummer=[OptionDic objectForKey:@"Anzahl"];
	if (AnzahlNummer)
	{
		AnzahlOption=(int)[AnzahlNummer intValue];
		NSLog(@"KommentarNotificationAktion AnzahlOption: %d",[AnzahlNummer intValue]);
	}
	
	NSNumber* nurMarkierteNummer=[OptionDic objectForKey:@"nurMarkierte"];
	if (nurMarkierteNummer)
	{
		nurMarkierteOption=(int)[nurMarkierteNummer intValue];
		//NSLog(@"KommentarNotificationAktion nurMarkierteOption: %d",[nurMarkierteNummer intValue]);
	}
	
	NSNumber* tempProjektNamenOptionNumber=[OptionDic objectForKey:@"projektnamenoption"];
	if (tempProjektNamenOptionNumber )
	{
		ProjektNamenOption=[tempProjektNamenOptionNumber intValue];
		ProjektPfadOptionString=[[AdminProjektArray objectAtIndex:ProjektNamenOption]objectForKey:@"projektpfad"];
		//NSLog(@"KommentarNotificationAktion   tempProjektNamenOptionNumber: %@ ProjektNamenOption: %d",[tempProjektNamenOptionNumber description],ProjektNamenOption);
	 	//NSLog(@"KommentarNotificationAktion  AuswahlOption: %d",AuswahlOption);
		switch (AuswahlOption)
		{
			case lastKommentarOption:
			{
				//NSLog(@"ProjektnamenOption lastKommentarOption: %d",lastKommentarOption); 
				
			}break;//lastKommentarOption
				
			case alleVonNameKommentarOption:
			{			  
				
				NSArray* LeserArray=[self LeserArrayAnProjektPfad:ProjektPfadOptionString];
				//NSLog(@"alleVonTitelKommentarOption LeserArray: %@",[LeserArray description]); 
				
				[KommentarFenster setPopAMenu:LeserArray erstesItem:@"alle" aktuell:@"alle"];
				[KommentarFenster resetPopBMenu];
			}break;//alleVonNameKommentarOption
				
			case alleVonTitelKommentarOption:
			{
				NSArray* tempTitelArray= [self TitelArrayVonAllenAnProjektPfad:ProjektPfadOptionString
															 bisAnzahlProLeser:AnzahlOption ];
				//NSLog(@"alleVonTitelKommentarOption tempTitelArray: %@",[tempTitelArray description]); 
				[KommentarFenster setPopAMenu:tempTitelArray erstesItem:@"alle" aktuell:NULL];
				
				
				NSArray* LeserArray=[self LeserArrayVonTitel:[self OptionA] anProjektPfad:ProjektPfadOptionString];
				//NSLog(@"Komm.Not.Aktion LeserArray: %@	OptionAString: %@  OptionBString. %@",	[LeserArray description],[self OptionA],[self OptionB]);
				if ([LeserArray count]==1)//Nur ein Leser für diesen Titel
				{
					[KommentarFenster setPopBMenu:LeserArray erstesItem:NULL aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
				}
				else
				{
					[KommentarFenster setPopBMenu:LeserArray erstesItem:@"alle" aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
				}
				
				
				
			}break;//alleVonTitelKommentarOption
				
		}	 
		
	}
	
	
	NSString* tempAString=[OptionDic objectForKey:@"PopA"];
	if (tempAString )//&& [tempAString length])
	{
		//NSLog(@"KommentarNotificationAktion   tempAString: %@   Länge: %d" ,tempAString, [tempAString length]);
		OptionAString=[tempAString copy];
	 	switch (AuswahlOption)
		{
			case lastKommentarOption:
			{
				
			}break;//lastKommentarOption
				
			case alleVonNameKommentarOption:
			{			  
				if ([[self OptionA] isEqualToString:alle])
				{
					[KommentarFenster resetPopBMenu];
					
				}
				else
				{				  
					//NSLog(@"\n******\nKommentarNotifikation alleVonNameKommentarOption: OptionAString: %@",[self OptionA]);
					
					
					NSMutableArray* TitelArray=[[self TitelMitKommentarArrayVon:[self OptionA] anProjektPfad:ProjektPfadOptionString]mutableCopy];
					
					
					
					//NSLog(@"KommentarNotifilkation alleVonNameKommentarOption: \nProjektPfadOptionString: %@   \nTitelArray: %@",ProjektPfadOptionString,[TitelArray description]);
					//NSLog(@"TitelArray: %@	OptionAString: %@  OptionBString. %@",	[TitelArray description],[self OptionA],[self OptionB]);
					if(ProjektAuswahlOption==0)//nur bei einzelnem Projekt
					{
						[KommentarFenster setPopBMenu:TitelArray erstesItem:@"alle" aktuell:@"alle" mitPrompt:@"mit Titel:"];
					}
				}
			}break;//alleVonNameKommentarOption
				
			case alleVonTitelKommentarOption:
			{
				//NSLog(@"alleVonTitelKommentarOption: OptionA: %@ ",[self OptionA]);
				{
					if ([[self OptionA] isEqualToString:@"alle"])
					{
						[KommentarFenster resetPopBMenu];
					}
					else
					{
						NSMutableArray* LeserArray=[[self LeserArrayVonTitel:[self OptionA] anProjektPfad:ProjektPfadOptionString]mutableCopy];
						//NSLog(@"alleVonTitelKommentarOption vor .DS: LeserArray: %@	[self OptionA]: %@  OptionBString. %@",	[LeserArray description],[self OptionA],[self OptionB]);
						if ([LeserArray count]>0)//ES HAT LESER MIT KOMMENTAR FÜR DIESENJ TITEL
						{
							
							if ([[LeserArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
							{
								//NSLog(@"LeserArray .DS");
								[LeserArray removeObjectAtIndex:0];
							}
							
							//NSLog(@"alleVonTitelKommentarOption: LeserArray: %@	[self OptionA]: %@  OptionBString. %@",	[LeserArray description],[self OptionA],[self OptionB]);
							if ([LeserArray count]==1)//Nur ein Leser für diesen Titel
							{
								[KommentarFenster setPopBMenu:LeserArray erstesItem:NULL aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
							}
							else
							{
								[KommentarFenster setPopBMenu:LeserArray erstesItem:@"alle" aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
							}
						}//Count>0
					}
					
				}
			}break;//alleVonTitelKommentarOption
				
		}//switch AuswahlOption
		
	}
	
	NSString* tempBString=[OptionDic objectForKey:@"PopB"];
	if (tempBString )//&& [tempBString length])
	{
		//NSLog(@"\nKommentarNotificationAktion   tempBString: %@\n",tempBString);
		OptionBString=[tempBString copy];
		
		
	}
	
	//	OptionAString=[[KommentarFenster PopAOption]retain];
	//	OptionBString=[[KommentarFenster PopBOption]retain];
	
	
	NSNumber* tempProjektAuswahlOptionNumber=[OptionDic objectForKey:@"projektauswahloption"];
	if (tempProjektAuswahlOptionNumber )
	{
		ProjektAuswahlOption=[tempProjektAuswahlOptionNumber intValue];
		//NSLog(@"KommentarNotificationAktion   tempProjektAuswahlOptionNumber: %@ ProjektOption: %d",[tempProjektAuswahlOptionNumber description],ProjektAuswahlOption);
		switch (ProjektAuswahlOption)
		{
			case 0://Nur ein Projekt
			{
				NSLog(@"tempProjektAuswahlOptionNumber: Nur 1 Projekt");
			}break;
				
			case 1://Nur aktive Projekte
			{
				//NSLog(@"tempProjektAuswahlOptionNumber Nur aktive Projeke");
				[KommentarFenster setAuswahlPop:alleVonNameKommentarOption];
				AuswahlOption=alleVonNameKommentarOption;
				
				//[KommentarFenster setPopAMenu:NULL erstesItem:alle aktuell:alle];
				NSMutableArray* tempNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
				
				NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
				id einProjektDic;
				while (einProjektDic=[ProjektArrayEnum nextObject])
				{
					//NSLog(@"		Nur aktive Projekte: %@",[einProjektDic description]);
					if ([einProjektDic objectForKey:@"ok"])
					{
						if ([[einProjektDic objectForKey:@"ok"]boolValue]&&[einProjektDic objectForKey:@"projektpfad"])
						{
							NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
							NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
							//NSLog(@"tempProjektPfad: %@",tempProjektPfad);
							
							NSArray* tempProjektNamenArray=[self LeserArrayAnProjektPfad:tempProjektPfad];
							
							//NSLog(@"tempProjektNamenArray: %@",[tempProjektNamenArray description]);
							NSEnumerator* ProjektNamenEnum=[tempProjektNamenArray objectEnumerator];
							id einProjektName;
							while(einProjektName=[ProjektNamenEnum nextObject])
							{
								if(![tempNamenArray containsObject:einProjektName])
								{
									[tempNamenArray addObject:einProjektName];
								}
							}//while
						}
					}
				}//while enum
				//NSLog(@"tempNamenArray: %@",[tempNamenArray description]);
				
				[KommentarFenster setPopAMenu:tempNamenArray erstesItem:@"alle" aktuell:@"alle"];
				[KommentarFenster setPopBMenu:NULL erstesItem:@"alle" aktuell:@"alle" mitPrompt:@"mit Titel:"];
			}break;
				
			case 2://Alle Projekte
			{
				//NSLog(@"tempProjektAuswahlOptionNumberNur alle Projekte");
				[KommentarFenster setAuswahlPop:alleVonNameKommentarOption];
				AuswahlOption=alleVonNameKommentarOption;
				
				//[KommentarFenster setPopAMenu:NULL erstesItem:alle aktuell:alle];
				NSMutableArray* tempNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
				
				NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
				id einProjektDic;
				while (einProjektDic=[ProjektArrayEnum nextObject])
				{
					//NSLog(@"		Alle Projekte: %@",[einProjektDic description]);
					if ([einProjektDic objectForKey:@"ok"])
					{
						if ([einProjektDic objectForKey:@"projektpfad"])
						{
							NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
							NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
							NSArray* tempProjektNamenArray=[self LeserArrayAnProjektPfad:tempProjektPfad];
							//NSLog(@"tempProjektNamenArray: %@",[tempProjektNamenArray description]);
							NSEnumerator* ProjektNamenEnum=[tempProjektNamenArray objectEnumerator];
							id einProjektName;
							while(einProjektName=[ProjektNamenEnum nextObject])
							{
								if(![tempNamenArray containsObject:einProjektName])
								{
									[tempNamenArray addObject:einProjektName];
								}
							}//while
						}
					}
				}//while enum
				//NSLog(@"tempNamenArray: %@",[tempNamenArray description]);
				
				[KommentarFenster setPopAMenu:tempNamenArray erstesItem:@"alle" aktuell:@"alle"];
				[KommentarFenster setPopBMenu:NULL erstesItem:@"alle" aktuell:@"alle" mitPrompt:@"mit Titel:"];
				
			}break;
				
		}
	}
	
	//****
	//NSLog(@"KommentarArray entsprechend den Settings aufbauen");
	
	//KommentarArray entsprechend den Settings aufbauen
	
	NSMutableArray* tempProjektDicArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	switch (ProjektAuswahlOption)
	{
		case 0://Nur ein Projekt
		{
			
			NSString* tempProjektPfad=[[AdminProjektArray objectAtIndex:ProjektNamenOption]objectForKey:@"projektpfad"];
			//NSLog(@"tempProjektPfad: %@",tempProjektPfad);
			NSMutableDictionary* tempProjektDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
			[tempProjektDictionary setObject:ProjektPfadOptionString forKey:@"projektpfad"];
			[tempProjektDictionary setObject:[ProjektPfadOptionString lastPathComponent] forKey:@"projekt"];
			[tempProjektDicArray addObject:tempProjektDictionary];
			
		}break;
			
		case 1://Nur aktive Projekte
		{
			NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
			id einProjektDic;
			while (einProjektDic=[ProjektArrayEnum nextObject])
			{
				//NSLog(@"		Nur aktive Projekte: %@",[einProjektDic description]);
				if ([einProjektDic objectForKey:@"ok"])
				{
					if ([[einProjektDic objectForKey:@"ok"]boolValue]&&[einProjektDic objectForKey:@"projektpfad"])
					{
						NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
						NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
						//NSLog(@"Nur aktive Projekte: tempProjektPfad: %@",tempProjektPfad);
						NSMutableDictionary* tempProjektDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
						[tempProjektDictionary setObject:tempProjektPfad forKey:@"projektpfad"];
						[tempProjektDictionary setObject:[tempProjektPfad lastPathComponent] forKey:@"projekt"];
						[tempProjektDicArray addObject:tempProjektDictionary];
						
					}
				}
			}//while enum
			
		}break;
			
		case 2://Alle Projekte
		{
			NSEnumerator* ProjektArrayEnum=[AdminProjektArray objectEnumerator];
			id einProjektDic;
			while (einProjektDic=[ProjektArrayEnum nextObject])
			{
				//NSLog(@"		Nur aktive Projekte: %@",[einProjektDic description]);
				if ([einProjektDic objectForKey:@"ok"])
				{
					if ([einProjektDic objectForKey:@"projektpfad"])
					{
						NSString* tempProjektName=[[einProjektDic objectForKey:@"projektpfad"]lastPathComponent];
						NSString* tempProjektPfad=[einProjektDic objectForKey:@"projektpfad"];
						//NSLog(@"Nur aktive Projekte: tempProjektPfad: %@",tempProjektPfad);
						NSMutableDictionary* tempProjektDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
						[tempProjektDictionary setObject:tempProjektPfad forKey:@"projektpfad"];
						[tempProjektDictionary setObject:[tempProjektPfad lastPathComponent] forKey:@"projekt"];
						[tempProjektDicArray addObject:tempProjektDictionary];
						
					}
				}
			}//while enum
			
		}break;
			
	}//switch ProjektAuswahlOption
	
	
	//Angepassten Kommentarstring an Kommentarfenster schicken
	
	//NSLog(@"KommentarNotificationAktion vor setKommentar");
	//NSLog(@"\n+++++++++++\n˙KommentarNotificationAktion tempProjektDicArray: %@%@%@",@"\r",[tempProjektDicArray description],@"\r");
	//NSLog(@"\nKommentarNotificationAktion ProjektPfadArray für create: %@%@%@",@"\r",[tempProjektDicArray valueForKey:@"projektpfad"],@"\r");
	
	NSArray* KommentarStringArray=[self createKommentarStringArrayWithProjektPfadArray:[tempProjektDicArray valueForKey:@"projektpfad"]];
	
	//NSLog(@"KommentarNotificationAktion nach Create:  KommentarStringArray: %@%@%@",@"\r",[KommentarStringArray description],@"\r");
	//NSLog(@"\n**********\nvor KommentarFenster setKommentarMitKommentarDicArray");
	[KommentarFenster setKommentarMitKommentarDicArray:KommentarStringArray];
	//NSLog(@"\nnach KommentarFenster setKommentarMitKommentarDicArray\n**********\n");
	
}

- (NSArray*)KommentareVonLeser:(NSString*)derLeser 
					  mitTitel:(NSString*)derTitel 
					   maximal:(int)dieAnzahl
					 anProjektPfad:(NSString*)derProjektPfad
{
	BOOL erfolg;
	BOOL istDirectory;
	NSString* crSeparator=@"\r";
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");

	NSFileManager *Filemanager=[NSFileManager defaultManager];
	//NSLog(@"KommentareVonLeser : LeserPfad: %@ mitTitel: %@",derLeser,derTitel);
	NSMutableArray* KommentareVonLeserMitTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];

	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  NSMutableArray* tempAufnahmen=[[NSMutableArray alloc]initWithCapacity:0];
		  tempAufnahmen=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  //NSLog(@":   tempAufnahmen roh: %@",[tempAufnahmen description]);
		  if ([tempAufnahmen count])//Aufnahmen vorhanden
			{
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmen indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmen removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Array entfernen
				  }
				//NSLog(@":   tempAufnahmen ohne Kommentar: %@",[tempAufnahmen description]);
				
				if ([tempAufnahmen count])
				  {
					if ([[tempAufnahmen objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
					  {
						[tempAufnahmen removeObjectAtIndex:0];
					  }
					
					tempAufnahmen=(NSMutableArray*)[self sortNachNummer:tempAufnahmen];
					//NSLog(@":  KommentareVonLeser mitTitel:   tempAufnahmen ohne .DS: %@",[tempAufnahmen description]);
					NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
					int passendeAufnahmen=0;
					NSEnumerator* enumerator=[tempAufnahmen objectEnumerator];
					id eineAufnahme;
					int pos=0;
					while ((eineAufnahme=[enumerator nextObject])&&(passendeAufnahmen<dieAnzahl))							
					  {
						//NSLog(@": eineAufnahme: %@    passendeAufnahmen: %d",eineAufnahme,passendeAufnahmen);
						NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
						BOOL OK=[self mitMarkierungAufnehmenOptionAnPfad:tempAufnahmePfad];

						if (OK&&[[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel])
						  {
						  
						  {
							NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:eineAufnahme];
							if ([Filemanager fileExistsAtPath:tempKommentarPfad])//Kommentar für Aufnahme ist da)
							  {
								  NSString* tempKommentarMitTitelString=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
								  if (pos)//Ab zweitem Kommentar Name entfernen
									{
										//NSLog(@"Namen entfernt: %d",pos);
										NSMutableArray* tempZeilenArray=[[NSMutableArray alloc]initWithCapacity:0];
										tempZeilenArray=[[tempKommentarMitTitelString componentsSeparatedByString:crSeparator]mutableCopy];
										NSString* tempName=[tempZeilenArray objectAtIndex:0];
										int n=[tempName length];
										NSRange r=NSMakeRange(0,n-1);
										tempName=[[tempZeilenArray objectAtIndex:0]substringFromIndex:n];
										tempName=[NSString stringWithFormat:@"%@  %@",@"  -  ",tempName];
										//[tempZeilenArray replaceObjectAtIndex:0 withObject:@"\n    -"];
										[tempZeilenArray replaceObjectAtIndex:0 withObject:tempName];
										
										//
										[tempZeilenArray removeObjectAtIndex:3];
						  
										//
			
										NSString* redZeile=[tempZeilenArray componentsJoinedByString:@" "];
										tempKommentarMitTitelString=[tempZeilenArray componentsJoinedByString:crSeparator];
										
									}
								  pos++;									
								[KommentareVonLeserMitTitelArray addObject:tempKommentarMitTitelString];

								  passendeAufnahmen++;
							  }
							}//ist Markiert
						  }//Titel stimmt
						  
					  }//while enumerator
					   //NSLog(@"Leserordner letztes Objekt: %@",letzteAufnahme);
					}
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  
		  
		  
}//if exists LeserPfad

return KommentareVonLeserMitTitelArray;

}

- (NSString*)KommentarZuAufnahme:(NSString*)dieAufnahme 
					  vonLeser:(NSString*)derLeser 
				 anProjektPfad:(NSString*)derProjektPfad
					  
{
	BOOL erfolg;
	BOOL istDirectory;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	//NSLog(@"KommentarZuAufnahme: dieAufnahme: %@  derLeser: %@ ",dieAufnahme,derLeser);
	//NSMutableArray* KommentareMitTitelVonLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];

	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	NSString* tempKommentar=[NSString string];
		if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  NSMutableArray* tempAufnahmen=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  //NSLog(@":   tempAufnahmen roh: %@",[tempAufnahmen description]);
		  if ([tempAufnahmen count])//Aufnahmen vorhanden
		  {
			  int KommentarIndex=NSNotFound;
			  KommentarIndex=[tempAufnahmen indexOfObject:locKommentar];
			  if (!(KommentarIndex==NSNotFound))
			  {
				  NSString* LeserKommentarOrdnerPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
				  NSString* KommentarPfad=[LeserKommentarOrdnerPfad stringByAppendingPathComponent:dieAufnahme];//Kommentar der Aufnahme
				  //NSLog(@"   KommentarPfad: %@",KommentarPfad );
					  if ([Filemanager fileExistsAtPath:KommentarPfad])//Kommentar ist da
					  {
						tempKommentar=[NSString stringWithContentsOfFile: KommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
						
					  }
			  }
			  else
			  {
				  //NSLog(@"Keine Aufnahmen von: %@",derLeser);
			  }
		  }//[tempAufnahmen count]
		  else
			{
			  NSLog(@"KommentareMitTitel:count=0");
			}
		  
	  
}//if exists LeserPfad
//NSLog(@"KommentareMitTitel:ende");
return tempKommentar;
}

- (NSArray*)KommentareMitTitel:(NSString*)derTitel 
					  vonLeser:(NSString*)derLeser 
				 anProjektPfad:(NSString*)derProjektPfad
					   maximal:(int)dieAnzahl
{
	BOOL erfolg;
	BOOL istDirectory;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	//NSLog(@"KommentareMitTitel: mitTitel: %@  LeserPfad: %@ ",derTitel,derLeser);
	NSMutableArray* KommentareMitTitelVonLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];

	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
		if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  NSMutableArray* tempAufnahmen=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  //NSLog(@":   tempAufnahmen roh: %@",[tempAufnahmen description]);
		  if ([tempAufnahmen count])//Aufnahmen vorhanden
			{
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmen indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmen removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Array entfernen
				  }
				//NSLog(@":   tempAufnahmen ohne Kommentar: %@",[tempAufnahmen description]);
				
				if ([tempAufnahmen count])
				  {
					if ([[tempAufnahmen objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
					  {
						[tempAufnahmen removeObjectAtIndex:0];
					  }
					//NSLog(@":   tempAufnahmen ohne .DS: %@",[tempAufnahmen description]);
					
					if (![tempAufnahmen count])
						return KommentareMitTitelVonLeserArray;

					tempAufnahmen=(NSMutableArray*)[self sortNachNummer:tempAufnahmen];
					NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
						int passendeAufnahmen=0;
						NSEnumerator* enumerator=[tempAufnahmen objectEnumerator];
						id eineAufnahme;
						while ((eineAufnahme=[enumerator nextObject])&&(passendeAufnahmen<dieAnzahl))							
						  {
							//NSLog(@": eineAufnahme: %@    passendeAufnahmen: %d",eineAufnahme,passendeAufnahmen);
							if ([[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel])
							  {
								NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:eineAufnahme];
								if ([Filemanager fileExistsAtPath:tempKommentarPfad])//Kommentar für letzte Aufnahme ist da)
								  {
									  // lastKommentarMitTitelString=[NSString stringWithContentsOfFile:lastKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
									  
									  
									  
									  
									  [KommentareMitTitelVonLeserArray addObject:[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL]];
									  passendeAufnahmen++;
								  }
								
						  }
					  }//while enumerator
					   //NSLog(@"Leserordner letztes Objekt: %@",letzteAufnahme);
					}
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  else
			{
			  NSLog(@"KommentareMitTitel:count=0");
			}
		  
}//if exists LeserPfad
//NSLog(@"KommentareMitTitel:ende");

return KommentareMitTitelVonLeserArray;
}




- (NSArray*)alleKommentareZuTitel:(NSString*)derTitel 
					anProjektPfad:(NSString*)derProjektPfad
						  maximal:(int)dieAnzahl
{
	NSLog(@"alleKommentareZuTitel: Titel: %@",derTitel);
	BOOL erfolg;
	BOOL istDirectory;
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSMutableArray* alleKommentareArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	//NSMutableArray* tempKommentarArray=[[[NSMutableArray alloc]initWithCapacity:0]autorelease];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];

	NSMutableArray* LeserArray;
	LeserArray=[[Filemanager contentsOfDirectoryAtPath:tempProjektPfad error:NULL]mutableCopy];
	if ([[LeserArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
	  {
		[LeserArray removeObjectAtIndex:0];
	  }
	if (![LeserArray count])
	  {
		NSLog(@"alleKommentareZuTitel: Archiv ist leer");
		NSString* ArchivLeerString=NSLocalizedString(@"There are no comments for this project",@"Für dieses Projekt hat es keine Anmerkungen");
		[alleKommentareArray addObject:ArchivLeerString];
	  }				
  
	NSLog(@"alleKommentareZuTitel: LeserArray: %@",[LeserArray description]);
	
	NSEnumerator* LeserEnumerator =[LeserArray objectEnumerator];
	NSString* tempLeser;
	while (tempLeser = [LeserEnumerator nextObject]) 
	{
		NSString* tempLeserKommentarPfad=[tempProjektPfad stringByAppendingPathComponent:tempLeser];
		tempLeserKommentarPfad=[tempLeserKommentarPfad stringByAppendingPathComponent:locKommentar];
		if ([Filemanager fileExistsAtPath:tempLeserKommentarPfad isDirectory:&istDirectory]&&istDirectory)
		{
			//Kommentarordner des Lesers ist da
			NSLog(@"alleKommentareZuTitel: %@: Kommentarordner von %@ ist da",derTitel, tempLeser);
			NSMutableArray* tempKommentarArray=[[NSMutableArray alloc]initWithCapacity:0];
			tempKommentarArray=[[Filemanager contentsOfDirectoryAtPath:tempLeserKommentarPfad error:NULL]mutableCopy];
			if (![tempKommentarArray count])
			{
				NSLog(@"alleKommentareZuTitel: Kommentarordner von %@ ist leer",tempLeser);
				NSString* ArchivLeerString=NSLocalizedString(@"There are no comments for this project",@"Für dieses Projekt hat es keine Anmerkungen");
				[alleKommentareArray addObject:ArchivLeerString];
				
				//return alleKommentareArray;
			}	
			else
			{
				if ([[tempKommentarArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
				{
					[tempKommentarArray removeObjectAtIndex:0];
				}
				//NSLog(@"alleKommentareZuTitel: tempKommentarArray: %@",[tempKommentarArray description]);
				if (![tempKommentarArray count])
				{
					NSLog(@"alleKommentareZuTitel: Kommentarordner nach .DS von %@ ist leer",tempLeser);
					NSString* ArchivLeerString=NSLocalizedString(@"There are no comments for this project",@"Für dieses Projekt hat es keine Anmerkungen");
					[alleKommentareArray addObject:ArchivLeerString];
					
					//return alleKommentareArray;
				}
				else
				{
				tempKommentarArray=(NSMutableArray*)[self sortNachNummer:tempKommentarArray];
				NSLog(@"alleKommentareZuTitel: tempKommentarArray nach sort: %@",[tempKommentarArray description]);
				
				//[tempKommentarArray retain];
				int anzVonTitel=0;
				NSEnumerator* KommentarEnumerator =[tempKommentarArray objectEnumerator];
				NSString* tempKommentar;
				while (tempKommentar = [KommentarEnumerator nextObject]) 
				{
					NSLog(@"tempKommentar: %@",tempKommentar);
					if ([[self AufnahmeTitelVon:tempKommentar]isEqualToString:derTitel])
					{
						
						if (anzVonTitel<dieAnzahl)
						{
							NSString* tempKommentarPfad=[tempLeserKommentarPfad stringByAppendingPathComponent:tempKommentar];
							NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
							
							[alleKommentareArray addObject:tempKommentarString];
						}
						anzVonTitel++;
					}
				}//while tempKommentar
				}// Ordner nach .DS leer
			} // Ordner von Anfang an leer
		}//if  fileExistsAtPath:tempLeserKommentarPfad
	}//while tempLeser
	  NSLog(@"alleKommentareZuTitel Ergebnis: alleKommentareArray: %@",[alleKommentareArray description]);
	return alleKommentareArray;
}	



- (NSArray*)alleKommentareNachTitelAnProjektPfad:(NSString*)derProjektPfad bisAnzahl:(int)dieAnzahl
{
	//BOOL istDirectory;
	NSMutableArray* alleKommentareNachTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//NSFileManager *Filemanager=[NSFileManager defaultManager];
	//NSMutableArray* tempKommentarArray=[[[NSMutableArray alloc]initWithCapacity:0]autorelease];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	NSArray* tempTitelArray=[self TitelArrayVonAllenAnProjektPfad:tempProjektPfad 
												bisAnzahlProLeser:AnzahlOption];

	NSEnumerator* TitelEnumerator =[tempTitelArray objectEnumerator];
	NSString* einTitel;
	while (einTitel = [TitelEnumerator nextObject]) 
	  {
		NSArray* tempKommentareZuTitelArray=[self alleKommentareZuTitel:einTitel 
														  anProjektPfad:tempProjektPfad 
																maximal:AnzahlOption];
																
		[alleKommentareNachTitelArray addObjectsFromArray:tempKommentareZuTitelArray];
		
	  }//while einTitel
	return alleKommentareNachTitelArray;
}




- (NSString*)lastKommentarVonLeser:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
	BOOL erfolg;
	BOOL istDirectory;
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");

	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSLog(@"lastKommentarVon: LeserPfad: %@ anPfad: %@",derLeser,derProjektPfad);
	NSString* letzteAufnahme=@"xxx";
	NSString* lastKommentarString=[NSString string];	
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		NSLog(@"Leser %@ da",derLeser);
		  NSMutableArray* tempAufnahmen=[[NSMutableArray alloc]initWithCapacity:0];
		  tempAufnahmen=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  
		  if (tempAufnahmen && [tempAufnahmen count])//Aufnahmen vorhanden
			{
				NSLog(@"tempAufnahmen: %@",[tempAufnahmen description]);
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmen indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					//[tempAufnahmen removeObjectAtIndex:KommentarIndex];
				  }
				if ([[tempAufnahmen objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
				  {
					[tempAufnahmen removeObjectAtIndex:0];
				  }
				
				//NSLog(@"tempAufnahmen: %@",[tempAufnahmen description]);
				if ([tempAufnahmen count])
				  {
					int letzte=0;
					NSEnumerator* enumerator=[tempAufnahmen objectEnumerator];
					id eineAufnahme;						
					NSString* tempLeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
						while (eineAufnahme=[enumerator nextObject])
						  {
							NSString* tempKommentarPfad=[tempLeserKommentarPfad stringByAppendingPathComponent:eineAufnahme];
							if ([Filemanager fileExistsAtPath:tempKommentarPfad])//Kommentar für diese Aufnahme ist da)
							  {
								  int n=[self AufnahmeNummerVon:eineAufnahme];
								  if (n>letzte)
									{
									  letzte=n;
									  letzteAufnahme=eineAufnahme;
									}
							  }
						   }//while enumerator
						tempLeserKommentarPfad=[tempLeserKommentarPfad stringByAppendingPathComponent:letzteAufnahme];
						lastKommentarString=[NSString stringWithContentsOfFile:tempLeserKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
						
                 NSDictionary* Attrs=[Filemanager attributesOfItemAtPath:tempLeserKommentarPfad error:NULL];
						NSNumber *fsize, *refs, *owner;
						NSDate *moddate;
						if (Attrs) 
						  {
							if ((refs = [Attrs objectForKey:NSFilePosixPermissions]))
                     {
								;//NSLog(@"Leser: %@   POSIX: %d\n",letzteAufnahme, [refs intValue]);
                     }
						  }
						
					}
				else
				  {
					NSLog(@"Keine Aufnahmen von: %@",derLeser);
				//NSLog(@"alleKommentareZuTitel: Kommentarordner von %@ ist leer",tempLeser);
				NSString* keineAufnahmeString=@"Für dieses Leser hat es keine Aufnahmen";
				lastKommentarString=keineAufnahmeString;
				  }
			}//[tempAufnahmen count]
		  else
		  {
		  NSLog(@"Leser %@ hat keine ",derLeser);
		  }
		  //[tempAufnahmen release];
		  
}//if exists LeserPfad
return lastKommentarString;

}



- (NSArray*)alleKommentareVonLeser:(NSString*)derLeser 
					  anProjektPfad:(NSString*)derProjektPfad 
						  bisAnzahl:(int)dieAnzahl
{
	BOOL erfolg;
	BOOL istDirectory;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	//NSLog(@"alleKommentarVonLeser: Leser: %@  derProjektPfad: %@  dieAnzahl: %d",derLeser ,derProjektPfad,dieAnzahl);
	NSMutableArray* tempKommentareArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	NSString* crSeparator=@"\r";
	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:NSLocalizedString(@"Comments",@"Anmerkungen")];
			//Kommentarordner des Lesers
		//NSLog(@"alleKommentareVonLeser: LeserPfad: %@",LeserKommentarPfad);
		if ([Filemanager fileExistsAtPath:LeserKommentarPfad isDirectory:&istDirectory]&&istDirectory)//Ordner des Lesers ist da)
		  {
			  //NSLog(@"Kommentarordner von %@ ist da",derLeser);
			 NSMutableArray*  tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
			 tempTitelArray= [[Filemanager contentsOfDirectoryAtPath:LeserKommentarPfad error:NULL]mutableCopy];
			  
			  if ([tempTitelArray count])
				{
				  if ([[tempTitelArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
					{
					  [tempTitelArray removeObjectAtIndex:0];
					}
				  
				 //NSLog(@"\nalleKommentareVonLeser: %@  KommentareArray: %@",derLeser,[tempTitelArray description]);
				 NSArray* sortArray=[self sortNachNummer:[tempTitelArray copy]];
				  tempTitelArray=(NSMutableArray*)[self sortNachNummer:tempTitelArray];
				  //NSLog(@"\nalleKommentareVonLeser  nach sortArray: %@\n",[tempTitelArray description]);
 
				  NSEnumerator* enumerator =[tempTitelArray objectEnumerator];
				  NSString* tempTitel;
				  int pos=0;
				  while ((tempTitel = [enumerator nextObject])&&pos<dieAnzahl) 
					{
					 NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:tempTitel];
					
					BOOL OK=[self mitMarkierungAufnehmenOptionAnPfad:tempAufnahmePfad];
					//if (OK)
					//NSLog(@"Kommentar zu File %@ kann aufgenommen werden",tempTitel);
					//else
					//NSLog(@"Kommentar zu File %@ kann nicht aufgenommen werden",tempTitel);
					
					  NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempTitel];
					  
					  if (OK&&[Filemanager fileExistsAtPath:tempKommentarPfad])//Kommentar existiert
					  {
					  NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
					  if (pos)
						{//Ab zweitem Kommentar Name entfernen
						  NSMutableArray* tempZeilenArray=[[NSMutableArray alloc]initWithCapacity:0];
						  tempZeilenArray=[[tempKommentarString componentsSeparatedByString:crSeparator]mutableCopy];
						  NSString* tempName=[tempZeilenArray objectAtIndex:0];
						  int n=[tempName length];
						  NSRange r=NSMakeRange(0,n-1);
						  tempName=[[tempZeilenArray objectAtIndex:0]substringFromIndex:n];
						  tempName=[NSString stringWithFormat:@"%@  %@",@"  -  ",tempName];
						  //[tempZeilenArray replaceObjectAtIndex:0 withObject:@"\n    -"];
						  [tempZeilenArray replaceObjectAtIndex:0 withObject:tempName];
						  
						  //
						  [tempZeilenArray removeObjectAtIndex:3];
						  
						  //
						  
						  
						  NSString* redZeile=[tempZeilenArray componentsJoinedByString:@" "];
						  tempKommentarString=[tempZeilenArray componentsJoinedByString:crSeparator];
						}
					  pos++;
					  [tempKommentareArray addObject:tempKommentarString];
					  }//OK
					}//enumerator
					 //NSLog(@"lastKommentarVonAllen:    Kommentar: %@", lastKommentarString);
				  
				 NSLog(@"nach enum:  Leser: %@  ",derLeser);
				 NSLog(@"nach enum:  Kommentarordner : %@", [tempKommentareArray description]);
				}
			  else
				{
				  NSLog(@"keine Kommentare da");//keine Kommentare
				}
			  
		  }
		else
		  {
			//Kein Kommentarordner für Leser
		  }
		  //NSLog(@"vor ende if: Leser: %@  Kommentarordner : %@",derLeser, tempKommentareArray);
}//if exists LeserPfad

//NSLog(@"vor return: Leser: %@  Kommentarordner : %@",derLeser, tempKommentareArray);

return tempKommentareArray;

}


- (NSArray*)lastKommentarVonAllenAnProjektPfad:(NSString*)derProjektPfad
{
	BOOL erfolg;
	BOOL istDirectory;
	NSString* lastKommentarString=@"";//Anmerkungen in Tabelle mit 6 Kolonnen konvertieren \r";
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSMutableArray* tempKommentarArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSMutableArray* LeserArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	if (![Filemanager fileExistsAtPath:tempProjektPfad isDirectory:&istDirectory]&&istDirectory)
	  {
	  NSLog(@"lastKommentarVonAllen: kein Archiv");
	  }
	  //NSLog(@"lastKommentarVonAllenAnProjektPfad: derProjektPfad: %@",derProjektPfad);
	LeserArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:tempProjektPfad error:NULL];
	if (![LeserArray count])
		{
		NSLog(@"lastKommentarVonAllen: Archiv ist leer");
		}				
	if ([[LeserArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
		  {
			[LeserArray removeObjectAtIndex:0];
		  }
	
	NSLog(@"lastKommentarVonAllenAnProjektPfad: LeserArray: %@",[LeserArray description]);
	NSEnumerator* enumerator =[LeserArray objectEnumerator];
	NSString* tempLeser;
	while (tempLeser = [enumerator nextObject]) 
	  {
		NSString* tempKommentar=[self lastKommentarVonLeser:tempLeser anProjektPfad:tempProjektPfad];
		if ([tempKommentar length])
		  {
			//NSLog(@"lastKommentarVonAllen A: tempLeser: %@ ",tempLeser);

			[tempKommentarArray addObject:tempKommentar];
			//NSLog(@"lastKommentarVonAllen B: tempLeser: %@ ",tempLeser);
		  }
	  }//enumerator
//
   NSLog(@"lastKommentarVonAllen:    Kommentar: %@", [tempKommentarArray description]);
return tempKommentarArray;
}



- (NSString*)heutigeKommentareVon:(NSString*)derLeser
{
	BOOL erfolg;
	BOOL istDirectory;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSLog(@"heutigeKommentareVon: LeserPfad: %@",derLeser);
	NSString* tempDatum=@"xxx";

   NSLog(@"heutigeKommentareVon  heute: %@   LeserPfad: %@",heuteDatumString,derLeser);

	NSString* heutigerKommentarString=@"*";	
	NSString* LeserPfad=[AdminProjektPfad stringByAppendingPathComponent:derLeser];//Leserordner im Archiv
	if ([Filemanager fileExistsAtPath:LeserPfad])
	  {
		NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:NSLocalizedString(@"Comments",@"Anmerkungen")];//Kommentarordner des Lesers
																							 //NSLog(@"lastKommentarVon: LeserPfad: %@",LeserKommentarPfad);
		if ([Filemanager fileExistsAtPath:LeserKommentarPfad isDirectory:&istDirectory]&&istDirectory)//Ordner des Lesers ist da)
		  {
			  NSLog(@"Kommentarordner da");
			  
			  NSArray* KommentareArray=[Filemanager contentsOfDirectoryAtPath:LeserKommentarPfad error:NULL];
			  if ([KommentareArray count])
				{
				  NSEnumerator* enumerator=[KommentareArray objectEnumerator];
				  NSString* tempKommentar;
				  while (tempKommentar=[enumerator nextObject])
					{
					NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempKommentar];
					NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
					  tempDatum=[self DatumVon:tempKommentarString];
					  NSLog(@"tempDatum: %@",tempDatum);
					  if ([tempDatum isEqualTo:heuteDatumString])
						  {
						  NSLog(@"Heutiger Kommentar da: %@",tempKommentarString);
						  heutigerKommentarString=tempKommentarString;
						  }
					  //NSLog(@"Kommentarordner letztes Objekt: %@",letzteAufnahme);
					}
				}
			  else
				{
				  NSLog(@"keine Kommentare da");//keine Kommentare
				}
			  
		  }
		else
		  {
			//Kein Kommentarordner für Leser
		  }
		
		
}//if exists LeserPfad

return heutigerKommentarString;
}




- (NSArray*)alleKommentareNachNamenAnProjektPfad:(NSString*)derProjektPfad bisAnzahl:(int)dieAnzahl
{
	BOOL erfolg;
	BOOL istDirectory;
	NSMutableArray* alleKommentareArray=[[NSMutableArray alloc]initWithCapacity:0];

	NSFileManager *Filemanager=[NSFileManager defaultManager];
		NSMutableArray* tempKommentarArray=[[NSMutableArray alloc]initWithCapacity:0];
		
		NSMutableArray* LeserArray=[[NSMutableArray alloc]initWithCapacity:0];
		NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
		
		if (![Filemanager fileExistsAtPath:tempProjektPfad isDirectory:&istDirectory]&&istDirectory)
		  {
			NSLog(@"alleKommentareNachNamen: kein Archiv");
			
		  }
		LeserArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:tempProjektPfad error:NULL];
		if ([[LeserArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
		  {
			[LeserArray removeObjectAtIndex:0];
		  }
		if (![LeserArray count])
		  {
			NSLog(@"alleKommentareNachNamen: Archiv ist leer");
			
			return alleKommentareArray;
		  }				
		
		//NSLog(@"alleKommentareNachNamen: LeserArray: %@",[LeserArray description]);
		NSEnumerator* enumerator =[LeserArray objectEnumerator];
		NSString* tempLeser;
		while (tempLeser = [enumerator nextObject]) 
		  {
			NSArray* tempArray=[self alleKommentareVonLeser:tempLeser
											   anProjektPfad:tempProjektPfad 
												   bisAnzahl:dieAnzahl];
			//NSLog(@"alleKommentareVonLeser: tempArray: %@",[tempArray description]);

			if ([tempArray count])
			  {
				[alleKommentareArray addObjectsFromArray:tempArray];
				//NSLog(@"alleKommentareNachNamen: tempLeser: %@ ",tempLeser);
			  }
		  }//enumerator
		   //NSLog(@"alleKommentareNachNamen:    Kommentar: %@", alleKommentareArray);
		
		return alleKommentareArray;
}



- (NSArray*)TitelArrayVon:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
	//NSLog(@"TitelArrayVon: derLeser: %@  derProjektPfad: %@",derLeser, derProjektPfad);
	NSFileManager *Filemanager=[NSFileManager defaultManager];

	NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	//NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:kommentar];//Kommentarordner des Lesers

	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
		  tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  if ([tempAufnahmenArray count])//Aufnahmen vorhanden
			{
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmenArray indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmenArray removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Liste entfernen
				  }
				if ([tempAufnahmenArray count])
				  {
					if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
					  {
						[tempAufnahmenArray removeObjectAtIndex:0];
						
					  }
					//NSLog(@"\n\nTitelArrayVon:  tempAufnahmenArray: %@\n\n",[tempAufnahmenArray description]);
					
					NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
					id eineAufnahme;
					while (eineAufnahme=[enumerator nextObject])
					  {
						//NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
						NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
						//NSLog(@"tempAufnahmePfad: %@",tempAufnahmePfad);
						if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da)
						  {
							  NSString* tempTitel=[self AufnahmeTitelVon:eineAufnahme];
							  if ([tempTitel length])
								{
								  if (![tempTitelArray containsObject:tempTitel])
									{
									  [tempTitelArray insertObject: tempTitel atIndex:[tempTitelArray count]];
									}
								}
							  //NSLog(@"TitelArrayVon: %@  tempTitel: %@",derLeser,tempTitel);
						  }
						else
						  {
							//NSLog(@"kein Kommentare da");//keine Kommentare
							
						  }
						}//while enumerator
						 //NSLog(@"TitelArrayVon:  tempTitelArray: %@",[tempTitelArray description]);
					
					}// if tempAufnahmen count
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  
		  
		  
}//if exists LeserPfad

//NSLog(@"TitelArrayVon: ende");
return tempTitelArray;
}


- (NSArray*)TitelMitKommentarArrayVon:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
	/*
	Sucht alle Titel von 'derLeser' am Projektpfad 'derProjektPfad', die einen Kommentar haben 
	*/
	//NSLog(@"TitelMitKommentarArrayVon: derLeser: %@  derProjektPfad: %@",derLeser, derProjektPfad);
	NSFileManager *Filemanager=[NSFileManager defaultManager];

	NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];

	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	NSString* KommentarString=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:KommentarString];//Kommentarordner des Lesers
	BOOL KommentarordnerDa=[Filemanager fileExistsAtPath:LeserKommentarPfad];
	if ([Filemanager fileExistsAtPath:LeserPfad]&&KommentarordnerDa)//Ordner des Lesers und der Kommentarordner ist da
	  {
		  NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
		  tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  if ([tempAufnahmenArray count])//Aufnahmen vorhanden
			{
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmenArray indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmenArray removeObjectAtIndex:KommentarIndex];//Zeile mit Kommentarordner aus Liste entfernen
				  }
				if ([tempAufnahmenArray count])
				  {
					if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
					  {
						[tempAufnahmenArray removeObjectAtIndex:0];
						
					  }
					//NSLog(@"\n\nTitelArrayVon:  tempAufnahmenArray: %@\n\n",[tempAufnahmenArray description]);
					
					NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
					id eineAufnahme;
					while (eineAufnahme=[enumerator nextObject])
					  {
						//NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
						NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
						//NSLog(@"TitelMitKommentarArrayVon: tempAufnahmePfad: %@",tempAufnahmePfad);
						if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da
						  {
						  NSString* tempAufnahmeKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:eineAufnahme];//Pfad des Kommentars
						  if ([Filemanager fileExistsAtPath:tempAufnahmeKommentarPfad])// ein Kommentar ist da
						  {
							  NSString* tempTitel=[self AufnahmeTitelVon:eineAufnahme];
							  if ([tempTitel length])
								{
								  if (![tempTitelArray containsObject:tempTitel])
									{
									  [tempTitelArray insertObject: tempTitel atIndex:[tempTitelArray count]];
									}
								}
							  //NSLog(@"TitelArrayVon: %@  tempTitel: %@",derLeser,tempTitel);
							  }//Kommentar für Aufnahme da
						  }
						else
						  {
							//NSLog(@"kein Kommentare da");//keine Kommentare
							
						  }
						}//while enumerator
						 //NSLog(@"TitelArrayVon:  tempTitelArray: %@",[tempTitelArray description]);
					
					}// if tempAufnahmen count
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  
		  
		  
}//if exists LeserPfad

//NSLog(@"TitelArrayVon: ende");
return tempTitelArray;
}




- (NSArray*)TitelArrayVonAllenAnProjektPfad:(NSString*)derProjektPfad 
						  bisAnzahlProLeser:(int)dieAnzahl
{
	/*
	Sucht alle Titel in einem Projekt mit einem Kommentar
	
	*/
	BOOL istDirectory;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSMutableArray* tempNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSLog(@"TitelArrayVonAllenAnPfad  derProjektPfad: %@\n AdminLeseboxPfad: %@\nAdminArchivPfad: %@", derProjektPfad,AdminLeseboxPfad,AdminArchivPfad);
	NSLog(@"AdminProjektPfad: %@",AdminProjektPfad);
	NSMutableArray* tempTitelArrayVonAllen= [[NSMutableArray alloc]initWithCapacity:0];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	if ([Filemanager fileExistsAtPath:tempProjektPfad isDirectory:&istDirectory]&&istDirectory)
	{
	tempNamenArray=[[Filemanager contentsOfDirectoryAtPath:tempProjektPfad error:NULL]mutableCopy];
	[tempNamenArray removeObject:@".DS_Store"];
	NSLog(@"TitelArrayVonAllenAnPfad  tempNamenArray: %@", [tempNamenArray description]);

	NSEnumerator* LeserEnumerator=[tempNamenArray objectEnumerator];
	id einLeser;
	while (einLeser=[LeserEnumerator nextObject])
	  {
		// Vorhandene Titel suchen
		NSArray* tempTitelArray=[self TitelMitKommentarArrayVon:einLeser anProjektPfad:tempProjektPfad];
		
		//NSLog(@"TitelArrayVonAllenAnProjektPfad  Leser: %@  tempTitelArray: %@%@",einLeser,@"\r", [tempTitelArrayVonAllen description]);
		
		if ([tempTitelArray count])
			{
			id einTitel;
			int anzTitelVonLeser=0;
			NSEnumerator* TitelEnumerator=[tempTitelArray objectEnumerator];
			while (einTitel=[TitelEnumerator nextObject])
			  {
				
				if (![tempTitelArrayVonAllen containsObject:einTitel]&&anzTitelVonLeser<dieAnzahl)
				  {
					[tempTitelArrayVonAllen addObject:einTitel];
					anzTitelVonLeser++;
				  }
				
			  }//while einTitel
				
			}//tempTitelArray count
	  }//while einLeser
	//NSLog(@"TitelArrayVonAllenAnPP   tempTitelArrayVonAllen: %@%@",@"\r",[tempTitelArrayVonAllen description]);
	
	}
	else
	{
	NSLog(@"Kein Ordner fuer Projekt: %@",tempProjektPfad);
	}
	//[tempTitelArrayVonAllen retain];
	return tempTitelArrayVonAllen;
}




- (NSArray*)LeserArrayVonTitel:(NSString*)derTitel
{
	NSLog(@"LeserArrayVonTitel: AdminProjektPfad: %@",AdminProjektPfad);
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSMutableArray* tempLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	
	NSEnumerator* enumerator=[AdminProjektNamenArray objectEnumerator];
	id einLeser;
	while (einLeser=[enumerator nextObject])
	{
		NSString* LeserPfad=[AdminProjektPfad stringByAppendingPathComponent:einLeser];
		NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
			
		if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
			{
				NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
				tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
				if ([tempAufnahmenArray count])//Aufnahmen vorhanden
				{
					int KommentarIndex=NSNotFound;
					KommentarIndex=[tempAufnahmenArray indexOfObject:locKommentar];
					if (!(KommentarIndex==NSNotFound))
					{
						[tempAufnahmenArray removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Liste entfernen
					}
					
					if ([tempAufnahmenArray count])
					{
						if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
						{
							[tempAufnahmenArray removeObjectAtIndex:0];
							
						}
						//NSLog(@"TitelArrayVon:  tempAufnahmenArray: %@",[tempAufnahmenArray description]);
						
						NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
						id eineAufnahme;
						while (eineAufnahme=[enumerator nextObject])
						{
							//NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
							NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
							//NSLog(@"tempAufnahmePfad: %@",tempAufnahmePfad);
							if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da)
							  {
								  //if ([[[self AufnahmeTitelVon:eineAufnahme]lowercaseString] isEqualToString:[derTitel lowercaseString]])
								  if ([[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel])
									{
									  NSString* 	tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:eineAufnahme];
									  if ([Filemanager fileExistsAtPath:tempKommentarPfad])// Kommentar für eineAufnahme ist da)
										{
											if (![tempLeserArray containsObject:einLeser])
											  {
												[tempLeserArray addObject:einLeser];
											  }
										}
								}
								  //NSLog(@"tempLeserArray: %@  tempTitel: %@",derLeser,tempTitel);
							}
							else
							{
								//NSLog(@"kein Leser mit diesem Titel");//
								
							}
						}//while enumerator
						 //NSLog(@"tempLeserArray: %@",[tempLeserArray description]);
						
					}// if tempAufnahmen count
					else
					{
						//NSLog(@"Keine Aufnahmen von: %@",derLeser);
					}
			}//[tempAufnahmen count]
				
				
				
}//if exists LeserPfad



	}//while (einLeser

//NSLog(@"tempLeserArray: %@",[tempLeserArray description]);
return tempLeserArray;
}


- (NSArray*)LeserArrayAnProjektPfad:(NSString*)derProjektPfad
{
	//NSLog(@"LeserArrayAnProjektPfad:  derProjektPfad: %@",derProjektPfad);
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSMutableArray* tempLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	
	NSMutableArray* tempProjektNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	tempProjektNamenArray=[[Filemanager contentsOfDirectoryAtPath:tempProjektPfad error:NULL]mutableCopy];
	if (tempProjektNamenArray)
	{
		if ([[tempProjektNamenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
			{
				[tempProjektNamenArray removeObjectAtIndex:0];
								
			}
		//NSLog(@"LeserArrayAnProjektPfad: tempProjektNamenArray: %@",[tempProjektNamenArray description]);
	}//if tempProjektnamenArray
	//NSLog(@"LeserArrayAnProjektPfad: tempProjektNamenArray: %@",[tempProjektNamenArray description]);
	//[tempProjektNamenArray retain];
return tempProjektNamenArray;
}

- (NSArray*)LeserArrayVonTitel:(NSString*)derTitel anProjektPfad:(NSString*)derProjektPfad
{
	//NSLog(@"LeserArrayVonTitel: derTitel: %@  derProjektPfad: %@",derTitel,derProjektPfad);
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSMutableArray* tempLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	
	NSMutableArray* tempProjektNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	tempProjektNamenArray=[[Filemanager contentsOfDirectoryAtPath:tempProjektPfad error:NULL]mutableCopy];
	if (tempProjektNamenArray)
	{
		if ([[tempProjektNamenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
			{
				[tempProjektNamenArray removeObjectAtIndex:0];
								
			}
		//NSLog(@"LeserArrayVonTitel: tempProjektNamenArray: %@",[tempProjektNamenArray description]);
		NSEnumerator* enumerator=[tempProjektNamenArray objectEnumerator];
		id einLeser;
		while (einLeser=[enumerator nextObject])
		{
			
			NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:einLeser];
			NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
				
				if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
				{
					NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
					tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
					if ([tempAufnahmenArray count])//Aufnahmen vorhanden
					{
						int KommentarIndex=NSNotFound;
						KommentarIndex=[tempAufnahmenArray indexOfObject:locKommentar];
						if (!(KommentarIndex==NSNotFound))
						{
							[tempAufnahmenArray removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Liste entfernen
						}
						
						if ([tempAufnahmenArray count])
						{
							if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
							{
								[tempAufnahmenArray removeObjectAtIndex:0];
								
							}
							//NSLog(@"TitelArrayVon:  tempAufnahmenArray: %@",[tempAufnahmenArray description]);
							
							NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
							id eineAufnahme;
							while (eineAufnahme=[enumerator nextObject])
							{
								//NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
								NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
								//NSLog(@"tempAufnahmePfad: %@",tempAufnahmePfad);
								if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da)
								{
									//if ([[[self AufnahmeTitelVon:eineAufnahme]lowercaseString] isEqualToString:[derTitel lowercaseString]])
									if ([[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel])
									{
										NSString* 	tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:eineAufnahme];
										if ([Filemanager fileExistsAtPath:tempKommentarPfad])// Kommentar für eineAufnahme ist da)
										{
											if (![tempLeserArray containsObject:einLeser])
											{
												[tempLeserArray addObject:einLeser];
											}
										}
								}
									//NSLog(@"tempLeserArray: %@  tempTitel: %@",derLeser,tempTitel);
							}
								else
								{
									//NSLog(@"kein Leser mit diesem Titel");//
									
								}
						}//while enumerator
						 //NSLog(@"tempLeserArray: %@",[tempLeserArray description]);
							
					}// if tempAufnahmen count
						else
						{
							//NSLog(@"Keine Aufnahmen von: %@",derLeser);
						}
			}//[tempAufnahmen count]
					
					
					
}//if exists LeserPfad



	}//while (einLeser
}//if tempProjektnamenArray
 //NSLog(@"tempLeserArray: %@",[tempLeserArray description]);
return tempLeserArray;
}




- (NSString*)lastKommentarVonLeser:(NSString*)derLeser mitTitel:(NSString*)derTitel
{
	BOOL erfolg;
	BOOL istDirectory;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSLog(@"lastKommentarVonLeser: LeserPfad: %@ mitTitel: %@",derLeser,derTitel);
	NSString* letzteAufnahme=@"xxx";
	NSString* lastKommentarMitTitelString=[NSString string];	
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* LeserPfad=[AdminProjektPfad stringByAppendingPathComponent:derLeser];
	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  NSMutableArray* tempAufnahmen=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  if ([tempAufnahmen count])//Aufnahmen vorhanden
			{
				long KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmen indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmen removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Array entfernen
				  }
				//NSLog(@"tempAufnahmen: %@",[tempAufnahmen description]);
				if ([tempAufnahmen count])
				  {
					int letzte=0;
					if ([[tempAufnahmen objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
					  {
						[tempAufnahmen removeObjectAtIndex:0];
					  }
					
					NSEnumerator* enumerator=[tempAufnahmen objectEnumerator];
					id eineAufnahme;
					while (eineAufnahme=[enumerator nextObject])
					  {
						//NSLog(@"eineAufnahme: %@",eineAufnahme);
						if ([[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel])
						  {
							int n=[self AufnahmeNummerVon:eineAufnahme];
							if (n>letzte)
							  {
								letzte=n;
								letzteAufnahme=eineAufnahme;
								
							  }
						  }
					  }//while enumerator
					   //NSLog(@"Leserordner letztes Objekt: %@",letzteAufnahme);
					NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers
						NSString* lastKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:letzteAufnahme];
						if ([Filemanager fileExistsAtPath:lastKommentarPfad])//Kommentar für letzte Aufnahme ist da)
						  {
							  lastKommentarMitTitelString=[NSString stringWithContentsOfFile:lastKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
							  //NSLog(@"lastKommentarMitTitelString: %@  TitelPfad: %@",lastKommentarMitTitelString,lastKommentarPfad);
							  
						  }
						else
						  {
							//NSLog(@"kein Kommentare da");//keine Kommentare
							
						  }
					}
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  
		  
		  
}//if exists LeserPfad
return lastKommentarMitTitelString;

}

- (NSArray*)TitelMitAnzahlArrayVon:(NSString*)derLeser
{
	NSString* titel=@"titel";
	NSString* anzahl=@"anzahl";

	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSMutableArray* tempTitelDicArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* LeserPfad=[AdminProjektPfad stringByAppendingPathComponent:derLeser];
	//NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:kommentar];//Kommentarordner des Lesers
	
	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  //NSLog(@"TitelMitAnzahlArrayVon: %@" ,derLeser);
		  NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
		  tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  if ([tempAufnahmenArray count])//Aufnahmen vorhanden
			{
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmenArray indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmenArray removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Liste entfernen
				  }
				[tempAufnahmenArray removeObject:@"Kommentar"];//Sicherheit. Eventuell von alten Versionen noch vorhanden
				if ([tempAufnahmenArray count])
				  {
					if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
					  {
						[tempAufnahmenArray removeObjectAtIndex:0];
						
					  }
					//NSLog(@"TitelMtAnzahlArrayVon:  tempAufnahmenArray: %@",[tempAufnahmenArray description]);
					tempAufnahmenArray=(NSMutableArray*)[self sortNachABC:tempAufnahmenArray];
					//NSLog(@"TitelMtAnzahlArrayVon:  tempAufnahmenArray nach sort: %@",[tempAufnahmenArray description]);

					NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
					id eineAufnahme;
					int anz=1;
					NSString* lastTitel=[NSString string];
					while (eineAufnahme=[enumerator nextObject])
					  {
						//NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
						NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
						//NSLog(@"tempAufnahmePfad: %@",tempAufnahmePfad);
						if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da)
						  {
							  NSString* tempTitel=[self AufnahmeTitelVon:eineAufnahme];
							  if ([tempTitel length])
								{
								  if ([tempTitelArray containsObject:tempTitel])
									{
									  anz++;
									 // if (![lastTitel length])
										{
										 //NSLog(@"Titel schon in Liste       tempTitel: %@ anz: %d lastTitel: %@",tempTitel,anz, lastTitel);
										}
									}
								  else
									{
									  //NSLog(@"neuer Titel: %@ lastTitel: %@  anz: %d",tempTitel,lastTitel,anz);
									  [tempTitelArray insertObject: tempTitel atIndex:[tempTitelArray count]];
									  if ((![tempTitel isEqualToString:lastTitel])&&[lastTitel length])
										{
										  NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:lastTitel
																										  forKey:titel];
										  [tempDic setObject:[NSNumber numberWithInt:anz] forKey:anzahl];
										  [tempTitelDicArray insertObject:tempDic 
																  atIndex:[tempTitelDicArray count]];
										  
										  anz=1;
										  
										}
									  lastTitel=tempTitel;
									}
								}
							  //NSLog(@"TitelMitAnzahlArrayVon: %@  tempTitel: %@",derLeser,tempTitel);
						  }
						else
						  {
							//NSLog(@"kein Kommentare da");//keine Kommentare
							
						  }
						}//while enumerator
					//letztes Dic einsetzen:
					NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:lastTitel
																					forKey:titel];
					[tempDic setObject:[NSNumber numberWithInt:anz] forKey:anzahl];
					[tempTitelDicArray insertObject:tempDic 
											atIndex:[tempTitelDicArray count]];
					
						 //NSLog(@"TitelArrayVon:  tempTitelArray: %@",[tempTitelArray description]);
					
					}// if tempAufnahmen count
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  
		  
		  
}//if exists LeserPfad

//NSLog(@"TitelMitAnzahlArrayVon: %@   %@",derLeser, [tempTitelDicArray description]);
return tempTitelDicArray;
}


- (NSArray*)TitelMitAnzahlArrayVon:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
	NSString* titel=@"titel";
	NSString* anzahl=@"anzahl";

	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSMutableArray* tempTitelDicArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
	NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
	
	NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
	//NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:kommentar];//Kommentarordner des Lesers
	
	if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
		  //NSLog(@"TitelMitAnzahlArrayVon: %@" ,derLeser);
		  NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
		  tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
		  if ([tempAufnahmenArray count])//Aufnahmen vorhanden
			{
				int KommentarIndex=NSNotFound;
				KommentarIndex=[tempAufnahmenArray indexOfObject:locKommentar];
				if (!(KommentarIndex==NSNotFound))
				  {
					[tempAufnahmenArray removeObjectAtIndex:KommentarIndex];//Kommentarordner aus Liste entfernen
				  }
				if ([tempAufnahmenArray count])
				  {
					if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
					  {
						[tempAufnahmenArray removeObjectAtIndex:0];
						
					  }
					//NSLog(@"TitelMtAnzahlArrayVon:  tempAufnahmenArray: %@",[tempAufnahmenArray description]);
					tempAufnahmenArray=(NSMutableArray*)[self sortNachABC:tempAufnahmenArray];
					//NSLog(@"TitelMtAnzahlArrayVon:  tempAufnahmenArray nach sort: %@",[tempAufnahmenArray description]);

					NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
					id eineAufnahme;
					int anz=1;
					NSString* lastTitel=[NSString string];
					while (eineAufnahme=[enumerator nextObject])
					  {
						//NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
						NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
						//NSLog(@"tempAufnahmePfad: %@",tempAufnahmePfad);
						if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da)
						  {
							  NSString* tempTitel=[self AufnahmeTitelVon:eineAufnahme];
							  if ([tempTitel length])
								{
								  if ([tempTitelArray containsObject:tempTitel])
									{
									  anz++;
									 // if (![lastTitel length])
										{
										 //NSLog(@"Titel schon in Liste       tempTitel: %@ anz: %d lastTitel: %@",tempTitel,anz, lastTitel);
										}
									}
								  else
									{
									  //NSLog(@"neuer Titel: %@ lastTitel: %@  anz: %d",tempTitel,lastTitel,anz);
									  [tempTitelArray insertObject: tempTitel atIndex:[tempTitelArray count]];
									  if ((![tempTitel isEqualToString:lastTitel])&&[lastTitel length])
										{
										  NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:lastTitel
																										  forKey:titel];
										  [tempDic setObject:[NSNumber numberWithInt:anz] forKey:anzahl];
										  [tempTitelDicArray insertObject:tempDic 
																  atIndex:[tempTitelDicArray count]];
										  
										  anz=1;
										  
										}
									  lastTitel=tempTitel;
									}
								}
							  //NSLog(@"TitelMitAnzahlArrayVon: %@  tempTitel: %@",derLeser,tempTitel);
						  }
						else
						  {
							//NSLog(@"kein Kommentare da");//keine Kommentare
							
						  }
						}//while enumerator
					//letztes Dic einsetzen:
					NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithObject:lastTitel
																					forKey:titel];
					[tempDic setObject:[NSNumber numberWithInt:anz] forKey:anzahl];
					[tempTitelDicArray insertObject:tempDic 
											atIndex:[tempTitelDicArray count]];
					
						 //NSLog(@"TitelArrayVon:  tempTitelArray: %@",[tempTitelArray description]);
					
					}// if tempAufnahmen count
				else
				  {
					//NSLog(@"Keine Aufnahmen von: %@",derLeser);
				  }
			}//[tempAufnahmen count]
		  
		  
		  
}//if exists LeserPfad

//NSLog(@"TitelMitAnzahlArrayVon: %@   %@",derLeser, [tempTitelDicArray description]);
return tempTitelDicArray;
}

- (int)AufnahmeNummerVon:(NSString*) dieAufnahme
{
	NSString* tempAufnahme=[dieAufnahme copy];
	int posLeerstelle1=0;
	int posLeerstelle2=0;
	int Leerstellen=0;
	int tempNummer=0;
	
	int charpos=0;
	int Leerschlag=0;
	while (charpos<[tempAufnahme length])
	{
		if ([tempAufnahme characterAtIndex:charpos]==' ')
		{
			Leerschlag++;
			if (Leerschlag==1)
				Leerstellen++;
			if (Leerstellen==1)
			{
				posLeerstelle1=charpos;//erste Leerstelle gefunden
			}
			if (Leerstellen==2)
			{
				posLeerstelle2=charpos;//zweite Leerstelle gefunden
			}
		}
		else //kein Leerschlag
		{
			Leerschlag=0;
		}
		charpos++;
	}//while pos
	 //NSLog(@"indexTitelString: %@   pos Leerstelle1:%d pos Leerstelle2:%d",indexTitelString,posLeerstelle1,posLeerstelle2);
	
	if ((posLeerstelle2 - posLeerstelle1)>1)
	{
		NSRange tempRange=NSMakeRange(posLeerstelle1+1,(posLeerstelle2-posLeerstelle1));
		tempNummer=[[tempAufnahme substringWithRange:tempRange] intValue];
	}
	else
	{
		tempNummer=-1;
	}
	return tempNummer;
}//AufnahmeNummerVon



- (NSString*)AufnahmeTitelVon:(NSString*) dieAufnahme
{

	NSString* tempAufnahme=[dieAufnahme copy];
	int posLeerstelle1=0;
	int posLeerstelle2=0;
	int Leerstellen=0;
	NSString*  tempString;
	
	int charpos=0;
	int Leerschlag=0;
	int TitelChars=0;
	while (charpos<[tempAufnahme length])
	  {
		if ([tempAufnahme characterAtIndex:charpos]==' ')
		  {
			Leerschlag++;
			if (Leerschlag==1)
				Leerstellen++;
			if (Leerstellen==1)
			  {
				posLeerstelle1=charpos;//erste Leerstelle gefunden
			  }
			if (Leerstellen==2)
			  {
				posLeerstelle2=charpos;//zweite Leerstelle gefunden
			  }
		  }
		else //kein Leerschlag
		  {
			Leerschlag=0;
			if (Leerstellen==2)
				TitelChars++; //chars nach 2. Leerstelle
		  }
		charpos++;
	  }//while pos
	
	//NSLog(@"tempAufnahme: %@   pos Leerstelle1:%d pos Leerstelle2:%d  TitelChars: %d",tempAufnahme,posLeerstelle1,posLeerstelle2,TitelChars);
	
	if ((posLeerstelle2 - posLeerstelle1)>1&&TitelChars)//Nummer an zweiter Stelle und chars nach 2. Leerstelle
	  {
		  tempString=[tempAufnahme substringFromIndex:posLeerstelle2+1];
	  }
	else
	  {
		tempString=[tempAufnahme copy];
	  }
	return tempString;
}//AufnahmeTitelVon


- (NSString*)KommentarVon:(NSString*) derKommentarString
{
	NSArray* tempMarkArray=[derKommentarString componentsSeparatedByString:@"\r"];
	//NSLog(@"tempMarkVon: anz Components: %d",[tempMarkArray count]);
	if ([tempMarkArray count]==6)//noch keine Zeile für Mark
	{
		NSString* tempKommentarString=[tempMarkArray objectAtIndex:5];
		return [tempMarkArray objectAtIndex:5];
		//[tempKommentarString release];
		tempKommentarString=[derKommentarString copy];
		int AnzReturns=0;
		int pos=0;
		int KommentarReturnAlt=5;
		while((AnzReturns<KommentarReturnAlt)&&(pos<[tempKommentarString length]))
		{
			if (([tempKommentarString characterAtIndex:pos]=='\r')||([tempKommentarString characterAtIndex:pos]=='\n'))
			{
				AnzReturns++;
			}
			pos++;
		}//while
		tempKommentarString=[tempKommentarString substringFromIndex:pos];
		//NSLog(@"******  tempKommentarString: %@", tempKommentarString);
		
		return tempKommentarString;
	}//noch keine Zeile für Mark
	else if ([tempMarkArray count]==8)//neue version von Kommentar
	{
		NSString* tempKommentarString=[tempMarkArray objectAtIndex:7];
		
		return tempKommentarString;
		
	}
	return @"alt";
}

- (NSString*)DatumVon:(NSString*) derKommentarString
{
	NSString* tempDatumString;
	tempDatumString=[derKommentarString copy];
	int AnzReturns=0;
	int returnpos1=0,returnpos2=0;
	int pos=0;
	while(pos<[tempDatumString length])
	  {
		if (([tempDatumString characterAtIndex:pos]=='\r')||([tempDatumString characterAtIndex:pos]=='\n'))
		  {
			AnzReturns++;
			if ((returnpos1==0)&&(AnzReturns==DatumReturn))
			  {
				returnpos1=pos;
			  }
			else
			//if ((returnpos2==0)&&(AnzReturns==DatumReturn+1))
				if (returnpos1&&(returnpos2==0))
			  {
				returnpos2=pos;
			  }
			
		  }
		pos++;
	  }//while
	
	returnpos1++;
	if (returnpos2>returnpos1)
	  {
		NSRange r=NSMakeRange(returnpos1,returnpos2-returnpos1);
		tempDatumString=[tempDatumString substringWithRange:r];
		if ([tempDatumString length]==0)
		  {
			tempDatumString=@"--";
			return tempDatumString;
		  }
		//NSLog(@"tempDatumString: %@", tempDatumString);
		pos=0;
		int leerpos=0;
		while(pos<[tempDatumString length])
		  {
			if ([tempDatumString characterAtIndex:pos]==' ')
			  {
				leerpos=pos;
			  }
			pos++;
		  }//while
		if (leerpos)
		  {
		r=NSMakeRange(0,leerpos);
		tempDatumString=[tempDatumString substringWithRange:r];
		NSLog(@"DatumVon tempDatumString: %@", tempDatumString);
		  }
		else
		  {
			tempDatumString=@" ";
		  }
	  }
	
	
	return tempDatumString;
	
}

- (NSString*)BewertungVon:(NSString*) derKommentarString
{
	NSString* tempBewertungString;
	//[tempKommentarString release];
	tempBewertungString=[derKommentarString copy];
	int AnzReturns=0;
	int returnpos1=0,returnpos2=0;
	int pos=0;
	while(pos<[tempBewertungString length])
	  {
		if (([tempBewertungString characterAtIndex:pos]=='\r')||([tempBewertungString characterAtIndex:pos]=='\n'))
		  {
			AnzReturns++;
			if ((returnpos1==0)&&(AnzReturns==BewertungReturn))
			  {
				returnpos1=pos;
			  }
			else
				//if ((returnpos2==0)&&(AnzReturns==DatumReturn+1))
				if (returnpos1&&(returnpos2==0))
				  {
					returnpos2=pos;
				  }
			
		  }
		pos++;
	  }//while
	
	returnpos1++;
	if (returnpos2>returnpos1)
	  {
		NSRange r=NSMakeRange(returnpos1,returnpos2-returnpos1);
		tempBewertungString=[tempBewertungString substringWithRange:r];
		if ([tempBewertungString length]==0)
		  {
			tempBewertungString=@"--";
			return tempBewertungString;
		  }
		//NSLog(@"BewertungVon:		tempBewertungString: %@", tempBewertungString);
	  }
	else
	  {
		
	  }
	
	
	return tempBewertungString;
	
}


- (BOOL)AdminMarkVon:(NSString*) derKommentarString
{
	BOOL MarkSet=NO;
	NSArray* tempMarkArray=[derKommentarString componentsSeparatedByString:@"\r"];
	//NSLog(@"AdminMarkVon: anz Components: %d",[tempMarkArray count]);
	if ([tempMarkArray count]==8)//Zeile für Mark ist da
	{
		if ([[tempMarkArray objectAtIndex:6]isEqualToString:@"1"])
		{
			MarkSet=YES;
		}
	}
	
	
	return MarkSet;
}



- (NSString*)NoteVon:(NSString*) derKommentarString
{
	NSString* tempNotenString;
	//[tempKommentarString release];
	tempNotenString=[derKommentarString copy];
	int AnzReturns=0;
	int returnpos1=0,returnpos2=0;
	int pos=0;
	while(pos<[tempNotenString length])
	  {
		if (([tempNotenString characterAtIndex:pos]=='\r')||([tempNotenString characterAtIndex:pos]=='\n'))
		  {
			AnzReturns++;
			if ((returnpos1==0)&&(AnzReturns==NotenReturn))
			  {
				returnpos1=pos;
			  }
			else
				//if ((returnpos2==0)&&(AnzReturns==DatumReturn+1))
				if (returnpos1&&(returnpos2==0))
				  {
					returnpos2=pos;
				  }
			
		  }
		pos++;
	  }//while
	
	returnpos1++;
	if (returnpos2>returnpos1)
	  {
		NSRange r=NSMakeRange(returnpos1,returnpos2-returnpos1);
		tempNotenString=[tempNotenString substringWithRange:r];
		if ([tempNotenString length]==0)
		  {
			tempNotenString=@"--";
			return tempNotenString;
		  }
		//NSLog(@"NoteVon:		tempNotenString: %@", tempNotenString);
	  }
	else
	  {
		
	  }
	return tempNotenString;
	
}



- (int)UserMarkVon:(NSString*)derKommentarString
{
int UserMark=0;
	NSArray* tempMarkArray=[derKommentarString componentsSeparatedByString:@"\r"];
	//NSLog(@"UserMarkVon: anz Components: %d inhalt: %@",[tempMarkArray count],[tempMarkArray description]);
	if ([tempMarkArray count]==8)//Zeile für Mark da
	{
	//NSLog(@"UserMarkVon: Mark da");
	UserMark=[[tempMarkArray objectAtIndex:UserMarkReturn]intValue];
	}
	
return UserMark;

}


- (NSArray*)sortNachNummer:(NSArray*)derArray
{
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	tempArray =[derArray mutableCopy];
	//return derArray;
	//[derArray release];
	int anz=[tempArray count];
	BOOL tausch=YES;
	int index=0;
	int stop=0;
	//NSLog(@"sortNachNummer: derArray vor sortieren: %@",[derArray description]);
	while (tausch&&stop<100)
	  {
		tausch=NO;
		for (index=0;index<anz-1;index++)
		  {
			int n=[[[[tempArray objectAtIndex:index]componentsSeparatedByString:@" "]objectAtIndex:1]intValue];
			int m=[[[[tempArray objectAtIndex:index+1]componentsSeparatedByString:@" "]objectAtIndex:1]intValue];
			//NSLog(@"m: %d  n:%d",m,n);
			if (m>n)
			  {
				//NSLog(@"m: %d  n:%d",m,n);
				tausch=YES;
				[tempArray exchangeObjectAtIndex:index+1 withObjectAtIndex:index];
			  }
		  }//for index
		stop++;
	  }//while tausch
	   //NSLog(@"sortNachNummer: derArray nach sortieren: %@",[tempArray description]);
	
	
	return tempArray;
}

- (NSArray*)sortNachABC:(NSArray*)derArray
{
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	tempArray =[derArray mutableCopy];
	//return derArray;
	//[derArray release];
	int anz=[tempArray count];
	BOOL tausch=YES;
	int index=0;
	int stop=0;
	//NSLog(@"sortNachABC: derArray vor sortieren: %@",[derArray description]);
	while (tausch&&stop<100)
	  {
		tausch=NO;
		for (index=0;index<anz-1;index++)
		  {
			NSString* n=[[[tempArray objectAtIndex:index]componentsSeparatedByString:@" "]objectAtIndex:2];
			NSString* m=[[[tempArray objectAtIndex:index+1]componentsSeparatedByString:@" "]objectAtIndex:2];
			//NSLog(@"m: %@  n:%@",m,n);
			if ([m caseInsensitiveCompare:n]==NSOrderedDescending)
			  {
				//NSLog(@"tauschen:          m: %@  n:%@",m,n);
				tausch=YES;
				[tempArray exchangeObjectAtIndex:index+1 withObjectAtIndex:index];
			  }
		  }//for index
		stop++;
	  }//while tausch
	//NSLog(@"sortNachNummer: derArray nach sortieren: %@",[tempArray description]);

	
	return tempArray;
}

- (NSString*)alleKommentareVonHeute
{
	BOOL erfolg;
	BOOL istDirectory;
	NSString* lastKommentarString=@"";//Anmerkungen in Tabelle mit 6 Kolonnen konvertieren \r";
		NSFileManager *Filemanager=[NSFileManager defaultManager];
		
		
		NSMutableArray* LeserArray=[[NSMutableArray alloc]initWithCapacity:0];
		if (![Filemanager fileExistsAtPath:AdminProjektPfad isDirectory:&istDirectory]&&istDirectory)
		  {
			NSLog(@"lastKommentarVonHeute: kein Archiv");
		  }
		LeserArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:AdminProjektPfad error:NULL];
		if (![LeserArray count])
		  {
			NSLog(@"lastKommentarVonAllen: Archiv ist leer");
		  }				
		if ([[LeserArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
		  {
			[LeserArray removeObjectAtIndex:0];
		  }
		
		NSLog(@"lastKommentarVonHeute: LeserArray: %@",[LeserArray description]);
		NSEnumerator* enumerator =[LeserArray objectEnumerator];
		NSString* tempLeser;
		while (tempLeser = [enumerator nextObject]) 
		  {
           
           /* ev Fehler*/
			lastKommentarString=[lastKommentarString stringByAppendingString:[self lastKommentarVonLeser:tempLeser anProjektPfad:AdminProjektPfad]];
			//NSLog(@"lastKommentarVonAllen: tempLeser: %@ ",tempLeser);
			lastKommentarString=[lastKommentarString stringByAppendingString:@"\r\r"];
		  }//enumerator
		   //NSLog(@"lastKommentarVonHeute:    Kommentar: %@", lastKommentarString);

		return lastKommentarString;
}

- (NSString*)InitialenVon:(NSString*)derName
{
	NSString* tempstring =[derName copy];
	unichar  Anfangsbuchstabe=[tempstring characterAtIndex:0];
	NSMutableString* initial=[NSMutableString stringWithCharacters:&Anfangsbuchstabe length:1];
	int pos=0;;
	int i;
	for (i=0;i<(int)[tempstring length];i++)
	  {
		if([tempstring characterAtIndex:i]==' ')
			pos=i;
	  }
	if (pos>0)
	  {
		unichar  ZweiterBuchstabe=[tempstring characterAtIndex:(pos+1)];
		NSMutableString* s=[NSMutableString stringWithCharacters:&ZweiterBuchstabe length:1];
		initial=[[initial stringByAppendingString:s ]mutableCopy];
	  }
	return initial;
}


- (void)Markierungenreset
{
  int i;
  for (i=0;i<	[AdminProjektNamenArray count];i++)
	{
	[self MarkierungEntfernenFuerZeile:i];
	}//for
	[self setMark:NO];
}







@end

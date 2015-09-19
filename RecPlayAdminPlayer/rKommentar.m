#import "rKommentar.h"

enum
{lastKommentarOption= 0,
   heuteKommentarOption,
   lastVonTitelKommOption
};
enum
{alsTabelleFormatOption=0,
   alsAbsatzFormatOption
};
enum
{ausEinemProjektOption= 0,
   ausAktivenProjektenOption,
   ausAllenProjektenOption
};


typedef NS_ENUM(NSInteger,B)
{
   
   alleVonNameKommentarOption=1,
   alleVonTitelKommentarOption
};

typedef NS_ENUM(NSInteger, A)
{
   kDatum = 2,
   kBewertung,
   kNoten,
   kUserMark,
   kAdminMark,
   kKommentar
};


@implementation rKommentar
- (id) init
{
   self=[super initWithWindowNibName:@"RPKommentar"];
   
   AdminLeseboxPfad=@"";
   AuswahlOption=0;
   AbsatzOption=0;
   AnzahlOption=2;
   ProjektNamenOption=0;
   ProjektAuswahlOption=0;
   
   AdminProjektArray=[[NSMutableArray alloc] initWithCapacity:0];
   return self;
}

- (void)awakeFromNib
{
   //NSLog(@"Kommentar awakeFromNib");
   TitelArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   NamenArray=[[NSMutableArray alloc]initWithCapacity:0];
   [ProjektMatrix setDelegate:self];
   heuteDatumString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];//  12.09.2015 19:20:26

}

// Transfer von Kommentarkontroller
- (NSArray*)LeserArrayVonTitel:(NSString*)derTitel anProjektPfad:(NSString*)derProjektPfad
{
   //NSLog(@"LeserArrayVonTitel: derTitel: %@  derProjektPfad: %@",derTitel,derProjektPfad);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   NSMutableArray* tempLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
   //NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
   
   NSMutableArray* tempProjektNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
   NSLog(@"LeserArrayVonTitel: tempProjektPfad: %@",tempProjektPfad);
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
- (NSArray*)LeserArrayAnProjektPfad:(NSString*)derProjektPfad
{
   //NSLog(@"LeserArrayAnProjektPfad:  derProjektPfad: %@",derProjektPfad);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   NSMutableArray* tempLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
   //NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
   
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
   // NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
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
                 NSLog(@"KommentareMitTitel: eineAufnahme: %@    passendeAufnahmen: %d",eineAufnahme,passendeAufnahmen);
                 if ([[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel])
                 {
                    // m4a entfernen, txt anfuegen
                    NSString* tempKommentarTitel =[[eineAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
                    
                    NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempKommentarTitel];
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
   //NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
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
        //NSString* ArchivLeerString=NSLocalizedString(@"There are no comments for this project",@"Für dieses Projekt hat es keine Anmerkungen");
        NSString* ArchivLeerString=@"Für dieses Projekt hat es keine Anmerkungen";
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
            //NSString* ArchivLeerString=NSLocalizedString(@"There are no comments for this project",@"Für dieses Projekt hat es keine Anmerkungen");
            NSString* ArchivLeerString=@"Für dieses Projekt hat es keine Anmerkungen";
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
               //NSString* ArchivLeerString=NSLocalizedString(@"There are no comments for this project",@"Für dieses Projekt hat es keine Anmerkungen");
               NSString* ArchivLeerString=@"Für dieses Projekt hat es keine Anmerkungen";
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
- (NSArray*)KommentareVonLeser:(NSString*)derLeser
                      mitTitel:(NSString*)derTitel
                       maximal:(int)dieAnzahl
                 anProjektPfad:(NSString*)derProjektPfad
{
   // OK
   BOOL erfolg;
   BOOL istDirectory;
   NSString* crSeparator=@"\r";
   //NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   //
   NSMutableArray* KommentareVonLeserMitTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
   
   NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
   NSLog(@"KommentareVonLeser :Leser: %@ Titel: %@  LeserPfad: %@ ",derLeser,derTitel,LeserPfad);
   if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
        NSMutableArray* tempAufnahmen=[[NSMutableArray alloc]initWithCapacity:0];
        tempAufnahmen=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
        NSLog(@":   tempAufnahmen roh: %@",[tempAufnahmen description]);
        if ([tempAufnahmen count])//Aufnahmen vorhanden
        {
           double KommentarIndex=NSNotFound;
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
              NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:locKommentar];//Kommentarordner des Lesers OK
              NSLog(@":   LeserKommentarPfad: %@",LeserKommentarPfad); // ok
              int passendeAufnahmen=0;
              NSEnumerator* enumerator=[tempAufnahmen objectEnumerator];
              id eineAufnahme;
              int pos=0;
              while ((eineAufnahme=[enumerator nextObject])&&(passendeAufnahmen<dieAnzahl))
              {
                 NSLog(@"KommentareVonLeserMitTitel: eineAufnahme: %@    passendeAufnahmen: %d",eineAufnahme,passendeAufnahmen);
                 NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme]; // mit extension
                 
                 BOOL OK=[self mitMarkierungAufnehmenOptionAnPfad:tempAufnahmePfad];
                 
                 // temp
                 // OK=1;
                 
                 
                 if (OK&&[[self AufnahmeTitelVon:eineAufnahme] isEqualToString:derTitel]) // AufnahmeTitelVon entfernt extension
                 {
                    
                    {
                       // m4a entfernen, txt anfuegen
                       NSString* tempKommentarTitel =[[eineAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
                       NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempKommentarTitel]; // OK
                       
                       NSLog(@": tempKommentarPfad: %@",tempKommentarPfad);
                       
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
        NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
        //Kommentarordner des Lesers
        //NSLog(@"alleKommentareVonLeser: LeserPfad: %@",LeserKommentarPfad);
        if ([Filemanager fileExistsAtPath:LeserKommentarPfad isDirectory:&istDirectory]&&istDirectory)//KommentarOrdner des Lesers ist da)
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
              while ((tempTitel = [enumerator nextObject])&&pos<dieAnzahl) // RH 33 abc.txt
              {
                 // txt entfernen und m4a an titel anfuegen
                 NSString* tempAufnahmeTitel = [[tempTitel stringByDeletingLastPathComponent]stringByAppendingString:@"m4a"];
                 NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:tempTitel];
                 
                 BOOL OK=[self mitMarkierungAufnehmenOptionAnPfad:tempAufnahmePfad];
                 //if (OK)
                 //NSLog(@"Kommentar zu File %@ kann aufgenommen werden",tempTitel);
                 //else
                 //NSLog(@"Kommentar zu File %@ kann nicht aufgenommen werden",tempTitel);
                 
                 NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempTitel];
                 NSLog(@"tempKommentarPfad: %@",tempKommentarPfad);
                 
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

- (NSArray*)alleKommentareNachNamenAnProjektPfad:(NSString*)derProjektPfad bisAnzahl:(int)dieAnzahl
{
   NSLog(@"alleKommentareNachNamenAnProjektPfad: ProjektpFAD: %@",derProjektPfad);
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


- (NSString*)lastKommentarVonLeser:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
   BOOL erfolg;
   BOOL istDirectory;
   //NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
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
           long KommentarIndex=NSNotFound;
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
                 
                 // m4a entfernen, txt anfuegen
                 NSString* tempKommentarTitel =[[eineAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
                 NSString* tempKommentarPfad=[tempLeserKommentarPfad stringByAppendingPathComponent:tempKommentarTitel]; // OK
                 
                 
                 
                 if ([Filemanager fileExistsAtPath:tempKommentarPfad])//Kommentar für diese Aufnahme ist da)
                 {
                    //
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
           NSLog(@"Leser %@ hat keine Aufnahmen",derLeser);
        }
        //[tempAufnahmen release];
        
     }//if exists LeserPfad
   return lastKommentarString;
   
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


- (BOOL)AufnahmeIstMarkiertAnPfad:(NSString*)derAufnahmePfad
{
   BOOL istMarkiert=NO;
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSString* AnmerkungenPfad=[[derAufnahmePfad stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Anmerkungen"];
   
   AnmerkungenPfad=[AnmerkungenPfad stringByAppendingPathComponent:[derAufnahmePfad lastPathComponent]];
   NSLog(@"AufnahmeIstMarkiertAnPfad AnmerkungenPfad: %@",AnmerkungenPfad);
   if ([Filemanager fileExistsAtPath:AnmerkungenPfad])
   {
      //NSLog(@"File exists an Pfad: %@",derAufnahmePfad);
      NSString* tempKommentarString=[NSString stringWithContentsOfFile:AnmerkungenPfad encoding:NSMacOSRomanStringEncoding error:NULL];
      NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
      //NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
      if (tempKommentarArrary &&[tempKommentarArrary count])
      {
         NSNumber* AdminMarkNumber=[tempKommentarArrary objectAtIndex:kAdminMark];
         //NSLog(@"istMarkiert		AdminMarkNumber: %d",[AdminMarkNumber intValue]);
         
         istMarkiert=[AdminMarkNumber intValue];
         
      }
      
      
   }//file exists
   return istMarkiert;
}


- (BOOL)mitMarkierungAufnehmenOptionAnPfad:(NSString*)derAufnahmePfad
{
   BOOL AufnehmenOK=YES;
 //  BOOL nurMarkierteAufnehmenOK=nurMarkierteOption;
   BOOL AufnahmeIstMarkiertOK=[self AufnahmeIstMarkiertAnPfad:derAufnahmePfad];
   if ([nurMarkierteCheck state] &&!AufnahmeIstMarkiertOK)
   {
      AufnehmenOK=NO;
   }
   return AufnehmenOK;
}

- (NSArray*)TitelArrayVon:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
   //NSLog(@"TitelArrayVon: derLeser: %@  derProjektPfad: %@",derLeser, derProjektPfad);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
   // NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
   NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
   
   NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
   //NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:kommentar];//Kommentarordner des Lesers
   
   if ([Filemanager fileExistsAtPath:LeserPfad])//Ordner des Lesers ist da
	  {
        NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
        tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
        if ([tempAufnahmenArray count])//Aufnahmen vorhanden
        {
           double KommentarIndex=NSNotFound;
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
                    NSString* tempTitel=[[self AufnahmeTitelVon:eineAufnahme]stringByDeletingPathExtension];
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
   tempString = [tempString stringByDeletingPathExtension];
   return tempString;
}//AufnahmeTitelVon


- (NSArray*)TitelMitKommentarArrayVon:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad
{
   /*
    Sucht alle Titel von 'derLeser' am Projektpfad 'derProjektPfad', die einen Kommentar haben
    */
   NSLog(@"TitelMitKommentarArrayVon: derLeser: %@  derProjektPfad: %@",derLeser, derProjektPfad);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   NSMutableArray* tempTitelArray=[[NSMutableArray alloc]initWithCapacity:0];
   //NSString* locKommentar=NSLocalizedString(@"Comments",@"Anmerkungen");
   NSString* locKommentar=@"Anmerkungen";
   NSString* tempProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:[derProjektPfad lastPathComponent]];
   
   NSString* LeserPfad=[tempProjektPfad stringByAppendingPathComponent:derLeser];
   NSString* KommentarOrdnerString=@"Anmerkungen";
   NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:KommentarOrdnerString];//Kommentarordner des Lesers
   BOOL KommentarordnerDa=[Filemanager fileExistsAtPath:LeserKommentarPfad];
   if ([Filemanager fileExistsAtPath:LeserPfad]&&KommentarordnerDa)//Ordner des Lesers und der Kommentarordner ist da
	  {
        NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc]initWithCapacity:0];
        tempAufnahmenArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL];
        if ([tempAufnahmenArray count])//Aufnahmen vorhanden
        {
           double KommentarIndex=NSNotFound;
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
              NSLog(@"\n\nTitelArrayVon:  tempAufnahmenArray: %@\n\n",[tempAufnahmenArray description]);
              
              NSEnumerator* enumerator=[tempAufnahmenArray objectEnumerator];
              id eineAufnahme;
              while (eineAufnahme=[enumerator nextObject])
              {
                 //NSLog(@"tempAufnahmenArray eineAufnahme: %@",eineAufnahme);
                 
                 
                 NSString* tempAufnahmePfad=[LeserPfad stringByAppendingPathComponent:eineAufnahme];
                 //NSLog(@"TitelMitKommentarArrayVon: tempAufnahmePfad: %@",tempAufnahmePfad);
                 if ([Filemanager fileExistsAtPath:tempAufnahmePfad])// eineAufnahme ist da
                 {
                    // m4a entfernen, txt anfuegen
                    NSString* tempKommentarTitel =[[eineAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
                    
                    NSString* tempAufnahmeKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempKommentarTitel];//Pfad des Kommentars
                    //NSLog(@"tempAufnahmeKommentarPfad: %@",tempAufnahmeKommentarPfad);
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
         
         NSLog(@"TitelArrayVonAllenAnProjektPfad  Leser: %@  tempTitelArray: %@%@",einLeser,@"\r", [tempTitelArray description]);
         
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

- (NSArray*)createKommentarStringArrayWithProjektPfadArray:(NSArray*)derProjektPfadArray
{
   NSLog(@"\n\n*********\n		Beginn createKommentarStringArrayWithProjektPfadArray\n\n");
   NSLog(@"\nderProjektPfadArray: %@",[derProjektPfadArray description]);
  // NSLog(@"AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,OptionAString,OptionBString);
   NSLog(@"   [self OptionA]: %@  [self PopBOption]: %@  AnzahlDics: %lu",[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem],(unsigned long)[derProjektPfadArray count]);

   //NSLog(@"AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,OptionAString,OptionBString);
   NSArray* tempProjektPfadArray=[NSArray arrayWithArray:derProjektPfadArray];
   
   /*
    NSString* name=NSLocalizedString(@"Name:",@"Name:");
    NSString* datum=NSLocalizedString(@"Date:",@"Datum:");
    NSString* titel=NSLocalizedString(@"Title:",@"Titel:");
    NSString* bewertung=NSLocalizedString(@"Assessment:",@"Bewertung:");
    
    NSString* anmerkungen=NSLocalizedString(@"Comments",@"Anmerkungen:");
    NSString* note=NSLocalizedString(@"Mark:",@"Note:");
    */
   
   NSString* name=@"Name:";
   NSString* datum=@"Datum:";
   NSString* titel=@"Titel:";
   NSString* bewertung=@"Bewertung:";
   
   NSString* anmerkungen=@"Anmerkungen:";
   NSString* note=@"Note:";
   NSString* tabSeparator=@"\t";
   NSString* crSeparator=@"\r";
   NSString* alle=@"alle";
   
   NSArray* TabellenkopfArray=[NSArray arrayWithObjects:name,titel,datum,bewertung,note,anmerkungen,nil];
   //	NSArray* TabellenkopfArray=[NSArray arrayWithObjects:name,titel,datum,note,anmerkungen,nil];
   
   NSMutableArray* tempKommentarStringArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   
   NSEnumerator* ProjektPfadEnum=[tempProjektPfadArray objectEnumerator];
   id einProjektPfad;
   while (einProjektPfad=[ProjektPfadEnum nextObject])
   {
      //NSLog(@"while einProjektPfad:        einProjektPfad: %@",einProjektPfad);
      //KommentarString enthält den Kopfstring und die Kommentare für einProjektPfad
      NSMutableString* projektKommentarString=[NSMutableString stringWithCapacity:0];
      
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
            NSString* tempLeser=[PopAMenu  titleOfSelectedItem];
            NSLog(@"alleVonNameKommentarOption tempLeser: %@ optionB: %@",[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
            
            if ([[PopAMenu  titleOfSelectedItem] isEqualToString:@"alle"]) // alle Namen
            {
               tempKommentarArray=(NSMutableArray*)[self alleKommentareNachNamenAnProjektPfad:einProjektPfad
                                                                                    bisAnzahl:AnzahlOption];
               NSLog(@"Projekt: %@	tempKommentarArray: %@",[einProjektPfad lastPathComponent], [tempKommentarArray description]);
               NSLog(@"\n\n\n");
            }
            else
            {
               if ( [[PopBMenu  titleOfSelectedItem] isEqualToString:@"alle"])
               {
                  NSLog(@"\n++++++ alleVonNameKommentarOption PopAOption %@       PopBOption: %@",[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
                  tempKommentarArray=(NSMutableArray*)[self alleKommentareVonLeser :[PopAMenu  titleOfSelectedItem]
                                                                      anProjektPfad:einProjektPfad
                                                                          bisAnzahl:AnzahlOption];
                  //NSLog(@"++	tempKommentarArray:  \n%@  ",[tempKommentarArray description]);
                  
               }
               else //Titel ausgewählt
               {
                  NSLog(@"alleVonNameKommentarOption OptionAString: %@ OptionBString:%@ ",[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]); // OK
                  //NSLog(@"tempKommentarArray: Anz: %d %@",[tempKommentarArray count],[tempKommentarArray description]);
                  tempKommentarArray=[[self KommentareVonLeser:[PopAMenu  titleOfSelectedItem]
                                                      mitTitel:[PopBMenu  titleOfSelectedItem]
                                                       maximal:AnzahlOption
                                                 anProjektPfad:einProjektPfad]mutableCopy];
                  
                  
                  //NSLog(@"createKomm.String\ntempKommentarArray: Anz: %d %@",[tempKommentarArray count],[tempKommentarArray description]);
                  
                  
               }
               
            }
            
         }break;
            
         case ausAllenProjektenOption:
         {
            NSLog(@"switch (AuswahlOption): ausAllenProjektenOption");
            //NSLog(@" OptionAOption %@	OptionBOption: %@",[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
            if ([[PopAMenu  titleOfSelectedItem] isEqualToString:@"alle"])//Alle Titel
            {
               tempKommentarArray=(NSMutableArray*)[self alleKommentareNachTitelAnProjektPfad:einProjektPfad
                                                                                    bisAnzahl:AnzahlOption];
               //NSLog(@"createKomm.String: OptionAString ist alle  tempKommentarArray: %@",[tempKommentarArray description]);
               if ([[PopBMenu  titleOfSelectedItem] isEqualToString:@"alle"])//alle Namen Zu Titel
               {
                  // tempKommentarArray=(NSMutableArray*)[self alleKommentareNachTitel:AnzahlOption];
               }
               else
               {
                  //tempKommentarArray=(NSMutableArray*)[self alleKommentareVonLeser :[PopBMenu  titleOfSelectedItem]
                  //												  maximal:AnzahlOption];
               }
               
            }
            else
            {
               if ([PopBMenu  titleOfSelectedItem])
               {
                  if ([[PopBMenu  titleOfSelectedItem] isEqualToString:@"alle"])//alle Namen Zu Titel
                  {
                     //NSLog(@"OptionBString ist alle: -> alleKommentareZuTitel");
                     tempKommentarArray=(NSMutableArray*)[self alleKommentareZuTitel:[PopAMenu  titleOfSelectedItem]
                                                                       anProjektPfad:einProjektPfad
                                                                             maximal:AnzahlOption];
                  }
                  else
                  {
                     tempKommentarArray=(NSMutableArray*)[self KommentareMitTitel:[PopAMenu  titleOfSelectedItem]
                                                                         vonLeser:[PopBMenu  titleOfSelectedItem]
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
      
      //NSLog(@"\n******************\n\ntempKommentarArray nach switch: : %@\n\n**********",[tempKommentarArray description]);
      
      //entsprechend den Optionen im Kommentarfenster
      //
      if ([tempKommentarArray count])
      {
         switch (AbsatzOption)
         {
            case alsTabelleFormatOption:
            {
               NSLog(@"alsTabelleFormatOption");
               int index;
               //NSLog(@"alleVonTitelKommentarOption 2");
               
               for (index=0;index<[TabellenkopfArray count];index++)
               {
                  NSString* tempKopfString=[TabellenkopfArray objectAtIndex:index];
                  //NSLog(@"tempKopfString: %@",tempKopfString);
                  //Kommentar als Array von Zeilen
                  [projektKommentarString appendFormat:@"%@%@",tempKopfString,tabSeparator];
                  //NSLog(@"KommentarString: %@  index:%d",KommentarString,index);
               }
               //NSLog(@"createKommentarString tempKommentarArray  %@  count:%d",[tempKommentarArray description],[tempKommentarArray count]);
               
               if ([tempKommentarArray count]==0)
               {
                  NSMutableDictionary* returnDic=[[NSMutableDictionary alloc]initWithCapacity:0];
                  [returnDic setObject:[einProjektPfad lastPathComponent] forKey:@"projekt"];
                  [returnDic setObject:@"Dieses Projekt hat keine Anmerkungen" forKey:@"kommentarstring"];
                  
                  NSArray* returnArray=[NSArray arrayWithObject: returnDic];
                  
                  break;
               }
               
               
               [projektKommentarString appendString:crSeparator];
               
               
               for (index=0;index<[tempKommentarArray count];index++)
               {
                  //ganzer Kommentar zu einem Leser als String
                  NSString* tempKommentarString=[tempKommentarArray objectAtIndex:index];
                  
                  //Kommentar als Array von Zeilen, reduzieren auf 6
                  NSMutableArray* tempKomponentenArray=(NSMutableArray*)[tempKommentarString componentsSeparatedByString:crSeparator];
                  int zeile;
                  //NSLog(@"++	tempKomponentenArray count: %d   TabellenkopfArray count: %d",[tempKomponentenArray count],[TabellenkopfArray count]);
                  if ([tempKomponentenArray count]>[TabellenkopfArray count]+1)
                  {
                     NSLog(@"Anz Zeilen > als Elemente der Kopfzeile: tempKomponentenArray: %@",[tempKomponentenArray description]);
                  }
                  if ([tempKomponentenArray count]>8)
                  {
                     NSLog(@"Zu viele Elemente: %lu%@tempKomponentenArray: %@",(unsigned long)[tempKomponentenArray count],crSeparator,[tempKomponentenArray description]);
                  }
                  
                  if ([tempKomponentenArray count]==7)//neue Version mit usermark
                  {
                     [tempKomponentenArray removeObjectAtIndex:kUserMark];//UserMark weg
                     
                  }
                  if ([tempKomponentenArray count]==8)//neue Version mit usermark und AdminMark
                  {
                     // AdminMark zuerst loeschen, da hoeherer Index
                     [tempKomponentenArray removeObjectAtIndex:kAdminMark];//AdminMark weg
                     [tempKomponentenArray removeObjectAtIndex:kUserMark];//UserMark weg
                     
                  }
                  
                  
                  
                  NSLog(@"index: %d\n    tempKomponentenArray: %@",index, [tempKomponentenArray description]);
                  
                  if ([tempKomponentenArray count]==6)//korrekte Version mit 6 Zeilen
                  {
                     //NSLog(@"Array hat 6 Zeilen: index: %d",index);
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
                        
                        if (zeile==1)//Titel
                        {
                           tempString = [tempString stringByDeletingPathExtension];
                        }
                        if (zeile==5)//Anmerkungen
                        {
                           
                           //Zeilenwechsel entfernen
                           NSRange r=NSMakeRange(0,[tempString length]);
                           long anzn, anzr;
                           //NSLog(@"tempString orig: %s",[tempString cString]);
                           anzn=[tempString replaceOccurrencesOfString:@"\n" withString:@" " options:NSBackwardsSearch range:r];
                           anzr=[tempString replaceOccurrencesOfString:@"\r" withString:@" " options:NSBackwardsSearch range:r];
                           //NSLog(@"Zeilenwechsel in tempString: %s n: %d r: %d",[tempString cString],anzn,anzr);
                        }
                        [projektKommentarString appendFormat:@"%@%@",tempString,tabSeparator];
                     }
                     
                  }
                  
                  else
                  {
                     NSLog(@"Zuwenig Elemente: tempKommentarString: %@",tempKommentarString);
                  }
                  
                  //for (zeile=0;zeile<[TabellenkopfArray count];zeile++)//Zusätzliche Zeilen werden ignoriert
                  
                  [projektKommentarString appendString:crSeparator];
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
                     
                     
                     [projektKommentarString appendFormat:@"%@%@%@",[TabellenkopfArray objectAtIndex:zeile],tabSeparator, tempString];
                     [projektKommentarString appendString:crSeparator];
                  }
                  [projektKommentarString appendString:crSeparator];
               }//for index
               
            }break;//alsAbsatzFormatOption
         }//switch FormatOption
         
         NSMutableDictionary* tempKommentarStringDic=[[NSMutableDictionary alloc]initWithCapacity:0];
         
         [tempKommentarStringDic setObject: projektKommentarString forKey:@"kommentarstring"];
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
      NSString* keinKommentarProjektString=@"Leerer Ordner für Anmerkungen";
      NSString* keinKommentarString=@"Keine Kommentare für diese Einstellungen";
      
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

#pragma mark setKommentar

- (void)setKommentarMitProjektArray:(NSArray*)derProjektArray mitLeser:(NSString*)aktuellerLeser anPfad:(NSString*)aktuellerProjektPfad// aus Kommentarkontroller
{
   // NSLog(@"\n\n			--------setAdminProjektArray: derProjektArray: %@",derProjektArray);
   NSLog(@"setAdminProjektArray: aktuellerProjektPfad: %@",aktuellerProjektPfad);
   AdminProjektPfad = aktuellerProjektPfad; // /Users/ruediheimlicher/Documents/Lesebox/Archiv/ggg
   AdminArchivPfad = [aktuellerProjektPfad stringByDeletingLastPathComponent];
   AdminAktuellerLeser = aktuellerLeser;
   [AdminProjektArray removeAllObjects];
   [AdminProjektArray setArray:derProjektArray];
   AdminProjektNamenArray=[[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:AdminProjektPfad error:NULL]] ;
   [AdminProjektNamenArray removeObject:@".DS_Store"];
   
   //NSLog(@"setAdminProjektArray: AdminProjektArray: %@",[[AdminProjektArray lastObject]description]);
   [self setAnzahlPopMenu:AnzahlOption];
   if ([AdminAktuellerLeser length])
	  {
        AuswahlOption=alleVonNameKommentarOption; // 1
        [self setAuswahlPop:alleVonNameKommentarOption];
        
        [self setPopAMenu:AdminProjektNamenArray erstesItem:@"alle" aktuell:AdminAktuellerLeser];
        
        
        NSArray* tempTitelArray=[self TitelArrayVon:AdminAktuellerLeser anProjektPfad:AdminProjektPfad];
        
        if ([AdminAktuelleAufnahme length])
        {
           // titel ohne extension
           [self setPopBMenu:tempTitelArray erstesItem:@"alle" aktuell:[self AufnahmeTitelVon:AdminAktuelleAufnahme] mitPrompt:@"mit Titel:"];
        }
        else
        {
           [self setPopBMenu:tempTitelArray erstesItem:@"alle" aktuell:nil mitPrompt:@"mit Titel:"];
           
        }
     }
   else
	  {
        AuswahlOption=lastKommentarOption;
        [self setAuswahlPop:lastKommentarOption];
     }
  // nurMarkierteOption=[nurMarkierteCheck state];
   ProjektPfadOptionString=AdminProjektPfad;
   //NSLog(@"AdminProjektArray: %@",[AdminProjektArray description]);
   NSArray* StartProjektArray=[AdminProjektArray valueForKey:@"projekt"];
   NSLog(@"StartProjektArray: %@",[StartProjektArray description]);
   
   [self setProjektMenu:StartProjektArray mitItem:[AdminProjektPfad lastPathComponent]];
   
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
   [self setKommentarMitKommentarDicArray:startKommentarStringArray];
   
   
}

- (void)setAuswahlPop:(int)dieAuswahlOption
{
   [AuswahlPopMenu selectItemAtIndex:dieAuswahlOption];
   AuswahlOption=dieAuswahlOption;
}


- (void)setPopAMenu:(NSArray*)derArray erstesItem:(NSString*)dasItem aktuell:(NSString*)aktuellerString
{
   NSLog(@"setPopAMenu  derArray: %@ erstesItem: %@ aktuell: %@",[derArray description], dasItem, aktuellerString);
   NSString* alle=NSLocalizedString(@"All",@"alle");
   //NSString* namenwaehlen=@"Namen wählen";
   //[PopAMenu synchronizeTitleAndSelectedItem];
   [PopAMenu setEnabled:YES];
   [AnzahlPop setEnabled:YES];
   [PopAMenu removeAllItems];
   if (dasItem)
   {
      //NSLog(@"setPopAMenu: erstesItem nicht NULL");
      [PopAMenu addItemWithTitle:dasItem];
   }
   if (derArray)
   {
      [PopAMenu addItemsWithTitles:derArray];
   }
   if (aktuellerString&&[aktuellerString length])
	  {
        [PopAMenu selectItemWithTitle:aktuellerString];
     }
   else
	  {
        //[PopAMenu selectItemWithTitle:alle];
     }
   //[derNamenArray release];
   //return erfolg;
}

- (void)resetPopAMenu
{
   //NSString* auswaehlen=@"auswählen";
   [PopAMenu removeAllItems];
   //[PopAMenu addItemWithTitle:auswaehlen];
   [PopAMenu setEnabled:NO];
   //[AnzahlPop setEnabled:NO];
   
}


- (void)setPopBMenu:(NSArray*)derArray erstesItem:(NSString*)dasItem aktuell:(NSString*)aktuellerString mitPrompt:(NSString*)dasPrompt
{
   NSLog(@"setPopBMenu  derArray: %@ erstesItem: %@ aktuell: %@ Prompt: %@",[derArray description], dasItem, aktuellerString, dasPrompt);
   
   NSString* alle=@"alle";
   //NSString* namenwaehlen=@"Namen wählen";
   [PopBMenu setEnabled:YES];
   [AnzahlPop setEnabled:YES];
   [PopBPrompt setStringValue:dasPrompt];
   [PopBMenu removeAllItems];
   if (dasItem)
   {
      //NSLog(@"setPopBMenu: erstesItem nicht NULL");
      [PopBMenu addItemWithTitle:dasItem];
   }
   [PopBMenu addItemsWithTitles:derArray];
   //NSLog(@"in setPopBMenu %@  aktuell: %@",[derArray description], aktuellerString);
   if (aktuellerString )//&&[aktuellerString length])
	  {
        [PopBMenu selectItemWithTitle:aktuellerString];
        //NSLog(@"setPopBMenu2");
     }
   else
	  {
        [PopBMenu selectItemWithTitle:@"alle"];
     }
}

- (void)resetPopBMenu
{
   //NSString* auswaehlen=@"auswählen";
   [PopBMenu removeAllItems];
   [PopBMenu setEnabled:NO];
   [PopBPrompt setStringValue:@""];
   //[AnzahlPop setEnabled:NO];
   
}


- (void) setAnzahlPopMenu:(int)dieAnzahl
{
   NSString* alle=NSLocalizedString(@"All",@"alle");
   if (dieAnzahl==99)
	  {
        [AnzahlPop selectItemWithTitle:alle];
     }
   else
	  {
        [AnzahlPop selectItemWithTitle:[[NSNumber numberWithInt:dieAnzahl]stringValue]];
     }
}

- (void)setProjektMenu:(NSArray*)derProjektMenuArray mitItem:(NSString*)dasProjektItem
{
   //NSLog(@"setProjektMenu: derProjektMenuArray: %@",[derProjektMenuArray description]);
   
   [ProjektPopMenu setEnabled:YES];
   [ProjektPopPrompt setStringValue:NSLocalizedString(@"Project: ",@"Projekt: ")];
   [ProjektPopMenu removeAllItems];
   if ([derProjektMenuArray count])
   {
      [ProjektPopMenu addItemsWithTitles:derProjektMenuArray];
   }
   if ([ProjektPopMenu indexOfItemWithTitle:dasProjektItem]>=0)
   {
      [ProjektPopMenu selectItemWithTitle:dasProjektItem];
   }
}


- (void)setNurMarkierteOption:(int)nurMarkierte
{
   [nurMarkierteCheck setState:nurMarkierte];
}


- (void)setKommentar:(NSString*)derKommentarString
{
   
   if ([derKommentarString length]==0)
      return;
   NSString* ProjektTitel=@"Deutsch";
   KommentarString=[derKommentarString copy];
   //[KommentarString release];
   NSFontManager *fontManager = [NSFontManager sharedFontManager];
   //NSLog(@"*KommentarFenster  setKommentar* %@",derKommentarString);
   
   
   NSString* TitelString=@"Anmerkungen vom ";
   NSString* KopfString=[NSString stringWithFormat:@"%@  %@%@",TitelString,heuteDatumString,@"\r\r"];
   
   //Font für Titelzeile
   NSFont* TitelFont;
   TitelFont=[NSFont fontWithName:@"Helvetica" size: 14];
   
   //Stil für Titelzeile
   NSMutableParagraphStyle* TitelStil=[[NSMutableParagraphStyle alloc]init];
   [TitelStil setTabStops:[NSArray array]];//default weg
   NSTextTab* TitelTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:90];
   
   [TitelStil addTabStop:TitelTab1];
   
   //Attr-String für Titelzeile zusammensetzen
   NSMutableAttributedString* attrTitelString=[[NSMutableAttributedString alloc] initWithString:KopfString];
   [attrTitelString addAttribute:NSParagraphStyleAttributeName value:TitelStil range:NSMakeRange(0,[KopfString length])];
   [attrTitelString addAttribute:NSFontAttributeName value:TitelFont range:NSMakeRange(0,[KopfString length])];
   
   //titelzeile einsetzen
   [[KommentarView textStorage]setAttributedString:attrTitelString];
   
   
   
   //Font für Projektzeile
   NSFont* ProjektFont;
   ProjektFont=[NSFont fontWithName:@"Helvetica" size: 12];
   
   NSString* ProjektString=NSLocalizedString(@"Project: ",@"Projekt: ");
   NSString* ProjektKopfString=[NSString stringWithFormat:@"%@    %@%@",ProjektString,ProjektTitel,@"\r"];
   
   //Stil für Projektzeile
   NSMutableParagraphStyle* ProjektStil=[[NSMutableParagraphStyle alloc]init];
   [ProjektStil setTabStops:[NSArray array]];//default weg
   NSTextTab* ProjektTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:150];
   [ProjektStil addTabStop:ProjektTab1];
   
   //Attr-String für Projektzeile zusammensetzen
   NSMutableAttributedString* attrProjektString=[[NSMutableAttributedString alloc] initWithString:ProjektKopfString];
   [attrProjektString addAttribute:NSParagraphStyleAttributeName value:ProjektStil range:NSMakeRange(0,[ProjektKopfString length])];
   [attrProjektString addAttribute:NSFontAttributeName value:ProjektFont range:NSMakeRange(0,[ProjektKopfString length])];
   
   //Projektzeile einsetzen
   [[KommentarView textStorage]appendAttributedString:attrProjektString];
   
   //Stil für Abstand1
   NSMutableParagraphStyle* Abstand1Stil=[[NSMutableParagraphStyle alloc]init];
   NSFont* Abstand1Font=[NSFont fontWithName:@"Helvetica" size: 8];
   NSMutableAttributedString* attrAbstand1String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
   [attrAbstand1String addAttribute:NSParagraphStyleAttributeName value:Abstand1Stil range:NSMakeRange(0,1)];
   [attrAbstand1String addAttribute:NSFontAttributeName value:Abstand1Font range:NSMakeRange(0,1)];
   //Abstandzeile einsetzen
   [[KommentarView textStorage]appendAttributedString:attrAbstand1String];
   
   
   NSMutableString* TextString=[derKommentarString mutableCopy];
   int pos=[TextString length]-1;
   BOOL letzteZeileWeg=NO;
   if ([TextString characterAtIndex:pos]=='\r')
   {
      //NSLog(@"last Char ist r");
      //[TextString deleteCharactersInRange:NSMakeRange(pos-1,1)];
      letzteZeileWeg=YES;
      pos--;
   }
   
   if([TextString characterAtIndex:pos]=='\n')
	  {
        NSLog(@"last Char ist n");
     }
   
   AuswahlOption=[[AuswahlPopMenu selectedCell]tag];
   
   //NSLog(@"*KommentarFenster  setKommentar textString: %@  AuswahlOption: %d",TextString, AuswahlOption);
   
   switch ([[AbsatzMatrix selectedCell]tag])
   
   {
      case alsTabelleFormatOption:
      {
         int Textschnitt=10;
         NSFont* TextFont;
         TextFont=[NSFont fontWithName:@"Helvetica" size: Textschnitt];
         //NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
         
         NSMutableArray* KommentarArray=(NSMutableArray*)[TextString componentsSeparatedByString:@"\r"];
         if (letzteZeileWeg)
         {
            //NSLog(@"letzteZeileWeg");
            [KommentarArray removeLastObject];
         }
         [Anz setIntValue:[KommentarArray count]-1];
         NSString* titel=NSLocalizedString(@"Title:",@"Titel:");
         //char * tb=[titel lossyCString];
         const char * tb=[titel cStringUsingEncoding:NSMacOSRomanStringEncoding];
         int Titelbreite=strlen(tb);
         NSString* name=NSLocalizedString(@"Name",@"Name:");
         //char * nb=[name lossyCString];
         const char * nb=[name cStringUsingEncoding:NSMacOSRomanStringEncoding];
         int Namenbreite=strlen(nb);
         
         int i;
         
         //Länge von Name und Titel feststellen
         for (i=0;i<[KommentarArray count];i++)
         {
            
            //if ([KommentarArray objectAtIndex:i])
            {
               //NSLog(@"%@KommentarArray Zeile: %d %@",@"\r",i,[KommentarArray objectAtIndex:i]);
               NSArray* ZeilenArray=[[KommentarArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
               if ([ZeilenArray count]>1)
               {
                  //char * nc=[[ZeilenArray objectAtIndex:0]lossyCString];
                  const char * nc=[[ZeilenArray objectAtIndex:0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
                  int nl=strlen(nc);
                  if(nl>Namenbreite)
                     Namenbreite=nl;
                  //char * tc=[[ZeilenArray objectAtIndex:1]lossyCString];
                  const char * tc=[[ZeilenArray objectAtIndex:1] cStringUsingEncoding:NSMacOSRomanStringEncoding];
                  int tl=strlen(tc);
                  if(tl>Titelbreite)
                     Titelbreite=tl;
                  
                  //NSLog(@"tempNamenbreite: %d  Titelbreite: %d",nl, tl);
               }
            }
         }
         //NSLog(@"Namenbreite: %d  Titelbreite: %d",Namenbreite, Titelbreite);
         
         //Tabulatoren aufaddieren
         float titeltab=120;
         
         titeltab=Namenbreite*(3*Textschnitt/5);
         float datumtab=260;
         
         datumtab=titeltab+Titelbreite*(3*Textschnitt/5);
         float bewertungtab=325;
         bewertungtab=datumtab+12*(3*Textschnitt/5);
         float notetab=380;
         notetab=bewertungtab+12*(3*Textschnitt/5);
         float anmerkungentab=410;
         anmerkungentab=notetab+8*(3*Textschnitt/5);
         
         NSMutableParagraphStyle* TabellenKopfStil=[[NSMutableParagraphStyle alloc]init];
         [TabellenKopfStil setTabStops:[NSArray array]];
         NSTextTab* TabellenkopfTitelTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:titeltab];
         [TabellenKopfStil addTabStop:TabellenkopfTitelTab];
         NSTextTab* TabellenkopfDatumTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:datumtab];
         [TabellenKopfStil addTabStop:TabellenkopfDatumTab];
         NSTextTab* TabellenkopfBewertungTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:bewertungtab];
         [TabellenKopfStil addTabStop:TabellenkopfBewertungTab];
         NSTextTab* TabellenkopfNoteTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:notetab];
         [TabellenKopfStil addTabStop:TabellenkopfNoteTab];
         NSTextTab* TabellenkopfAnmerkungenTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:anmerkungentab];
         [TabellenKopfStil addTabStop:TabellenkopfAnmerkungenTab];
         [TabellenKopfStil setParagraphSpacing:4];
         
         
         NSMutableParagraphStyle* TabelleStil=[[NSMutableParagraphStyle alloc]init];
         [TabelleStil setTabStops:[NSArray array]];
         NSTextTab* TabelleTitelTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:titeltab];
         [TabelleStil addTabStop:TabelleTitelTab];
         NSTextTab* TabelleDatumTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:datumtab];
         [TabelleStil addTabStop:TabelleDatumTab];
         NSTextTab* TabelleBewertungTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:bewertungtab];
         [TabelleStil addTabStop:TabelleBewertungTab];
         NSTextTab* TabelleNoteTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:notetab];
         [TabelleStil addTabStop:TabelleNoteTab];
         NSTextTab* TabelleAnmerkungenTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:anmerkungentab];
         [TabelleStil addTabStop:TabelleAnmerkungenTab];
         [TabelleStil setHeadIndent:anmerkungentab];
         [TabelleStil setParagraphSpacing:2];
         
         //Kommentarstring in Komponenten aufteilen
         //NSString* TabellenkopfString=[[KommentarArray objectAtIndex:0]stringByAppendingString:@"\r"];
         NSMutableString* TabellenkopfString=[[KommentarArray objectAtIndex:0]mutableCopy];
         int lastBuchstabenPos=[TabellenkopfString length]-1;
         //NSLog(@"TabellenkopfString: %@   length: %d  last: %d",TabellenkopfString,lastBuchstabenPos,[TabellenkopfString characterAtIndex:lastBuchstabenPos] );
         
         
         if([TabellenkopfString characterAtIndex:lastBuchstabenPos]=='\n')
         {
            NSLog(@"TabellenkopfString: last Char ist n");
         }
         if([TabellenkopfString characterAtIndex:lastBuchstabenPos]=='\r')
         {
            NSLog(@"TabellenkopfString: last Char ist r");
         }
         [TabellenkopfString deleteCharactersInRange:NSMakeRange(lastBuchstabenPos,1)];
         NSMutableAttributedString* attrKopfString=[[NSMutableAttributedString alloc] initWithString:TabellenkopfString];
         [attrKopfString addAttribute:NSParagraphStyleAttributeName value:TabellenKopfStil range:NSMakeRange(0,[TabellenkopfString length])];
         [attrKopfString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TabellenkopfString length])];
         [[KommentarView textStorage]appendAttributedString:attrKopfString];
         
         //Stil für Abstand2
         NSMutableParagraphStyle* Abstand2Stil=[[NSMutableParagraphStyle alloc]init];
         NSFont* Abstand2Font=[NSFont fontWithName:@"Helvetica" size: 2];
         NSMutableAttributedString* attrAbstand2String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
         [attrAbstand2String addAttribute:NSParagraphStyleAttributeName value:Abstand2Stil range:NSMakeRange(0,1)];
         [attrAbstand2String addAttribute:NSFontAttributeName value:Abstand2Font range:NSMakeRange(0,1)];
         
         [[KommentarView textStorage]appendAttributedString:attrAbstand2String];
         
         
         
         
         NSString* cr=@"\r";
         //NSAttributedString*CR=[[[NSAttributedString alloc]initWithString:cr]autorelease];
         int index=1;
         if ([KommentarArray count]>1)
         {
            for (index=1;index<[KommentarArray count];index++)
            {
               NSString* tempZeile=[KommentarArray objectAtIndex:index];
               
               if ([tempZeile length]>1)
               {
                  NSString* tempString=[tempZeile substringToIndex:[tempZeile length]-1];
                  NSString* tempArrayString=[NSString stringWithFormat:@"%@%@",tempString, cr];
                  
                  NSMutableAttributedString* attrTextString=[[NSMutableAttributedString alloc] initWithString:tempArrayString];
                  [attrTextString addAttribute:NSParagraphStyleAttributeName value:TabelleStil range:NSMakeRange(0,[tempArrayString length])];
                  [attrTextString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[tempArrayString length])];
                  [[KommentarView textStorage]appendAttributedString:attrTextString];
                  //NSLog(@"Ende setKommentar: attrTextString retainCount: %d",[attrTextString retainCount]);
                  
               }
            }//for index
         }//if count>1
      }break;//alsTabelleFormatOption
         
      case alsAbsatzFormatOption:
      {
         NSFont* TextFont;
         TextFont=[NSFont fontWithName:@"Helvetica" size: 12];
         NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
         
         NSMutableParagraphStyle* AbsatzStil=[[NSMutableParagraphStyle alloc]init];
         [AbsatzStil setTabStops:[NSArray array]];
         NSTextTab* AbsatzTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:90];
         [AbsatzStil addTabStop:AbsatzTab1];
         [AbsatzStil setHeadIndent:90];
         //[AbsatzStil setParagraphSpacing:4];
         
         NSMutableAttributedString* attrTextString=[[NSMutableAttributedString alloc] initWithString:TextString];
         [attrTextString addAttribute:NSParagraphStyleAttributeName value:AbsatzStil range:NSMakeRange(0,[TextString length])];
         
         [attrTextString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TextString length])];
         
         [[KommentarView textStorage]appendAttributedString:attrTextString];
         //NSLog(@"Ende setKommentar: attrTextString retainCount: %d",[attrTextString retainCount]);
         
         
      }break;//alsAbsatzFormatOption
   }//Auswahloption
   
   //NSLog(@"Ende setKommentar: TitelStil retainCount: %d",[TitelStil retainCount]);
   //NSLog(@"Ende setKommentar: attrTitelString retainCount: %d",[attrTitelString retainCount]);
   //NSLog(@"Ende setKommentar: TitelTab1 retainCount: %d",[TitelTab1 retainCount]);
   //[TitelTab1 release];
   //NSLog(@"Ende setKommentar%@",@"\r***\r\r\r");//: attrTitelString retainCount: %d",[attrTitelString retainCount]);
   
}

- (void)setKommentarMitKommentarDicArray:(NSArray*)derKommentarDicArray
{
   
   if ([derKommentarDicArray count]==0)
      return;
   
   
   NSFontManager *fontManager = [NSFontManager sharedFontManager];
   //NSLog(@"*KommentarFenster  setKommentar* %@",derKommentarString);
   
   
   //NSString* TitelString=NSLocalizedString(@"Comments from ",@"Anmerkungen vom ");
   NSString* TitelString=@"Anmerkungen vom ";
   NSString* KopfString=[NSString stringWithFormat:@"%@  %@%@",TitelString,heuteDatumString,@"\r\r"];
   
   //Font für Titelzeile
   NSFont* TitelFont;
   TitelFont=[NSFont fontWithName:@"Helvetica" size: 14];
   
   //Stil für Titelzeile
   NSMutableParagraphStyle* TitelStil=[[NSMutableParagraphStyle alloc]init];
   [TitelStil setTabStops:[NSArray array]];//default weg
   NSTextTab* TitelTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:90];
   
   //Stil für Abstand12
   NSMutableParagraphStyle* Abstand12Stil=[[NSMutableParagraphStyle alloc]init];
   NSFont* Abstand12Font=[NSFont fontWithName:@"Helvetica" size: 12];
   NSMutableAttributedString* attrAbstand12String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
   [attrAbstand12String addAttribute:NSParagraphStyleAttributeName value:Abstand12Stil range:NSMakeRange(0,1)];
   [attrAbstand12String addAttribute:NSFontAttributeName value:Abstand12Font range:NSMakeRange(0,1)];
   //Abstandzeile einsetzen
   
   
   [TitelStil addTabStop:TitelTab1];
   
   //Attr-String für Titelzeile zusammensetzen
   NSMutableAttributedString* attrTitelString=[[NSMutableAttributedString alloc] initWithString:KopfString];
   [attrTitelString addAttribute:NSParagraphStyleAttributeName value:TitelStil range:NSMakeRange(0,[KopfString length])];
   [attrTitelString addAttribute:NSFontAttributeName value:TitelFont range:NSMakeRange(0,[KopfString length])];
   
   //titelzeile einsetzen
   [[KommentarView textStorage]setAttributedString:attrTitelString];
   
   
   //Breite von variablen Feldern
   int maxNamenbreite=12;
   int maxTitelbreite=12;
   int Textschnitt=10;
   int AnzahlAnmerkungen=0;
   NSLog(@"setKommentarMit KommentarDicArray: %@",[derKommentarDicArray objectAtIndex:0]);
   NSEnumerator* TabEnum=[derKommentarDicArray objectEnumerator];
   id einTabDic;
   //NSLog(@"setKommentarMit Komm.DicArray: vor while   Anz. Dics: %d",[derKommentarDicArray count]);
   
   while (einTabDic=[TabEnum nextObject])//erster Durchgang: Länge von Namen und Titel bestimmen
   {
      NSLog(@"einTabDic: %@",[einTabDic description]);
      NSString* ProjektTitel;
      NSString* KommentarString;
      if ([einTabDic objectForKey:@"projekt"])
      {
         ProjektTitel=[einTabDic objectForKey:@"projekt"];
         //NSLog(@"ProjektTitel: %@",ProjektTitel);
         
         if ([einTabDic objectForKey:@"kommentarstring"])
         {
            NSMutableString* TextString=[[einTabDic objectForKey:@"kommentarstring"] mutableCopy];
            int pos=[TextString length]-1;
            BOOL letzteZeileWeg=NO;
            if ([TextString characterAtIndex:pos]=='\r')
            {
               letzteZeileWeg=YES;
               pos--;
            }
            
            if([TextString characterAtIndex:pos]=='\n')
            {
               NSLog(@"last Char ist n");
            }
            NSFont* TextFont;
            TextFont=[NSFont fontWithName:@"Helvetica" size: Textschnitt];
            //NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
            
            NSMutableArray* KommentarArray=(NSMutableArray*)[TextString componentsSeparatedByString:@"\r"];
            if (letzteZeileWeg)
            {
               //NSLog(@"letzteZeileWeg");
               [KommentarArray removeLastObject];
            }
            //[Anz setIntValue:[KommentarArray count]-1];
            AnzahlAnmerkungen+=[KommentarArray count]-1;
            //NSString* titel=NSLocalizedString(@"Title:",@"Titel:";
            NSString* titel=@"Titel:";
            //char * tb=[titel lossyCString];
            const char * tb=[titel cStringUsingEncoding:NSMacOSRomanStringEncoding];
            int Titelbreite=strlen(tb);//Minimalbreite für Tabellenkopf von Titel
            if (Titelbreite>maxTitelbreite)
            {
               maxTitelbreite=Titelbreite;
            }
            NSString* name=@"Name:";
            
            //NSString* name=NSLocalizedString(@"Name",@"Name:");
            //char * nb=[name lossyCString];
            const char * nb=[name cStringUsingEncoding:NSMacOSRomanStringEncoding];
            int Namenbreite=strlen(nb);//Minimalbreite für Tabellenkopf von Name
            if (Namenbreite>maxNamenbreite)
            {
               maxNamenbreite=Namenbreite;
            }
            //NSLog(@"Tabellenkopf: Namenbreite: %d  Titelbreite: %d",Namenbreite, Titelbreite);
            
            int i;
            
            //Länge von Name und Titel feststellen
            for (i=0;i<[KommentarArray count];i++)
            {
               
               //if ([KommentarArray objectAtIndex:i])
               
               //NSLog(@"%@KommentarArray Zeile: %d %@",@"\r",i,[KommentarArray objectAtIndex:i]);
               NSArray* ZeilenArray=[[KommentarArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
               if ([ZeilenArray count]>1)
               {
                  //char * nc=[lossyCString];
                  const char * nc=[[ZeilenArray objectAtIndex:0]cStringUsingEncoding:NSMacOSRomanStringEncoding];
                  int nl=strlen(nc);
                  if(nl>Namenbreite)
                     Namenbreite=nl;
                  
                  //char * tc=[[ZeilenArray objectAtIndex:1]lossyCString];
                  const char * tc=[[ZeilenArray objectAtIndex:1] cStringUsingEncoding:NSMacOSRomanStringEncoding];
                  int tl=strlen(tc);
                  if(tl>Titelbreite)
                     Titelbreite=tl;
                  //NSLog(@"tempNamenbreite: %d  Titelbreite: %d",nl, tl);
               }
               
            }
            
            //NSLog(@"Namenbreite: %d  Titelbreite: %d",Namenbreite, Titelbreite);
            if (Namenbreite>maxNamenbreite)
            {
               maxNamenbreite=Namenbreite;
            }
            if (Titelbreite>maxTitelbreite)
            {
               maxTitelbreite=Titelbreite;
            }
            //NSLog(@"maxNamenbreite: %d  maxTitelbreite: %d",maxNamenbreite, maxTitelbreite);
         }//if Kommentarstring
      }//if einProjekt
   }//while Wortlängen bestimmen
   
   
   //Anmerkungen einsetzen
   
   NSEnumerator* KommentarArrayEnum=[derKommentarDicArray objectEnumerator];
   id einKommentarDic;
   while (einKommentarDic=[KommentarArrayEnum nextObject])//Tabulatoren setzen und Tabelle aufbauen
   {
      NSLog(@"setKommentarMit KommentarDicArray: Beginn while");
      NSString* ProjektTitel;
      
      if ([einKommentarDic objectForKey:@"projekt"])
      {
         ProjektTitel=[einKommentarDic objectForKey:@"projekt"];
         NSLog(@"ProjektTitel: %@",ProjektTitel);
      }
      else //Kein Projekt angegeben
      {
         ProjektTitel=@"Kein Projekt";
      }
      
      
      //Font für Projektzeile
      NSFont* ProjektFont;
      ProjektFont=[NSFont fontWithName:@"Helvetica" size: 12];
      
      //NSString* ProjektString=NSLocalizedString(@"Project: ",@"Projekt: ");
      NSString* ProjektString=@"Projekt: ";
      
      NSString* ProjektKopfString=[NSString stringWithFormat:@"%@    %@%@",ProjektString,ProjektTitel,@"\r"];
      
      //Stil für Projektzeile
      NSMutableParagraphStyle* ProjektStil=[[NSMutableParagraphStyle alloc]init];
      [ProjektStil setTabStops:[NSArray array]];//default weg
      NSTextTab* ProjektTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:150];
      [ProjektStil addTabStop:ProjektTab1];
      
      //Attr-String für Projektzeile zusammensetzen
      NSMutableAttributedString* attrProjektString=[[NSMutableAttributedString alloc] initWithString:ProjektKopfString];
      [attrProjektString addAttribute:NSParagraphStyleAttributeName value:ProjektStil range:NSMakeRange(0,[ProjektKopfString length])];
      [attrProjektString addAttribute:NSFontAttributeName value:ProjektFont range:NSMakeRange(0,[ProjektKopfString length])];
      
      //Projektzeile einsetzen
      [[KommentarView textStorage]appendAttributedString:attrProjektString];
      
      //Stil für Abstand1
      NSMutableParagraphStyle* Abstand1Stil=[[NSMutableParagraphStyle alloc]init];
      NSFont* Abstand1Font=[NSFont fontWithName:@"Helvetica" size: 6];
      NSMutableAttributedString* attrAbstand1String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
      [attrAbstand1String addAttribute:NSParagraphStyleAttributeName value:Abstand1Stil range:NSMakeRange(0,1)];
      [attrAbstand1String addAttribute:NSFontAttributeName value:Abstand1Font range:NSMakeRange(0,1)];
      //Abstandzeile einsetzen
      [[KommentarView textStorage]appendAttributedString:attrAbstand1String];
      
      NSMutableString* TextString;
      if ([einKommentarDic objectForKey:@"kommentarstring"])
      {
         TextString=[[einKommentarDic objectForKey:@"kommentarstring"]mutableCopy];
      }
      else //Keine Kommentare in diesem Projekt
      {
         TextString=[NSLocalizedString(@"No comments for this Project",@"Keine Kommentare für dieses Projekt") mutableCopy];
      }
      
      
      int pos=[TextString length]-1;
      BOOL letzteZeileWeg=NO;
      if ([TextString characterAtIndex:pos]=='\r')
      {
         //NSLog(@"last Char ist r");
         //[TextString deleteCharactersInRange:NSMakeRange(pos-1,1)];
         letzteZeileWeg=YES;
         pos--;
      }
      
      if([TextString characterAtIndex:pos]=='\n')
      {
         NSLog(@"last Char ist n");
      }
      
      AuswahlOption=[[AuswahlPopMenu selectedCell]tag];
      
      //NSLog(@"*KommentarFenster  setKommentar textString: %@  AuswahlOption: %d",TextString, AuswahlOption);
      
      switch ([[AbsatzMatrix selectedCell]tag])
      
      {
         case alsTabelleFormatOption:
         {
            //int Textschnitt=10;
            
            NSFont* TextFont;
            TextFont=[NSFont fontWithName:@"Helvetica" size: Textschnitt];
            //NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
            
            NSMutableArray* KommentarArray=(NSMutableArray*)[TextString componentsSeparatedByString:@"\r"];
            if (letzteZeileWeg)
            {
               //NSLog(@"letzteZeileWeg");
               [KommentarArray removeLastObject];
            }
            //[Anz setIntValue:[KommentarArray count]-1];
            //
            
            //NSLog(@"2. Runde: maxNamenbreite: %d  maxTitelbreite: %d",maxNamenbreite, maxTitelbreite);
            //
            //Tabulatoren aufaddieren
            float titeltab=120;
            
            titeltab=maxNamenbreite*(3*Textschnitt/5);
            float datumtab=260;
            
            datumtab=titeltab+maxTitelbreite*(3*Textschnitt/5);
            float bewertungtab=325;
            bewertungtab=datumtab+12*(3*Textschnitt/5);
            float notetab=380;
            notetab=bewertungtab+12*(3*Textschnitt/5);
            float anmerkungentab=410;
            anmerkungentab=notetab+6*(3*Textschnitt/5);
            
            NSMutableParagraphStyle* TabellenKopfStil=[[NSMutableParagraphStyle alloc]init];
            [TabellenKopfStil setTabStops:[NSArray array]];
            NSTextTab* TabellenkopfTitelTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:titeltab];
            [TabellenKopfStil addTabStop:TabellenkopfTitelTab];
            NSTextTab* TabellenkopfDatumTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:datumtab];
            [TabellenKopfStil addTabStop:TabellenkopfDatumTab];
            NSTextTab* TabellenkopfBewertungTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:bewertungtab];
            [TabellenKopfStil addTabStop:TabellenkopfBewertungTab];
            NSTextTab* TabellenkopfNoteTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:notetab];
            [TabellenKopfStil addTabStop:TabellenkopfNoteTab];
            NSTextTab* TabellenkopfAnmerkungenTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:anmerkungentab];
            [TabellenKopfStil addTabStop:TabellenkopfAnmerkungenTab];
            [TabellenKopfStil setParagraphSpacing:4];
            
            
            NSMutableParagraphStyle* TabelleStil=[[NSMutableParagraphStyle alloc]init];
            [TabelleStil setTabStops:[NSArray array]];
            NSTextTab* TabelleTitelTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:titeltab];
            [TabelleStil addTabStop:TabelleTitelTab];
            NSTextTab* TabelleDatumTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:datumtab];
            [TabelleStil addTabStop:TabelleDatumTab];
            NSTextTab* TabelleBewertungTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:bewertungtab];
            [TabelleStil addTabStop:TabelleBewertungTab];
            NSTextTab* TabelleNoteTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:notetab];
            [TabelleStil addTabStop:TabelleNoteTab];
            NSTextTab* TabelleAnmerkungenTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:anmerkungentab];
            [TabelleStil addTabStop:TabelleAnmerkungenTab];
            [TabelleStil setHeadIndent:anmerkungentab];
            [TabelleStil setParagraphSpacing:2];
            
            //Kommentarstring in Komponenten aufteilen
            NSMutableString* TabellenkopfString=[[KommentarArray objectAtIndex:0]mutableCopy];
            int lastBuchstabenPos=[TabellenkopfString length]-1;
            //NSLog(@"TabellenkopfString: %@   length: %d  last: %d",TabellenkopfString,lastBuchstabenPos,[TabellenkopfString characterAtIndex:lastBuchstabenPos] );
            
            
            if([TabellenkopfString characterAtIndex:lastBuchstabenPos]=='\n')
            {
               NSLog(@"TabellenkopfString: last Char ist n");
            }
            if([TabellenkopfString characterAtIndex:lastBuchstabenPos]=='\r')
            {
               NSLog(@"TabellenkopfString: last Char ist r");
            }
            [TabellenkopfString deleteCharactersInRange:NSMakeRange(lastBuchstabenPos,1)];
            NSMutableAttributedString* attrKopfString=[[NSMutableAttributedString alloc] initWithString:TabellenkopfString];
            [attrKopfString addAttribute:NSParagraphStyleAttributeName value:TabellenKopfStil range:NSMakeRange(0,[TabellenkopfString length])];
            [attrKopfString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TabellenkopfString length])];
            [[KommentarView textStorage]appendAttributedString:attrKopfString];
            
            //Stil für Abstand2
            NSMutableParagraphStyle* Abstand2Stil=[[NSMutableParagraphStyle alloc]init];
            NSFont* Abstand2Font=[NSFont fontWithName:@"Helvetica" size: 2];
            NSMutableAttributedString* attrAbstand2String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
            [attrAbstand2String addAttribute:NSParagraphStyleAttributeName value:Abstand2Stil range:NSMakeRange(0,1)];
            [attrAbstand2String addAttribute:NSFontAttributeName value:Abstand2Font range:NSMakeRange(0,1)];
            
            [[KommentarView textStorage]appendAttributedString:attrAbstand2String];
            
            
            
            
            NSString* cr=@"\r";
            //NSAttributedString*CR=[[[NSAttributedString alloc]initWithString:cr]autorelease];
            int index=1;
            if ([KommentarArray count]>1)
            {
               for (index=1;index<[KommentarArray count];index++)
               {
                  NSString* tempZeile=[KommentarArray objectAtIndex:index];
                  
                  if ([tempZeile length]>1)
                  {
                     NSString* tempString=[tempZeile substringToIndex:[tempZeile length]-1];
                     NSString* tempArrayString=[NSString stringWithFormat:@"%@%@",tempString, cr];
                     
                     NSMutableAttributedString* attrTextString=[[NSMutableAttributedString alloc] initWithString:tempArrayString];
                     [attrTextString addAttribute:NSParagraphStyleAttributeName value:TabelleStil range:NSMakeRange(0,[tempArrayString length])];
                     [attrTextString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[tempArrayString length])];
                     [[KommentarView textStorage]appendAttributedString:attrTextString];
                     
                  }
               }//for index
            }//if count>1
         }break;//alsTabelleFormatOption
            
         case alsAbsatzFormatOption:
         {
            NSFont* TextFont;
            TextFont=[NSFont fontWithName:@"Helvetica" size: 10];
            NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
            
            NSMutableParagraphStyle* AbsatzStil=[[NSMutableParagraphStyle alloc]init];
            [AbsatzStil setTabStops:[NSArray array]];
            NSTextTab* AbsatzTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:90];
            [AbsatzStil addTabStop:AbsatzTab1];
            [AbsatzStil setHeadIndent:90];
            //[AbsatzStil setParagraphSpacing:4];
            
            NSMutableAttributedString* attrTextString=[[NSMutableAttributedString alloc] initWithString:TextString];
            [attrTextString addAttribute:NSParagraphStyleAttributeName value:AbsatzStil range:NSMakeRange(0,[TextString length])];
            
            [attrTextString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TextString length])];
            
            [[KommentarView textStorage]appendAttributedString:attrTextString];
            
            
         }break;//alsAbsatzFormatOption
      }//Auswahloption
      
      //NSLog(@"Ende setKommentar: TitelStil retainCount: %d",[TitelStil retainCount]);
      //NSLog(@"Ende setKommentar: attrTitelString retainCount: %d",[attrTitelString retainCount]);
      //[attrTitelString release];
      //NSLog(@"Ende setKommentar: TitelTab1 retainCount: %d",[TitelTab1 retainCount]);
      //[TitelTab1 release];
      //NSLog(@"Ende setKommentar%@",@"\r***\r\r\r");//: attrTitelString retainCount: %d",[attrTitelString retainCount]);
      //NSLog(@"setKommentarMit Komm.DicArray: Ende while");
      [[KommentarView textStorage]appendAttributedString:attrAbstand12String];//Abstand zu nächstem Projekt
      [[KommentarView textStorage]appendAttributedString:attrAbstand12String];
      
   }//while Enum
   //NSLog(@"Schluss: maxNamenbreite: %d  maxTitelbreite: %d",maxNamenbreite, maxTitelbreite);
   [Anz setIntValue:AnzahlAnmerkungen];
   //NSLog(@"setKommentarMit Komm.DicArray: nach while");
}

- (IBAction)toggleDrawer:(id)sender
{
   //NSLog(@"Drawer:%@",[OptionDrawer description]);
   [OptionDrawer toggle:sender];
}

- (IBAction)reportKommentarOption:(id)sender // Darstellungsoptionen
{
   NSMutableDictionary* KommentarOptionDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   
   [AuswahlPopMenu synchronizeTitleAndSelectedItem];
   NSNumber* AuswahlOptionTag;
   AuswahlOptionTag=[NSNumber numberWithDouble:[[AuswahlPopMenu selectedCell]tag]];
   //NSMutableDictionary* KommentarOptionDic=[NSMutableDictionary dictionaryWithObject:AuswahlOptionTag forKey:@"auswahl"];
   
   NSNumber* AbsatzOptionTag;
   //AbsatzOption=[[AbsatzMatrix selectedCell]tag];
   AbsatzOptionTag=0; //[NSNumber numberWithInt:[AbsatzMatrix selectedColumn]];
   NSLog(@"reportKommentarOption:AbsatzOptionTag: %d ",[AbsatzOptionTag intValue]);
   [KommentarOptionDic setObject:AbsatzOptionTag forKey:@"Absatz"];
   
   //	NamenOptionString=[[PopAMenu selectedItem]description];
   NamenOptionString=[PopAMenu titleOfSelectedItem];
   [KommentarOptionDic setObject:NamenOptionString forKey:@"popa"];
   //NSLog(@"reportKommentarOption:A");
   NSNumber* AnzahlOptionTag;
   AnzahlOption=[[AnzahlPop selectedCell]tag];
   //NSLog(@"reportKommentarOption:B");
   AnzahlOptionTag=[NSNumber numberWithInt:[[AnzahlPop selectedCell]tag]];
   NSLog(@"reportKommentarOption:C");
   [KommentarOptionDic setObject:AnzahlOptionTag forKey:@"Anzahl"];
   
   NSLog(@"reportKommentarOption:%@ ",[KommentarOptionDic description]);
   //NSNotificationCenter * nc;
   //nc=[NSNotificationCenter defaultCenter];
   //[nc postNotificationName:@"KommentarOption" object: self userInfo:KommentarOptionDic];
   [self KommentarSuchenMitDic:KommentarOptionDic];
   
}

/*
- (int)AuswahlOption
{
   return [ProjektMatrix selectedRow];
}
*/
- (int)AbsatzOption
{
   return [AbsatzMatrix selectedRow];
}




- (IBAction)nurMarkierteOption:(id)sender
{
   //NSLog(@"setAuswahl: %d",[[sender selectedCell]tag]);
   int nurMarkierteOK=[nurMarkierteCheck state];
   NSNumber* nurMarkierteNumber =[NSNumber numberWithInt:nurMarkierteOK];
   
   NSMutableDictionary* KommentarOptionDic=[NSMutableDictionary dictionaryWithObject:nurMarkierteNumber forKey:@"nurmarkierte"];
   if (NamenOptionString)
   {
   }
   
   
   //NSNotificationCenter * nc;
   //nc=[NSNotificationCenter defaultCenter];
   //[nc postNotificationName:@"KommentarOption" object: self userInfo:KommentarOptionDic];
   [self KommentarSuchenMitDic:KommentarOptionDic];
}

/*
- (NSString*)PopAOption
{
   return [PopAMenu  titleOfSelectedItem];
}


- (NSString*)PopBOption
{
   return [PopBMenu  titleOfSelectedItem];
}
*/

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
   const short DatumReturn=2;
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
           //NSLog(@"DatumVon tempDatumString: %@", tempDatumString);
        }
        else
        {
           tempDatumString=@" ";
        }
     }
   
   
   return tempDatumString;
   
}
- (NSString*)ZeitVon:(NSString*) derKommentarString
{
   const short DatumReturn=2;
   NSString* tempZeitString;
   tempZeitString=[derKommentarString copy];
   int AnzReturns=0;
   int returnpos1=0,returnpos2=0;
   int pos=0;
   while(pos<[tempZeitString length])
	  {
        if (([tempZeitString characterAtIndex:pos]=='\r')||([tempZeitString characterAtIndex:pos]=='\n'))
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
        tempZeitString=[tempZeitString substringWithRange:r]; // ganze DatumZeile
        NSArray* tempArray= [tempZeitString componentsSeparatedByString:@" "];
        if ([tempArray count]> 1)
        {
           tempZeitString = [tempArray objectAtIndex:1];
        }
        else
        {
           tempZeitString = @"";
        }
        
        
     }
   
   
   return tempZeitString;
   
}



-(int) tagVonDatum:(NSString*)datumstring
{
   int returnvalue=0;
   returnvalue = [[[datumstring componentsSeparatedByString:@"."]objectAtIndex:0]intValue];
   return returnvalue;
}
-(int) monatVonDatum:(NSString*)datumstring
{
   int returnvalue=0;
   returnvalue = [[[datumstring componentsSeparatedByString:@"."]objectAtIndex:1]intValue];
   return returnvalue;
}
-(int) jahrVonDatum:(NSString*)datumstring
{
   int returnvalue=0;
   returnvalue = [[[datumstring componentsSeparatedByString:@"."]objectAtIndex:2]intValue];
   return returnvalue;
}

-(int) stundeVonZeit:(NSString*)zeitstring
{
   int returnvalue=0;
   returnvalue = [[[zeitstring componentsSeparatedByString:@":"]objectAtIndex:0]intValue];
   return returnvalue;
}


- (void)KommentarSuchenMitDic:(NSDictionary*)OptionDic
{
   NSString* alle=@"alle";
   //Aufgerufen nach Änderungen in den Pops des Kommentarfensters
   //NSString* alle=@"alle";
   NSLog(@"\n\n********				Beginn KommentarSuchenMitDic\n\n ");
   //NSDictionary* OptionDic=[note userInfo];
   NSLog(@"KommentarSuchenMitDic: OptionDic: %@",[OptionDic description]);
   NSString* tempProjektName;
   if ([OptionDic objectForKey:@"projektname"])
   {
      tempProjektName=[OptionDic objectForKey:@"projektname"];
   }
   //NSLog(@"tempProjektName: %@ AdminLeseboxPfad: %@ AdminArchivPfad: %@",tempProjektName,AdminLeseboxPfad,AdminArchivPfad);
   //Pop Auswahl
   //Einstellung, welche Auswahl aus den Kommentaren getroffen werden soll.
   //Grundeinstellung ist: lastKommentarOption. Die neuesten Kommentare werden angezeigt
   
   
   NSNumber* AuswahlNummer=[OptionDic objectForKey:@"auswahl"];
   if (AuswahlNummer) // index von AuswahlPop,
   {
      AuswahlOption=(int)[AuswahlNummer intValue];
      NSLog(@"KommentarSuchenMitDic AuswahlOption: %d",[AuswahlNummer intValue]);
      switch (AuswahlOption)
      {
         case lastKommentarOption:
         {
            NSLog(@"KommentarSuchenMitDic lastKommentarOption");
            [self resetPopAMenu];
            [self resetPopBMenu];
            switch (ProjektAuswahlOption)
            {
               case 0://Nur ein Projekt
               {
                  NSLog(@"alleVonNameKommentarOption: Nur 1 Projekt AdminProjektPfad: %@ tempProjektName: %@",AdminProjektPfad,tempProjektName);
                  
                  NSString* tempAdminProjektPfad=[[AdminProjektPfad stringByDeletingLastPathComponent]stringByAppendingPathComponent:tempProjektName];
                  NSLog(@"tempAdminProjektPfad: %@",tempAdminProjektPfad);
                  NSArray* tempNamenArray=[self LeserArrayAnProjektPfad:tempAdminProjektPfad];
                  NSLog(@"lastKommentarOption: Nur 1 Projekt tempNamenArray: %@",[tempNamenArray description]);
                  
                  NSString* tempKommentarPfad = [tempAdminProjektPfad stringByAppendingPathComponent:@"Anmerkungen"];
                  
                  for (int namenindex=0;namenindex < [tempNamenArray count];namenindex++)
                  {
                     
                     NSString* lastKommentarstring = [self lastKommentarVonLeser:[tempNamenArray objectAtIndex:namenindex] anProjektPfad:tempAdminProjektPfad];
                     
                     /*
                     NSError* err;
                     NSString* tempKommentarPfad  = [tempAdminProjektPfad stringByAppendingPathComponent:[tempNamenArray objectAtIndex:namenindex]];
                     NSString* tempKommentarfuerNamePfad = [tempKommentarPfad stringByAppendingPathComponent:@"Anmerkungen"];
                     // NSLog(@"tempKommentarfuerNamePfad: %@",tempKommentarfuerNamePfad);
                     NSArray* AnmerkungenArray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:tempKommentarfuerNamePfad error: &err];
                     
                     //NSLog(@"AnmerkungenArray: %@",[AnmerkungenArray description]);
                     int tag=0;
                     int monat=0;
                     int jahr=0;
                     NSLog(@"Leser: %@",[tempNamenArray objectAtIndex:namenindex]);
                     for (int kommentarindex = 0;kommentarindex < [AnmerkungenArray count]; kommentarindex ++ )
                     {
                        if ([[AnmerkungenArray objectAtIndex:kommentarindex] rangeOfString:@".DS_Store"].location == NSNotFound )
                        {
                           NSString* tempAnmerkungPfad = [tempKommentarfuerNamePfad stringByAppendingPathComponent:[AnmerkungenArray objectAtIndex:kommentarindex]];
                           
                           NSString* namenKommentarString=[NSString stringWithContentsOfFile:tempAnmerkungPfad encoding:NSMacOSRomanStringEncoding error:NULL];
                           //NSLog(@"Pfad: %@ namenKommentarString: \n%@",tempAnmerkungPfad,namenKommentarString);
                           NSString* tempAnmerkung = [self KommentarVon:namenKommentarString ];
                           if ([tempAnmerkung length] > 2)
                           {
                              NSString* DatumString = [self DatumVon:namenKommentarString];
                              NSString* ZeitString = [self ZeitVon:namenKommentarString];
                              //NSLog(@"Kommentar: %@ Datum: %@",[AnmerkungenArray objectAtIndex:kommentarindex],DatumString);
                              int tempstunde = [self stundeVonZeit:ZeitString];
                              int temptag = [self tagVonDatum:DatumString];
                              int tempmonat = [self monatVonDatum:DatumString];
                              int tempjahr = [self jahrVonDatum:DatumString]%2000;
                              
                              //NSLog(@"Datum: %@ temptag: %d tempMonat: %d tempjahr: %d",DatumString,temptag, tempmonat, tempjahr);
                              long datumcode = tempstunde + temptag*100 + 10000*tempmonat + 1000000*tempjahr;
                             // NSLog(@"Datum: %@ temptag: %d tempstunde: %d tempMonat: %d tempjahr: %d  datumcode: %ld",DatumString,tempstunde,temptag, tempmonat, tempjahr,datumcode);
                              NSLog(@"Datum: %@ datumcode: %ld tempAnmerkung: %@",DatumString,datumcode, tempAnmerkung);
                           }
                           
                        }
                     }
                     */
                     
                     
                  }
                  
                  
                  
                  
                  [self setPopAMenu:tempNamenArray erstesItem:alle aktuell:NULL];
                  [self resetPopBMenu];
                  
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
                  
                  [self setPopAMenu:tempNamenArray erstesItem:alle aktuell:alle];
                  [self setPopBMenu:NULL erstesItem:alle aktuell:alle mitPrompt:@"mit Titel:"];
               }break;
                  
               case 2://Alle Projekte
               {
                  
               }break;
                  
            }
            
            
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
                  [self setPopAMenu:tempNamenArray erstesItem:alle aktuell:NULL];
                  [self resetPopBMenu];
                  
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
                  
                  [self setPopAMenu:tempNamenArray erstesItem:alle aktuell:alle];
                  [self setPopBMenu:NULL erstesItem:alle aktuell:alle mitPrompt:@"mit Titel:"];
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
            NSLog(@"alleVonTitelKommentarOption tempTitelArray: %@",[tempTitelArray description]);
            [self setPopAMenu:tempTitelArray erstesItem:alle aktuell:NULL];
            [self resetPopBMenu];
            
         }break;//alleVonTitelKommentarOption
      }//switch AuswahlOption
      
      //NSLog(@"Notifik: AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
      NSLog(@"AuswahlOption: %d  OptionAString: %@  OptionBString: %@",AuswahlOption,[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
      
      
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
   
   NSNumber* nurMarkierteNummer=[OptionDic objectForKey:@"nurmarkierte"];
   if (nurMarkierteNummer)
   {
      //nurMarkierteOption=[nurMarkierteCheck state];
      //NSLog(@"KommentarNotificationAktion nurMarkierteOption: %d",[nurMarkierteCheck state]);
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
            
            [self setPopAMenu:LeserArray erstesItem:alle aktuell:alle];
            [self resetPopBMenu];
         }break;//alleVonNameKommentarOption
            
         case alleVonTitelKommentarOption:
         {
            NSArray* tempTitelArray= [self TitelArrayVonAllenAnProjektPfad:ProjektPfadOptionString
                                                         bisAnzahlProLeser:AnzahlOption ];
            //NSLog(@"alleVonTitelKommentarOption tempTitelArray: %@",[tempTitelArray description]);
            [self setPopAMenu:tempTitelArray erstesItem:alle aktuell:NULL];
            
            
            NSArray* LeserArray=[self LeserArrayVonTitel:[PopAMenu  titleOfSelectedItem] anProjektPfad:ProjektPfadOptionString];
            //NSLog(@"Komm.Not.Aktion LeserArray: %@	OptionAString: %@  OptionBString. %@",	[LeserArray description],[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
            if ([LeserArray count]==1)//Nur ein Leser für diesen Titel
            {
               [self setPopBMenu:LeserArray erstesItem:NULL aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
            }
            else
            {
               [self setPopBMenu:LeserArray erstesItem:alle aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
            }
            
            
            
         }break;//alleVonTitelKommentarOption
            
      }
      
   }
   
   
   NSString* tempAString=[OptionDic objectForKey:@"popa"];
   if (tempAString )//&& [tempAString length])
   {
      //NSLog(@"KommentarNotificationAktion   tempAString: %@   Länge: %d" ,tempAString, [tempAString length]);
     // OptionAString=[tempAString copy];
      switch (AuswahlOption)
      {
         case lastKommentarOption:
         {
            
         }break;//lastKommentarOption
            
         case alleVonNameKommentarOption:
         {
            if ([[PopAMenu  titleOfSelectedItem] isEqualToString:alle])
            {
               [self resetPopBMenu];
               
            }
            else
            {
               //NSLog(@"\n******\nKommentarNotifikation alleVonNameKommentarOption: OptionAString: %@",[PopAMenu  titleOfSelectedItem]);
               
               
               NSMutableArray* TitelArray=[[self TitelMitKommentarArrayVon:[PopAMenu  titleOfSelectedItem] anProjektPfad:ProjektPfadOptionString]mutableCopy];
               
               
               
               //NSLog(@"KommentarNotifilkation alleVonNameKommentarOption: \nProjektPfadOptionString: %@   \nTitelArray: %@",ProjektPfadOptionString,[TitelArray description]);
               //NSLog(@"TitelArray: %@	OptionAString: %@  OptionBString. %@",	[TitelArray description],[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
               if(ProjektAuswahlOption==0)//nur bei einzelnem Projekt
               {
                  [self setPopBMenu:TitelArray erstesItem:alle aktuell:alle mitPrompt:@"mit Titel:"];
               }
            }
         }break;//alleVonNameKommentarOption
            
         case alleVonTitelKommentarOption:
         {
            //NSLog(@"alleVonTitelKommentarOption: PopAOption: %@ ",[PopAMenu  titleOfSelectedItem]);
            {
               if ([[PopAMenu  titleOfSelectedItem] isEqualToString:alle])
               {
                  [self resetPopBMenu];
               }
               else
               {
                  NSMutableArray* LeserArray=[[self LeserArrayVonTitel:[PopAMenu  titleOfSelectedItem] anProjektPfad:ProjektPfadOptionString]mutableCopy];
                  //NSLog(@"alleVonTitelKommentarOption vor .DS: LeserArray: %@	[PopAMenu  titleOfSelectedItem]: %@  OptionBString. %@",	[LeserArray description],[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
                  if ([LeserArray count]>0)//ES HAT LESER MIT KOMMENTAR FÜR DIESENJ TITEL
                  {
                     
                     if ([[LeserArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
                     {
                        //NSLog(@"LeserArray .DS");
                        [LeserArray removeObjectAtIndex:0];
                     }
                     
                     //NSLog(@"alleVonTitelKommentarOption: LeserArray: %@	[PopAMenu  titleOfSelectedItem]: %@  OptionBString. %@",	[LeserArray description],[PopAMenu  titleOfSelectedItem],[PopBMenu  titleOfSelectedItem]);
                     if ([LeserArray count]==1)//Nur ein Leser für diesen Titel
                     {
                        [self setPopBMenu:LeserArray erstesItem:NULL aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
                     }
                     else
                     {
                        [self setPopBMenu:LeserArray erstesItem:alle aktuell:NULL mitPrompt:NSLocalizedString(@"for Reader",@"für Leser:")];
                     }
                  }//Count>0
               }
               
            }
         }break;//alleVonTitelKommentarOption
            
      }//switch AuswahlOption
      
   }
   
   NSString* tempBString=[OptionDic objectForKey:@"popb"];
   if (tempBString )//&& [tempBString length])
   {
      //NSLog(@"\nKommentarNotificationAktion   tempBString: %@\n",tempBString);
      OptionBString=[tempBString copy];
      
      
   }
   
   
   
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
            [self setAuswahlPop:alleVonNameKommentarOption];
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
            
            [self setPopAMenu:tempNamenArray erstesItem:alle aktuell:alle];
            [self setPopBMenu:NULL erstesItem:alle aktuell:alle mitPrompt:@"mit Titel:"];
         }break;
            
         case 2://Alle Projekte
         {
            //NSLog(@"tempProjektAuswahlOptionNumberNur alle Projekte");
            [self setAuswahlPop:alleVonNameKommentarOption];
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
            
            [self setPopAMenu:tempNamenArray erstesItem:alle aktuell:alle];
            [self setPopBMenu:NULL erstesItem:alle aktuell:alle mitPrompt:@"mit Titel:"];
            
         }break;
            
      }
   }
   
   //****
   //NSLog(@"KommentarArray entsprechend den Settings aufbauen");
   
   //KommentarArray entsprechend den Settings aufbauen
   
   NSMutableArray* tempProjektDicArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSLog(@"ProjektAuswahlOption: %d",ProjektAuswahlOption);
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
   
   NSLog(@"KommentarSuchenMitDic nach Create:  KommentarStringArray: %@%@%@",@"\r",[KommentarStringArray description],@"\r");
   //NSLog(@"\n**********\nvor KommentarFenster setKommentarMitKommentarDicArray");
   [self setKommentarMitKommentarDicArray:KommentarStringArray];
   //NSLog(@"\nnach KommentarFenster setKommentarMitKommentarDicArray\n**********\n");
   
}

- (IBAction)reportAuswahl:(id)sender
{
   NSLog(@"setAuswahl: %d",[[sender selectedCell]tag]);
   AuswahlOption=[[sender selectedCell]tag];
   [AnzahlPop setEnabled:AuswahlOption>0];
   NSNumber* AuswahlOptionNumber =[NSNumber numberWithInt:AuswahlOption];
   
   NSMutableDictionary* KommentarOptionDic=[NSMutableDictionary dictionaryWithObject:AuswahlOptionNumber forKey:@"auswahl"];
   
   if (NamenOptionString) // aus PopAMenu
   {
      
   }
   
   [KommentarOptionDic setObject:[ProjektPopMenu titleOfSelectedItem]forKey:@"projektname"];
   double projektpopindex = [ProjektPopMenu indexOfSelectedItem]; // Option von ProjektMatrix
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:projektpopindex]forKey:@"projektnamenoption"];
   double popaindex = [PopAMenu indexOfSelectedItem]; // Option von PopA
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:popaindex]forKey:@"popa"];
   double popbindex = [PopBMenu indexOfSelectedItem]; // Option von PopB
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:popbindex]forKey:@"popb"];

   double nurmarkierteindex = [nurMarkierteCheck state]; // Option von nurMarkierteCheck
   [KommentarOptionDic setObject:[NSNumber numberWithBool:nurmarkierteindex]forKey:@"nurmarkierte"];

   [KommentarOptionDic setObject:[NSNumber numberWithDouble:[ProjektMatrix selectedRow]]forKey:@"projektauswahloption"];
   
  
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:[[AnzahlPop selectedCell]tag]]forKey:@"anzahloption"];
  
 
   [self KommentarSuchenMitDic:KommentarOptionDic];
  
   NSLog(@"Ende setAuswahl");
}

- (NSDictionary*)aktuellerOptionDic
{
   NSMutableDictionary* KommentarOptionDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   double auswahloption = [[AuswahlPopMenu selectedCell]tag];
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:auswahloption]forKey:@"auswahl"];
   AuswahlOption = auswahloption;
   
   [KommentarOptionDic setObject:[ProjektPopMenu titleOfSelectedItem]forKey:@"projektname"];
   
   double projektpopindex = [ProjektPopMenu indexOfSelectedItem]; // Option von ProjektMatrix
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:projektpopindex]forKey:@"projektnamenoption"];
   double popaindex = [PopAMenu indexOfSelectedItem]; // Option von PopA
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:popaindex]forKey:@"popa"];
   
   double popbindex = [PopBMenu indexOfSelectedItem]; // Option von PopB
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:popbindex]forKey:@"popb"];
   
   double nurmarkierteindex = [nurMarkierteCheck state]; // Option von nurMarkierteCheck
   [KommentarOptionDic setObject:[NSNumber numberWithBool:nurmarkierteindex]forKey:@"nurmarkierte"];
   //nurMarkierteOption = [nurMarkierteCheck state];
   
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:[ProjektMatrix selectedRow]]forKey:@"projektauswahloption"];
   //ProjektAuswahlOption =
   [KommentarOptionDic setObject:[NSNumber numberWithDouble:[[AnzahlPop selectedCell]tag]]forKey:@"anzahloption"];
   return KommentarOptionDic;
}

- (IBAction)reportAnzahl:(id)sender
{
   NSLog(@"reportAnzahl: %d",[[sender selectedCell]tag]);
   AnzahlOption=[[sender selectedCell]tag];
   NSNumber* AnzahlOptionNumber =[NSNumber numberWithInt:AnzahlOption];
   
   NSMutableDictionary* KommentarOptionDic=[NSMutableDictionary dictionaryWithObject:AnzahlOptionNumber forKey:@"Anzahl"];
   [KommentarOptionDic setObject:[ProjektPopMenu titleOfSelectedItem]forKey:@"projektname"];
   NSLog(@"reportAnzahl: KommentarOptionDic: %@",[KommentarOptionDic description]);
   if (NamenOptionString)
   {
   }
   
   //NSNotificationCenter * nc;
   //nc=[NSNotificationCenter defaultCenter];
   //[nc postNotificationName:@"KommentarOption" object: self userInfo:KommentarOptionDic];
   [self KommentarSuchenMitDic:KommentarOptionDic];
}
- (IBAction)reportPopA:(id)sender
{
   NSLog(@"reportPopA: %@",[sender titleOfSelectedItem]);
   NamenOptionString=[sender titleOfSelectedItem];
   
   NSMutableDictionary* KommentarOptionDic=[NSMutableDictionary dictionaryWithObject:NamenOptionString forKey:@"popa"];
   
   [KommentarOptionDic setObject:[NSNumber numberWithInt:[ProjektPopMenu tag]]forKey:@"tag"];
   [KommentarOptionDic setObject:[ProjektPopMenu titleOfSelectedItem]forKey:@"projektname"];
   
   
   
   
   //Notifikation
   [self KommentarSuchenMitDic:KommentarOptionDic];
   
   //
}
- (IBAction)reportPopB:(id)sender
{
   NSLog(@"reportPopB: %@",[sender titleOfSelectedItem]);
   TitelOptionString=[sender titleOfSelectedItem];
   
   NSMutableDictionary* KommentarOptionDic=[NSMutableDictionary dictionaryWithObject:TitelOptionString forKey:@"popb"];
   [KommentarOptionDic setObject:[ProjektPopMenu titleOfSelectedItem]forKey:@"projektname"];
   
   //	NSNotificationCenter * nc;
   //	nc=[NSNotificationCenter defaultCenter];
   //	[nc postNotificationName:@"KommentarOption" object: self userInfo:KommentarOptionDic];
   [self KommentarSuchenMitDic:KommentarOptionDic];
}

- (IBAction)reportProjektNamenOption:(id)sender
{
   NSLog(@"setProjektNamenOption: %@ Index: %d",[sender titleOfSelectedItem],[sender indexOfSelectedItem]);
   ProjektOption=[sender indexOfSelectedItem];
   NSMutableDictionary* ProjektOptionDic=[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:ProjektOption] forKey:@"projektnamenoption"];
   [ProjektOptionDic setObject:[sender titleOfSelectedItem] forKey:@"projektname"];
   
   
   
   //	NSNotificationCenter * nc;
   //	nc=[NSNotificationCenter defaultCenter];
   //	[nc postNotificationName:@"KommentarOption" object: self userInfo:ProjektOptionDic];
   [self KommentarSuchenMitDic:ProjektOptionDic];
   
   
   //[self setPopAMenu:NULL erstesItem:@"alle" aktuell:NULL];
   
   //[self setAuswahlPop:lastKommentarOption];
   //[self resetPopBMenu];
}


- (IBAction)reportProjektAuswahlOption:(id)sender
{
   NSLog(@"setProjektAuswahlOption: %d Index: %d",[sender selectedRow],[sender selectedRow]);
   ProjektOption=[[ProjektMatrix selectedCell]tag];
   switch (ProjektOption)
   {
      case 0: //nur ein Projekt
      {
         [ProjektPopMenu setEnabled:YES];
      }break;
      case 1://nur aktive Projekte
      {
         [ProjektPopMenu setEnabled:NO];
      }break;
      case 2://alle Projekte
      {
         [ProjektPopMenu setEnabled:NO];
      }break;
   }//switch
   NSMutableDictionary* ProjektOptionDic=[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:ProjektOption] forKey:@"projektauswahloption"];
   [ProjektOptionDic setObject:[ProjektPopMenu titleOfSelectedItem]forKey:@"projektname"];
   
   //NSNotificationCenter * nc;
   //nc=[NSNotificationCenter defaultCenter];
   //[nc postNotificationName:@"KommentarOption" object: self userInfo:ProjektOptionDic];
   [self KommentarSuchenMitDic:ProjektOptionDic];
}

- (NSTextView*)setDruckKommentarMitKommentarDicArray:(NSArray*)derKommentarDicArray
                                             mitFeld:(NSRect)dasFeld
{
   //NSLog(@"setDruckKommentarMitKommentarDicArray: KommentarDicArray: %@",[derKommentarDicArray description]);
   NSTextView* DruckKommentarView=[[NSTextView alloc]initWithFrame:dasFeld];
   //[DruckKommentarView retain];
   if ([derKommentarDicArray count]==0)
   {
      NSLog(@"setDruckKommentarMitKommentarDicArray: kein KommentarDicArray");
      return 0;
   }
   
   NSFontManager *fontManager = [NSFontManager sharedFontManager];
   //NSLog(@"*KommentarFenster  setDruckKommentarMitKommentarDicArray* %@",[[derKommentarDicArray valueForKey:@"kommentarstring"]description]);
   
    
   //NSString* TitelString=NSLocalizedString(@"Comments from ",@"Anmerkungen vom ");
   NSString* TitelString=@"Anmerkungen vom ";
   
   NSString* KopfString=[NSString stringWithFormat:@"%@  %@%@",TitelString,heuteDatumString,@"\r\r"];
   
   //Font für Titelzeile
   NSFont* TitelFont;
   TitelFont=[NSFont fontWithName:@"Helvetica" size: 14];
   
   //Stil für Titelzeile
   NSMutableParagraphStyle* TitelStil=[[NSMutableParagraphStyle alloc]init];
   [TitelStil setTabStops:[NSArray array]];//default weg
   NSTextTab* TitelTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:90];
   
   //Stil für Abstand12
   NSMutableParagraphStyle* Abstand12Stil=[[NSMutableParagraphStyle alloc]init];
   NSFont* Abstand12Font=[NSFont fontWithName:@"Helvetica" size: 12];
   NSMutableAttributedString* attrAbstand12String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
   [attrAbstand12String addAttribute:NSParagraphStyleAttributeName value:Abstand12Stil range:NSMakeRange(0,1)];
   [attrAbstand12String addAttribute:NSFontAttributeName value:Abstand12Font range:NSMakeRange(0,1)];
   //Abstandzeile einsetzen
   
   
   [TitelStil addTabStop:TitelTab1];
   
   //Attr-String für Titelzeile zusammensetzen
   NSMutableAttributedString* attrTitelString=[[NSMutableAttributedString alloc] initWithString:KopfString];
   [attrTitelString addAttribute:NSParagraphStyleAttributeName value:TitelStil range:NSMakeRange(0,[KopfString length])];
   [attrTitelString addAttribute:NSFontAttributeName value:TitelFont range:NSMakeRange(0,[KopfString length])];
   
   //titelzeile einsetzen
   [[DruckKommentarView textStorage]setAttributedString:attrTitelString];
   
   
   //Breite von variablen Feldern
   int maxNamenbreite=12;
   int maxTitelbreite=12;
   int Textschnitt=10;
   
   NSEnumerator* TabEnum=[derKommentarDicArray objectEnumerator];
   id einTabDic;
   NSLog(@"setDruckKommentarMit Komm.DicArray: vor while   Anz. Dics: %d",[derKommentarDicArray count]);
   
   while (einTabDic=[TabEnum nextObject])//erster Durchgang: Länge von Namen und Titel bestimmen
   {
      NSString* ProjektTitel;
      //NSString* KommentarString;
      if ([einTabDic objectForKey:@"projekt"])
      {
         ProjektTitel=[einTabDic objectForKey:@"projekt"];
         //NSLog(@"ProjektTitel: %@",ProjektTitel);
         
         if ([einTabDic objectForKey:@"kommentarstring"])
         {
            NSMutableString* TextString=[[einTabDic objectForKey:@"kommentarstring"] mutableCopy];
            long pos=[TextString length]-1;
            BOOL letzteZeileWeg=NO;
            if ([TextString characterAtIndex:pos]=='\r')
            {
               letzteZeileWeg=YES;
               pos--;
            }
            
            if([TextString characterAtIndex:pos]=='\n')
            {
               NSLog(@"last Char ist n");
            }
            NSFont* TextFont;
            TextFont=[NSFont fontWithName:@"Helvetica" size: Textschnitt];
            //NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
            
            NSMutableArray* KommentarArray=(NSMutableArray*)[TextString componentsSeparatedByString:@"\r"];
            if (letzteZeileWeg)
            {
               //NSLog(@"letzteZeileWeg");
               [KommentarArray removeLastObject];
            }
            [Anz setDoubleValue:[KommentarArray count]-1];
            NSString* titel=NSLocalizedString(@"Title:",@"Titel:");
            //char * tb=[titel lossyCString];
            const char * tb=[titel cStringUsingEncoding:NSMacOSRomanStringEncoding];
            double Titelbreite=strlen(tb);//Minimalbreite für Tabellenkopf von Titel
            if (Titelbreite>maxTitelbreite)
            {
               maxTitelbreite=Titelbreite;
            }
            NSString* name=NSLocalizedString(@"Name",@"Name:");
            //char * nb=[name lossyCString];
            const char * nb=[name cStringUsingEncoding:NSMacOSRomanStringEncoding];
            double Namenbreite=strlen(nb);//Minimalbreite für Tabellenkopf von Name
            if (Namenbreite>maxNamenbreite)
            {
               maxNamenbreite=Namenbreite;
            }
            //NSLog(@"Tabellenkopf: Namenbreite: %d  Titelbreite: %d",Namenbreite, Titelbreite);
            
            int i;
            
            //Länge von Name und Titel feststellen
            for (i=0;i<[KommentarArray count];i++)
            {
               
               //if ([KommentarArray objectAtIndex:i])
               
               //NSLog(@"%@KommentarArray Zeile: %d %@",@"\r",i,[KommentarArray objectAtIndex:i]);
               NSArray* ZeilenArray=[[KommentarArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
               if ([ZeilenArray count]>1)
               {
                  //char * nc=[[ZeilenArray objectAtIndex:0]lossyCString];
                  const char * nc=[[ZeilenArray objectAtIndex:0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
                  double nl=strlen(nc);
                  if(nl>Namenbreite)
                     Namenbreite=nl;
                  
                  //char * tc=[[ZeilenArray objectAtIndex:1]lossyCString];
                  const char * tc=[[ZeilenArray objectAtIndex:1] cStringUsingEncoding:NSMacOSRomanStringEncoding];
                  double tl=strlen(tc);
                  if(tl>Titelbreite)
                     Titelbreite=tl;
                  //NSLog(@"tempNamenbreite: %d  Titelbreite: %d",nl, tl);
               }
               
            }
            
            //NSLog(@"Namenbreite: %d  Titelbreite: %d",Namenbreite, Titelbreite);
            if (Namenbreite>maxNamenbreite)
            {
               maxNamenbreite=Namenbreite;
            }
            if (Titelbreite>maxTitelbreite)
            {
               maxTitelbreite=Titelbreite;
            }
            //NSLog(@"maxNamenbreite: %d  maxTitelbreite: %d",maxNamenbreite, maxTitelbreite);
         }//if Kommentarstring
      }//if einProjekt
   }//while Wortlängen bestimmen
   
   
   
   NSEnumerator* KommentarArrayEnum=[derKommentarDicArray objectEnumerator];
   id einKommentarDic;
   while (einKommentarDic=[KommentarArrayEnum nextObject])//Tabulatoren setzen und Tabelle aufbauen
   {
      //NSLog(@"											setKommentarMit Komm.DicArray: Beginn while 2. Runde");
      NSString* ProjektTitel;
      
      if ([einKommentarDic objectForKey:@"projekt"])
      {
         ProjektTitel=[einKommentarDic objectForKey:@"projekt"];
         //NSLog(@"ProjektTitel: %@",ProjektTitel);
      }
      else //Kein Projekt angegeben
      {
         ProjektTitel=@"Kein Projekt";
      }
      
      
      //Font für Projektzeile
      NSFont* ProjektFont;
      ProjektFont=[NSFont fontWithName:@"Helvetica" size: 12];
      
      NSString* ProjektString=NSLocalizedString(@"Project: ",@"Projekt: ");
      NSString* ProjektKopfString=[NSString stringWithFormat:@"%@    %@%@",ProjektString,ProjektTitel,@"\r"];
      
      //Stil für Projektzeile
      NSMutableParagraphStyle* ProjektStil=[[NSMutableParagraphStyle alloc]init];
      [ProjektStil setTabStops:[NSArray array]];//default weg
      NSTextTab* ProjektTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:150];
      [ProjektStil addTabStop:ProjektTab1];
      
      //Attr-String für Projektzeile zusammensetzen
      NSMutableAttributedString* attrProjektString=[[NSMutableAttributedString alloc] initWithString:ProjektKopfString];
      [attrProjektString addAttribute:NSParagraphStyleAttributeName value:ProjektStil range:NSMakeRange(0,[ProjektKopfString length])];
      [attrProjektString addAttribute:NSFontAttributeName value:ProjektFont range:NSMakeRange(0,[ProjektKopfString length])];
      
      //Projektzeile einsetzen
      [[DruckKommentarView textStorage]appendAttributedString:attrProjektString];
      
      //Stil für Abstand1
      NSMutableParagraphStyle* Abstand1Stil=[[NSMutableParagraphStyle alloc]init];
      NSFont* Abstand1Font=[NSFont fontWithName:@"Helvetica" size: 6];
      NSMutableAttributedString* attrAbstand1String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
      [attrAbstand1String addAttribute:NSParagraphStyleAttributeName value:Abstand1Stil range:NSMakeRange(0,1)];
      [attrAbstand1String addAttribute:NSFontAttributeName value:Abstand1Font range:NSMakeRange(0,1)];
      //Abstandzeile einsetzen
      [[DruckKommentarView textStorage]appendAttributedString:attrAbstand1String];
      
      NSMutableString* TextString;
      if ([einKommentarDic objectForKey:@"kommentarstring"])
      {
         TextString=[[einKommentarDic objectForKey:@"kommentarstring"]mutableCopy];
      }
      else //Keine Kommentare in diesem Projekt
      {
         TextString=[NSLocalizedString(@"No comments for this Project",@"Keine Kommentare für dieses Projekt") mutableCopy];
      }
      
      
      int pos=[TextString length]-1;
      BOOL letzteZeileWeg=NO;
      if ([TextString characterAtIndex:pos]=='\r')
      {
         //NSLog(@"last Char ist r");
         //[TextString deleteCharactersInRange:NSMakeRange(pos-1,1)];
         letzteZeileWeg=YES;
         pos--;
      }
      
      if([TextString characterAtIndex:pos]=='\n')
      {
         NSLog(@"last Char ist n");
      }
      
      AuswahlOption=[[AuswahlPopMenu selectedCell]tag];
      
      //NSLog(@"*KommentarFenster  setKommentar textString: %@  AuswahlOption: %d",TextString, AuswahlOption);
      
      switch ([[AbsatzMatrix selectedCell]tag])
      
      {
         case alsTabelleFormatOption:
         {
            //int Textschnitt=10;
            
            NSFont* TextFont;
            TextFont=[NSFont fontWithName:@"Helvetica" size: Textschnitt];
            //NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
            
            NSMutableArray* KommentarArray=(NSMutableArray*)[TextString componentsSeparatedByString:@"\r"];
            if (letzteZeileWeg)
            {
               //NSLog(@"letzteZeileWeg");
               [KommentarArray removeLastObject];
            }
            
            [Anz setIntValue:[KommentarArray count]-1];
            
            //NSLog(@"2. Runde: maxNamenbreite: %d  maxTitelbreite: %d",maxNamenbreite, maxTitelbreite);
            //
            //Tabulatoren aufaddieren
            float titeltab=120;
            
            titeltab=maxNamenbreite*(3*Textschnitt/5);
            float datumtab=260;
            
            datumtab=titeltab+maxTitelbreite*(3*Textschnitt/5);
            float bewertungtab=325;
            bewertungtab=datumtab+12*(3*Textschnitt/5);
            
            //bewertungtab=datumtab;
            
            float notetab=380;
            notetab=bewertungtab+12*(3*Textschnitt/5);
            float anmerkungentab=410;
            anmerkungentab=notetab+8*(3*Textschnitt/5);
            
            NSMutableParagraphStyle* TabellenKopfStil=[[NSMutableParagraphStyle alloc]init];
            [TabellenKopfStil setTabStops:[NSArray array]];
            NSTextTab* TabellenkopfTitelTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:titeltab];
            [TabellenKopfStil addTabStop:TabellenkopfTitelTab];
            NSTextTab* TabellenkopfDatumTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:datumtab];
            [TabellenKopfStil addTabStop:TabellenkopfDatumTab];
            //				NSTextTab* TabellenkopfBewertungTab=[[[NSTextTab alloc]initWithType:NSLeftTabStopType location:bewertungtab]autorelease];
            //				[TabellenKopfStil addTabStop:TabellenkopfBewertungTab];
            NSTextTab* TabellenkopfNoteTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:notetab];
            [TabellenKopfStil addTabStop:TabellenkopfNoteTab];
            NSTextTab* TabellenkopfAnmerkungenTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:anmerkungentab];
            [TabellenKopfStil addTabStop:TabellenkopfAnmerkungenTab];
            [TabellenKopfStil setParagraphSpacing:4];
            
            
            NSMutableParagraphStyle* TabelleStil=[[NSMutableParagraphStyle alloc]init];
            [TabelleStil setTabStops:[NSArray array]];
            NSTextTab* TabelleTitelTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:titeltab];
            [TabelleStil addTabStop:TabelleTitelTab];
            NSTextTab* TabelleDatumTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:datumtab];
            [TabelleStil addTabStop:TabelleDatumTab];
            //				NSTextTab* TabelleBewertungTab=[[[NSTextTab alloc]initWithType:NSLeftTabStopType location:bewertungtab]autorelease];
            //				[TabelleStil addTabStop:TabelleBewertungTab];
            NSTextTab* TabelleNoteTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:notetab];
            [TabelleStil addTabStop:TabelleNoteTab];
            NSTextTab* TabelleAnmerkungenTab=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:anmerkungentab];
            [TabelleStil addTabStop:TabelleAnmerkungenTab];
            [TabelleStil setHeadIndent:anmerkungentab];
            [TabelleStil setParagraphSpacing:2];
            
            //Kommentarstring in Komponenten aufteilen
            //NSString* TabellenkopfString=[[KommentarArray objectAtIndex:0]stringByAppendingString:@"\r"];
            NSMutableString* TabellenkopfString=[[KommentarArray objectAtIndex:0]mutableCopy];
            int lastBuchstabenPos=[TabellenkopfString length]-1;
            //NSLog(@"TabellenkopfString: %@   length: %d  last: %d",TabellenkopfString,lastBuchstabenPos,[TabellenkopfString characterAtIndex:lastBuchstabenPos] );
            
            
            if([TabellenkopfString characterAtIndex:lastBuchstabenPos]=='\n')
            {
               NSLog(@"TabellenkopfString: last Char ist n");
            }
            if([TabellenkopfString characterAtIndex:lastBuchstabenPos]=='\r')
            {
               NSLog(@"TabellenkopfString: last Char ist r");
            }
            [TabellenkopfString deleteCharactersInRange:NSMakeRange(lastBuchstabenPos,1)];
            NSMutableAttributedString* attrKopfString=[[NSMutableAttributedString alloc] initWithString:TabellenkopfString];
            [attrKopfString addAttribute:NSParagraphStyleAttributeName value:TabellenKopfStil range:NSMakeRange(0,[TabellenkopfString length])];
            [attrKopfString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TabellenkopfString length])];
            [[DruckKommentarView textStorage]appendAttributedString:attrKopfString];
            
            //Stil für Abstand2
            NSMutableParagraphStyle* Abstand2Stil=[[NSMutableParagraphStyle alloc]init];
            NSFont* Abstand2Font=[NSFont fontWithName:@"Helvetica" size: 2];
            NSMutableAttributedString* attrAbstand2String=[[NSMutableAttributedString alloc] initWithString:@" \r"];
            [attrAbstand2String addAttribute:NSParagraphStyleAttributeName value:Abstand2Stil range:NSMakeRange(0,1)];
            [attrAbstand2String addAttribute:NSFontAttributeName value:Abstand2Font range:NSMakeRange(0,1)];
            
            [[DruckKommentarView textStorage]appendAttributedString:attrAbstand2String];
            
            
            
            
            NSString* cr=@"\r";
            //NSAttributedString*CR=[[[NSAttributedString alloc]initWithString:cr]autorelease];
            int index=1;
            if ([KommentarArray count]>1)
            {
               for (index=1;index<[KommentarArray count];index++)
               {
                  NSString* tempZeile=[KommentarArray objectAtIndex:index];
                  
                  if ([tempZeile length]>1)
                  {
                     NSString* tempString=[tempZeile substringToIndex:[tempZeile length]-1];
                     NSString* tempArrayString=[NSString stringWithFormat:@"%@%@",tempString, cr];
                     
                     NSMutableAttributedString* attrTextString=[[NSMutableAttributedString alloc] initWithString:tempArrayString];
                     [attrTextString addAttribute:NSParagraphStyleAttributeName value:TabelleStil range:NSMakeRange(0,[tempArrayString length])];
                     [attrTextString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[tempArrayString length])];
                     [[DruckKommentarView textStorage]appendAttributedString:attrTextString];
                     //NSLog(@"Ende setKommentar: attrTextString retainCount: %d",[attrTextString retainCount]);
                     
                  }
               }//for index
            }//if count>1
         }break;//alsTabelleFormatOption
            
         case alsAbsatzFormatOption:
         {
            NSFont* TextFont;
            TextFont=[NSFont fontWithName:@"Helvetica" size: 12];
            NSFontTraitMask TextFontMask=[fontManager traitsOfFont:TextFont];
            
            NSMutableParagraphStyle* AbsatzStil=[[NSMutableParagraphStyle alloc]init];
            [AbsatzStil setTabStops:[NSArray array]];
            NSTextTab* AbsatzTab1=[[NSTextTab alloc]initWithType:NSLeftTabStopType location:90];
            [AbsatzStil addTabStop:AbsatzTab1];
            [AbsatzStil setHeadIndent:90];
            //[AbsatzStil setParagraphSpacing:4];
            
            NSMutableAttributedString* attrTextString=[[NSMutableAttributedString alloc] initWithString:TextString];
            [attrTextString addAttribute:NSParagraphStyleAttributeName value:AbsatzStil range:NSMakeRange(0,[TextString length])];
            
            [attrTextString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TextString length])];
            
            [[DruckKommentarView textStorage]appendAttributedString:attrTextString];
            //NSLog(@"Ende setKommentar: attrTextString retainCount: %d",[attrTextString retainCount]);
            
            
         }break;//alsAbsatzFormatOption
      }//Auswahloption
      
      //NSLog(@"Ende setKommentar: TitelStil retainCount: %d",[TitelStil retainCount]);
      //NSLog(@"Ende setKommentar: attrTitelString retainCount: %d",[attrTitelString retainCount]);
      //[attrTitelString release];
      //NSLog(@"Ende setKommentar: TitelTab1 retainCount: %d",[TitelTab1 retainCount]);
      //[TitelTab1 release];
      //NSLog(@"Ende setKommentar%@",@"\r***\r\r\r");//: attrTitelString retainCount: %d",[attrTitelString retainCount]);
      //NSLog(@"setKommentarMit Komm.DicArray: Ende while");
      [[DruckKommentarView textStorage]appendAttributedString:attrAbstand12String];//Abstand zu nächstem Projekt 
      [[DruckKommentarView textStorage]appendAttributedString:attrAbstand12String];
      
   }//while Enum
   //NSLog(@"Schluss: maxNamenbreite: %d  maxTitelbreite: %d",maxNamenbreite, maxTitelbreite);
   
   //NSLog(@"setKommentarMit Komm.DicArray: nach while");
   //[KommentarView retain];
   return DruckKommentarView;
}



- (NSTextView*)setDruckViewMitFeld:(NSRect)dasDruckFeld
              mitKommentarDicArray:(NSArray*)derKommentarDicArray
{
   NSTextView* tempView;
   tempView=[self setDruckKommentarMitKommentarDicArray:derKommentarDicArray mitFeld:dasDruckFeld];
   
   return tempView;
}




- (void)KommentarDruckenMitProjektDicArray:(NSArray*)derProjektDicArray
{
   
   NSTextView* DruckView=[[NSTextView alloc]init];
   //NSLog (@"Kommentar: KommentarDruckenMitProjektDicArray ProjektDicArray: %@",[derProjektDicArray description]);
   NSPrintInfo* PrintInfo=[NSPrintInfo sharedPrintInfo];
   switch (AbsatzOption)
	  {
        case alsTabelleFormatOption:
        {
           [PrintInfo setOrientation:NSLandscapeOrientation];
        };break;
           
        case alsAbsatzFormatOption:
        {
           [PrintInfo setOrientation:NSPortraitOrientation];
        };break;
     }//switch AbsatzOption
   
   
   //[PrintInfo setOrientation:NSPortraitOrientation];
   //[PrintInfo setHorizontalPagination: NSAutoPagination];
   [PrintInfo setVerticalPagination: NSAutoPagination];
   
   [PrintInfo setHorizontallyCentered:NO];
   [PrintInfo setVerticallyCentered:NO];
   NSRect bounds=[PrintInfo imageablePageBounds];
   
   //int x=bounds.origin.x;int y=bounds.origin.y;int h=bounds.size.height;int w=bounds.size.width;
   //NSLog(@"Bounds 1 x: %d y: %d  h: %d  w: %d",x,y,h,w);
   NSSize Papiergroesse=[PrintInfo paperSize];
   int leftRand=(Papiergroesse.width-bounds.size.width)/2;
   int topRand=(Papiergroesse.height-bounds.size.height)/2;
   int platzH=(Papiergroesse.width-bounds.size.width);
   
   int freiLinks=60;
   int freiOben=30;
   //int DruckbereichH=bounds.size.width-freiLinks+platzH*0.5;
   int DruckbereichH=Papiergroesse.width-freiLinks-leftRand;
   
   int DruckbereichV=bounds.size.height-freiOben;
   
   int platzV=(Papiergroesse.height-bounds.size.height);
   
   //NSLog(@"platzH: %d  platzV %d",platzH,platzV);
   
   int botRand=(Papiergroesse.height-topRand-bounds.size.height-1);
   
   [PrintInfo setLeftMargin:freiLinks];
   [PrintInfo setRightMargin:leftRand];
   [PrintInfo setTopMargin:freiOben];
   [PrintInfo setBottomMargin:botRand];
   
   
   int Papierbreite=(int)Papiergroesse.width;
   int Papierhoehe=(int)Papiergroesse.height;
   int obererRand=[PrintInfo topMargin];
   int linkerRand=(int)[PrintInfo leftMargin];
   int rechterRand=[PrintInfo rightMargin];
   
   NSLog(@"linkerRand: %d  rechterRand: %d  Breite: %d Hoehe: %d",linkerRand,rechterRand, DruckbereichH,DruckbereichV);
   NSRect DruckFeld=NSMakeRect(linkerRand, obererRand, DruckbereichH, DruckbereichV);
   
   
   
   DruckView=[self setDruckViewMitFeld:DruckFeld mitKommentarDicArray:derProjektDicArray];
   
   
   
   
   
   //[DruckView setBackgroundColor:[NSColor grayColor]];
   //[DruckView setDrawsBackground:YES];
   NSPrintOperation* DruckOperation;
   DruckOperation=[NSPrintOperation printOperationWithView: DruckView
                                                 printInfo:PrintInfo];
   [DruckOperation setShowsPrintPanel:YES];
   [DruckOperation runOperation];
   
}


- (void)KommentarSichernMitProjektDicArray:(NSArray*)derProjektDicArray
{
   
   NSTextView* DruckView=[[NSTextView alloc]init];
   //NSLog (@"Kommentar: KommentarDruckenMitProjektDicArray ProjektDicArray: %@",[derProjektDicArray description]);
   NSPrintInfo* PrintInfo=[NSPrintInfo sharedPrintInfo];
   switch (AbsatzOption)
	  {
        case alsTabelleFormatOption:
        {
           [PrintInfo setOrientation:NSLandscapeOrientation];
        };break;
           
        case alsAbsatzFormatOption:
        {
           [PrintInfo setOrientation:NSPortraitOrientation];
        };break;
     }//switch AbsatzOption
   
   
   //[PrintInfo setOrientation:NSPortraitOrientation];
   //[PrintInfo setHorizontalPagination: NSAutoPagination];
   [PrintInfo setVerticalPagination: NSAutoPagination];
   
   [PrintInfo setHorizontallyCentered:NO];
   [PrintInfo setVerticallyCentered:NO];
   NSRect bounds=[PrintInfo imageablePageBounds];
   
   int x=bounds.origin.x;int y=bounds.origin.y;int h=bounds.size.height;int w=bounds.size.width;
   //NSLog(@"Bounds 1 x: %d y: %d  h: %d  w: %d",x,y,h,w);
   NSSize Papiergroesse=[PrintInfo paperSize];
   int leftRand=(Papiergroesse.width-bounds.size.width)/2;
   int topRand=(Papiergroesse.height-bounds.size.height)/2;
   int platzH=(Papiergroesse.width-bounds.size.width);
   
   int freiLinks=60;
   int freiOben=30;
   //int DruckbereichH=bounds.size.width-freiLinks+platzH*0.5;
   int DruckbereichH=Papiergroesse.width-freiLinks-leftRand;
   
   int DruckbereichV=bounds.size.height-freiOben;
   
   int platzV=(Papiergroesse.height-bounds.size.height);
   
   //NSLog(@"platzH: %d  platzV %d",platzH,platzV);
   
   int botRand=(Papiergroesse.height-topRand-bounds.size.height-1);
   
   [PrintInfo setLeftMargin:freiLinks];
   [PrintInfo setRightMargin:leftRand];
   [PrintInfo setTopMargin:freiOben];
   [PrintInfo setBottomMargin:botRand];
   
   
   int Papierbreite=(int)Papiergroesse.width;
   int Papierhoehe=(int)Papiergroesse.height;
   int obererRand=[PrintInfo topMargin];
   int linkerRand=(int)[PrintInfo leftMargin];
   int rechterRand=[PrintInfo rightMargin];
   
   NSLog(@"linkerRand: %d  rechterRand: %d  Breite: %d Hoehe: %d",linkerRand,rechterRand, DruckbereichH,DruckbereichV);
   NSRect DruckFeld=NSMakeRect(linkerRand, obererRand, DruckbereichH, DruckbereichV);
   
   DruckView=[self setDruckViewMitFeld:DruckFeld mitKommentarDicArray:derProjektDicArray];
   
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [NotificationDic setObject:DruckView forKey:@"druckview"];
   NSLog(@"NotificationDic: %@",[NotificationDic description]);
   //NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   //[nc postNotificationName:@"SaveKommentar" object:self userInfo:NotificationDic];
   [self KommentarSuchenMitDic:NotificationDic];
}




- (NSView*)KommentarView
{
   NSLog(@"Kommentar return KommentarView");
   return KommentarView;
}

- (void)dealloc
{
}
@end

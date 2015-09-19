//
//  kommentare.c
//  Lesestudio_20
//
//  Created by Ruedi Heimlicher on 06.09.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#include "kommentare.h"
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
                       // ***************
                       // m4a entfernen, txt anfuegen
                       NSString* tempKommentarTitel =[[eineAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
                       NSString* tempKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempKommentarTitel]; // OK
                       // **********
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
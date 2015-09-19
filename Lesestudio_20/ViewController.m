//
//  ViewController.m
//  Lesestudio_20
//
//  Created by Ruedi Heimlicher on 01.09.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//
enum
{
   Datum=2,
   Bewertung,
   Noten,
   UserMark,
   AdminMark,
   Kommentar
};
enum
{
   kModusMenuTag=30000,
   kRecPlayTag,
   kAdminTag,
   kKommentarTag,
   kEinstellungenTag
};

enum
{
   kAblaufMenuTag=40000,
   kProjektWahlenTag,
   kProjektlisteBearbeitenTag,
   kMarkierungenLoschenTag,
   kAlleMarkierungenLoschenTag,
   kListeAktualisierenTag,
   kAufnahmenLoschenTag,
   kAufnahmenExportierenTag,
   kLeseboxNeuOrdnenTag,
   kAndereLeseboxTag,
   kSettingsTag
};

enum
{
   kNamenListeBearbeitenTag=50001,
   kPasswortAndernTag,
   kPasswortListeBearbeitenTag,
   kTitelListeBearbeitenTag
};
enum
{
   kRecorderMenuTag=80000,
   kRecorderProjektWahlenTag,
   kRecorderPasswortAndernTag,
   kRecorderSettingsTag,
   kNeueSessionTag,
   kSessionAktualisierenTag
};


#import "ViewController.h"

#import "rUtils.h"

const short DatumReturn=2;
const short BewertungReturn= 3;
const short NotenReturn= 4;
const short UserMarkReturn= 5;
const short AdminMarkReturn= 6;
const short KommentarReturn=7;
NSString*	RPDevicedatenKey=	@"RPDevicedaten";



@implementation ViewController

@synthesize AdminPlayer;

@synthesize Testfenster;

- (id)initWithNibName:(NSString *)nibname bundle:(NSBundle *)bundlename
{
   NSLog(@"init nibname: %@ ",self.nibName);
   self = [ super initWithNibName: nil bundle:nil];
   return self;
}
- (void)viewDidLoad
{
   [super viewDidLoad];
      NSLog(@"nibname: %@ window: %@",self.nibName, [[self.view window]description]);
   

   
//   [self initWithNibName:self.nibName bundle:nil];
   startcode=0;
   RPAufnahmenDirIDKey		=	@"RPAufnahmenDirID";
   Wert1Key=@"Wert1";
   Wert2Key=@"Wert2";
   RPModusKey=@"RPModus";
   RPBewertungKey=@"RPBewertung";
   RPNoteKey=@"RPNote";
   RPStartStatusKey=@"StartStatus";
   
   self.aktuellAnzAufnahmen=0;
   self.Aufnahmedauer=0;

   
   //   projekt=@"projekt";
   //   projektpfad=@"projektpfad";
   //   archivpfad=@"archivpfad";
   //  leseboxpfad=@"leseboxpfad";
   //  projektarray=@"projektarray";
   //  OK=@"OK";
   //   fix=@"fix";
   //  mituserpw=@"mituserpw";
   
   RPDevicedaten=[NSMutableData dataWithCapacity:0];
   SystemDevicedaten=[NSMutableData dataWithCapacity:0];
   self.LeseboxDa=NO;
   self.ArchivPlayerGeladen=NO;
   
   self.mitAdminPasswort=YES;
   self.mitUserPasswort=YES;
   self.AdminZugangOK=NO;
   
   [self.view.window setDelegate:self];
   
   //NSLog(@"NSAlertDefaultReturn: %d",NSAlertDefaultReturn);
   
   NSLog(@"[NSDate date]: %@",[[NSDate date]description]); // 2015-09-12 17:15:21 +0000
 //  NSLog(@"[NSCalendarDate date]: %@",[[NSCalendarDate date]description]); // 2015-09-12 19:16:41 +0200
   
   
   // http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c
   localDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];//  12.09.2015 19:20:26
   NSLog(@"localDate: %@",localDate);
   heuteDatumString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];//  12.09.2015 19:20:26
   NSLog(@"heuteDatumString: %@",heuteDatumString);
   
   NSDate *currentDate = [NSDate date];
   NSCalendar* calendar = [NSCalendar currentCalendar];
   NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate]; // Get necessary date components

   long monat = [components month]; //gives you month
   long tag = [components day]; //gives you day
   long jahr = [components year]; // gives you year

   NSLog(@"tag: %ld monat: %ld jahr: %ld",tag,monat,jahr);
   
   heuteTagDesJahres = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];

   NSLog(@"heuteTagDesJahres: %ld ",heuteTagDesJahres);
 
   
   
   NSNotificationCenter * nc;
   nc=[NSNotificationCenter defaultCenter];
   [nc addObserver:self
          selector:@selector(KeyNotifikationAktion:)
              name:@"Pfeiltaste"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(ZeilenNotifikationAktion:)
              name:@"selektierteZeile"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(EnterKeyNotifikationAktion:)
              name:@"EnterKey"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(BewertungNotifikationAktion:)
              name:@"mitBewertung"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(NotenNotifikationAktion:)
              name:@"mitNote"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(StartStatusNotifikationAktion:)
              name:@"StartStatus"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(UmgebungAktion:)
              name:@"Umgebung"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(VolumesAktion:)
              name:@"VolumeWahl"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(SettingsAktion:)
              name:@"Settings"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(ProjektListeAktion:)
              name:@"ProjektWahl"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(neuesProjektAktion:)
              name:@"neuesProjekt"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(neuesProjektVomStartAktion:)
              name:@"neuesProjektVomStart"
            object:nil];
   
 
   
   [nc addObserver:self
          selector:@selector(anderesProjektAktion:)
              name:@"anderesProjekt"
            object:nil];
   
   
   [nc addObserver:self
          selector:@selector(ProjektStartAktion:)
              name:@"ProjektStart"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(ProjektEntfernenAktion:)
              name:@"ProjektEntfernen"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(ProjektMenuAktion:)
              name:@"ProjektMenu"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(savePListAktion:)
              name:@"savePList"
            object:nil];
   
   
   
   
   [nc addObserver:self
          selector:@selector(BeendenAktion:)
              name:@"externbeenden"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(TitelListeAktion:)
              name:@"titelliste"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(TimeoutAktion:)
              name:@"timeout"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(SaveKommentarAktion:)
              name:@"SaveKommentar"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(LevelmeterAktion:)
              name:@"levelmeter"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(RecordingAktion:)
              name:@"recording"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(AbspielPosAktion:)
              name:@"abspielpos"
            object:nil];
   
   
   [nc addObserver:self
          selector:@selector(ListeAktualisierenAktion:)
              name:@"ListeAktualisieren"
            object:nil];
   
   
   [nc addObserver:self
          selector:@selector(RecordingAktion2:)
              name:@"AVCaptureSessionDidStartRunningNotification"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(AdminStartAktion:)
              name:@"adminstart"
            object:nil];
 
   [nc addObserver:self
          selector:@selector(NameIstEntferntAktion:)
              name:@"NameIstEntfernt"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(NameIstEingesetztAktion:)
              name:@"NameIstEingesetzt"
            object:nil];

   [nc addObserver:self
          selector:@selector(AdminEntfernenNotificationAktion:)
              name:@"adminentfernen"
            object:nil];

   
   NSArray* windowViewArray = [[self view] subviews];
   
   
   BOOL success = NO;
   NSError *error;
   Utils = [[rUtils alloc ]init];
   
   self.ProjektArray = [[NSMutableArray alloc]initWithCapacity:0];
   self.PListProjektArray = [[NSMutableArray alloc]initWithCapacity:0];
   self.ProjektNamenArray = [[NSMutableArray alloc]initWithCapacity:0];
   self.UserPasswortArray = [[NSMutableArray alloc]initWithCapacity:0];
   self.AdminPasswortDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   
   
   NSString* lb=@"Lesebox";
   NSString* cb=@"Anmerkungen";
   NSString*HomeLeseboxPfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@",@"/Documents/",lb];
   //NSLog(@"cb: %@  Lesebox: %@ HomeLeseboxPfad: %@",cb,lb,HomeLeseboxPfad);
   NSString* locBeenden=@"Beenden";
   NSColor* HintergrundFarbe=[NSColor colorWithDeviceRed: 150.0/255 green:249.0/255 blue:150.0/255 alpha:1.0];

   //NSColor* HintergrundFarbe=[NSColor colorWithDeviceRed:80.0/255.0 green:230.0/255.0 blue:140.0/255.0 alpha:1.0];
   NSColor * TitelFarbe=[NSColor purpleColor];
   NSFont* TitelFont;
   TitelFont=[NSFont fontWithName:@"Helvetica" size: 36];
   [[self TitelString]setFont:TitelFont];
   [[self TitelString] setTextColor:TitelFarbe];
   [[self ModusString] setFont:TitelFont];
   [[self ModusString] setTextColor:TitelFarbe];
   HomeLeseboxPfad = @"/Users/ruediheimlicher/Documents/Lesebox";
   //NSLog(@"viewdidload cb: %@ Lesebox: %@ HomeLeseboxPfad: %@",cb,lb,HomeLeseboxPfad);
   
   //BOOL istOrdner;
   //   [self.RecPlayFenster setDelegate:self];
   //   [self.RecPlayFenster setBackgroundColor:HintergrundFarbe];
 //  NSColor* FensterFarbe=[NSColor colorWithDeviceRed: 194.0/255 green:249.0/255 blue:194.0/255 alpha:1.0];
   NSColor* FensterFarbe=[NSColor colorWithDeviceRed: 150.0/255 green:249.0/255 blue:150.0/255 alpha:1.0];

   //  self.view.backgroundColor=FensterFarbe;
   //[[self view]window].backgroundColor=FensterFarbe;
   
   // http://stackoverflow.com/questions/2962790/best-way-to-change-the-background-color-for-an-nsview
   [self.view setWantsLayer:YES];
   [self.view.layer setBackgroundColor:[FensterFarbe CGColor]];
   
   
   
   [[self.view window ]setDelegate:self];
   //	NSColor * TitelFarbe=[NSColor whiteColor];
   TitelFont=[NSFont fontWithName:@"Helvetica" size: 36];
   [self.TitelString setFont:TitelFont];
   [self.TitelString setTextColor:TitelFarbe];
   [self.ModusString setFont:TitelFont];
   [self.ModusString setTextColor:TitelFarbe];
   
   
   NSImage* myImage = [NSImage imageNamed: @"MicroIcon"];
   [NSApp setApplicationIconImage: myImage];
   
   [self.AblaufMenu setDelegate:self];
  // self.ModusMenu = [[NSMenu alloc]initWithName:@"Modus"];
   [self.ModusMenu setDelegate:self];
   [self.RecorderMenu setDelegate:self];
[[self.ModusMenu itemWithTag:kAdminTag] setTarget:self];//Admin
   /*
   [[self.ModusMenu itemWithTag:kRecPlayTag] setTarget:self];//Recorder
   
   [[self.ModusMenu itemWithTag:kKommentarTag] setTarget:self];//Kommentar
   [[self.ModusMenu itemWithTag:kEinstellungenTag] setTarget:self];//Kommentar
   */
   //NSLog(@"Menu: %@ setAutoenablesItems: %d",[[ModusMenu itemWithTag:30002] title],[ModusMenu autoenablesItems]);
   //[AblaufMenu setDelegate:self];
   [[self.AblaufMenu itemWithTag:kAndereLeseboxTag] setTarget:self];//neue Lesebox
   [[self.AblaufMenu itemWithTag:kListeAktualisierenTag] setTarget:self];//Lesebox aktualisieren
   [[self.AblaufMenu itemWithTag:kLeseboxNeuOrdnenTag] setTarget:self];//Lesebox neu ordnen
   [[self.AblaufMenu itemWithTag:kAufnahmenLoschenTag] setTarget:self];//Aufnahmen loeschen
   [[self.AblaufMenu itemWithTag:kAufnahmenExportierenTag] setTarget:self];//Aufnahmen exportieren
   [[self.AblaufMenu itemWithTag:kSettingsTag] setTarget:self];//Settings
   [[self.AblaufMenu itemWithTag:kMarkierungenLoschenTag] setTarget:self];//
   [[self.AblaufMenu itemWithTag:kAlleMarkierungenLoschenTag] setTarget:self];//
   [[self.AblaufMenu itemWithTag:kTitelListeBearbeitenTag] setTarget:self];//
   
   // NSLog(@"Menu: %@ tag: %d",[[AblaufMenu itemWithTag:kProjektWahlenTag]description],kProjektWahlenTag);
   //[[AblaufMenu itemWithTag:kProjektWahlenTag] setTarget:self];//
   
   [[self.RecorderMenu itemWithTag:kRecorderProjektWahlenTag] setTarget:self];//
   [[self.RecorderMenu itemWithTag:kRecorderPasswortAndernTag] setTarget:self];//
   [[self.RecorderMenu itemWithTag:kRecorderSettingsTag] setTarget:self];//
   
   
   
   NSFileManager *Filemanager = [NSFileManager defaultManager];
   
   
   BOOL PListBusy=YES;
   int runde=0;
   while (PListBusy)
   {
      runde++;
      BOOL PListOK=[self Leseboxvorbereiten];
      
      
      PListBusy=!PListOK;
      if (runde==20)
      {
         PListBusy=NO;
      }
   }//while
   
   [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
   
   
   NSURL* URLPfad=[[NSURL alloc]initFileURLWithPath:self.LeseboxPfad];
   
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [NotificationDic setObject:self.LeseboxPfad forKey:@"leseboxpfad"];
   [NotificationDic setObject:self.ArchivPfad forKey:@"archivpfad"];
   
   [NotificationDic setObject:self.ProjektPfad forKey:@"projektpfad"];
   [NotificationDic setObject:self.ProjektArray forKey:@"projektarray"];
   
   [nc postNotificationName:@"Utils" object:self userInfo:NotificationDic];
   [self.ProjektFeld setStringValue:[self.ProjektPfad lastPathComponent]];
   [self.RecorderMenu setSubmenu:self.ProjektMenu forItem:[self.RecorderMenu itemWithTag:kRecorderProjektWahlenTag]];
   
   self.neueSettings=NO;
   switch (self.Umgebung)
   {
      case 1:
      {
         //NSLog(@"vor beginAdminPlayer:      ProjektArray: \n%@",[ProjektArray description]);
         
         if(!self.AdminZugangOK)
         {
            self.AdminZugangOK=[self checkAdminZugang];
         }
         if (self.AdminZugangOK)
            
         {
            //self.Umgebung=1;
            //NSLog(@"PListDic nach checkAdminZugang: %@",[PListDic description]);
            [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
            
            [self beginAdminPlayer:nil];
            //NSLog(@"PListDic nach beginAdminPlayer: %@",[PListDic description]);
            
            
            return;
         }
         else
         {
            NSLog(@"case kAdminUmgebung: Zugang nicht OK");
            
            self.Umgebung=0;
            //Kein gültiges PW für Admin, also Recorder öffnen
            if (![self NamenListeValidAnPfad:self.ProjektPfad]||([self checkAdminPW]==NO))//Im Projektordner sind keine Namen
            {
               NSAlert *Warnung = [[NSAlert alloc] init];
               
               [Warnung addButtonWithTitle:locBeenden];
               [Warnung setMessageText:@"Kein gültiges Admin-Passwort"];
               
               NSString* s1=@"Ordner für  Projekt xx ist leer";
               NSString* s2=[NSString stringWithFormat:s1,[self.ProjektPfad lastPathComponent]];
               
               NSString* s3=@"Das Programm wird beendet";
               NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s2,s3];
               [Warnung setInformativeText:InformationString];
               [Warnung setAlertStyle:NSWarningAlertStyle];
               
               //[Warnung setIcon:RPImage];
               long antwort=[Warnung runModal];
               if ([self checkAdminPW]==NO)//Neue LB, noch kein checkAdminPW gesetzt, aufräumen
               {
                  
                  if ([Filemanager fileExistsAtPath:self.LeseboxPfad])
                  {
                     NSLog(@"awake LB entfernen: %@",self.LeseboxPfad);
                     [Filemanager removeItemAtURL:[NSURL fileURLWithPath:self.LeseboxPfad] error:NULL];
                  }
                  [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
                  [NSApp terminate:self];
                  
               }
               else
               {
                  [self terminate:NULL];//ordentlich aussteigen
               }
            }
            
            
         }
         
         
      }break;
      case 0:
      {
         
      }break;
      default:
      {
         NSLog(@"switch RPModus: terminate");
         [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
         [self terminate:NULL];
         
      }
         
   }//Switch Umgebung
   
   [self Aufnahmevorbereiten];
   NSFont* Lesernamenfont;
   Lesernamenfont=[NSFont fontWithName:@"Helvetica" size: 20];
   NSColor * LesernamenFarbe=[NSColor whiteColor];
   [self.Leserfeld setFont: Lesernamenfont];
   [self.Leserfeld setTextColor: LesernamenFarbe];
   
   NSRect f = Abspielanzeige.frame;
   //NSLog(@"didLoad x: %f y: %f w:%f h:%f",f.origin.x,f.origin.y,f.size.width,f.size.height);
   
   
   NSRect abspielanzeigerect = NSMakeRect(315,295,225,20);
   Abspielanzeige = [[rAbspielanzeige alloc]initWithFrame:abspielanzeigerect];
   
   
   
   [[[self.RecPlayTab tabViewItemAtIndex:0] view]addSubview:Abspielanzeige];
   
   f = self.ArchivAbspielanzeige.frame;
   self.ArchivAbspielanzeige = [[rAbspielanzeige alloc]initWithFrame:f];
   
   [[[self.RecPlayTab tabViewItemAtIndex:1] view]addSubview:self.ArchivAbspielanzeige];
   
   NSArray* viewArray0 = [[[self.RecPlayTab tabViewItemAtIndex:0]view]subviews];
   //NSLog(@"viewArray0: %@",[viewArray0 description]);
   [Abspielanzeige setMax:abspielanzeigerect.size.width];
   [self.Fortschritt startAnimation:nil];
   [self.RecPlayFenster setIsVisible:YES];
   
   //[Leserfeld setBackgroundColor:[NSColor lightGrayColor]];
   //NSImage* StartRecordImg=[[NSImage alloc]initWithContentsOfFile:@"StartPlayImg.tif"];
   
   NSImage* StartRecordImg=[NSImage imageNamed:@"recordicon_w.gif"];
   
   //self.StartStopKnopf.image=StartRecordImg;
   //[[self.StartStopKnopf cell]setImage:StartRecordImg];
   
   NSImage* StopRecordImg=[NSImage imageNamed:@"stopicon_w.gif"];
   //   [[self.StopRecordKnopf cell]setImage:StopRecordImg];
   
   // NSImage* StartPlayImg=[NSImage imageNamed:@"StartPlayImg.tif"];
   NSImage* StartPlayImg=[NSImage imageNamed:@"playicon.gif"];
   //   [[self.StartPlayKnopf cell]setImage:StartPlayImg];
   
   
  // [[self.ArchivPlayTaste cell]setImage:StartPlayImg];
   NSImage* StopPlayImg=[NSImage imageNamed:@"StopPlayImg.tif"];
   //[[self.StopPlayKnopf cell]setImage:StopPlayImg];
   //[[self.ArchivStopTaste cell]setImage:StopPlayImg];
   NSImage* BackImg=[NSImage imageNamed:@"Back.tif"];
   //[[self.BackKnopf cell]setImage:BackImg];
   //[[self.ArchivZumStartTaste cell]setImage:BackImg];
   
   
   
   [self.RecPlayTab setDelegate:self];
   [self.RecPlayTab selectFirstTabViewItem:nil];
   self.ArchivDaten=[[rArchivDS alloc]initWithRowCount:0];
   [self.ArchivView setDelegate: self.ArchivDaten];
   [self.ArchivView setDataSource: self.ArchivDaten];
   //NSLog(@"setRecPlay:	mitUserPasswort: %d",mitUserPasswort);
   if (self.mitUserPasswort)
   {
      [self.PWFeld setStringValue:@"Mit Passwort"];
   }
   else
   {
      [self.PWFeld setStringValue:@"Ohne Passwort"];
   }
   NSLog(@"TimeoutDelay: %f",self.TimeoutDelay);
   //self.TimeoutDelay=40.0;
   self.AdminTimeoutDelay = 40.0;
   //Tooltips
   
   [self.StartRecordKnopf setToolTip:@"Aufnahme beginnen\nEine schon vorhandene ungesicherte Aufnahme wird überschrieben"];
   [self.StopRecordKnopf setToolTip:@"Aufnahme beenden"];
   [self.StartPlayKnopf setToolTip:@"Wiedergabe beginnen"];
   [self.BackKnopf setToolTip:@"Zurück an den Anfang"];
   [self.StopPlayKnopf setToolTip:@"Wiedergabe anhalten"];
   [self.SichernKnopf setToolTip:@"Aufnahme sichern.\nDie Aufnahme wird in der Lesebox gesichert."];
   [self.LogoutKnopf setToolTip:@"Abmelden des aktuellen Lesers."];
   //[[RecPlayTab tabViewItemAtIndex:1]setToolTip:@"Archiv von bisherigen Aufnahmen."];
   [self.ArchivInListeTaste setToolTip:@"Aktuelle Aufnahme in die Liste zurücklegen"];
   [self.ArchivInPlayerTaste setToolTip:@"Ausgewählte Aufnahme in den Player verschieben."];
   [self.UserMarkCheckbox setToolTip:@"Diese Aufnahme markieren."];
   [self.ArchivPlayTaste setToolTip:@"Wiedergabe beginnen"];
   [self.ArchivZumStartTaste setToolTip:@"Zurück an den Anfang"];
   [self.ArchivStopTaste setToolTip:@"Wiedergabe anhalten"];
   [self.TitelPop setToolTip:@"Nach dem Login:\n˙Titel der letzten Aufnahme.\nDarunter: Liste der vorhandenen Titel"];
   [self.ArchivnamenPop setToolTip:@"Liste der Namen im aktuellen Projekt."];
   [self.Leserfeld setToolTip:@"Nach dem Login:\nAktueller Leser"];
   [self.ProjektFeld setToolTip:@"Aktuelles Projekt\nEin anderes Projekt kann im Menü Recorder ausgewählt werden."];
//   [[self.ModusMenu itemWithTag:kAdminTag]setToolTip:@"Hallo"];
//   [[self.ModusMenu itemWithTag:kRecPlayTag]setToolTip:@"Hallo"];
//   [[self.ModusMenu itemWithTag:kKommentarTag]setToolTip:@"Hallo"];
   [[self.AblaufMenu itemWithTag:kEinstellungenTag]setToolTip:@"Hallo"];
   int i=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Wert1"]intValue];
   //NSLog(@"Test Wert1: %d",i);
   //i--;
   
   NSTimer* KontrollTimer=[NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(KontrollTimerfunktion:)
                                                         userInfo:nil
                                                          repeats:YES];
   
   [self.TimeoutFeld setIntValue:self.TimeoutDelay];
   // AVRecorder
   
   if (!(AVRecorder))
   {
      AVRecorder = [[rAVRecorder alloc]init];
   }
   if (AVRecorder)
   {
      AVRecorder.RecorderFenster = [self.view window];
      //   [AVRecorder setRecording:YES];
      // if AVRecorder
      AufnahmeZeit=0;
      [AVRecorder setstartzeit:startzeit];
   }
   
   if (!(AVAbspielplayer))
   {
      AVAbspielplayer = [[rAVPlayer alloc]init];
   }
   if (AVAbspielplayer)
   {
      AVAbspielplayer.PlayerFenster = [self.view window];
   }
   
  
   self.mainstoryboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
   //NSLog(@"mainstoryboard: %@",[self.mainstoryboard description]);
//   self.Testfenster = [rTestfensterController new];
   self.Testfenster = [self.mainstoryboard instantiateControllerWithIdentifier:@"testfenster"];
   //[[[self.Testfenster view]window] makeKeyAndOrderFront:nil];
    //NSLog(@"Testfenster: %@",[self.Testfenster description]);
 
   // EinstellungenFenster init
   self.EinstellungenFenster = [self.mainstoryboard instantiateControllerWithIdentifier:@"einstellungenfenster"];

   // Adminplayer init
//   self.AdminPlayer = [self.mainstoryboard instantiateControllerWithIdentifier:@"adminplayerfenster"];
  
   //self.view.window = [[NSWindow alloc]initWithFrame:[self.view bounds] stylemask:NSBorderlessWindowMask];
   
   [self.view.window setIsVisible:YES];
   [self.view.window makeFirstResponder:nil];
   
   //NSLog(@"end nibname: %@ window: %@",self.nibName, [[self.view window]description]);

   
   if (startcode)
   {
    //  [self beginAdminPlayer:nil];
   }
   NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
   
   NSMenu *modusMenu = [[mainMenu itemWithTitle:@"Modus"] submenu];
      for (NSMenuItem *item in [modusMenu itemArray])
      {
          //NSLog(@"Menuitem: %@",[item title]);
         [item setTarget:self];
      }

   NSMenu *adminMenu = [[mainMenu itemWithTitle:@"Admin"]submenu];
   for (NSMenuItem *item in [adminMenu itemArray])
   {
      //NSLog(@"Menuitem: %@",[item title]);
      [item setTarget:self];
      
   }
   NSMenu *recorderMenu = [[mainMenu itemWithTitle:@"Recorder"]submenu];
   for (NSMenuItem *item in [recorderMenu itemArray])
   {
      //NSLog(@"Menuitem: %@",[item title]);
      [item setTarget:self];
      
   }
 

  

   
   
   
   
   
   
   NSMenu *appMenu = [[mainMenu itemWithTitle:@"Modus"] submenu];
   
   [[mainMenu itemWithTitle:@"Modus"]setTarget:self];
   for (NSMenuItem *item in [appMenu itemArray])
   {
      [item setTarget:self];
   }

 //  [[appMenu itemWithTitle:@"Admin"]setTarget:self];
 //  [[appMenu itemWithTitle:@"Anmerkungen"]setTarget:self];
   [appMenu setAutoenablesItems:NO];
   //NSLog(@"viewDidLoad MenuItem: Modus: %@",[[appMenu itemWithTitle:@"Admin"]title]);
   [[mainMenu itemWithTitle:@"Modus"]setEnabled:YES];
   [[appMenu itemWithTitle:@"Admin"]setEnabled:YES];
   

   for (NSMenuItem *item in [appMenu itemArray])
   {
      [item setEnabled:YES];
   }
   //NSLog(@"MenuItem: Modus: %@",[[appMenu itemWithTitle:@"Admin"]title]);
}



- (void)setRepresentedObject:(id)representedObject {
   [super setRepresentedObject:representedObject];
   NSLog(@"setRepresentedObject");
   // Update the view, if already loaded.
}

#pragma mark start segue
- (IBAction)startTestfeld:(id)sender
{
   
    // [self presentViewController:Testfenster animated:YES completion:nil];
   // http://beardforhire.com/blog/super-simple-custom-segues/
   //NSLog(@"startTestfeld self.Testfenster: %@",[self.Testfenster description]);
   NSStoryboardSegue* adminsegue = [[NSStoryboardSegue alloc] initWithIdentifier:@"testfeld" source:self destination:self.Testfenster];
   [self prepareForSegue:adminsegue sender:sender];
   //[adminsegue perform];
  [self performSegueWithIdentifier:@"testfeld" sender:sender];
  
   NSStoryboardSegue* anzeigesegue = [[NSStoryboardSegue alloc] initWithIdentifier:@"anzeigefeld" source:self destination:self.Testfenster];
   [self prepareForSegue:anzeigesegue sender:sender];
   [self performSegueWithIdentifier:@"anzeigefeld" sender:sender];

   

}



- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
   //NSLog(@"prepareForSegue %@",[segue description]);
   if ([[segue identifier] isEqualToString:@"admindata"])
   {
      
      // Get destination view
      self.Testfenster = [segue destinationController];
   }
   
   if ([[segue identifier] isEqualToString:@"testfeld"])
   {
      //NSLog(@"prepareForSegue testfeld");
      // Get destination view
      self.Testfenster = [segue destinationController];
      [self.Testfenster setzeAnzeigeFeld:@"First"];
      
   }
 
   if ([[segue identifier] isEqualToString:@"anzeigefeld"])
   {
      
      [self.Testfenster setzeAnzeigeFeld:@"Seccond"];
      
      // NSLog(@"prepareForSegue erfolg: %d",erfolg);
   }
   
   
   
   if ([[segue identifier] isEqualToString:@"einstellungenanzeigefeld"])// zweiter kontakt
   {
      //NSLog(@"prepareForSegue einstellungenanzeigefeld");
      
 //     [self.EinstellungenFenster setzeAnzeigeFeld:@"*Anzeige*"];
   
   }

   
    if ([[segue identifier] isEqualToString:@"einstellungensegue"]) // erster kontakt
    {
       //NSLog(@"prepareForSegue einstellungensegue");
       self.EinstellungenFenster = (rEinstellungen*)segue.destinationController ;
       
       [self.EinstellungenFenster setBewertung:YES];
       [self.EinstellungenFenster setNote:YES];
       [self.EinstellungenFenster setzeAnzeigeFeld:@"Hallo Anzeige"];
       [self.EinstellungenFenster setTimeoutDelay:self.TimeoutDelay];
    }
   
   if ([[segue identifier] isEqualToString:@"adminplayersegue"]) // erster kontakt
   {
      //NSLog(@"prepareForSegue adminplayersegue");
      self.AdminPlayer = (rAdminPlayer*)segue.destinationController ;
 
   }
   
   // adminanzeigesegue
   if ([[segue identifier] isEqualToString:@"adminanzeigesegue"]) // erster kontakt
   {
      //NSLog(@"prepareForSegue adminanzeigesegue");
      
       self.AdminPlayer = (rAdminPlayer*)segue.destinationController ;
      NSLog(@"in beginAdminPlayer vor setAdminProjektArray: AdminPlayer:      ProjektArray: \n%@",[self.ProjektArray description]);
   
      
      [self.AdminPlayer setAdminPlayer:self.LeseboxPfad inProjekt:[self.ProjektPfad lastPathComponent]];
      
      [self.AdminPlayer setAdminProjektArray:self.ProjektArray];

      //NSLog(@"beginAdminPlayer nach setAdminPlayer");
      self.Umgebung=3;
     //NSLog(@"in beginAdminPlayer vor setProjektPop: AdminPlayer:      ProjektArray: \n%@",[self.ProjektArray description]);
      
      [self.AdminPlayer setProjektPopMenu:self.ProjektArray];
      
   }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier
                                  sender:(id)sender
{
   //NSLog(@"shouldPerformSegueWithIdentifier segue: %@",identifier);
   
   
   if ([identifier isEqualToString:@"einstellungensegue"])
   {
      
   }
   return YES;
   
   
}

#pragma mark end segue
/*
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
return YES;
}
*/

- (void)AdminStartAktion:(NSNotification*)note
{
   NSLog(@"AdminStartAktion note: %@",note);
   
   NSString* tempProjektWahl=[[note userInfo] objectForKey:@"projektwahl"];
   //tempProjektWahl = [tempProjektWahl stringByAppendingPathComponent:tempProjektWahl];
   // NSLog(@"ProjektStartAktion tempProjektWahl: %@",tempProjektWahl);
   
   self.ProjektPfad=[self.ArchivPfad stringByAppendingPathComponent:tempProjektWahl];
   if ([[note userInfo] objectForKey:@"projektpfad"])
   {
      self.ProjektPfad=[[note userInfo] objectForKey:@"projektpfad"];
   }
   NSLog(@"ArchivPfad :%@ * ProjektPfad: %@",self.ArchivPfad,self.ProjektPfad);
  //  [self beginAdminPlayer:nil];
   startcode=1;
}


- (void)RecordingAktion2:(NSNotification*)note{
   //NSLog(@"RecordingAktion note: %@",note);
   if ([[note userInfo ]objectForKey:@"record"])
   {
      switch([[[note userInfo ] objectForKey:@"record"]intValue])
      {
         case 0:
         {
            NSLog(@"RecordingAktion2 Aufnahme stop");
            if ([AufnahmeTimer isValid])
            {
               NSLog(@"RecordingAktion Timer valid");
               [AufnahmeTimer invalidate];
            }
         }break;
            
         case 1:
         {
            NSLog(@"RecordingAktion2 Aufnahme start");
            
            AufnahmeTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(AufnahmeTimerFunktion:)
                                                         userInfo:nil
                                                          repeats:YES];
         }break;
      }// switch
   }
   
}


- (void)TimeoutAktion:(NSNotification*)note
{
   //NSLog(@"TimeoutAktion %@",[[note userInfo]description]);
   
   if ([[note userInfo]objectForKey:@"run"])
   {
      if ([[[note userInfo]objectForKey:@"run"]intValue])
      {
         if ([[note userInfo]objectForKey:@"counter"])
         {
            if ([[[note userInfo]objectForKey:@"counter"]intValue])
            {
               int timeoutcounter = [[[note userInfo]objectForKey:@"counter"]intValue];
               [self.TimeoutFeld setIntValue:timeoutcounter];
            }
            else
            {
               [self.TimeoutFeld setIntValue:self.TimeoutDelay];
            }
         }
      }
      else
      {
         [self.TimeoutFeld setIntValue:self.TimeoutDelay];
      }
      
   }
   if ([[note userInfo]objectForKey:@"abmelden"])
   {
      int  AbmeldenCode=[[[note userInfo]objectForKey:@"abmelden"]intValue];
      //NSLog(@"TimeoutAktion: AbmeldenCode: %d",AbmeldenCode);
      switch (AbmeldenCode)
      {
         case 2://Retten
         {
            NSArray* FehlerArray=[self AufnahmeRetten];
            [Utils stopTimeout];
            [self resetRecPlay];
            
         }break;
            
         case 1://Sichern und abmelden
         {
            [self saveRecord:NULL];
            [self resetRecPlay];
            [Utils stopTimeout];
            //[self.view.window makeFirstResponder:self.view.window];
            //[self.view.window makeKeyAndOrderFront:nil];
         }break;
            
         case 0://Timeout abbrechen
         {
            [Utils startTimeout:self.TimeoutDelay];
         }break;
      }//switch
   }
 //
}


- (void)SaveKommentarAktion:(NSNotification*)note
{
   NSLog(@"SaveKommentarAktion");
   
   if ([[note userInfo]objectForKey:@"druckview"])
   {
      NSTextView* SaveView=[[note userInfo]objectForKey:@"druckview"];
      NSFileManager *Filemanager=[NSFileManager defaultManager];
      
      // Grab an instance of the global Save Panel:
      NSSavePanel *savePanel = [NSSavePanel savePanel];
      
      // save the text in an rtfd file wrapper
      [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"doc",nil]];
      
      // run the save panel modally to get the filename
      //NSString* tempSavePfad=@"/users/sysadmin/documents/Lesebox";
      if ([savePanel runModal ])//ForDirectory:LeseboxPfad file:@"Anmerkungen.doc"])
      {
         BOOL RemoveOK=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:[self.LeseboxPfad stringByAppendingPathComponent:@"Anmerkungen.doc"]]error:nil];
         // the text object knows how to save itself:
         //NSData* DataToSave=[DruckView RTFFromRange:NSMakeRange(0,[[DruckView textStorage] length])];
         //[DataToSave writeToFile:[[savePanel filename]stringByAppendingPathComponent:@"Kommentar.doc"]  atomically:YES];
         //[DruckView writeRTFDToFile:[savePanel filename]  atomically:YES];
         //NSLog(@"[savePanel filename]: %@, RemoveOK: %d",[savePanel filename],RemoveOK);
         NSString* Pfad=[[savePanel URL]path];
         NSRange SaveRange=NSMakeRange(0,[[SaveView textStorage] length]);
         [[SaveView RTFFromRange:SaveRange] writeToFile:Pfad  atomically:YES];
         //[DruckView writeRTFDToFile:Pfad  atomically:YES];
      }
   }
}

- (IBAction)KommentarSichern:(id)sender
{
   NSLog(@"RecplayController: KommentarSichern");
   //[AdminPlayer SaveKommentarVonProjekt:[ProjektPfad lastPathComponent]];
   //*   [self.AdminPlayer KommentarSichern];
}


- (void)BeendenAktion:(NSNotification*)note
{
   
   BOOL OK=[self beenden];
   NSLog(@"BeendenAktion OK: %d",OK);
   if (OK)
   {
      [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
      [NSApp terminate:self];
      
   }
   
}

-(IBAction)terminate:(id)sender
{
   BOOL OK=[self beenden];
   NSLog(@"terminate OK: %d",OK);
   if (OK)
   {
      [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
      [NSApp terminate:self];
      
   }
   
}



- (BOOL)beenden
{
   //BOOL setVersionOK=[Utils setVersion];
   [self savePListAktion:nil];
   [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
   BOOL BeendenOK=YES;

   NSFileManager *Filemanager=[NSFileManager defaultManager];
   //NSLog(@"neueAufnahmepfad: %@",neueAufnahmePfad);
   if (self.neueAufnahmePfad)
   {
      BOOL sauberOK=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:self.neueAufnahmePfad] error:nil];
   }
   return BeendenOK;
}

- (BOOL)windowShouldClose:(id)sender
{
   BOOL OK=[self beenden];
   NSLog(@"windowShouldClose");
   if (OK)
   {
      [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
      
      [NSApp terminate:self];
      
   }
   return OK;
}

- (IBAction)print:(id)sender
{
   //NSLog (@"RecPlayController print");
   //[AdminPlayer KommentarDruckenVonProjekt: [ProjektPfad lastPathComponent]];
   //*   [self.AdminPlayer KommentarDrucken];
   
   return;
}


- (IBAction)ArchivaufnahmeInPlayer:(id)sender
{
 //  [self resetArchivPlayer:nil];
   self.ArchivPlayerGeladen=YES;
   [self.ArchivInListeTaste setEnabled:YES];
   [self.ArchivInPlayerTaste setEnabled:NO];
   //[ArchivPlayTaste setEnabled:YES];
   
   
   NSString* tempAchivPlayPfad = [self.ArchivPlayPfad stringByAppendingPathExtension:@"m4a"];
   
   NSLog(@"ArchivaufnahmeInPlayer tempAchivPlayPfad: %@",tempAchivPlayPfad);
   
   NSURL *ArchivURL = [NSURL fileURLWithPath:tempAchivPlayPfad];
   [AVAbspielplayer prepareAufnahmeAnURL:ArchivURL];
   
   //sofort abspielen
   //[self startArchivPlayer:nil];
   
   [self.ArchivPlayTaste setEnabled:YES];
   //   BOOL erfolg=[RecPlayFenster makeFirstResponder:ArchivInListeTaste];
   [self.ArchivInListeTaste setKeyEquivalent:@"\r"];
   [Utils stopTimeout];
   [self.UserMarkCheckbox setEnabled:YES];
   
}

- (IBAction)ArchivZurListe:(id)sender
{
   //NSLog(@"ArchivZurListe");
   self.ArchivPlayerGeladen=NO;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSLog(@"ArchivZurListe: ArchivKommentarPfad: %@",self.ArchivKommentarPfad);
   if ([Filemanager fileExistsAtPath:[self.ArchivKommentarPfad stringByAppendingPathExtension:@"txt"]])
			{
            //NSLog(@"vor saveUserMarkFuerAufnahmePfad: UserMarkCheckbox: %d",[UserMarkCheckbox state]);
            [self saveUserMarkFuerAufnahmePfad:[self.ArchivKommentarPfad stringByAppendingPathExtension:@"txt"]];
            //NSLog(@"nach saveUserMarkFuerAufnahmePfad");
            
         }
   
   [self resetArchivPlayer:nil];
   
   // [self.ArchivZurListeTaste setEnabled:YES];
   
   //   int	erfolg=[RecPlayFenster makeFirstResponder:ArchivView];
   [AVAbspielplayer resetTimer];
   //  [Utils startTimeout:self.TimeoutDelay];
   
}

- (IBAction)reportUserMark:(id)sender
{
   
}

- (void)saveUserMarkFuerAufnahmePfad:(NSString*)derAufnahmePfad
{
   NSMutableString* tempKommentarString=[[NSString stringWithContentsOfFile:derAufnahmePfad encoding:NSMacOSRomanStringEncoding error:NULL]mutableCopy];
   if (tempKommentarString)
   {
      NSMutableArray* tempMarkArray=(NSMutableArray*)[tempKommentarString componentsSeparatedByString:@"\r"];
      //NSLog(@"tempMarkArray: %@ UserMarkCheckbox state: %d",[tempMarkArray description],[UserMarkCheckbox state]);
      NSNumber* MarkNumber =[NSNumber numberWithBool:[self.UserMarkCheckbox state]];
      if ([tempMarkArray count]==8)//Zeile für Mark  ist da
      {
         //NSLog(@"UserMark Hier? %@",[MarkNumber stringValue]);
         [tempMarkArray replaceObjectAtIndex:UserMark withObject:[MarkNumber stringValue]];
         //NSLog(@"tempMarkArray neu: %@",[tempMarkArray description]);
         
         //[tempKommentarString setString:[tempMarkArray componentsJoinedByString:@"\r"]];
         
      }
      else if([tempMarkArray count]==6)//Zeile für Mark  ist nicht da
      {
         [tempMarkArray insertObject:[MarkNumber stringValue] atIndex:UserMarkReturn];
      }
      [tempKommentarString setString:[tempMarkArray componentsJoinedByString:@"\r"]];
      //NSLog(@"saveUserMarkFuerAufnahmePfad: tempKommentarString: %@",tempKommentarString);
      [tempKommentarString writeToFile:derAufnahmePfad atomically:YES encoding:NSMacOSRomanStringEncoding error:NULL];
   }
}


- (void) VolumesAktion:(NSNotification*)note
{
   //NSLog(@"VolumesAktion");
   NSNumber* n=[[note userInfo]objectForKey:@"LeseboxDa"];
   self.LeseboxDa=[n boolValue];
   if ([n intValue]==0)//Abbrechen
   {
      //NSLog(@"VolumesAktion: number=0 %d   ",[n intValue]);
      //Beenden
      NSMutableDictionary* BeendenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
      [BeendenDic setObject:[NSNumber numberWithInt:1] forKey:@"beenden"];
      NSNotificationCenter* beendennc=[NSNotificationCenter defaultCenter];
      [beendennc postNotificationName:@"externbeenden" object:self userInfo:BeendenDic];
   }
   //NSLog(@"VolumesAktion: number %d   ",[n intValue]);
}

- (IBAction)PrefsLesen:(id)sender
{
   NSNumber* Testnummer;
   Testnummer=[[NSUserDefaults standardUserDefaults]objectForKey:Wert1Key];
   self.Wert1=[Testnummer intValue];
   //[Levelfeld setIntValue:Wert1];
   //NSLog(@"Prefs lesen Wert 1: %d",Wert1);
   Testnummer=[[NSUserDefaults standardUserDefaults]objectForKey:Wert2Key];
   self.Wert2=[Testnummer intValue];
   //NSLog(@"Prefs lesen Wert 2: %d",Wert2);
   [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:self.Wert1+2] forKey:Wert2Key];
   self.Wert1=[[[NSUserDefaults standardUserDefaults]objectForKey:Wert2Key]intValue];
   //NSLog(@"Prefs lesen:Wert1 nach: %d",Wert1);
   [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:self.Wert1] forKey:Wert1Key];
   
   self.RPDevicedaten=[[NSUserDefaults standardUserDefaults]objectForKey:RPDevicedatenKey];
   //int l=[RPDevicedaten length];
   //NSLog(@"Prefs lesen: Länge Devicedaten: %d",l);
   
}
- (IBAction)PrefsSchreiben:(id)sender
{
   //Wert1=[Levelfeld intValue];
   //NSLog(@"Prefs schreiben neuer Wert 1: %d",Wert1);
   [[NSUserDefaults standardUserDefaults]setInteger: self.Wert1 forKey: Wert1Key];
   
   //Wert2+=10;
   //NSLog(@"Prefs schreiben neuer Wert 2: %d",Wert2);
   //RPModus=1;
   
   short l=[self.RPDevicedaten length];
   //NSLog(@"Prefs schreiben: Länge Devicedaten: %ddata: %@",l,[RPDevicedaten description]);
   //NSString * datenstring=[RPDevicedaten description];
   //int n,sum=0;   //Summe der unicode-chars bestimmen
   //for (n=0;n<l;n++)
   //	sum+=[datenstring characterAtIndex:n];
   //NSLog(@"Prefs schreiben: Länge Devicedaten: %d  summe: %d",l,sum);
   if(l>0)
   {
      [[NSUserDefaults standardUserDefaults]setObject:self.RPDevicedaten forKey:RPDevicedatenKey];
   }
   [[NSUserDefaults standardUserDefaults]synchronize];
   
   return;
   
   
   
   //NSLog(@"Gesicherte Prefs lesen: %d",ii);
}

- (void)setRecPlay
{
   [self Aufnahmevorbereiten];
   
   if ([self.timer isValid])
   {
      [self.timer invalidate];
   }
   
   
   /*
    AufnahmezeitTimer=[NSTimer scheduledTimerWithTimeInterval:1.0
    target:self
    selector:@selector(setAufnahmetimerfunktion:)
    userInfo:nil
    repeats:YES];
    */
   /*
    if ([AbspielzeitTimer isValid])
    {
    [AbspielzeitTimer invalidate];
    }
    */
   /*
    AbspielzeitTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
    target:self
    selector:@selector(Abspieltimerfunktion:)
    userInfo:nil
    repeats:YES];
    */
   NSFont* Lesernamenfont;
   Lesernamenfont=[NSFont fontWithName:@"Helvetica" size: 20];
   NSColor * LesernamenFarbe=[NSColor whiteColor];
   [self.Leserfeld setFont: Lesernamenfont];
   [self.Leserfeld setTextColor: LesernamenFarbe];
   
   //*   [RecPlayFenster setIsVisible:YES];
   //[Leserfeld setBackgroundColor:[NSColor lightGrayColor]];
   //NSImage* StartRecordImg=[[NSImage alloc]initWithContentsOfFile:@"StartPlayImg.tif"];
   NSImage* StartRecordImg=[NSImage imageNamed:@"recordicon_k.gif"];
   [[self.StartRecordKnopf cell]setImage:StartRecordImg];
   NSImage* StopRecordImg=[NSImage imageNamed:@"StopRecordImg.tif"];
   [[self.StopRecordKnopf cell]setImage:StopRecordImg];
   
   //[[self.StartStopKnopf cell]setImage:StartRecordImg];
   [self.StartStopString setStringValue:@"START"];
   NSImage* StartPlayImg=[NSImage imageNamed:@"StartPlayImg.tif"];
   [[self.StartPlayKnopf cell]setImage:StartPlayImg];
   NSImage* StopPlayImg=[NSImage imageNamed:@"StopPlayImg.tif"];
   //[[self.StopPlayKnopf cell]setImage:StopPlayImg];
   NSImage* BackImg=[NSImage imageNamed:@"Back.tif"];
   [[self.BackKnopf cell]setImage:BackImg];
   
   [self.RecPlayTab setDelegate:self];
   [self.RecPlayTab selectFirstTabViewItem:nil];
   self.ArchivView=[[rArchivDS alloc]initWithRowCount:0];
   [self.ArchivView setDelegate: self.ArchivDaten];
   [self.ArchivView setDataSource: self.ArchivDaten];
   //NSLog(@"setRecPlay:	mitUserPasswort: %d",mitUserPasswort);
   if (self.mitUserPasswort)
   {
      [self.PWFeld setStringValue:@"Mit Passwort"];
   }
   else
   {
      [self.PWFeld setStringValue:@"Ohne Passwort"];
   }
   
}



- (IBAction)ReadDeviceEinstellungen:(id)sender
{
   OSErr err=0;
   /*
    Handle RecordereinstellungenHandle;
    UserData Einstellungsdaten;
    RecordereinstellungenHandle=NewHandle(0);
    err=MemError();
    if (err)
    {
    NSLog(@"ReadDeviceEinstellungen: MemErr nach NewHandle:%d",err);;
    }
    //	*RecordereinstellungenHandle=*(Recorder->GetEinstellungen());
    
    HLock(RecordereinstellungenHandle);
    long l=GetHandleSize(RecordereinstellungenHandle);
    //NSLog(@"GetHandleSize(RecordereinstellungenH): %d",l);
    RPDevicedaten=[NSData dataWithBytes:(UInt8*)*RecordereinstellungenHandle length: l];
    l=[RPDevicedaten length];
    //NSLog(@"Controller: err nach GetEinstellungen Fehler: %d Laenge: %d\n ", err,l);
    //	NSLog(@"************************GetEinstellungen: Devicedaten: %@",[RPDevicedaten description]);
    
    HUnlock(RecordereinstellungenHandle);
    DisposeHandle(RecordereinstellungenHandle);
    
    //[self PrefsSchreiben];
    */
}

- (void)SettingsAktion
{
   //[self GetEinstellungen:nil];
}

- (IBAction)WriteDeviceEinstellungen:(id)sender
{
}


- (BOOL)WriteSystemDeviceEinstellungen
{
   return 0;
}

- (IBAction)changeTitel:(id)sender
{
   [self.TitelPop setEnabled:YES];
   [self.TitelPop setEditable:YES];
   
}

- (IBAction)Einstellungentest:(id)sender
{
   OSErr err=0;
   //err=Recorder->Einstellungentest();
   //NSLog(@"err bei Einstellungentest: %d ", err);
   
}

- (IBAction)showSettingsDialog:(id)sender
{
   [self restartAdminTimer];
   [Utils stopTimeout];
   //[Utils startTimeout:self.TimeoutDelay];
}

#pragma mark QTKit



- (IBAction)goQTKitStart:(id)sender
{
   NSLog(@"goQTKitStart");
   
}

#pragma mark UI updating

- (void)updateAudioLevels:(NSTimer *)timer
{
   // Get the mean audio level from the movie file output's audio connections
   
   float totalDecibels = 0.0;
   
   //*  QTCaptureConnection *connection = nil;
   NSUInteger numberOfPowerLevels = 0;	// Keep track of the total number of power levels in order to take the mean
   //NSLog(@"updateAudioLevels: %d",[[movieFileOutput connections] count]);
   
   /*
    for (i = 0; i < [[movieFileOutput connections] count]; i++)
    {
    connection = [[movieFileOutput connections] objectAtIndex:i];
    
    if ([[connection mediaType] isEqualToString:QTMediaTypeSound])
    {
    NSArray *powerLevels = [connection attributeForKey:QTCaptureConnectionAudioAveragePowerLevelsAttribute];
    NSUInteger j, powerLevelCount = [powerLevels count];
    
    for (j = 0; j < powerLevelCount; j++)
    {
    NSNumber *decibels = [powerLevels objectAtIndex:j];
    totalDecibels += [decibels floatValue];
    numberOfPowerLevels++;
    }
    }
    }
    */
   if (numberOfPowerLevels > 0)
   {
      [self.LevelMeter setFloatValue:(pow(10., 0.05 * (totalDecibels / (float)numberOfPowerLevels)) * 20.0)];
   }
   else
   {
      [self.LevelMeter setFloatValue:0];
   }
   
   //  float l=(float)[mCaptureMovieFileOutput  recordedDuration].timeValue/[mCaptureMovieFileOutput  recordedDuration].timeScale;
   //NSLog(@"updateAudioLevels l: %2.1f",l);
   
   
   
   //   NSString* TimeString=QTStringFromTime([mCaptureMovieFileOutput  recordedDuration]);
   // 0:00:00:15.18434/22050
   /*
    NSArray* TimeArray=[self.TimeString componentsSeparatedByString:@":"];
    
    NSString* MinutenString=[TimeArray objectAtIndex:2];
    int Sekunden=[[TimeArray objectAtIndex:3]intValue];
    NSString* SekundenString;
    if (Sekunden<10)
    {
    SekundenString=[NSString stringWithFormat:@"0%d",Sekunden];
    }
    else
    {
    SekundenString=[NSString stringWithFormat:@"%d",Sekunden];
    }
    //NSLog(@"updateAudioLevels Min: %@ Sek: %@",MinutenString, SekundenString);
    */
   
   //QTTime aktuelleZeit = [mCaptureMovieFileOutput  recordedDuration];
   //float floatZeit=(float)aktuelleZeit.timeValue/aktuelleZeit.timeScale;
   //NSLog(@"floatZeit : %2.0f",floatZeit );
   //NSString* ZeitString=[NSString stringWithFormat:@"%2.0f",floatZeit];
   //NSLog(@"ZeitString: %@",ZeitString);
   //	NSLog(@"recordedDuration: %2.2f",(float)[mCaptureMovieFileOutput  recordedDuration].timeValue/1000);
   //	NSValue* ZeitVal=[NSValue valueWithQTTime:aktuelleZeit];
   //NSLog(@"aktuelleZeit timescale: %d",aktuelleZeit.timeScale );
   
   //   [self.Zeitfeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   
   // recordedDuration
}

// Do something with your QuickTime movie at the path you've specified at /Users/Shared/My Recorded Movie.mov"

/*
 - (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
 {
 
 //	[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
 [RecordQTKitPlayer setMovie:[QTMovie movieWithURL:outputFileURL error:NULL]];
 
 }
 */
#pragma mark end QTKit


QTMovie* qtMovie;

- (IBAction)handleOpenMovie:(id)sender
{
   /* an array to capture the constants for metadata types:
      kQTMetaDataTypeBinary = 0,
      kQTMetaDataTypeUTF8 = 1,
      kQTMetaDataTypeUTF16BE = 2,
      kQTMetaDataTypeMacEncodedText = 3,
      kQTMetaDataTypeSignedIntegerBE = 21,
      kQTMetaDataTypeUnsignedIntegerBE = 22,
      kQTMetaDataTypeFloat32BE = 23,
      kQTMetaDataTypeFloat64BE = 24
    */
   NSArray* valueTypeDescriptions =
   [NSArray arrayWithObjects: @"Binary", @"UTF-8", @"UTF-16BE", @"Mac-Encoded Text",
    @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined",  // 4-10 undefined
    @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", @"undefined", // 11-20 undefined
    @"Signed Integer (Big-Endian)",
    @"Unsigned Integer (Big-Endian)",
    @"32-bit Float (Big-Endian)",
    @"64-bit Float (Big-Endian)",
    nil];
   
   // these should probably be constants
   NSString* emptyString = @"";
   NSArray* fileTypes = [NSArray arrayWithObjects:@"mov", @"mp4", @"m4a", @"mp3", @"m4p", @"jpg", @"jpeg",nil];
   NSString* moviesDir = [NSHomeDirectory() stringByAppendingString:
                          @"/Movies"];
   
   printf ("\n\nhandleOpenMenuItem!\n");
   NSOpenPanel* panel = [NSOpenPanel openPanel];
   //	[panel runModalForDirectory:moviesDir file:nil types:fileTypes ];
   
   printf ("panel dismissed\n");
   //NSURL* url = [[panel URLs] objectAtIndex: 0];
   NSURL* url=[NSURL fileURLWithPath:@"/Users/sysadmin/Documents/neueAufnahme.mov"];
   NSLog(@"URL: %@\n",url );
   
   printf ("Creating qtmovie\n");
   NSError* openError = nil;
   /*
    qtMovie = [QTMovie movieWithURL: url error:&openError];
    if (openError)
    {
    NSAlert *theAlert = [NSAlert alertWithError:openError];
    [theAlert runModal]; // Ignore return value.
    }
    
    [RecordQTKitPlayer setControllerVisible: YES];
    [RecordQTKitPlayer setMovie: qtMovie];
    [RecordQTKitPlayer play:NULL];
    */
}


- (void)updatePlayBalken:(NSTimer *)derTimer
{
   /*
    QTTime Gesamtzeit=[[RecordQTKitPlayer movie]duration];
    QTTime Spielzeit=[[RecordQTKitPlayer movie]currentTime];
    float Restzeit=(float)(Gesamtzeit.timeValue-Spielzeit.timeValue)/Gesamtzeit.timeScale;
    //NSLog(@"Restzeit: %2.2f",Restzeit);
    [Abspielanzeige setLevel:(Spielzeit.timeValue)];
    if (Restzeit>0)
    {
    [Abspieldauerfeld setStringValue:[self Zeitformatieren:(int)Restzeit]];
    }
    if (Restzeit==0)
    {
    [derTimer invalidate];
    //NSLog(@"Restzeit ist null");
    }
    */
}

- (IBAction)startPlay:(id)sender
{
   NSLog(@"startPlay");
   if([self isRecording])
   {
      NSBeep();
      return;
   }
   //BOOL result=NO;
   
   
   /*
    if (![RecordQTKitPlayer movie])
    {
    NSLog(@"Noch kein Movie da");
    
    NSURL *movieUrl = [NSURL fileURLWithPath:hiddenAufnahmePfad];
    NSError* startErr=0;
    //QTMovie *tempMovie = [QTMovie movieWithURL:[NSURL fileURLWithPath:neueAufnahmePfad]error:NULL];
    QTMovie *tempMovie = [[QTMovie alloc]initWithURL:[NSURL fileURLWithPath:hiddenAufnahmePfad]error:&startErr];
    if (startErr)
    {
    NSAlert *theAlert = [NSAlert alertWithError:startErr];
    [theAlert runModal]; // Ignore return value.
    }
    else
    {
    [tempMovie play];
    }
    
    //[ArchivQTKitPlayer setMovie:tempMovie];
    [RecordQTKitPlayer setMovie:tempMovie];
    if (!tempMovie)
    {
    NSLog(@"Kein Movie da");
    }
    // retrieve the QuickTime-style movie (type "Movie" from QuickTime/Movies.h)
    //PlayerMovie =[tempMovie quickTimeMovie];
    
    //NSLog(@"Beginn startPlay: Dauer in s:%2.2f ",Dauer/600.0);
    
    double PlayerVolume=120.0;
    }
    */
   //NSLog(@"startPlay hiddenAufnahmePfad: %@",hiddenAufnahmePfad);
   NSURL *movieURL = [NSURL fileURLWithPath:self.hiddenAufnahmePfad];
   NSError* err1;
   
   /*
    QTMovie *tempMovie=[QTMovie movieWithURL:movieURL error:&err1];
    
    if (err1)
    {
    NSAlert *theAlert = [NSAlert alertWithError:err1];
    [theAlert runModal]; // Ignore return value.
    
    }
    */
   
   
   //[Volumesteller setFloatValue: GetMovieVolume(PlayerMovie)];
   
   //	QTMovie *tempMovie=[RecordQTKitPlayer movie];
   //Dauer=[tempMovie duration].timeValue/[tempMovie duration].timeScale;
   //NSLog(@"startPlay Dauer: %d",Dauer);
   //   QTKitDauer=(float)[tempMovie duration].timeValue/[tempMovie duration].timeScale;
   //NSLog(@"startPlay QTKitDauer: %2.2f",QTKitDauer);
   [Utils stopTimeout];
   //GesamtAbspielzeit=Dauer;
   // self.QTKitGesamtAbspielzeit=self.QTKitDauer;
   //   [self.Abspielanzeige setMax: [tempMovie duration].timeValue];
   
   if ([self.playBalkenTimer isValid])
   {
      [self.playBalkenTimer invalidate];
   }
   self.playBalkenTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(updatePlayBalken:)
                                                         userInfo:nil
                                                          repeats:YES];
   
   
   //NSLog(@"startPlay QTKitPause: %2.2f", QTKitPause);
   
   if (self.QTKitPause)
   {
      [self.Abspieldauerfeld setStringValue:[self Zeitformatieren:self.QTKitPause]];
      //Abspieldauer=Pause;
      
      //[Levelbalken setDoubleValue: Pause];
      //      [self.Abspielanzeige setLevel:QTKitPause];
      self.Pause=0;
      //QTKitPause=0;
      
   }
   else
   {
      
      [self.Abspieldauerfeld setStringValue:[self Zeitformatieren:self.QTKitGesamtAbspielzeit]];
      
      //Abspieldauer=GesamtAbspielzeit;
      
      [self.LevelMeter setFloatValue: 0];
      [self->Abspielanzeige setLevel:0];
      //*      [self.ArchivQTKitPlayer gotoBeginning:NULL];
   }
   //[ArchivQTKitPlayer play:NULL];
   //*   [RecordQTKitPlayer play:NULL];
   
   //NSLog(@"MovieDuration: %d", GesamtAbspielzeit);
   //[tempMovie release];
   [self.StartRecordKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self.StopRecordKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:YES];
   [self.StopPlayKnopf setEnabled:YES];
   
   
}


- (void)AbspielenFertigAktion:(NSNotification *)aNotification
{
   /*
    if ([[self.RecordQTKitPlayer movie]duration].timeValue)
    {
    if ([self.playBalkenTimer isValid])
    {
    [playBalkenTimer invalidate];
    }
    
    [StartRecordKnopf setEnabled:YES];
    [SichernKnopf setEnabled:YES];
    [WeitereAufnahmeKnopf setEnabled:YES];
    [StopRecordKnopf setEnabled:YES];
    [BackKnopf setEnabled:NO];
    [StopPlayKnopf setEnabled:NO];
    [Abspieldauerfeld setStringValue:[self Zeitformatieren:(int)QTKitGesamtAbspielzeit]];
    //Abspieldauer=GesamtAbspielzeit;
    [Abspielanzeige setLevel:0];
    [ArchivQTKitPlayer gotoBeginning:NULL];
    Pause=0;
    QTKitPause=0;
    }
    */
}

- (IBAction)stopPlay:(id)sender
{
   
   //*[self.RecordQTKitPlayer pause:NULL];
   int PauseZeit=(self.Laufzeit)/60;
   //NSLog(@"Laufzeit:%d  PauseZeit: %d",Laufzeit,PauseZeit);
   self.Pause=self.Laufzeit/60;
   
   //*   self.QTKitPause=(float)[[RecordQTKitPlayer movie] duration].timeValue/[[RecordQTKitPlayer movie] duration].timeScale;
   self.Pause=self.QTKitPause;
   NSLog(@"stopPlay: Pause: %ld QTKitPause: %2.1f",self.Pause, self.QTKitPause);
   
   [self.StartRecordKnopf setEnabled:YES];
   [self.SichernKnopf setEnabled:YES];
   [self.WeitereAufnahmeKnopf setEnabled:YES];
   [self.StopRecordKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:YES];
   [self.StopPlayKnopf setEnabled:NO];
   [Utils startTimeout:self.TimeoutDelay];
   
}

- (IBAction)goStart:(id)sender
{
   if (self.playBalkenTimer)
   {
      [self.playBalkenTimer invalidate];
   }
   
   self.Pause=0;
   self.QTKitPause=0;
   [self.Abspieldauerfeld setStringValue:[self Zeitformatieren:self.QTKitGesamtAbspielzeit]];
   //Abspieldauer=GesamtAbspielzeit;
   [self->Abspielanzeige setLevel:0];
   //	[Utils startTimeout:TimeoutDelay];
   [self.BackKnopf setEnabled:YES];
   //[ArchivQTKitPlayer gotoBeginning:NULL];
   //*  [RecordQTKitPlayer gotoBeginning:NULL];
   [Utils startTimeout:self.TimeoutDelay];
}





- (IBAction)setVolume:(id)sender
{
   /* set the movie volume to correspond to the
    current value of the slider */
   //  SetMovieVolume((Movie)[[MoviePlayer movie] QTMovie],(short)[Volumesteller floatValue]);
   
}



- (void)setLevel:(int)derLevel
{
   NSLog(@"RPC setLevel: %d",derLevel);
   [self.Levelmeter setLevel:derLevel];
}


- (OSErr) finishMovie:(NSString*)derAufnahmePfad zuPfad:(NSString*)derFinishPfad
{
   //NSLog(@"finishMovie: derAufnahmePfad: %@  derFinishPfad: %@",derAufnahmePfad,derFinishPfad);
   /*
    BOOL success = NO;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithBool:YES], QTMovieExport,
    [NSNumber numberWithLong:kQTFileTypeAIFF], QTMovieExportType,
    [NSNumber numberWithLong:SoundMediaType], QTMovieExportManufacturer,
    nil];
    
    success = [audio writeToFile:outFile withAttributes:attributes];
    
    
    
    src = @"/Users/bittercold/Desktop/deadbolt.aif";
    snd = [[QTMovie alloc] initWithFile:src error: NULL];
    [snd play];
    
    
    NSDictionary    *dict = nil;
    dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
    forKey:QTMovieFlatten];
    if (dict)
    {
    // create a new movie file and flatten the movie to the file
    
    // passing the QTMovieFlatten attribute here means the movie
    // will be flattened
    success = [self writeToFile:filePath withAttributes:dict];
    
    
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc]initWithDictionary: [myFile movieAttributes]];
    [attrDict setObject: [NSNumber numberWithBool:YES] forKey:QTMovieFlatten];
    [attrDict setObject: [NSNumber numberWithBool:YES] forKey:QTMovieExport];
    [attrDict setObject: [NSNumber numberWithInt:kQTFileTypeAIFF] forKey:QTMovieExportType];
    [myFile writeToFile:[savePanel filename] withAttributes: attrDict];
    
    
    */
   
   
   NSError* finishErr;
   BOOL exportErr=0;
   //*  QTMovie * tempQTKitMovie=[QTMovie movieWithURL:[NSURL fileURLWithPath:derAufnahmePfad]error:&finishErr];
   
   //QTMovie * tempQTKitMovie=[[QTMovie alloc]initWithURL:[NSURL fileURLWithPath:derAufnahmePfad] error:&finishErr];
   
   //[[RecordQTKitPlayer movie]play];
   
   if (finishErr) // etwas passiert
   {
      NSAlert *theAlert = [NSAlert alertWithError:finishErr];
      [theAlert runModal]; // Ignore return value.
   }
   
   
   //*   [tempQTKitMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute]; // make movie editable
   /*
    [RecordQTKitPlayer setMovie:tempQTKitMovie];
    [RecordQTKitPlayer gotoBeginning:NULL];
    [RecordQTKitPlayer play:NULL];
    */
   
   
   
   // QTKit
   //Startknacks abschneiden
   /*
    QTTime gesamtTime=[tempQTKitMovie duration];
    float floatZeit=(float)gesamtTime.timeValue/gesamtTime.timeScale;
    //NSLog(@"floatZeit: %f",floatZeit);
    //NSLog(@"gesamtTime vor: %2.2f",(float)gesamtTime.timeValue/gesamtTime.timeScale);
    long timeScale=gesamtTime.timeScale;
    
    QTTime startZeit=QTMakeTime(0,timeScale);
    
    QTTime knackZeit=QTMakeTime(KnackDelay,timeScale);
    [tempQTKitMovie deleteSegment:QTMakeTimeRange(startZeit,knackZeit)];
    QTTime startKnackDauer=[tempQTKitMovie duration];
    //NSLog(@"gesamtTime nach: %2.2f",(float)startKnackDauer.timeValue/startKnackDauer.timeScale);
    
    //Endknacks abschneiden
    QTTime endZeit=QTMakeTime(gesamtTime.timeValue,timeScale);
    QTTime endKnackZeit=QTMakeTime(gesamtTime.timeValue-KnackDelay,timeScale);
    [tempQTKitMovie deleteSegment:QTMakeTimeRange(endKnackZeit,endZeit)];
    QTTime endKnackDauer=[tempQTKitMovie duration];
    //NSLog(@"gesamtTime nach end: %2.2f",(float)endKnackDauer.timeValue/endKnackDauer.timeScale);
    */
   /*
    [RecordQTKitPlayer setMovie:tempQTKitMovie];
    [RecordQTKitPlayer gotoBeginning:NULL];
    [RecordQTKitPlayer play:NULL];
    */
   
   /*
    long movieScale = [[tempQTKitMovie attributeForKey:QTMovieTimeScaleAttribute] longValue]; //get movie scale
    //NSLog(@"movieScale: %d duration: %d",movieScale, [tempQTKitMovie duration].timeValue);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithBool:YES], QTMovieExport,
    [NSNumber numberWithBool:YES] ,QTMovieFlatten,
    [NSNumber numberWithLong:kQTFileTypeAIFF], QTMovieExportType,
    [NSNumber numberWithLong:SoundMediaType], QTMovieExportManufacturer,
    nil];
    
    
    
    exportErr=[tempQTKitMovie writeToFile:derFinishPfad withAttributes:attributes];
    */
   //	NSFileManager* Filemanager=[NSFileManager defaultManager];
   //	[Filemanager moveItemAtPath:derAufnahmePfad toPath:derFinishPfad error:NULL];
   
   
   //	NSLog(@"exportErfolg: %d derFinishPfad: %@",exportErr,derFinishPfad);
   
   
   
   FSSpec								finishAufnahmeSpec;
   FSRef									finishAufnahmeRef;
   FSRef									LeserordnerRef;
   short									status;
   UniChar								buffer[255]; // HFS+ filename max is 255
   NSString*							finishAufnahmeName=[[derFinishPfad copy] lastPathComponent];
   
   //	NSLog(@"finishAufnahmeName: %@",finishAufnahmeName);
   
   [finishAufnahmeName getCharacters:buffer];
   
   //NSFileManager* Filemanager=[NSFileManager defaultManager];
   NSString* LeserordnerPfad=[[derFinishPfad copy] stringByDeletingLastPathComponent];
   //NSLog(@"LeserordnerPfad: %@",LeserordnerPfad);
   
   BOOL KommentarOK=[Utils setKommentar:@"Hallo" inAufnahmeAnPfad:derAufnahmePfad];
   
   
   if (exportErr)
   {
      return 0;
   }
   return 1;
   
   
}



- (void)SaveAufnahmeTimerFunktion:(NSTimer*)derTimer
{
   //NSLog(@"        SaveAufnahmeTimerFunktion info: %d",[[derTimer userInfo]intValue]);
   
   if ([[derTimer userInfo]intValue])	//Sichern und abmelden
   {
      //NSLog(@"        SaveAufnahmeTimerFunktion: Sichern und Abmelden");
      [self.ArchivnamenPop selectItemAtIndex:0];
      [self.Leserfeld setStringValue:@""];
      [[self.TitelPop cell]setStringValue:@""];
      [self.TitelPop removeAllItems];
      self.aktuellAnzAufnahmen=0;
      [self.TitelPop setEnabled:NO];
      [self clearArchiv];
   }
   
   
   
   [self.StartRecordKnopf setEnabled:YES];
   [self.StartPlayKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self.LogoutKnopf setEnabled:NO];
   
   // * [RecPlayFenster makeFirstResponder:RecPlayFenster];
   [self.KommentarView setString:@""];
   [self.KommentarView setEditable:NO];
   [self.Zeitfeld setStringValue:@""];
   
   self.QTKitGesamtAufnahmezeit=0;
   
}



- (NSArray*)AufnahmeRetten
{
   [Utils stopTimeout];
   NSMutableArray* FehlerArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   BOOL erfolg=YES;
   /*
    if ([[RecordQTKitPlayer movie]rate])
    {
    NSString* s=@"Wiedergabe gestoppt";
    NSDictionary* f=[NSDictionary dictionaryWithObject:s forKey:@"stopplaying"];
    [FehlerArray addObject: f];
    [self stopPlay:nil];
    
    }
    if ([Leser length]==0)
    {
    NSLog(@"[Leser length]==0");
    return FehlerArray;
    }
    
    
    if (QTKitGesamtAufnahmezeit==0)
    {
    //NSLog(@"GesamtAufnahmezeit==0");
    return FehlerArray;
    }
    */
   [self.Abspieldauerfeld setStringValue:@""];
   [self->Abspielanzeige setLevel:0];
   [self.Zeitfeld setStringValue:@""];
   
   NSString* tempAufnahmePfad;
   //tempLeserPfad=[NSString stringWithString:@""];
   NSFileManager *Manager = [NSFileManager defaultManager];
   if (Manager)
   {
      NSString* Leserinitialen=[self Initialen:self.Leser];
      Leserinitialen=[Leserinitialen stringByAppendingString:@" "];
      if ([Manager fileExistsAtPath: self.neueAufnahmePfad])		//neueAufnahme ist vorhanden
      {
         NSMutableArray * tempAufnahmeArray=(NSMutableArray*)[Manager contentsOfDirectoryAtPath:self.LeserPfad error:NULL];
         int AnzAufnahmen=[tempAufnahmeArray count];
         if (AnzAufnahmen&&[[tempAufnahmeArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
         {
            [tempAufnahmeArray removeObjectAtIndex:0];
            AnzAufnahmen--;
         }
         
         //NSString* Aufnahmenliste=[tempAufnahmeArray description];
         //NSLog(@"tempAufnahmeListe: %@", Aufnahmenliste);
         NSMutableString* tempNummerString=[NSMutableString stringWithCapacity:0];
         NSNumber* tempNummer;
         int maxNummer=0;
         int i;
         if (AnzAufnahmen)
         {
            
            for (i=0;i<AnzAufnahmen;i++)
            {
               int posLeerstelle1=0;
               int posLeerstelle2=0;
               int Leerstellen=0;
               NSString* loopNummerString=[NSString stringWithString:[tempAufnahmeArray objectAtIndex:i]];
               //int n=0;
               int charpos=0;
               while ((Leerstellen<2)&&(charpos<[loopNummerString length]))
               {
                  if ([loopNummerString characterAtIndex:charpos]==' ')
                  {
                     
                     Leerstellen++;
                     if (Leerstellen==1)
                     {
                        posLeerstelle1=charpos;
                     }
                     if (Leerstellen==2)
                     {
                        posLeerstelle2=charpos;
                     }
                     
                     
                  }
                  charpos++;
               }//while pos
               if (posLeerstelle1 && posLeerstelle2)
               {
                  //NSLog(@"loopNummerString: %@   pos Leerstelle1:%d pos Leerstelle2:%d",loopNummerString,posLeerstelle1,posLeerstelle2);
                  NSRange tempRange=NSMakeRange(posLeerstelle1+1,(posLeerstelle2-posLeerstelle1));
                  tempNummerString=(NSMutableString*)[loopNummerString substringWithRange:tempRange];
                  //NSLog(@"loopNummerString: %@   pos Leerstelle1:%d pos Leerstelle2:%d",loopNummerString,posLeerstelle1,posLeerstelle2);
                  
                  int loopNummer=[tempNummerString intValue];
                  if (loopNummer>maxNummer)
                     maxNummer=loopNummer;
               }
               //NSLog(@"neue maxNummer: %d",maxNummer);
               //[loopNummerString release];
            }
         }
         maxNummer++;
         tempNummer=[NSNumber numberWithInt:maxNummer];
         if ( maxNummer<10)
         {
            tempNummerString=@"";
            tempNummerString=(NSMutableString*)[tempNummerString stringByAppendingString:[tempNummer stringValue]];
         }
         else
         {
            tempNummerString=[NSString stringWithString:[tempNummer stringValue]];
         }
         
         Leserinitialen=[Leserinitialen stringByAppendingString:tempNummerString];
         Leserinitialen=[Leserinitialen stringByAppendingString:@" "];
         NSString* AufnahmeTitel;
         if (([[self titel]length]==0)||([[self titel]isEqualToString:@"neue Aufnahme"]))
         {
            AufnahmeTitel=[Leserinitialen stringByAppendingString:@"????"];
         }
         else
         {
            AufnahmeTitel=[Leserinitialen stringByAppendingString:[self titel]];
         }
         if ([tempAufnahmeArray containsObject:AufnahmeTitel])//schon eine gerettete Aufnbahem
         {
            AufnahmeTitel=[Leserinitialen stringByAppendingString:@"****"];
         }
         
         tempAufnahmePfad=[self.LeserPfad stringByAppendingPathComponent:AufnahmeTitel];//Pfad im Ordner in der Lesebox
         BOOL createKommentarOK=[Utils createKommentarFuerLeser:self.Leser FuerAufnahmePfad:tempAufnahmePfad];
         if (createKommentarOK)
         {
            NSLog(@"AufnahmePfad : %@", tempAufnahmePfad);
            
            OSErr err=[self finishMovie:self.neueAufnahmePfad zuPfad:tempAufnahmePfad];
            if (err)
            {
               NSString* s=@"Sichern misslungen";
               NSDictionary* f=[NSDictionary dictionaryWithObject:s forKey:@"finishfailed"];
               [FehlerArray addObject: f];
               
               [self.ArchivnamenPop selectItemAtIndex:0];
               [self.Leserfeld setStringValue:@""];
               [[self.TitelPop cell]setStringValue:@""];
               [self.TitelPop removeAllItems];
               
               return FehlerArray;
               
            }
            
            
            [self.ArchivnamenPop selectItemAtIndex:0];
            [self.Leserfeld setStringValue:@""];
            [[self.TitelPop cell]setStringValue:@""];
            [self.TitelPop removeAllItems];
         } // if savekommentatok
      }
      else
      {
         NSString* s=@"Sichern misslungen";
         NSDictionary* f=[NSDictionary dictionaryWithObject:s forKey:@"savingfailed"];
         [FehlerArray addObject: f];
         
         [self.ArchivnamenPop selectItemAtIndex:0];
         [self.Leserfeld setStringValue:@""];
         [[self.TitelPop cell]setStringValue:@""];
         [self.TitelPop removeAllItems];
         return FehlerArray;
      }
   }
   
   // 16.1.2010
   //SessionLeserArray aktualisieren
   
    NSString* creatingDatum=heuteDatumString;
   //NSLog(@"Projekt: %@ creatingDatum: %@",[ProjektPfad lastPathComponent],creatingDatum);
   
   NSString* tempLeser=[self.ArchivnamenPop titleOfSelectedItem];
   //NSLog(@"saveRecord Projekt: %@ tempLeser: %@",[ProjektPfad lastPathComponent],tempLeser);
   
   //Leser zur Sessionliste zufügen
   
   NSUInteger ProjektIndex=[[self.ProjektArray valueForKey:@"projekt"] indexOfObject:[self.ProjektPfad lastPathComponent]];
   //NSLog(@"ProjektIndex: %d",ProjektIndex);
   if (ProjektIndex<NSNotFound)
   {
      NSMutableDictionary* tempProjektDic=(NSMutableDictionary*)[self.ProjektArray objectAtIndex:ProjektIndex];
      
      NSMutableArray* SessionLeserArray=[[NSMutableArray alloc]initWithCapacity:0];
      
      if ([tempProjektDic objectForKey:@"sessionleserarray"])//Array ist vorhanden
      {
         //NSLog(@"SessionLeserArray da: ");
         [SessionLeserArray addObjectsFromArray:[tempProjektDic objectForKey:@"sessionleserarray"]];
         
         //NSLog(@"SessionLeserArray da2");
      }
      if (![SessionLeserArray containsObject:tempLeser])//tempLeser einsetzen
      {
         [SessionLeserArray addObject:tempLeser];
      }
      //NSLog(@"vor setArchivNamenPop");
      [tempProjektDic setObject:SessionLeserArray forKey:@"sessionleserarray"];
      
      //SessionListe in der PList sichern
      
      [self saveSessionForUser:self.Leser inProjekt:[self.ProjektPfad lastPathComponent]];
      
      
   }
   
   
   //
   [self resetRecPlay];
   return 0;
}

- (void)resetRecPlay
{
   //NSLog(@"resetRecPlay");
   
   [self stopAVRecord:NULL];
   [Utils stopTimeout];
   [self.ArchivnamenPop selectItemAtIndex:0];
   [self.Leserfeld setStringValue:@""];
   [[self.TitelPop cell]setStringValue:@""];
   [self.TitelPop removeAllItems];
   [self resetArchivPlayer:nil];
   [self clearArchivKommentar];
   [self.KommentarView setString:@""];
   [self.KommentarView setEditable:NO];
   [self.TitelPop setEnabled:NO];
   
   [self clearArchiv];
   self.QTKitGesamtAufnahmezeit=0;
   self.Leser =@"";
   
   [self.Abspieldauerfeld setStringValue:@"00:00"];
   [self.ArchivAbspieldauerFeld setStringValue:@"00:00"];
   [self.Zeitfeld setStringValue:@"00:00"];
   
   //   [RecPlayFenster makeFirstResponder:RecPlayFenster];
   
   self.aktuellAnzAufnahmen=0;
   //[self backArchivPlayer:NULL];
   [self backAVPlay:NULL];
   [self.StartRecordKnopf setEnabled:YES];
   [self.StopRecordKnopf setEnabled:NO];
   [self.StartPlayKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self.LogoutKnopf setEnabled:NO];
   
   //[self ArchivZurListe:nil];
   
   [Abspielanzeige setLevel:0];
   [Abspielanzeige setNeedsDisplay:YES];
   [self.ArchivAbspielanzeige setLevel:0];
   [self.ArchivAbspielanzeige setNeedsDisplay:YES];
   
   
   //LeserPfad  =@"";
}

- (OSErr) Versorgen
{
   
   return 0;
}



- (OSErr)Aufnahmevorbereiten
{
   OSStatus status;
   UniChar buffer[255]; // HFS+ filename max is 255
   
   //Quelle: void makeUserCopyOfFile(NSString* file) //aus LowLevel Filemanager
   
   NSString* neueAufnahmeName=[NSString stringWithFormat:@"neueAufnahme.mov"];
   //[neueAufnahmeName autorelease];
   [neueAufnahmeName getCharacters:buffer];
   NSArray *PfadArray;
   //NSString *neueAufnahmePfad;
   //int i=1;
   NSFileManager *Manager = [NSFileManager defaultManager];
   PfadArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   //NSLog(@"PfadArray  : %@",[PfadArray description]);
   if ([PfadArray count] > 0)
   { //
      //neueAufnahmePfad = [[PfadArray objectAtIndex:0] stringByAppendingPathComponent:[neueAufnahme lastPathComponent]];
      //i++;
      NSString *DokumentordnerPfad = [PfadArray objectAtIndex:0];//[LeseboxPfad stringByDeletingLastPathComponent];
      self.neueAufnahmePfad=[DokumentordnerPfad stringByAppendingPathComponent:neueAufnahmeName];
      //NSLog(@"Aufnahmevorbereiten  neueAufnahmePfad: %@",neueAufnahmePfad);
      
      status=YES;
      
   }//if PfadArray count
   
   [self.Zeitfeld setStringValue:@"00:00"];
   self.Pause=0;
   
   return status;
}

- (IBAction)neuOrdnen:(id)sender
{
   //  [self.AdminPlayer Leseboxordnen];
}
- (IBAction)resetLesebox:(id)sender
{
   //NSLog(@"resetLesebox");
   [self resetArchivPlayer:sender];
   [self.RecPlayTab selectFirstTabViewItem:sender];
   [self.ArchivnamenPop selectItemAtIndex:0];
   [self.Leserfeld setStringValue:@""];
   [self.ArchivDaten deleteAllRows];
   [self.ArchivView reloadData];
   [self.ArchivDatumfeld setStringValue:@""];
   [self.ArchivAbspieldauerFeld setStringValue:@""];
   [self.ArchivTitelfeld setStringValue:@""];
   [self.ArchivKommentarView setString:@""];
   [self.TitelPop removeAllItems];
   [self.TitelPop setStringValue:@""];
   [self.TitelPop deselectItemAtIndex:0];
   [self.Abspieldauerfeld setStringValue:@""];
   [self.KommentarView setString:@""];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   self.aktuellAnzAufnahmen=0;
}

- (IBAction)setLesebox:(id)sender;	// Nicht verwendet
{
   BOOL erfolg;
   OSErr err=0;
   NSLog(@"setLesebox Modus: %d",self.RPModus);
   //if Umgebung==1
   switch (self.Umgebung)
   {
      case 1:
      {
         NSLog(@"setLeseboxcase 1");
         erfolg=[self setNetworkLeseboxPfad:nil];
         if (erfolg)
         {
            //          [self.AdminPlayer setAdminPlayer: self.LeseboxPfad inProjekt:[self.ProjektPfad lastPathComponent]];
         }
      }break;
      case 0:
      {
         NSLog(@"setLeseboxcase 0");
         //        if ([AufnahmeGrabber isRecording])
         //return;
         [self resetLesebox:sender];
         BOOL erfolg=[self setNetworkLeseboxPfad:nil];
         
         err=[self Leseboxeinrichten];
         
      }break;
      case 2:
      {
         NSLog(@"setLesebox case 2");
      }break;
   }
   
}

- (BOOL)setHomeLeseboxPfad:(id)sender
{
   BOOL antwort=NO;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSString* tempLeseboxPfad=[NSString stringWithString:NSHomeDirectory()];
   NSString* s=@"Lesebox";
   tempLeseboxPfad=[[tempLeseboxPfad stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:s];
   //tempLeseboxPfad=[tempLeseboxPfad stringByAppendingPathComponent:@"Lesebox"];
   if ([Filemanager fileExistsAtPath:tempLeseboxPfad])//Es gibt eine Lesebox auf Home
	  {
        if (self.LeseboxPfad)
        {
           self.LeseboxPfad=(NSMutableString*)tempLeseboxPfad;
        }
        else
        {
           self.LeseboxPfad=[NSMutableString stringWithString:tempLeseboxPfad];//M
        }
        antwort=YES;
     }
   return antwort;
}


- (BOOL)setNetworkLeseboxPfad:(id)sender
{
   BOOL erfolg=NO;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSOpenPanel * LeseboxDialog=[NSOpenPanel openPanel];
   [LeseboxDialog setCanChooseDirectories:YES];
   [LeseboxDialog setCanChooseFiles:NO];
   [LeseboxDialog setAllowsMultipleSelection:NO];
   [LeseboxDialog setMessage:@"Auf welchem Computer ist die Lesebox zu finden?"];
   [LeseboxDialog setCanCreateDirectories:NO];
   NSString* tempLeseboxPfad;
   int LeseboxHit=0;
   {
      
      //LeseboxHit=[LeseboxDialog runModalForDirectory:DocumentsPfad file:@"Lesebox" types:nil];
      LeseboxHit=[LeseboxDialog runModal] ;//]ForDirectory:NSHomeDirectory() file:@"Volumes" types:nil];
      [LeseboxDialog  setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
   }
   
   NSLog(@"setNetworkLeseboxPfad NSOKButton: %d NSModalResponseOK: %d" ,NSOKButton,NSModalResponseOK);
   if (LeseboxHit==NSModalResponseOK)
	  {
        tempLeseboxPfad=[[LeseboxDialog URL]path]; //"home"
        
        tempLeseboxPfad=[tempLeseboxPfad stringByAppendingPathComponent:@"Documents"];
        NSString* lb=@"Lesebox";
        tempLeseboxPfad=[tempLeseboxPfad stringByAppendingPathComponent:lb];
        self.LeseboxPfad=(NSMutableString*)tempLeseboxPfad;
        NSLog(@"setNetworkLeseboxPfad:   LeseboxPfad: %@",self.LeseboxPfad);
        
        
        if ([Filemanager fileExistsAtPath:tempLeseboxPfad ])
        {
           NSLog(@"AdminLeseboxPfad da: %@",tempLeseboxPfad);
           erfolg=YES;
        }
        else
        {
           //int Antwort=NSRunAlertPanel(@"Keine Lesebox", @"Im Ordner 'Dokumente' muss ein Ordner mit dem Namen 'Lesebox' eingerichtet sein",@"OK", NULL,NULL);
           return NO;
        }
     }
   
   return erfolg;
}

- (void)ListeAktualisierenAktion:(NSNotification*)note
{
   [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
   [self setLeserliste:NULL];
}

- (IBAction)LeserListeAktualisieren:(id)sender
{
   [Utils setPListBusy:NO anPfad:self.LeseboxPfad];
   [self anderesProjektEinrichtenMit:[self.ProjektPfad lastPathComponent]];
   [self setLeserliste:NULL];
   [self setProjektMenu];
   
   
}

- (IBAction)setLeserliste:(id)sender
{
   
   switch (self.Umgebung)
   {
      case 1:
      {
         NSLog(@"setLeserliste RPModus=2");
         [self SessionListeAktualisieren];
         
         //     [self.AdminPlayer resetAdminPlayer];
         
         //     [self.AdminPlayer setAdminProjektArray:self.ProjektArray];
         //     [self.AdminPlayer setAdminPlayer:self.LeseboxPfad inProjekt:[self.ProjektPfad lastPathComponent]];
         
      }break;
      case 0:
      {
         NSLog(@"setLeserliste RPModus=0");
         //29.1.
         [self SessionListeAktualisieren];
         [self setArchivNamenPop];
         //
         
         //[self Leseboxvorbereiten];
      }break;
   }
   
}







- (void)setArchivNamenPopMitProjektArray:(NSArray*)derProjektArray
{
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   NSDictionary* tempProjektDic;
   NSArray* tempProjektNamenArray=[Utils ProjektNamenArrayVon:[self.LeseboxPfad stringByAppendingPathComponent:@"Archiv"]];
   NSUInteger ProjektIndex=[[derProjektArray valueForKey:@"projekt"]indexOfObject:[self.ProjektPfad lastPathComponent]];
//   NSCalendarDate* ProjektSessionDatum;
   if (ProjektIndex<NSNotFound)
   {
      //Dic des aktuellen Projekts im Projektarray
      tempProjektDic=[derProjektArray objectAtIndex:ProjektIndex];
      if ([tempProjektDic objectForKey:@"sessiondatum"])
      {
//         ProjektSessionDatum=[tempProjektDic objectForKey:@"sessiondatum"];
      }
      else
      {
//         ProjektSessionDatum=localDate   ;
      }
      
   }
   //NSLog(@"ProjektSessionDatum: %@",ProjektSessionDatum);
   
   int PopAnz=[self.ArchivnamenPop numberOfItems];
   //NSLog(@"ArchivnamenPop numberOfItems %d",PopAnz);
   
   if (PopAnz>1)//Alle ausser erstes Item entfernen (Name wählen)
   {
      while (PopAnz>1)
      {
         
         //NSLog(@"ArchivnamenPop removeItemAtIndex  %@",[[ArchivnamenPop itemAtIndex:1]description]);
         [self.ArchivnamenPop removeItemAtIndex:1];
         PopAnz--;
         
      }
   }
   
   //NSString* NamenwahlString=NSLocalizedString(@"Choose name",@"Namen auswählen");
   NSString* NamenwahlString=@"Namen auswählen";
   NSDictionary* tempItemAttr=[NSDictionary dictionaryWithObjectsAndKeys:[NSColor purpleColor], NSForegroundColorAttributeName,[NSFont systemFontOfSize:13], NSFontAttributeName,nil];
   NSAttributedString* tempNamenItem=[[NSAttributedString alloc]initWithString:NamenwahlString attributes:tempItemAttr];
   [[self.ArchivnamenPop itemAtIndex:0]setAttributedTitle:tempNamenItem];
   
   //SessionListe konfig: vorhandene Namen im ProjektArray mit SessionListe abgleichen
   
   //Sessioleserarray
   NSArray* tempSessionLeserArray=[self SessionLeserListeVonProjekt:[self.ProjektPfad lastPathComponent]];
   
   //NSLog(@"tempSessionLeserArray 1: %@",[tempSessionLeserArray description]);
   NSEnumerator* NamenEnum=[tempProjektNamenArray objectEnumerator];
   id einName;
   while (einName=[NamenEnum nextObject])
   {
      //NSLog(@"einName: %@",einName);
      [self.ArchivnamenPop addItemWithTitle:einName];
   }
	  
   NSEnumerator* SessionNamenEnum=[tempProjektNamenArray objectEnumerator];//Projektnamen im Archiv
   id einSessionName;
   int ItemIndex=1;
   while (einSessionName=[SessionNamenEnum nextObject])
   {
      //NSLog(@"setArchivNamenPopMitProjektArray tempProjektNamenArray index: %d: einSessionName: %@",ItemIndex,einSessionName);
      BOOL NameDa=NO;
      
      
      if (tempSessionLeserArray &&[tempSessionLeserArray containsObject:einSessionName])
      {
         //NSLog(@"Name da: %@",einSessionName);
         NameDa=YES;//Name ist in der Sessionsliste
      }
      
      //		[ArchivnamenPop addItemWithTitle:einSessionName];
      NSColor* itemColor=[NSColor blackColor];
      if (NameDa)
      {
         // itemColor=[NSColor greenColor];
         NSColor* SessionColor=[NSColor colorWithDeviceRed:66.0/255 green:185.0/255 blue:37.0/255 alpha:1.0];
         itemColor=SessionColor;
         
      }
      else
      {
         //			   itemColor=[NSColor blackColor];
      }
      
      NSDictionary* tempItemAttr=[NSDictionary dictionaryWithObjectsAndKeys:itemColor, NSForegroundColorAttributeName,[NSFont systemFontOfSize:13], NSFontAttributeName,nil];
      NSAttributedString* tempNamenItem=[[NSAttributedString alloc]initWithString:einSessionName attributes:tempItemAttr];
      //		[[ArchivnamenPop itemAtIndex:[ArchivnamenPop numberOfItems]-1]setAttributedTitle:tempNamenItem];
      if ([self.ArchivnamenPop numberOfItems]>2)
      {
         [[self.ArchivnamenPop itemAtIndex:ItemIndex]setAttributedTitle:tempNamenItem];
      }
      
      ItemIndex++;
      
   }//while
   
   //NSLog(@"setArchivnamenPop tempProjektNamenArray: %@",[tempProjektNamenArray description]);
   //	  [ArchivnamenPop addItemsWithTitles:tempProjektNamenArray];
   
   [self.Zeitfeld setSelectable:NO];
   //*   [RecPlayFenster makeFirstResponder:RecPlayFenster];
   
   
}

- (OSErr)Leseboxeinrichten	//	Nicht verwendet
{
   //Die Lesebox ist da und vollständig
   NSLog(@"Leseboxeinrichten		LeseboxPfad: %@",self.LeseboxPfad);
   OSErr err=0;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   NSMutableArray * Leseboxobjekte=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:self.LeseboxPfad error:NULL]];
   
   long AnzLeseboxObjekte=[Leseboxobjekte count];
   
   NSString* LeserNamenListe=[Leseboxobjekte description];
   
   if (AnzLeseboxObjekte &&[[Leseboxobjekte objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner
   {
      [Leseboxobjekte removeObjectAtIndex:0];
      AnzLeseboxObjekte--;
   }
   
   
   NSString* ArchivString=[NSString stringWithFormat:@"Archiv"];
   self.ArchivPfad=[self.LeseboxPfad stringByAppendingPathComponent:ArchivString];//Pfad des Archiv-Ordners
   
   if ([Filemanager fileExistsAtPath:self.ProjektPfad])
   {
      NSMutableArray * ArchivProjektNamenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:self.ArchivPfad error:NULL]];
      int AnzArchivProjektNamenArray=[ArchivProjektNamenArray count];											//Anzahl Leser
      LeserNamenListe=[ArchivProjektNamenArray description];
      
      if ([[ArchivProjektNamenArray objectAtIndex:0] hasPrefix:@".DS"])					//Unsichtbare Ordner entfernen
      {
         [ArchivProjektNamenArray removeObjectAtIndex:0];
         AnzArchivProjektNamenArray--;
      }
      
      int PopAnz=[self.ArchivnamenPop numberOfItems];
      NSLog(@"ArchivnamenPop numberOfItems %d",PopAnz);
      if (PopAnz>1)//Alle ausser erstel Item entfernen (Name wählen)
      {
         while (PopAnz>1)
         {
            
            //NSLog(@"ArchivnamenPop removeItemAtIndex  %@",[[ArchivnamenPop itemAtIndex:1]description]);
            [self.ArchivnamenPop removeItemAtIndex:1];
            PopAnz--;
            
         }
      }
      
      
      
      [self.ArchivnamenPop addItemsWithTitles:ArchivProjektNamenArray];
      //*      [RecPlayFenster makeFirstResponder:RecPlayFenster];
      [self.Zeitfeld setSelectable:NO];
      //AnzAdminProjektNamenArray++;
      
      
   }			//Archivpfad
   
   
   
   return err;
}


- (BOOL)LeseboxEinrichtenAnPfad:(NSString*)derProjektPfad	//	Nicht verwendet
{
   //Die Lesebox ist da und vollständig
   NSLog(@"LeseboxEinrichtenAnPfad: %@\nProjektArray: %@",derProjektPfad,[self.ProjektArray description]);
   OSErr err=0;
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSString* LeserNamenListe;
   if ([Filemanager fileExistsAtPath:self.ProjektPfad])
	  {
        NSMutableArray * tempProjektNamenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:derProjektPfad error:NULL]];
        int AnzAdminProjektNamenArray=[tempProjektNamenArray count];											//Anzahl Leser
        //LeserNamenListe=[ProjektNamenArray description];
        
        if ([[tempProjektNamenArray objectAtIndex:0] hasPrefix:@".DS"])					//Unsichtbare Ordner entfernen
        {
           [tempProjektNamenArray removeObjectAtIndex:0];
           AnzAdminProjektNamenArray--;
        }
        
        int PopAnz=[self.ArchivnamenPop numberOfItems];
        NSLog(@"ArchivnamenPop numberOfItems %d",PopAnz);
        if (PopAnz>1)//Alle ausser erstel Item entfernen (Name wählen)
        {
           while (PopAnz>1)
           {
              
              //NSLog(@"ArchivnamenPop removeItemAtIndex  %@",[[ArchivnamenPop itemAtIndex:1]description]);
              [self.ArchivnamenPop removeItemAtIndex:1];
              PopAnz--;
              
           }
        }
        
        [self.ArchivnamenPop addItemsWithTitles:tempProjektNamenArray];
        //*        [RecPlayFenster makeFirstResponder:RecPlayFenster];
        [self.Zeitfeld setSelectable:NO];
        //AnzAdminProjektNamenArray++;
        
        
     }			//Archivpfad
   
   
   
   return err;
}



- (NSArray*)ProjektNamenArrayVon:(NSString*)derArchivPfad
{
   NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* tempProjektNamenArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   BOOL istOrdner=NO;
   if ([Filemanager fileExistsAtPath:derArchivPfad isDirectory:&istOrdner]&&istOrdner)
   {
      tempArray=(NSMutableArray*)[Filemanager contentsOfDirectoryAtPath:derArchivPfad error:NULL];
      if ([tempArray count])
      {
         if ([[tempArray objectAtIndex:0] hasPrefix:@".DS"])
         {
            [tempArray removeObjectAtIndex:0];
         }
      }//count
      if ([tempArray count])
      {
         NSEnumerator* ProjektEnum=[tempArray objectEnumerator];
         id einProjekt;
         while (einProjekt=[ProjektEnum nextObject])
         {
            if (![[Filemanager contentsOfDirectoryAtPath:einProjekt error:NULL] count])
            {
               [tempProjektNamenArray addObject:[einProjekt lastPathComponent]];
            }//count
         }//while
      }//count
      //NSLog(@"tempProjektNamenArray: %@",[tempProjektNamenArray description]);
   }//fileExists
   return tempProjektNamenArray;
}


- (BOOL)setKommentarFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme
{
   BOOL erfolg=YES;
   BOOL istDirectory;
   NSString* tempLeser=[derLeser copy];
   
   NSString* tempAufnahme;
   tempAufnahme=[dieAufnahme copy];
   NSString* KommentarOrdnerString=@"Anmerkungen";
   NSString* tempKommentarOrdnerPfad=[[self.LeserPfad copy]stringByAppendingPathComponent:KommentarOrdnerString];
   
   NSString* tempKommentarPfad=[NSString stringWithString:self.ProjektPfad];
   
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   if ([Filemanager fileExistsAtPath:tempKommentarOrdnerPfad])
   {
      erfolg=YES;
   }
   else
   {
      erfolg=[Filemanager createDirectoryAtPath:tempKommentarOrdnerPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
      
   }
   
   if (erfolg)
   {
      NSString* testString;
      testString=@"Bemerkungen:";
      tempKommentarPfad=[tempKommentarOrdnerPfad stringByAppendingPathComponent:[tempAufnahme stringByAppendingPathExtension:@"txt"]];
      if (![Filemanager fileExistsAtPath:tempAufnahme])
      {
         NSString* Kommentarstring=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
         NSString*inhalt =[self KommentarVon:Kommentarstring];
         if (inhalt)
         {
            [self.KommentarView setString:inhalt];
         }
         //[KommentarView setEditable:NO];
      }
      
   }
   else
   {
      return erfolg;
   }
   return erfolg;
}//Beurteilungvorbereiten

- (NSString*)KommentarstringFuerLeser:(NSString*) derLeser vonAufnahme:(NSString*)dieAufnahme
{
   NSLog(@"KommentarstringFuerLeser Leser: %@ Aufnahme: %@",derLeser, dieAufnahme);
   NSString* Kommentarstring;
   BOOL erfolg=YES;
   BOOL istDirectory;
   NSString* tempLeser=[derLeser copy];
   
   NSString* tempAufnahme;
   tempAufnahme=[dieAufnahme copy];
   NSString* KommentarOrdnerString=@"Anmerkungen";
   NSString* tempKommentarOrdnerPfad=[[self.LeserPfad copy]stringByAppendingPathComponent:KommentarOrdnerString];
   
   NSString* tempKommentarPfad=[NSString stringWithString:self.ProjektPfad];
   
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   if ([Filemanager fileExistsAtPath:tempKommentarOrdnerPfad])
   {
      erfolg=YES;
   }
   else
   {
      erfolg=[Filemanager createDirectoryAtPath:tempKommentarOrdnerPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
      
   }
   
   if (erfolg)
   {
      NSString* testString;
      testString=@"Bemerkungen:";
      tempKommentarPfad=[tempKommentarOrdnerPfad stringByAppendingPathComponent:[tempAufnahme stringByAppendingPathExtension:@"txt"]];
      NSLog(@"KommentarstringFuerLeser tempKommentarPfad: %@ ",tempKommentarPfad);
      
      if (![Filemanager fileExistsAtPath:tempAufnahme])
      {
         Kommentarstring=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
         
         NSLog(@"KommentarstringFuerLeser Kommentarstring: %@ ",Kommentarstring);
         //[KommentarView setEditable:NO];
      }
      
   }
   
   return Kommentarstring;
}

- (void)setTimerfunktion:(NSTimer *)derTimer
{
   if (self.Durchgang  ==2)
   {
      self.Durchgang=0;
      
   }
   self.Durchgang++;
   return;
}



- (NSString*)Zeitformatieren:(long) dieSekunden
{
   //NSLog(@"Zeitformatieren dieSekunden: %d",dieSekunden);
   short Sekunden=dieSekunden%60;
   short Minuten=dieSekunden/60;
   NSNumber * n=0;
   n=[NSNumber numberWithLong:Minuten];
   NSString * stringMinuten=[n stringValue];
   n=[NSNumber numberWithLong:Sekunden];
   NSString*  stringSekunden=[n stringValue];
   NSString* stringZeit;
   if (Minuten < 10)
   {
      stringZeit=@"0";
      stringZeit=[stringZeit stringByAppendingString:stringMinuten];
   }
   else
   {
      stringZeit=[NSString stringWithString:stringMinuten];
   }
   stringZeit=[stringZeit stringByAppendingString:@":"];
   
   if (Sekunden<10)
   {
      
      stringZeit=[stringZeit stringByAppendingString:@"0"];
   }
   stringZeit=[stringZeit stringByAppendingString:stringSekunden];
   //NSLog(@"Zeitformatieren dieSekunden: %d stringZeit: %@",dieSekunden,stringZeit);
   return stringZeit;
   
}

- (IBAction)Logout:(id)sender
{
   //[NSApp terminate:self];
   NSAlert *Warnung = [[NSAlert alloc] init];
   [Warnung addButtonWithTitle:@"OK"];
   [Warnung addButtonWithTitle:@"Abbrechen"];
   [Warnung setMessageText:@"Alles gesichert?:"];
   [Warnung setInformativeText:@"Es werden alle ungesicherten Aufnahmen geloescht."];
   [Warnung setAlertStyle:NSWarningAlertStyle];
   int modalAntwort=[Warnung runModal];
   //NSLog(@"Logout modalAntwort: %d",modalAntwort);
   switch (modalAntwort)
   {
      case NSAlertFirstButtonReturn:
      {
         //NSLog(@"NSAlertFirstButtonReturn");
      }break;
      case NSAlertSecondButtonReturn:
      {
         //NSLog(@"NSAlertSecondButtonReturn");
         return;
      }break;
         
   }//switch
   
   [self resetRecPlay];
   
 //  return;
 //  [self ArchivZurListe:nil];
   
   [self stopPlay:nil];
   [self resetRecPlay];
   [self stopAVRecord:nil];
   
   [self.TitelPop setEnabled:NO];
   [self.StartRecordKnopf setEnabled:YES];
   [self.StartPlayKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:NO];
   [self.ForewardKnopf setEnabled:NO];
   [self.RewindKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self.LogoutKnopf setEnabled:NO];
   
   //*   [RecPlayFenster makeFirstResponder:RecPlayFenster];
   [self.KommentarView setString:@""];
   [self.KommentarView setEditable:NO];
   [self.TitelPop setEnabled:NO];
   [self clearArchiv];
   self.aktuellAnzAufnahmen=0;
   [self.Abspieldauerfeld setStringValue:@""];
   [self.Zeitfeld setStringValue:@""];
   [AVAbspielplayer stopTempAufnahme];
   [Abspielanzeige setLevel:0];
   [Abspielanzeige setNeedsDisplay:YES];
   [self.view.window makeFirstResponder:self.view];
}


- (IBAction)setzeLeser:(id)sender
{
   if ([AVRecorder isRecording])
   {
      // ++
      NSString* s1=@"Wiedergabe läuft";
      NSString* s2=@"Name kann nicht geändert werden während Abspielen";
      int Antwort=NSRunAlertPanel(s1,s2,@"OK", @"Stop",NULL);
      NSLog(@"Antwort: %d",Antwort);
      if (Antwort==1)
      {
         NSLog(@"Wiedergabe lauft: Antwort=1  weiter");
         return;
      }
      if (Antwort==0)
      {
         NSLog(@"Wiedergabe lauft: Antwort=0  stop");
         //        [self stopAVRecord:nil];
         NSString* s1=@"Aufnahme abgebrochen";
         NSString* s2=@"Abgebrochene Aufnahme sichern?";
         int Antwort=NSRunAlertPanel(s1, s2,@"JA", @"NEIN",NULL);
         if (Antwort==0)
         {
            NSLog(@"Aufnahme abgebrochen: Antwort=0  return");
            return;
         }
         if (Antwort==1)
         {
            NSLog(@"Aufnahme abgebrochen: Antwort=1  saveRecord");
            //          [self saveRecord:nil];
            
         }
      }
      // ++
      
   }
   //NSLog(@"setzeLeser: LeserPfad: %@ ",self.LeserPfad);
   //NSLog(@"setLeser: ProjektPfad: %@",[self.ProjektPfad description]);
   
   [self.ArchivnamenPop synchronizeTitleAndSelectedItem];
   
   NSString* Leser =[sender titleOfSelectedItem];
   
   if ([[sender titleOfSelectedItem] length]>0)
   {
      self.Leser=[NSString stringWithString:[sender titleOfSelectedItem]];
      
      //NSLog(@"setLeser: neuer Leser: %@",self.Leser);
      
      self.LeserPfad=[self.ProjektPfad stringByAppendingPathComponent:self.Leser];
      //NSLog(@"setLeser: neuer LeserPfad: %@",self.LeserPfad);
      if (self.mitUserPasswort)
      {
         BOOL PasswortOK=NO;
         NSData* tempPWData=[NSData data];
         NSEnumerator* PWEnum=[self.UserPasswortArray objectEnumerator];
         id einNamenDic;
         int index=0;
         int position=-1;
         while(einNamenDic=[PWEnum nextObject])
         {
            if ([[einNamenDic objectForKey:@"name"]isEqualToString:self.Leser])
            {
               if (position<0)//erstes Auftreten
               {
                  tempPWData=[einNamenDic objectForKey:@"pw"];
                  position=index;
               }
            }//if
            index++;
         }//while einNamenDic
         //const char* altespw=[@"anna" UTF8String];
         //tempPWData =[NSData dataWithBytes:altespw length:strlen(altespw)];
         
         NSMutableDictionary* tempPWDictionary=[[NSMutableDictionary alloc]initWithCapacity:0];
         [tempPWDictionary setObject:self.Leser forKey:@"name"];
         [tempPWDictionary setObject:tempPWData forKey:@"pw"];
         //NSLog(@"setLeser	tempPWDictionary: %@",[tempPWDictionary description]);
         if ([tempPWData length])
         {
            PasswortOK=[Utils confirmPasswort:tempPWDictionary];
         }
         else
         {
            //NSLog(@"UserPasswortArray vor changePasswort: %@\n",[UserPasswortArray description]);
            //NSLog(@"tempPWDictionary vor changePasswort: %@",[tempPWDictionary description]);
            NSMutableDictionary* neuesPWDic=[[NSMutableDictionary alloc]initWithCapacity:0];
            
            neuesPWDic=(NSMutableDictionary*)[Utils changePasswort:tempPWDictionary];
            
            //NSLog(@"tempPWDictionary in setLeser nach changePasswort: %@",[tempPWDictionary description]);
            
            //NSLog(@"UserPasswortArray nach changePasswort: %@\n",[UserPasswortArray description]);
            
            NSLog(@"neuesPWDic: %@",[neuesPWDic description]);
            if ([neuesPWDic objectForKey:@"pw"]&&[[neuesPWDic objectForKey:@"pw"]length])
            {
               PasswortOK=YES;
               //NSEnumerator* neuesPWEnum=[UserPasswortArray objectEnumerator];
               if (position>=0)//Leser hat ein PWDic im UserPasswortArray
               {
                  NSLog(@"Leser %@ hat ein PWDic im UserPasswortArray",self.Leser);
                  [self.UserPasswortArray replaceObjectAtIndex:position withObject:neuesPWDic];
               }
               else
               {
                  //NSLog(@"Alter PasswortArray: %@\nLeser %@ hat kein PWDic im UserPasswortArray\nneues PWDic: %@ ",[UserPasswortArray description],Leser,[neuesPWDic description]);
                  [self.UserPasswortArray addObject:neuesPWDic];
                  //NSLog(@"neuer UserPasswortArray: %@\n",[UserPasswortArray description]);
                  //[UserPasswortArray sortUsingSelector:@selector(compare:)];
                  //UserPasswortArray=[UserPasswortArray sortedArrayUsingFunction:ArrayOfDicSort context:@"name"];
                  
               }
               [self saveUserPasswortArray:self.UserPasswortArray];
            }
            
         }
         
         if(!PasswortOK)
         {
            NSLog(@"Passwort nicht OK");
            [sender selectItemAtIndex:0];
            [self resetLesebox:NULL];
            return;
         }
      }//mitUserPasswort
   }//if ([[sender titleOfSelectedItem] length]>0)
   else
   {
      self.Leser=@"";
   }
   [self.LogoutKnopf setEnabled:YES];
   
   
   [self.Leserfeld setStringValue:[sender titleOfSelectedItem]];
   //NSLog(@"setLeser: alter LeserPfad: %@",[self.LeserPfad description]);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   if ([Filemanager fileExistsAtPath:self.LeserPfad])
   {
      NSDictionary* Attribute=[Filemanager attributesOfFileSystemForPath:self.LeserPfad error:NULL];
      //NSLog(@"Attribute: %@",[Attribute description]);
      
      //TitelAufnahmen im Ordner Leser
      NSMutableArray* TitelArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:self.LeserPfad error:NULL]];
      
      
      int i;
      self.aktuellAnzAufnahmen=(int)[TitelArray count];
      NSString* tempTitelString;
      NSString* indexTitelString;
      NSString* nextindexTitelString;
      NSString* tempTitelnummerString;
      int tempNummer;
      //NSLog(@"TitelArray von FM: %@",[TitelArray description]);
      if (self.aktuellAnzAufnahmen)
      {
         if ([[TitelArray objectAtIndex:0] hasPrefix:@".DS"]) //Unsichtbare Ordner entfernen
         {
            [TitelArray removeObjectAtIndex:0];
            self.aktuellAnzAufnahmen--;
         }
      }
      int k;
      NSUInteger Kommentarindex=NSNotFound;
      for (k=0;k<self.aktuellAnzAufnahmen;k++)//'Kommentar' entfernen
      {
         
         NSString* tempAufnahme =[TitelArray objectAtIndex:k];
         if ([tempAufnahme rangeOfString:@"m4a"].location <NSNotFound)
         {
            [TitelArray replaceObjectAtIndex:k withObject:[tempAufnahme stringByDeletingPathExtension]];
         }
         
         //if([[TitelArray objectAtIndex:k] isEqualToString:@"Anmerkungen"])
         if([tempAufnahme isEqualToString:@"Anmerkungen"])
         {
            Kommentarindex=k;
         }
         
         
      }
      //NSLog(@"Kommentarindex: %d",Kommentarindex);
      if (!(Kommentarindex==NSNotFound))
      {
         [TitelArray removeObjectAtIndex:Kommentarindex];
         self.aktuellAnzAufnahmen--;
      }
      //NSLog(@"TitelArray vor Sortieren: %@",[TitelArray description]);
      
      //**
      
      //bei Löschen im Netz: File 'afpDeletedxxxx' suchen
      //NSLog(@"setLeser: bei Löschen im Netz: File 'afpDeletedxxxx' suchen: %@",[TitelArray description]);
      int afpZeile=-1;
      
      for(k=0;k<self.aktuellAnzAufnahmen;k++)
      {
         if ([[[TitelArray objectAtIndex:k]description]characterAtIndex:0]=='.')
         {
            //NSLog(@"String mit Punkt: %@ auf Zeile: %d",[[TitelArray objectAtIndex:k]description],k);
            afpZeile=k;
         }
         //NSLog(@"kein Kommentar bei %d",k);
         
      }
      if (afpZeile>=0) //afpDelete entfernen
      {
         [TitelArray removeObjectAtIndex:afpZeile];
         self.aktuellAnzAufnahmen--;
      }
      
      
      
      
      //**
      
      if (self.aktuellAnzAufnahmen)//der Leser hat schon Aufnahmen
      {
         //Array für die Titel in TitelPop
         NSMutableArray* TitelPopArray=[[NSMutableArray alloc] initWithCapacity:0];
         int tausch=1;
         
         while (tausch)
         {
            tausch=0;
            for (i=0;i<self.aktuellAnzAufnahmen-1;i++)//sortieren nach nummer
            {
               indexTitelString=[NSString stringWithString:[TitelArray objectAtIndex:i]];
               nextindexTitelString=[NSString stringWithString:[TitelArray objectAtIndex:i+1]];
               int n1=[self AufnahmeNummerVon:indexTitelString];
               int n2=[self AufnahmeNummerVon:nextindexTitelString];
               //NSLog(@"indexTitelString: %@  Nr:%d",indexTitelString,n1);
               //NSLog(@"nextindexTitelString: %@  Nr:%d",nextindexTitelString,n2);
               if(n2<n1)
               {
                  [TitelArray exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                  //NSLog(@"tausch: n1: %d    n2: %d",n1,n2);
                  tausch++;
               }
               
            }//for anzahl
         }//while tausch
         //NSLog(@"TitelArray nach Sortieren: %@",[TitelArray description]);
         NSMutableArray* AufnahmenPopArray=[[NSMutableArray alloc] initWithCapacity:self.aktuellAnzAufnahmen];
         [self.ArchivDaten resetArchivDaten];
         for (i=(int)[TitelArray count]-1;i>=0;i--)//Reihenfolge umkehren für TitelPop
         {
            [AufnahmenPopArray addObject:[TitelArray objectAtIndex:i]];
            
            [self.ArchivDaten setAufnahmePfad:[[TitelArray objectAtIndex:i]description] forRow:0];
            //NSLog(@"TitelArray: %@",[[TitelArray objectAtIndex:i]description]);
            
            //NSLog(@"TitelArray :%@END",[[TitelArray objectAtIndex:i]description]);
            //indexTitelString=[NSString stringWithString:[TitelArray objectAtIndex:i]];
            tempTitelString=[self AufnahmeTitelVon:[TitelArray objectAtIndex:i]];
            //NSLog(@"index: %d           tempTitel: %@",i,tempTitelString);
            if (![TitelPopArray containsObject:tempTitelString])
            {
               //[TitelPopArray insertObject:tempTitelString atIndex:tempNummer];
               long letzterPlatz=[TitelPopArray count];
               //NSLog(@"letzterPlatz: %d      indexTitelString: %@ ",letzterPlatz,tempTitelString);
               
               [TitelPopArray insertObject:tempTitelString atIndex:letzterPlatz];
            }
         }//for anzahl
         
         //NSLog(@"TitelPopArray : %@",[TitelPopArray description]);
         
         [self.ArchivView reloadData];
         self.ArchivZeilenhit=NO;
         
         //NSLog(@"AufnahmenPopArray def: %@",[AufnahmenPopArray description]);
         [self.KommentarPop removeAllItems];
         [self.KommentarPop addItemsWithTitles:AufnahmenPopArray];
         //NSLog(@"TitelPopArray def: %@",[TitelPopArray description]);
         [self.TitelPop removeAllItems];
         [self.TitelPop addItemsWithObjectValues:TitelPopArray];
         
         //NSLog(@"FirstResponder: %@",[[RecPlayFenster firstResponder]description]);
         //[TitelPop selectText:nil];
         
         //Titel von PList aus Projektordner anfügen
         BOOL TitelEditOK; //Titel editierbar?
         NSArray* tempTitelArray;
         NSArray* tempProjektNamenArray=[self.ProjektArray valueForKey:@"projekt"];//Verzeichnis ProjektNamen
         NSUInteger ProjektIndex=[tempProjektNamenArray indexOfObject:[self.ProjektPfad lastPathComponent]];//Dic des akt. Projekts
         if (!(ProjektIndex==NSNotFound))
         {
            NSDictionary* tempProjectDic=[self.ProjektArray objectAtIndex:ProjektIndex];
            //NSLog(@"tempProjectDic: %@",[tempProjectDic description]);
            if ([tempProjectDic objectForKey:@"fix"])
            {
               TitelEditOK=![[tempProjectDic objectForKey:@"fix"]boolValue];//Titel sind nicht fixiert
            }
            
            if ([tempProjectDic objectForKey:@"titelarray"])
            {
               tempTitelArray=[NSArray arrayWithArray:[tempProjectDic objectForKey:@"titelarray"]];
               //NSLog(@"tempTitelArray: %@ [TitelPop objectValues]: %@",[tempTitelArray description],[[TitelPop objectValues]description]);
               NSEnumerator* TitelEnum=[tempTitelArray objectEnumerator];
               id einTitelDic;
               while (einTitelDic=[TitelEnum nextObject])
               {
                  //NSLog(@"einTitelDic: %@",[einTitelDic description]);
                  NSString* tempTitel=[einTitelDic objectForKey:@"titel"];
                  if ([[einTitelDic objectForKey:@"ok"]boolValue]&&[tempTitel length])
                  {
                     [self.TitelPop addItemWithObjectValue:tempTitel];
                  }
               }//while
               
            }//if ([[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"titelarray"])
         }//if (!(ProjektIndex==NSNotFound))
         
         NSLog(@"setLeser nicht leer: LeserPfad: %@ TitelEditOK : %d ",[self.LeserPfad description], TitelEditOK);
         
         [self.TitelPop selectItemAtIndex:0];
         [self.TitelPop setEnabled:YES];
         if (TitelEditOK)
         {
            
            
            [self.TitelPop setEditable:TitelEditOK];//Nur wenn Titel editierbar
            [self.TitelPop setSelectable:TitelEditOK];
            //[self.TitelPop selectText:self];
            //       [[self.TitelPop currentEditor] setSelectedRange:NSMakeRange([[self.TitelPop stringValue] length], 0)];
            [self.view.window makeFirstResponder:self.TitelPop];
         }
         /*
          // http://stackoverflow.com/questions/764179/focus-a-nstextfield
          [textField selectText:self];
         [[textField currentEditor] setSelectedRange:NSMakeRange([[textField stringValue] length], 0)];
         */
         //*
         //     BOOL first=[[[self view]window] makeFirstResponder:self.TitelPop];
         
         
         [self setKommentarFuerLeser:self.Leser FuerAufnahme:[[TitelArray objectAtIndex:[TitelArray count]-1]description]];
         
      }//if aktuellAnzAufnahmen
      else //noch keine Aufnahmen im Ordner
      {
         NSLog(@"setLeser leer: LeserPfad: %@ ",[self.LeserPfad description]);
         
         [self.TitelPop removeAllItems];
         
         //Titel von PList aus Projektordner anfügen
         BOOL PListTitelAktiviert=YES;
         BOOL TitelEditOK=NO;//Titel editierbar?
         NSArray* tempTitelArray;
         NSArray* tempProjektNamenArray=[self.ProjektArray valueForKey:@"projekt"];//Verzeichnis ProjektNamen
         NSUInteger ProjektIndex=[tempProjektNamenArray indexOfObject:[self.ProjektPfad lastPathComponent]];//Dic des akt. Projekts
         if (!(ProjektIndex==NSNotFound))
         {
            NSDictionary* tempProjectDic=[self.ProjektArray objectAtIndex:ProjektIndex];
            if ([tempProjectDic objectForKey:@"fix"])
            {
               TitelEditOK=![[tempProjectDic objectForKey:@"fix"]boolValue];//Titel sind nicht fixiert
            }
            
            if ([tempProjectDic objectForKey:@"titelarray"])
            {
               tempTitelArray=[NSArray arrayWithArray:[tempProjectDic objectForKey:@"titelarray"]];
               //NSLog(@"tempTitelArray: %@ [TitelPop objectValues]: %@",[tempTitelArray description],[[TitelPop objectValues]description]);
               NSEnumerator* TitelEnum=[tempTitelArray objectEnumerator];
               id einTitelDic;
               while (einTitelDic=[TitelEnum nextObject])
               {
                  //NSLog(@"einTitelDic: %@",[einTitelDic description]);
                  NSString* tempTitel=[einTitelDic objectForKey:@"titel"];
                  if ([[einTitelDic objectForKey:@"ok"]boolValue]&&[tempTitel length])
                  {
                     [self.TitelPop addItemWithObjectValue:tempTitel];
                  }
               }//while
               
            }//if ([[ProjektArray objectAtIndex:ProjektIndex]objectForKey:@"titelarray"])
         }//if (!(ProjektIndex==NSNotFound))
         
         [self.TitelPop setEnabled:YES];
         
         if ([self.TitelPop numberOfItems]==0)//keine Titel aus PList
         {
            TitelEditOK=YES;//Eingabe eines ersten Titels ermöglichen
         }
         
         if (TitelEditOK)//Titel sind editierbar
         {
            [self.TitelPop addItemWithObjectValue:@"neue Aufnahme"];
         }
         NSLog(@"setLeser leer: LeserPfad: %@ titelfix : %d ",self.LeserPfad , TitelEditOK);
         
         [self.TitelPop selectItemAtIndex:0];
         
         [[self.TitelPop cell] setEditable:TitelEditOK];//Nur wenn Titel editierbar
         [[self.TitelPop cell] setSelectable:TitelEditOK];
         
         
         [self.ArchivDaten resetArchivDaten];
         [self.ArchivView reloadData];
         
         //self.aktuellAnzAufnahmen=0;
      }
      
      
      
   }//if ([Filemanager fileExistsAtPath:LeserPfad])
   
   
   
   
   [self setArchivView];
   
   [Utils startTimeout:self.TimeoutDelay];
   
}



- (IBAction)setTitel:(id)sender
{
   //int i=[sender indexOfSelectedItem];
   //NSLog(@"setTitel index: %d  Item: %@",i,[sender objectValueOfSelectedItem]);
   //NSLog(@"Titel: %@",[self titel]);
   
}

- (NSString*)titel
{
   
   return [[self.TitelPop cell]stringValue];
}

- (BOOL)istAktiviert:(NSString*)dasProjekt
{
   BOOL checkAktiviert=NO;
   if ([self.ProjektArray count])
   {
      //NSLog(@"istAktiviert Projekt: %@ ProjektArray: %@",dasProjekt,[ProjektArray description]);
      NSEnumerator* ProjektEnum=[self.ProjektArray objectEnumerator];
      id einProjekt;
      while (einProjekt=[ProjektEnum nextObject])
      {
         if ([einProjekt objectForKey:@"projekt"])
         {
            //NSLog(@"istAktiviert einProjekt: %@",[einProjekt description]);
            if([[einProjekt objectForKey:@"projekt"]isEqualToString:dasProjekt])
            {
               checkAktiviert= [[einProjekt objectForKey:@"ok"]boolValue];
            }
            //NSLog(@"istAktiviert einProjekt: %@ checkAktiviert: %d",[einProjekt description],checkAktiviert);
         }
      }//while
      
   }//count
   return checkAktiviert;
}




- (IBAction)switchAdminPlayer:(id)sender
{
   if (![self checkAdminZugang])
   {
      return;
   }
   [self.StartRecordKnopf setEnabled:YES];
   [self.StartPlayKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:NO];
   [self.ForewardKnopf setEnabled:NO];
   [self.RewindKnopf setEnabled:NO];
   [self.BackKnopf setEnabled:NO];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self.LogoutKnopf setEnabled:NO];
   [self.RewindKnopf setEnabled:NO];
   [self.ForewardKnopf setEnabled:NO];
   [self.KommentarView setString:@""];
   [self.KommentarView setEditable:NO];


   //NSLog(@"switchAdminPlayer start");
   [Utils stopTimeout];
   if (self.AdminZugangOK || [self checkAdminZugang])
   {
      NSLog(@"switchAdminPlayer ok");
   //   [[self.ModusMenu itemWithTag:kRecPlayTag]setEnabled:YES];
      [self beginAdminPlayer:nil];
      
      [Utils stopTimeout];
   }
   else
   {
      [Utils startTimeout:self.TimeoutDelay];
      NSBeep();
      NSLog(@"switchAdminPlayer abgebrochen");
      
   }
}


- (IBAction)beginRecPlay:(id)sender
{
   if (![self checkAdminZugang])
   {
      return;
   }

   if(self.Umgebung==0)
      return;
   if (![self istAktiviert:[self.ProjektPfad lastPathComponent]])
   {
      NSAlert *Warnung = [[NSAlert alloc] init];
      [Warnung addButtonWithTitle:@"OK"];
      //[Warnung addButtonWithTitle:@"Cancel"];
      [Warnung setMessageText:@"Projekt ist nicht aktiviert"];
      [Warnung setInformativeText:@"Recorder kann nicht geöffnet werden."];
      [Warnung setAlertStyle:NSWarningAlertStyle];
      NSImage* RPImage = [NSImage imageNamed: @"MicroIcon"];
      [Warnung setIcon:RPImage];
      [Warnung runModal];
      return;
      
   }
   [self.RecPlayFenster setIsVisible:YES];
   self.Umgebung=0;
   
   [self setRecPlay];
   
   //OSErr err=[self Leseboxeinrichten];
   [self.SichernKnopf setEnabled:NO];
   [self.WeitereAufnahmeKnopf setEnabled:NO];
   [self anderesProjektEinrichtenMit:[self.ProjektPfad lastPathComponent]];
   
   if (!self.ArchivDaten)
	  {
        self.ArchivDaten=[[rArchivDS alloc]initWithRowCount:0];
        [self.ArchivView setDelegate: self.ArchivDaten];
        [self.ArchivView setDataSource: self.ArchivDaten];
        
     }
   
}


- (NSString*)Initialen:(NSString*)derName
{
   if ([derName length]==0)
   {
      return @"YY";
   }
   
   NSString* tempstring =[derName copy];
   unichar  Anfangsbuchstabe=[tempstring characterAtIndex:0];
   NSMutableString*initial=[NSMutableString stringWithCharacters:&Anfangsbuchstabe length:1];
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
      NSString* s=[NSMutableString stringWithCharacters:&ZweiterBuchstabe length:1];
      initial=(NSMutableString*)[initial stringByAppendingString:s];
   }
   else
   {
      return @"XX";
   }
   return initial;
}


- (NSString*)AufnahmeTitelVon:(NSString*) dieAufnahme
{
   NSString* tempAufnahme=[dieAufnahme copy];
   int posLeerstelle1=0;
   int posLeerstelle2=0;
   int Leerstellen=0;
   NSString*  tempString;
   
   unsigned int charpos=0;
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



- (int)AufnahmeNummerVon:(NSString*) dieAufnahme
{
   NSString* tempAufnahme=[dieAufnahme copy];
   int posLeerstelle1=0;
   int posLeerstelle2=0;
   int Leerstellen=0;
   int tempNummer=0;
   
   unsigned int charpos=0;
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


- (NSString*)KommentarVon:(NSString*) derKommentarString
{
   NSArray* tempMarkArray=[derKommentarString componentsSeparatedByString:@"\r"];
   //NSLog(@"KommentarVon: anz Components: %d",[tempMarkArray count]);
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
      //NSLog(@" *** 6 el ***  tempKommentarString: %@", tempKommentarString);
      
      return tempKommentarString;
   }//noch keine Zeile für Mark
   else
   {
      //		NSString* tempKommentarString=[tempMarkArray objectAtIndex:Kommentar];
      NSString* tempKommentarString=[tempMarkArray lastObject];
      //NSLog(@" *** else  ***  tempKommentarString: %@", tempKommentarString);
      
      //		return [tempMarkArray objectAtIndex:Kommentar];
      return [tempMarkArray lastObject];
      
   }
}

- (NSString*)DatumVon:(NSString*) derKommentarString
{
   NSString* tempDatumString;
   tempDatumString=[derKommentarString copy];
   int AnzReturns=0;
   int returnpos1=0,returnpos2=0;
   int pos=0;
   while(pos<(int)[tempDatumString length])
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
        unsigned int leerpos=0;
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
           //NSLog(@"tempDatumString: %@", tempDatumString);
        }
        else
        {
           tempDatumString=@"--";
        }
     }
   
   
   return tempDatumString;
   
}

- (NSString*)BewertungVon:(NSString*) derKommentarString
{
   NSString* tempBewertungString;
   tempBewertungString=[derKommentarString copy];
   int AnzReturns=0;
   int returnpos1=0,returnpos2=0;
   unsigned int pos=0;
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
           tempBewertungString=@" ";
           return tempBewertungString;
        }
        //NSLog(@"BewertungVon:		tempBewertungString: %@", tempBewertungString);
     }
   else
	  {
        
     }
   // 8.12.08
   //tempBewertungString=@"";
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



- (BOOL)UserMarkVon:(NSString*) derKommentarString
{
   BOOL MarkSet=NO;
   NSArray* tempMarkArray=[derKommentarString componentsSeparatedByString:@"\r"];
   //NSLog(@"UserMarkVon: tempMarkArray: %@",[tempMarkArray description]);
   if ([tempMarkArray count]==8)//Zeile für Mark ist da
   {
      if ([[tempMarkArray objectAtIndex:UserMark]isEqualToString:@"1"])
      {
         MarkSet=YES;
      }
   }
   
   //NSLog(@"UserMarkVon: MarkSet: %d",MarkSet);
   return MarkSet;
}


- (NSString*)NoteVon:(NSString*) derKommentarString
{
   NSString* tempNotenString;
   //[tempKommentarString release];
   tempNotenString=[derKommentarString copy];
   int AnzReturns=0;
   int returnpos1=0,returnpos2=0;
   unsigned int pos=0;
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



- (void)setArchivPfadFuerAufnahme:(NSString*)dieAufnahme
{
   self.ArchivPlayPfad=[NSString stringWithString:self.LeserPfad];
   self.ArchivPlayPfad=[self.ArchivPlayPfad stringByAppendingPathComponent:[dieAufnahme copy]];
   NSLog(@"setArchivPfadFuerAufnahme ArchivPlayPfad: %@",self.ArchivPlayPfad);
   
   //	BOOL KommentarOK=[Utils setKommentar:@"Hallo" inAufnahmeAnPfad:ArchivPlayPfad];
   //	NSString* Kontrollstring=[Utils KommentarStringVonAufnahmeAnPfad:ArchivPlayPfad];
   //	NSLog(@"setArchivPfadFuerAufnahme ArchivPlayPfad: %@  Kontrollstring: %@",ArchivPlayPfad,Kontrollstring);
   
   
   
   NSFileManager* Filemanager=[NSFileManager defaultManager];
   if ([Filemanager fileExistsAtPath:[self.ArchivPlayPfad stringByAppendingPathExtension:@"m4a"]] || [Filemanager fileExistsAtPath:self.ArchivPlayPfad ])
	  {
        
        [self.ArchivInPlayerTaste setEnabled:YES];
        [self.ArchivInListeTaste setEnabled:NO];
        //NSLog(@"gueltiger ArchivPlayPfad: %@",ArchivPlayPfad);
        self.ArchivKommentarPfad=[NSString stringWithString:self.LeserPfad];
        //self.ArchivKommentarPfad=[self.ArchivKommentarPfad stringByAppendingPathComponent:@"Anmerkungen"];
        self.ArchivKommentarPfad=[self.ArchivKommentarPfad stringByAppendingPathComponent:@"Anmerkungen"];
        self.ArchivKommentarPfad=[self.ArchivKommentarPfad stringByAppendingPathComponent:[dieAufnahme copy]];
        NSLog(@"setArchivPfadFuerAufnahme ArchivKommentarPfad: %@",self.ArchivKommentarPfad);
        
        NSString* tempArchivKommentarPfad = [self.ArchivKommentarPfad stringByAppendingPathExtension:@"txt"];
        if ([Filemanager fileExistsAtPath:tempArchivKommentarPfad])
        {
           NSLog(@"Archiv: Kommentar da");
           [self setArchivKommentarFuerAufnahmePfad:tempArchivKommentarPfad];
        }
        else //Kein Kommentar da
        {
           NSLog(@"Archiv: KEIN Kommentar da");
           [self clearArchivKommentar];
           
        }
        
     }//file exists
   else
	  {
        NSLog(@"kein gueltiger ArchivPlayPfad");
        [self.ArchivPlayTaste setEnabled:NO];
        [self.ArchivInListeTaste setEnabled:NO];
        [self.ArchivInPlayerTaste setEnabled:NO];
        self.ArchivPlayPfad=@"";
        self.ArchivKommentarPfad=@"";
        
     }
   
}


- (void)setArchivKommentarFuerAufnahmePfad:(NSString*)derAufnahmePfad;
{
   //NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSLog(@"setArchivKommentarFuerAufnahmePfad: derAufnahmePfad: %@",derAufnahmePfad);
   NSString* tempKommentarString=[NSString stringWithContentsOfFile:derAufnahmePfad encoding:NSMacOSRomanStringEncoding error:NULL];
   NSLog(@"\nsetArchivKommentarFuerAufnahmePfad: tempKommentarString: %@",tempKommentarString);
   NSString* inhalt =[self KommentarVon:tempKommentarString];
   NSLog(@"setArchivKommentarFuerAufnahmePfad: inhalt: %@",inhalt);
   if (inhalt)
      [self.ArchivKommentarView setString:inhalt];
   [self.ArchivKommentarView setSelectable:NO];
   [self.ArchivDatumfeld setStringValue:[self DatumVon:tempKommentarString]];
   

   [self.ArchivTitelfeld setStringValue:[[self AufnahmeTitelVon:[derAufnahmePfad lastPathComponent]]stringByDeletingPathExtension]];
   int aufnahmenummer=[self AufnahmeNummerVon:[derAufnahmePfad lastPathComponent]];
   [self.ArchivAufnahmenummerfeld setIntValue:aufnahmenummer];
   NSLog(@"setArchivKommentarFuerAufnahmePfad titel: %@ nummer: %d",[derAufnahmePfad lastPathComponent],aufnahmenummer);
   if (self.BewertungZeigen)
	  {
        //[ArchivBewertungfeld setHidden:NO];
        [self.ArchivBewertungfeld setStringValue:[self BewertungVon:tempKommentarString]];
     }
   else
	  {
        //[ArchivBewertungfeld setHidden:YES];
        [self.ArchivBewertungfeld setStringValue:@" "];
     }
   if (self.NoteZeigen)
	  {
        //[ArchivNotenfeld setHidden:NO];
        [self.ArchivNotenfeld setStringValue:[self NoteVon:tempKommentarString]];
     }
   else
	  {
        //[ArchivNotenfeld setHidden:YES];
        [self.ArchivNotenfeld setStringValue:@"-"];
     }
   //NSLog(@"setArchivKommentarFuerAufnahmePfad 2");
   BOOL userMarkOK=[self UserMarkVon:tempKommentarString];
   NSLog(@"setArchivKommentarFuerAufnahmePfad MarkOK: %d",userMarkOK);
   [self.UserMarkCheckbox setState:userMarkOK];
   //NSLog(@"setArchivKommentatFuerAufnahmepfad: MarkOK: %d",MarkOK);
   BOOL adminMarkOK=[self AdminMarkVon:tempKommentarString];
   NSLog(@"setArchivKommentarFuerAufnahmePfad MarkOK: %d",adminMarkOK);
   [self.AdminMarkCheckbox setState:adminMarkOK];
   //NSLog(@"setArchivKommentatFuerAufnahmepfad: MarkOK: %d",adminMarkOK);

   return ;
}

- (void)clearArchivKommentar
{
   [self.ArchivKommentarView setString:@""];
   [self.ArchivDatumfeld setStringValue:@""];
   [self.ArchivTitelfeld setStringValue:@""];
   [self.ArchivAbspieldauerFeld setStringValue:@""];
   [self.ArchivBewertungfeld setStringValue:@""];
   [self.ArchivNotenfeld setStringValue:@""];
}


- (void)updateArchivPlayBalken:(NSTimer *)derTimer
{
   /*
    QTTime Gesamtzeit=[[ArchivQTKitPlayer movie]duration];
    QTTime Spielzeit=[[ArchivQTKitPlayer movie]currentTime];
    float Restzeit=(float)(Gesamtzeit.timeValue-Spielzeit.timeValue);///Gesamtzeit.timeScale;
    //NSLog(@"Restzeit: %2.2f",Restzeit);
    [ArchivAbspielanzeige setLevel:(Spielzeit.timeValue)];
    
    [ArchivAbspieldauerFeld setStringValue:[self Zeitformatieren:Restzeit]];
    if (Restzeit==0)
    {
    [derTimer invalidate];
    //NSLog(@"Restzeit ist null");
    }
    */
}

- (NSString*)zeitStringVonInt:(double)zeit
{
   int posint = (int)zeit;
   
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
   return [NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString];
}


- (IBAction)startArchivPlayer:(id)sender
{
   // NSLog(@"startArchivPlayer:");
   NSLog(@"startArchivPlayer:			ArchivPlayPfad: %@",self.ArchivPlayPfad);
   
  // NSString* tempAchivPlayPfad = [self.ArchivPlayPfad stringByAppendingPathExtension:@"m4a"];
   
   
   
   [AVAbspielplayer playArchivAufnahme];
   
   
   
  // [self.ArchivPlayTaste setEnabled:NO];
   //[self setBackTaste:YES];
   [self.ArchivStopTaste setEnabled:YES];
   [self.ArchivZumStartTaste setEnabled:YES];
   [self.ArchivRewindTaste setEnabled:YES];
   [self.ArchivForewardTaste setEnabled:YES];
   [Utils startTimeout:self.TimeoutDelay];
   
}

- (IBAction)stopArchivPlayer:(id)sender
{
   [AVAbspielplayer stopTempAufnahme];
   self.Pause=self.ArchivLaufzeit/60;
   //NSLog(@"Laufzeit:%d  PauseZeit: %d",Laufzeit,Pause);
   
   [self.ArchivPlayTaste setEnabled:YES];
   //  [self.ArchivStopTaste setEnabled:NO];
   [self.ArchivZumStartTaste setEnabled:YES];
   [Utils startTimeout:self.TimeoutDelay];
}
- (IBAction)backArchivPlayer:(id)sender
{
   [AVAbspielplayer toStartTempAufnahme];
   [self.ArchivPlayTaste setEnabled:YES];
   [self.ArchivStopTaste setEnabled:YES];
   self.Pause=0;
   //   [self.ArchivAbspieldauerFeld setStringValue:[self Zeitformatieren:QTKitGesamtAbspielzeit]];
   //Abspieldauer=GesamtAbspielzeit;
   [self.ArchivAbspielanzeige setLevel:0];
   [Utils startTimeout:self.TimeoutDelay];
   
}

- (void)setArchivView
{
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSMutableArray* AufnahmenArray;
   AufnahmenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:self.LeserPfad error:NULL]];
   //NSLog(@"Archiv AufnahmenArray: %@",[AufnahmenArray description]);
   //SEL DoppelSelektor;
//   DoppelSelektor=@selector(ArchivaufnahmeInPlayer:);
   
//   [self.ArchivView setDoubleAction:DoppelSelektor];
}

- (IBAction)resetArchivPlayer:(id)sender
{
   [AVAbspielplayer stopTempAufnahme];
   [self.ArchivAbspieldauerFeld setStringValue:@""];
   [self.Abspieldauerfeld setStringValue:@""];
   [self.ArchivAbspielanzeige setLevel:0];
   [self.ArchivAbspielanzeige setNeedsDisplay:YES];
   
   [Abspielanzeige setLevel:0];
   [Abspielanzeige setNeedsDisplay:YES];
   //
   [self.ArchivInListeTaste setEnabled:NO];
   [self.ArchivInListeTaste setKeyEquivalent:@""];
   [self.ArchivInPlayerTaste setEnabled:YES];
   [self.ArchivPlayTaste setEnabled:NO];
   [self.ArchivStopTaste setEnabled:NO];
   [self.ArchivRewindTaste setEnabled:NO];
   [self.ArchivForewardTaste setEnabled:NO];
   
   [self.ArchivZumStartTaste setEnabled:NO];
   //NSLog(@"reset UserMarkCheckbox");
   [self.UserMarkCheckbox setState:NO];
   [self.UserMarkCheckbox setEnabled:NO];
   
   [self clearArchivKommentar];
   
}

- (void)clearArchiv
{
   [self resetArchivPlayer:nil];
   [self clearArchivKommentar];
   [self.ArchivDaten resetArchivDaten];
   [self.ArchivView reloadData];
}


- (void)keyDown:(NSEvent *)theEvent
{
   int nr=[theEvent keyCode];
   NSLog(@"RecPlay  keyDown: nr: %d  char: %@",nr,[theEvent characters]);
  // [self keyDownAktion:nil];
   [super keyDown:theEvent];
}

- (IBAction)keyDownAktion:(id)sender
{
   //if ([ArchivDaten AufnahmePfadFuerZeile:zeilenNr])
   if ([self.ArchivDaten AufnahmePfadFuerZeile:0])
	  {
        [self resetArchivPlayer:nil];
        //[self setArchivPfadFuerAufnahme:[ArchivDaten AufnahmePfadFuerZeile:zeilenNr]];
     }
   else
      [self.ArchivPlayTaste setEnabled:NO];
   
}
- (void) KeyNotifikationAktion:(NSNotification*)note
{
   NSLog(@"KeyNotifikationAktion: note: %@",[note object]);
   //NSNumber* KeyNummer=[note object];
   //int keyNr=(int)[KeyNummer floatValue];
   //NSLog(@"keyDown KeyNotifikationAktion description: %@",[KeyNummer description]);
   //NSLog(@"keyDown KeyNotifikationAktion keyNr: %d",keyNr);
   //[self setLself.NamenListe ];
   //[self startAdminPlayer:AdminQTPlayer];
}


- (void) ZeilenNotifikationAktion:(NSNotification*)note
{
   if ([AVAbspielplayer isPlaying])
   {
      [AVAbspielplayer toStartTempAufnahme];
   }

   if (self.ArchivZeilenhit)
	  {
        //NSLog(@"ArchivZeilenhit=YES");
        self.ArchivZeilenhit=NO;
        //return ;
     }
   self.ArchivZeilenhit=YES;
   
   
   NSDictionary* QuellenDic=[note object];
   
   NSString* Quelle=[QuellenDic objectForKey:@"Quelle"];
   NSLog(@"ZeilenNotifikationAktion:   Quelle: %@",Quelle);
   
   if ([Quelle isEqualToString:@"ArchivView"])
	  {
       // NSLog(@"ZeilenNotifikationAktion:   Quelle: %@",Quelle);

        double lastZeilenNummer = [[QuellenDic objectForKey:@"lastarchivzeilennummer"]doubleValue];
        
        
        if (lastZeilenNummer >=0) // es war eine Zeile selektiert, aufraeumen
        {
           [self ArchivZurListe:nil];
           [self resetArchivPlayer:nil];
           
        }
        
        
        NSNumber* ZeilenNummer=[QuellenDic objectForKey:@"ArchivZeilenNummer"];
        int zeilenNr=(int)[ZeilenNummer floatValue];
        //NSLog(@"keyDown ZeilenNotifikationAktion description: %@",[ZeilenNummer description]);
        NSLog(@"\n\nZeilenNotifikationAktion fuer ArchivView       zeilenNr: %d\n",zeilenNr);
        [self.UserMarkCheckbox setState:NO];
        
        self.ArchivSelektierteZeile=zeilenNr;
        if ([self.ArchivDaten AufnahmePfadFuerZeile:zeilenNr])
        {
        //   [self resetArchivPlayer:nil];
           [self.ArchivPlayTaste setEnabled:YES];
           [self setArchivPfadFuerAufnahme:[self.ArchivDaten AufnahmePfadFuerZeile:zeilenNr]];
           
           // NSLog(@"ZeilenNotifikationAktion AchivPlayPfad: %@",self.ArchivPlayPfad);
           
           NSString* tempAchivPlayPfad = [self.ArchivPlayPfad stringByAppendingPathExtension:@"m4a"];
           
           NSLog(@"ZeilenNotifikationAktion tempAchivPlayPfad: %@",tempAchivPlayPfad);
           
           NSURL *ArchivURL = [NSURL fileURLWithPath:tempAchivPlayPfad];
           [AVAbspielplayer prepareArchivAufnahmeAnURL:ArchivURL];
           
          // if ([AVAbspielplayer AufnahmeURL])
           {
              double abspieldauer = [AVAbspielplayer duration];
           
              [self.ArchivAufnahmedauerfeld setStringValue:[self zeitStringVonInt:abspieldauer]];
           }
           
           //erfolg=[RecPlayFenster makeFirstResponder:ArchivPlayTaste];
           //[self.PlayTaste setKeyEquivalent:@"\r"];
        }
        else
        {
           [self.ArchivPlayTaste setEnabled:NO];
           [self.UserMarkCheckbox setEnabled:NO];
        }
        
     }
   //NSTableColumn* tempKolonne;
   //tempKolonne=[NamenListe tableColumnWithIdentifier:@"neu"];
   //[[tempKolonne dataCellForRow:selektierteZeile]setTitle:@"Los"];
}

- (void)EnterKeyNotifikationAktion:(NSNotification*)note
{
   //NSLog(@"RecPlay    EnterKeyNotifikationAktion: note: %@",[note object]);
   NSString* Quelle=[[note object]description];
   //NSLog(@"RecPlay EnterKeyNotifikationAktion: Quelle: %@",Quelle);
   //BOOL erfolg;
   
   if ([Quelle isEqualToString:@"ArchivListe"])
	  {
        
        if ([self.ArchivDaten AufnahmePfadFuerZeile:self.ArchivSelektierteZeile])
        {
           [self.ArchivInListeTaste setEnabled:YES];
           [self.ArchivInPlayerTaste setEnabled:NO];
           
           //erfolg=[self.RecPlayFenster makeFirstResponder:self.ArchivInListeTaste];
           [self.ArchivInListeTaste setKeyEquivalent:@"\r"];
           [self.ArchivPlayTaste setEnabled:YES];
           
           //[ArchivQTPlayer setHidden:NO];
           [self startArchivPlayer:nil];
           //			[MoviePlayer start:nil];
           //           [RecordQTKitPlayer gotoBeginning:NULL];
           //           [RecordQTKitPlayer play:nil];
           //NSLog(@"		Quelle: ArchivListe->QTPlayer: Enterkey erfolg: %d",erfolg);
           
        }
        else
        {
           NSBeep();NSBeep();
           [self.ArchivPlayTaste setEnabled:NO];
           [self.ArchivInListeTaste setEnabled:NO];
           [self.ArchivInListeTaste setKeyEquivalent:@""];
        }
        
        
     }
   
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
   
   BOOL umschalten=YES;
   NSLog(@"vor shouldSelectTabViewItem");
   //NSLog(@"vor shouldSelectTabViewItem: UserMarkCheckbox: %d",[self.UserMarkCheckbox state]);
   if ([[tabViewItem label]isEqualToString:@"Archiv"])
	  {
        [self.StartRecordKnopf setEnabled:YES];
        [self.StartPlayKnopf setEnabled:NO];
        [self.StopPlayKnopf setEnabled:NO];
        [self.ForewardKnopf setEnabled:NO];
        [self.RewindKnopf setEnabled:NO];
        [self.BackKnopf setEnabled:NO];
        [self.SichernKnopf setEnabled:NO];
        [self.WeitereAufnahmeKnopf setEnabled:NO];
         [self.RewindKnopf setEnabled:NO];
        [self.ForewardKnopf setEnabled:NO];
        [self.KommentarView setString:@""];
        [self.KommentarView setEditable:NO];

        if ([self.ArchivnamenPop indexOfSelectedItem]==0)
        {
           //self.StartStopKnopf.image=StartRecordImg;
           [self.StartStopString setStringValue:@"START"];
           NSAlert *NamenWarnung = [[NSAlert alloc] init];
           [NamenWarnung addButtonWithTitle:@"Mache ich"];
           //[RecorderWarnung addButtonWithTitle:@"Cancel"];
           [NamenWarnung setMessageText:@"Wer bist du?"];
           [NamenWarnung setInformativeText:@"Du musst einen Namen auswählen, bevor du das Archiv anschauen kannst."];
           [NamenWarnung setAlertStyle:NSWarningAlertStyle];
           
           [NamenWarnung runModal];
           return NO;
           //
           // http://stackoverflow.com/questions/23251464/how-to-create-custom-nsalert-sheet-method-with-the-completion-handler-paradigm
          /*
           [NamenWarnung beginSheetModalForWindow:[[self view]window] completionHandler:^(NSModalResponse result)
            {
               NSNotificationCenter * nc;
               nc=[NSNotificationCenter defaultCenter];
               [nc postNotificationName:@"Pfeiltaste" object:@"NO"];

             }];

           */
           //
        }
        [Utils stopTimeout];
        [AVAbspielplayer invalTimer];
        NSLog(@"TabView: archiv");
        if (self.aktuellAnzAufnahmen &&!([AVRecorder isRecording]))
        {
           [self resetArchivPlayer:nil];
           [self.ArchivnamenPop setEnabled:NO];
           [self.ArchivInPlayerTaste setEnabled:NO];
           [self.ArchivView deselectAll:NULL];
           [self.ArchivPlayTaste setEnabled:NO];
           [self.RecPlayFenster makeFirstResponder:self.ArchivView];
           //AVAbspielplayer=nil;
        }
        else
        {
           umschalten=NO;
        }
        
     }
   
	  
   if ([[tabViewItem label]isEqualToString:@"Recorder"])
   {
      
      NSLog(@"TabView:recorder");
      //NSLog(@"vor shouldSelectTabViewItem: UserMarkCheckbox: %d",[UserMarkCheckbox state]);
      umschalten=YES;
      if (AVAbspielplayer && [AVAbspielplayer isPlaying])
      {
         umschalten=NO;
         
      }
      //!MoviePlayerbusy;
      //NSLog(@"TabView:archiv: umschalten: %d isPlaying: %f",umschalten,[[RecordQTKitPlayer movie]rate]);
      if (umschalten)
      {
         [Utils stopTimeout];
         if (self.ArchivPlayerGeladen)
         {
            [self ArchivZurListe:nil];
            
         }
         
         [self backArchivPlayer:nil];
         
         
         [self resetArchivPlayer:nil];
         [self.ArchivView deselectAll:NULL];
         [self.ArchivnamenPop setEnabled:YES];
         [self.RecPlayFenster makeFirstResponder:self.RecPlayFenster];
         
         //umschalten=YES;
      }
   }
   
   //	  	[Utils startTimeout:TimeoutDelay];
   
   return umschalten;
}

#pragma mark Einstellungen
- (IBAction)showEinstellungen:(id)sender
{
   if (![self checkAdminZugang])
   {
      return;
   }

   
    if(!self.EinstellungenFenster)
	  {
        NSLog(@"EinstellungenFenster error");
        /*
        if ((EinstellungenFenster=[[rEinstellungen alloc]init]))
        {
           [EinstellungenFenster awakeFromNib];
        }
         */
     }

   //[[[self.Testfenster view]window] makeKeyAndOrderFront:nil];
   NSLog(@"EinstellungenFenster: %@",[self.EinstellungenFenster description]);

 
   // erster Aufruf
   NSStoryboardSegue* einstellungensegue = [[NSStoryboardSegue alloc] initWithIdentifier:@"einstellungensegue" source:self destination:self.EinstellungenFenster];
   [self prepareForSegue:einstellungensegue sender:sender];
   [self performSegueWithIdentifier:@"einstellungensegue" sender:sender];

   
   //zweiter Aufruf
   /*
   NSStoryboardSegue* anzeigesegue = [[NSStoryboardSegue alloc] initWithIdentifier:@"einstellungenanzeigefeld" source:self destination:self.EinstellungenFenster];
   [self prepareForSegue:anzeigesegue sender:sender];
   [self performSegueWithIdentifier:@"einstellungenanzeigefeld" sender:sender];
*/
   
   [Utils stopTimeout];
   
   /*
   [EinstellungenFenster showWindow:self];
   [EinstellungenFenster setBewertung:self.BewertungZeigen];
   [EinstellungenFenster setNote:self.NoteZeigen];
   [EinstellungenFenster setMitPasswort:self.mitUserPasswort];
   NSLog(@"showEinstellungen: TimeoutDelay: %d",(int)self.TimeoutDelay);
   [EinstellungenFenster setTimeoutDelay:self.TimeoutDelay];
   */
   
}

- (void)BewertungNotifikationAktion:(NSNotification*)note
{
   //NSLog(@"BewertungNotifikationAktion: note: %@",[note userInfo]);
   NSNumber* CheckboxStatus=[[note userInfo]objectForKey:@"Status"];
   int status=(int)[CheckboxStatus floatValue];
   //NSLog(@"BewertungNotifikationAktion: %@  Status: %d",[CheckboxStatus description],status);
   self.BewertungZeigen=(status==1);
   [[NSUserDefaults standardUserDefaults]setInteger: status forKey: RPBewertungKey];
   
   
}
- (void)NotenNotifikationAktion:(NSNotification*)note
{
   //NSLog(@"BewertungNotifikationAktion: note: %@",[note userInfo]);
   NSNumber* CheckboxStatus=[[note userInfo]objectForKey:@"Status"];
   int status=(int)[CheckboxStatus floatValue];
   NSLog(@"NotenNotifikationAktion: %@  Status: %d",[CheckboxStatus description],status);
   self.NoteZeigen=(status==1);
   [[NSUserDefaults standardUserDefaults]setInteger: status forKey: RPNoteKey];
   
}
- (void)StartStatusNotifikationAktion:(NSNotification*)note
{
   NSNumber* mitPasswort=[[note userInfo]objectForKey:@"mituserpasswort"];
   self.mitUserPasswort=[mitPasswort intValue];
   [self.PListDic setObject:mitPasswort forKey:@"mituserpasswort"];

   NSLog(@"StartStatusNotifikationAktion	mitPasswort: %@",[mitPasswort description]);
   if (self.mitUserPasswort)
   {
      [self.PWFeld setStringValue:@"Mit Passwort"];
   }
   else
   {
      [self.PWFeld setStringValue:@"Ohne Passwort"];
   }
   self.TimeoutDelay=[[[note userInfo]objectForKey:@"timeoutdelay"]intValue];
   self.BewertungZeigen=[[[note userInfo]objectForKey:@"bewertungstatus"]intValue];
   [self.PListDic setObject:[NSNumber numberWithInt:self.BewertungZeigen] forKey:RPBewertungKey];
   self.NoteZeigen=[[[note userInfo]objectForKey:@"notenstatus"]intValue];
   [self.PListDic setObject:[NSNumber numberWithInt:self.NoteZeigen] forKey:RPNoteKey];
   
   self.TimeoutDelay = [[[note userInfo]objectForKey:@"timeoutdelay"]intValue];
   [self.PListDic setObject:[NSNumber numberWithInt:self.TimeoutDelay] forKey:@"timeoutdelay"];
   NSLog(@"TimeoutDelay: %f",self.TimeoutDelay);
   [self.TimeoutFeld setIntValue:self.TimeoutDelay];
   //[Utils startTimeout:TimeoutDelay];
   //[Utils stopTimeout];
   //[ProjektArray setArray:[Utils ProjektArrayAusPListAnPfad:LeseboxPfad]];
   
   int ProjektIndex=[[self.ProjektArray valueForKey:@"projekt"] indexOfObject:[self.ProjektPfad lastPathComponent]];
   if (ProjektIndex>=0)
   {
      NSMutableDictionary* tempProjektDic=(NSMutableDictionary*)[self.ProjektArray objectAtIndex:ProjektIndex];
      NSLog(@"StatusnotAktion: tempProjektDic: %@",[tempProjektDic description]);
      [tempProjektDic setObject:[[note userInfo] objectForKey:@"mituserpasswort"] forKey:@"mituserpw"];
      //NSLog(@"ProjektStartAktion: tempProjektDic: %@",[tempProjektDic description]);
      
   }
   
   
}
- (void) Umgebung:(NSNotification*)note
{
   NSNumber* UmgebungNumber=[[note userInfo]objectForKey:@"umgebung"];
   self.Umgebung=(int)[UmgebungNumber floatValue];
}




- (IBAction)showKommentar:(id)sender
{
   if (![self checkAdminZugang])
   {
      return;
   }
if (!self.KommentarFenster)
{
   self.KommentarFenster = [[rKommentar alloc]init];
   
}
   [self.KommentarFenster showWindow:self];
    [self.KommentarFenster setKommentarMitProjektArray:self.ProjektArray mitLeser:self.Leser anPfad:self.ProjektPfad];


}


- (IBAction)showClean:(id)sender
{
   if (![self checkAdminZugang])
   {
      return;
   }

   //NSLog(@"RecPlayController	showClean: sender tag: %d",[sender tag]);
   // [AdminPlayer showCleanFenster:1];
   // [AdminPlayer setCleanTask:0];
}

- (IBAction)showExport:(id)sender
{
   if (![self checkAdminZugang])
   {
      return;
   }
   //NSLog(@"RecPlayController	showExport: sender tag: %d",[sender tag]);
   // [AdminPlayer showCleanFenster:2];
   // [AdminPlayer setCleanTask:1];
}

- (void)MarkierungenWeg:(id)sender
{
   
   // [AdminPlayer MarkierungenEntfernen];
}


- (IBAction)AlleMarkierungenWeg:(id)sender
{
   //  [AdminPlayer AlleMarkierungenEntfernen];
}






- (void)neuesProjektVomStartAktion:(NSNotification*)note
{
   [Utils stopTimeout];
   
   [self showProjektListe:nil];
   return;
   
   //Note von Projektliste über neues Projekt: reportNeuesProjekt
   BOOL neuesProjektOK=NO;
   NSMutableDictionary* tempNeuesProjektDic=[[[note userInfo] objectForKey:@"neuesprojektdic"]mutableCopy];
   NSLog(@"ViewController neuesProjektVomStartAktion: userInfo: %@",[[note userInfo] description]);
   
   //NSLog(@"RPC neuesProjektAktion: tempNeuesProjektDic: %@",[tempNeuesProjektDic description]);
   //NSString* neuesProjektName=[tempNeuesProjektDic objectForKey:projekt];
   NSString* neuesProjektName=[tempNeuesProjektDic objectForKey:@"projekt"];
   NSMutableDictionary* neuesProjektDic;
   if (neuesProjektName)
   {
      if ([neuesProjektName length])
      {
         NSString* tempProjektPfad=[self.ArchivPfad stringByAppendingPathComponent:neuesProjektName];
         NSLog(@"neuesProjektAktion tempProjektPfad: %@",tempProjektPfad);
         //NSLog(@"ProjektArray ist da: %d",!(ProjektArray==NULL));
         if (self.ProjektArray&&[self.ProjektArray count])
         {
            
            [Utils setUProjektArray:self.ProjektArray];//Bei Wahl von "Neues Projekt" beim Projektstart ist UProjektArray in Utils noch leer
         }
         else
         {
            
         }
         
         if ([Utils ProjektOrdnerEinrichtenAnPfad:tempProjektPfad])
         {
            NSLog(@"ProjektOrdnerEinrichtenAnPfad: ist OK");
            
            neuesProjektDic=[NSMutableDictionary dictionaryWithObject:neuesProjektName forKey:@"projekt"];
            [neuesProjektDic setObject:[tempProjektPfad copy] forKey:@"projektpfad"];
            [neuesProjektDic setObject: [NSNumber numberWithInt:1] forKey:@"ok"];//Projekt ist aktiviert
            [neuesProjektDic setObject:heuteDatumString forKey:@"sessiondatum"];
            
            
            
            NSNumber* tempFix=[tempNeuesProjektDic objectForKey:@"fix"];//Titel fix?
            if (tempFix)
            {
               [neuesProjektDic setObject: tempFix forKey:@"fix"];
               //			[self showTitelListe:NULL];
            }
            else
            {
               [neuesProjektDic setObject: [NSNumber numberWithInt:0] forKey:@"fix"];
            }
            //NSLog(@"neuesProjektAktion neuesProjektDic: %@",[neuesProjektDic description]);
            
            NSNumber* tempMitUserPW=[tempNeuesProjektDic objectForKey:@"mituserpw"];//Mit Userpasswort?
            if (tempMitUserPW)
            {
               [neuesProjektDic setObject: tempMitUserPW forKey:@"mituserpw"];
               //			[self showTitelListe:NULL];
            }
            else
            {
               [neuesProjektDic setObject: [NSNumber numberWithInt:0] forKey:@"mituserpw"];
            }
            //NSLog(@"neuesProjektAktion neuesProjektDic: %@",[neuesProjektDic description]);
            
            [self.ProjektArray addObject:neuesProjektDic];
            
            neuesProjektOK=YES;
            NSLog(@"neuesProjektAktion neuesProjektOK: YES");
         }
         else
         {
            //**
            //Kein Projektordner eingerichtet
            NSLog(@"neuesProjektAktion neuesProjektOK: NO kein Pojekt 	ProjektPanel resetPanel");
            [ProjektPanel resetPanel];
            neuesProjektOK=NO;
         }
         
      }
   }
   
   if (neuesProjektOK)
   {
      [self setProjektMenu];
      [ProjektPanel setNeuesProjekt];
      [ProjektPanel setProjektListeArray:self.ProjektArray inProjekt:neuesProjektName];
      NSLog(@"\n\n                    +++++   neuesProjektAktion Schluss: ProjektArray: %@\n",[self.ProjektArray description]);
      
      [self saveNeuesProjekt:neuesProjektDic];
      //*      [AdminPlayer setAdminProjektArray:ProjektArray];
      //29.1.		[self savePListAktion:nil];
      
      
   }//if NeueProjektListeOK
   else
   {
      //NSLog(@"*neuesProjektListeAktion Kein neues Projekt %@",[ProjektArray description]);
      [ProjektPanel resetPanel];
   }
   
   //8.11.06	[self savePListAktion:nil];
   
   //[[ProjektPanel window]close];
   
   
}

- (void)ProjektMenuAktion:(NSNotification*)note
{
   //NSLog(@"\n\n************ ProjektMenuAktion : \nNeues Projekt: %@",[[note userInfo] objectForKey:@"projekt"]);
   NSString* tempProjektString=[NSString stringWithString:[[note userInfo] objectForKey:@"projekt"]];
   if (tempProjektString)
   {
      
      self.ProjektPfad=(NSMutableString*)[self.ArchivPfad stringByAppendingPathComponent:[[note userInfo] objectForKey:@"projekt"]];
      [self setProjektMenu];
   }
}



- (void)anderesProjektAktion:(NSNotification*)note
{
   //NSLog(@"\nanderesProjektAktion start: \n%@",[[note userInfo] objectForKey:@"projekt"]);
   //NSLog(@"\nanderesProjektAktion start: %@",[[note userInfo] description]);
   [Utils stopTimeout];
   
   NSArray* tempProjektArray=[[note userInfo] objectForKey:@"projektarray"];
   //NSLog(@"anderesProjektAktion tempProjektArray: %@",[tempProjektArray description]);
   if (tempProjektArray&&[tempProjektArray count])
   {
      NSLog(@"tempProjektarray ist OK");
      [self.ProjektArray setArray:[tempProjektArray mutableCopy]];//Array mit allen Aenderungen aus ProjektlistePanel
      //NSLog(@"anderesProjektAktion Projektarray laden: %@",[ProjektArray description]);
      [self saveNeuenProjektArray:tempProjektArray];
   }
   
   NSString* anderesProjekt=[[note userInfo] objectForKey:@"projekt"];
   if ([anderesProjekt length])
   {
      //Titelliste pruefen
      
      [self anderesProjektMitTitel:anderesProjekt];
   }
   else
   {
      
   }
   
}

- (void)ProjektEntfernenAktion:(NSNotification*)note
{
   NSLog(@"*********ProjektEntfernenAktion start: %@",[[note userInfo] objectForKey:@"projekt"]);
   NSString* clearProjekt=[[note userInfo] objectForKey:@"projekt"];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   if ([clearProjekt length])
   {
      NSString* EntfernenPfad=[self.ArchivPfad stringByAppendingPathComponent:clearProjekt];
      if (![Filemanager fileExistsAtPath:EntfernenPfad ])
      {
         NSLog(@"Zu entfernender Ordner nicht vorhanden");
         return;
      }
      int wohin=[[[note userInfo] objectForKey:@"wohin"]intValue];
      
      NSString*ZielPfad;
      switch (wohin)
      {
         case 0://>Papierkorb
         {
            NSLog(@"*ProjektEntfernenAktion: Papierkorb: EntfernenPfad: %@",EntfernenPfad);
            [self fileInPapierkorb:EntfernenPfad];
            NSLog(@"*ProjektEntfernenAktion: nach inPapierkorbMitPfad ");
            [self updateProjektArray];
            NSLog(@"*ProjektEntfernenAktion: nach updateProjektArray");
         }break;
            
         case 1: //Magazin
         {
            NSLog(@"*ProjektEntfernenAktion: Magazin: EntfernenPfad: %@",EntfernenPfad);
            NSString* MagazinPfad=[self.LeseboxPfad stringByAppendingPathComponent:@"Magazin"];
            //NSLog(@"*ProjektEntfernenAktion: Magazin: MagazinPfad: %@",MagazinPfad);
            BOOL istOrdner=NO;
            
            
            
            
            
            
            if (!([Filemanager fileExistsAtPath:MagazinPfad isDirectory:&istOrdner]&&istOrdner))
            {
               BOOL createMagazinOK=[Filemanager createDirectoryAtPath:MagazinPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
               NSLog(@"createMagazinOK: %d",createMagazinOK);
               if (!createMagazinOK)
               {
                  NSAlert *Warnung = [[NSAlert alloc] init];
                  [Warnung addButtonWithTitle:@"OK"];
                  [Warnung setMessageText:@"Kein Ordner 'Magazin'"];
                  
                  NSString* s1=@"Der Ordner 'Magazin' konnte nicht angelegt werden.";
                  
                  NSString* s2=@"Ordner für Projekt manuell entfernen";
                  NSString* s3=[NSString stringWithFormat:s2,clearProjekt];
                  NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s1,s3];
                  [Warnung setInformativeText:InformationString];
                  [Warnung setAlertStyle:NSWarningAlertStyle];
                  
                  //[Warnung setIcon:RPImage];
                  int antwort=[Warnung runModal];
                  break;
               }
            }
            ZielPfad=[[MagazinPfad stringByAppendingPathComponent:clearProjekt]stringByAppendingString:@" alt"];
            //NSLog(@"ZielPfad: %@",ZielPfad);
            if ([Filemanager fileExistsAtPath:ZielPfad])
            {
               [Filemanager removeItemAtURL:[NSURL fileURLWithPath:ZielPfad] error:nil];
            }
            BOOL MagazinOK=[Filemanager moveItemAtURL:[NSURL fileURLWithPath:EntfernenPfad]  toURL:[NSURL fileURLWithPath:ZielPfad] error:nil];
            if (MagazinOK)
            {
               BOOL ProjektOK=[self ProjektListeValidAnPfad:self.ArchivPfad];
            }
            //NSLog(@"MagazinOK: %d",MagazinOK);
            
            
         }break;
         case 2://ex
         {
            //NSLog(@"*ProjektEntfernenAktion: ex: %@",EntfernenPfad);
            if ([Filemanager fileExistsAtPath:EntfernenPfad])
            {
               BOOL ExOK=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:EntfernenPfad] error:nil];
               if (ExOK)
               {
                  BOOL ProjektOK=[self ProjektListeValidAnPfad:self.ArchivPfad];
               }
               
            }
         }break;
         default:
         {
            return;
         }break;
      }//switch
      //NSLog(@"ProjektEntfernen ArchivPfad: %@  \nProjektArray: %@",ArchivPfad,[ProjektArray description]);
      
      
      [self setProjektMenu];
      [self.RecorderMenu setSubmenu:[self.ProjektMenu copy] forItem:[self.RecorderMenu itemWithTag:kRecorderProjektWahlenTag]];
      
      //*      [AdminPlayer setProjektPopMenu:ProjektArray];
      
   }
   
}

- (NSInteger) fileInPapierkorb:(NSString*) derFilepfad
{
   NSInteger tag;
   BOOL succeeded;
   NSString* HomeDir=@"";// = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
   NSFileManager* Filemanager=[NSFileManager defaultManager];
   //NSLog(@"fileInPapierkorb:NSHomeDirectory %@",NSHomeDirectory());
   
   NSMutableArray* PfadKomponenten=(NSMutableArray*)[derFilepfad pathComponents] ;
   int index=0;
   while (index<[PfadKomponenten count] && ![[PfadKomponenten objectAtIndex:index]isEqualToString:@"Documents"])
	  {
        NSString* tempString=[PfadKomponenten objectAtIndex:index];
        HomeDir=[HomeDir stringByAppendingPathComponent:tempString];
        index++;
     }
   if ([HomeDir isEqualToString:NSHomeDirectory()])
	  {
        NSString* trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
        trashDir=[trashDir stringByAppendingPathComponent:@".Trash"];
        
        NSString* sourceDir=[derFilepfad stringByDeletingLastPathComponent];
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        
        NSArray * vols=[workspace mountedLocalVolumePaths];
        NSLog(@"fileInPapierkorb volumes: %@   sourceDir:%@ trashDir: %@",[vols description],sourceDir, trashDir);
        
        NSArray *files = [NSArray arrayWithObject:[derFilepfad lastPathComponent]];
        succeeded = [workspace performFileOperation:NSWorkspaceRecycleOperation
                                             source:sourceDir destination:trashDir
                                              files:files tag:&tag];
        NSLog(@"fileInPapierkorb tag: %ld succeeded: %d",(long)tag, succeeded);
        return tag;//0 ist OK
     }
   else
	  {
        
        NSString* sourceDir=derFilepfad;
        int removeIt=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:sourceDir] error:nil];
        NSLog(@"removePath: removeIt: %d",removeIt);
        return 0;
        
     }
}

- (IBAction)setNeuesProjekt:(id)sender
{
   NSLog(@"setNeuesProjekt");
}



- (void)windowWillClose:(NSNotification *)notification
{
   NSLog(@"windowWillClose: %@",notification);
}



- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
   
   long anzahl=0;
   /*
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
    */
   return anzahl;
}

- (void)setData: (NSDictionary *)someData forRow: (int)rowIndex
{
   /*
    [aRow addEntriesFromDictionary: dataDic];
    
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
    
    */
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(long)rowIndex
{
   id dieZeile, derWert;
   //NSLog(@"objectValueForTableColumn tag: %d",[aTableView tag]);
   /*
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
    */
   
   return derWert;
}


@end

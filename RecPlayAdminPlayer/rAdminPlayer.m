//
//  AdminPlayer.m
//  RecPlayC
//
//  Created by Ruedi Heimlicher on 14.10.04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "rAdminPlayer.h"

typedef NS_ENUM(NSInteger, A)
{
Datum = 2,
Bewertung,
Noten,
kUserMark,
kAdminMark,
Kommentar
};

typedef NS_ENUM(NSInteger,B)
{
   lastKommentarOption= 0,
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

/*
BOOL AdminSaved=NO;
NSString* alle=@"alle";
NSString* name=@"name";
NSString* titel=@"titel";
NSString* anzahl=@"anzahl";
NSString* auswahl=@"auswahl";
NSString* leser=@"leser";
NSString* anzleser=@"anzleser";
*/
//NSString*	RPExportdatenKey=	@"RPExportdaten";
//NSString*	RPExportformatKey=	@"RPExportformat";

extern NSString* projekt;//=@"projekt";
//extern NSString* projektpfad;//=@"projektpfad";
extern NSString* archivpfad;//=@"archivpfad";
extern NSString* leseboxpfad;//=@"leseboxpfad";
//extern NSString* projektarray;//=@"projektarray";
//extern NSString* OK;//=@"OK";

const int StartmitRecPlay=0;
const int StartmitAdmin=1;
const int StartmitDialog=2;

const short kAdminUmgebung=1;
const short kRecPlayUmgebung=0;



@implementation rAdminPlayer




- (id)init
{
   NSLog(@"AdminPlayer init");
   self=[super initWithWindowNibName:@"RPAdminPlayer"];
	//AdminDaten = [[rAdminDS alloc] initWithRowCount: 10];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	
	RPExportdaten=[NSMutableData dataWithCapacity:0];
	ExportFormatString=[NSMutableString stringWithCapacity:0];
	[ExportFormatString setString:@"AIFF"];
   OptionAString=[[NSString alloc]init];
   OptionBString=[[NSString alloc]init];
	[nc addObserver:self
		   selector:@selector(AdminKeyNotifikationAktion:)
			   name:@"Pfeiltaste"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(AdminZeilenNotifikationAktion:)
			   name:@"AdminselektierteZeile"
			 object:nil];

	
	[nc addObserver:self
		   selector:@selector(AdminTabNotifikationAktion:)
			   name:@"AdminChangeTab"
			 object:nil];

	[nc addObserver:self
		   selector:@selector(AdminEnterKeyNotifikationAktion:)
			   name:@"AdminEnterKey"
			 object:nil];
/*
	[nc addObserver:self
		   selector:@selector(UmgebungAktion:)
			   name:@"Umgebung"
			 object:nil];
*/
	[nc addObserver:self
		   selector:@selector(DidChangeNotificationAktion:)
			   name:@"NSTextDidChangeNotification"
			 object:AdminKommentarView];

	[nc addObserver:self
		   selector:@selector(KommentarNotificationAktion:)
			   name:@"KommentarOption"
			 object:nil];


	[nc addObserver:self
		   selector:@selector(CleanOptionNotificationAktion:)
			   name:@"CleanOption"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(CleanViewNotificationAktion:)
			   name:@"CleanView"
			 object:nil];

	[nc addObserver:self
		   selector:@selector(ClearNotificationAktion:)//Taste "Löschen"
			   name:@"Clear"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(ExportNotificationAktion:)//Taste "Exportieren"
			   name:@"Export"
			 object:nil];
/*
	[nc addObserver:self
		   selector:@selector(ExportFormatDialogAktion:)//Taste "Optionen"
			   name:@"ExportFormatDialog"
			 object:nil];
*/
	[nc addObserver:self
		   selector:@selector(MarkierungNotificationAktion:)//Fenster Markierung
			   name:@"MarkierungOption"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(AdminProjektListeAktion:)
			   name:@"ProjektWahl"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(anderesAdminProjektAktion:)
			   name:@"anderesProjekt"
			 object:nil];
			 
	[nc addObserver:self
		   selector:@selector(ProjektArrayNotificationAktion:)
			   name:@"ProjektArray"
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
		   selector:@selector(SelectionDidChangeAktion:)
			   name:@"NSTableViewSelectionDidChangeNotification"
			 object:nil];

	[nc addObserver:self
		   selector:@selector(ButtonWillPopUpAktion:)
			   name:@"NSPopUpButtonWillPopUpNotification"
			 object:nil];

	[nc addObserver:self
		   selector:@selector(ComboBoxAktion:)
			   name:@"NSComboBoxSelectionDidChangeNotification"
			 object:nil];

 
   [nc addObserver:self
          selector:@selector(AbspielPosAktion:)
              name:@"abspielpos"
            object:nil];

   [nc addObserver:self
          selector:@selector(MarkCheckboxAktion:)
              name:@"markcheckbox"
            object:nil];

	
   NSMutableDictionary * defaultWerte=[[NSMutableDictionary alloc]initWithCapacity:0];
   
   [defaultWerte setObject:RPExportdaten  forKey:@"RPExportdaten"];
   
   [defaultWerte setObject:ExportFormatString forKey:@"RPExportformat"];
   
   [[NSUserDefaults standardUserDefaults] registerDefaults: defaultWerte];

   //NSLog(@"INIT: ExportFormatString; %@",ExportFormatString);
	selektierteZeile=-1;
	AdminLeseboxPfad=@"";
	AuswahlOption=0;
	AbsatzOption=0;
	AnzahlOption=2;
	ProjektNamenOption=0;
	ProjektAuswahlOption=0;
	
	selektierteAufnahmenTableZeile=-1;
	Textchanged=NO;
   NSLog(@"AdminPlayer end");
	return self;
	
}

- (void) awakeFromNib
{
   
   NSLog(@"AdminPlayer awake start");
   [NamenListe reloadData];
   NSColor * TitelFarbe=[NSColor whiteColor];
   NSFont* TitelFont;
   TitelFont=[NSFont fontWithName:@"Helvetica" size: 28];
   [TitelString setFont:TitelFont];
   [TitelString setTextColor:TitelFarbe];
   [ModusString setFont:TitelFont];
   [ModusString setTextColor:TitelFarbe];
   [AdminFenster setDelegate:self];
   //NSLog(@"FertigTaste int:%d ",[FertigTaste keyEquivalent]);
   //char * ret=[[BackTaste keyEquivalent]UTF8String];
   //NSLog(@"BackTaste string:%@ ",[[BackTaste keyEquivalent]UTF8String]);
   //[FertigTaste setKeyEquivalent:@""];
   //[[self window] setBackgroundColor:[NSColor blueColor]];
   //[[PlayerBox contentView]setBackgroundColor:[NSColor blueColor]];
   //[BackTaste setKeyEquivalent:@"\r"];
   OptionAString=[NSString string];
   OptionBString=[NSString string];
   AdminProjektArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   // von viewdidload
   heuteDatumString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];//  12.09.2015 19:20:26
   heuteTagDesJahres = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];

   
   
   // end von viewdidload
   RPExportdaten=[[NSUserDefaults standardUserDefaults] objectForKey:@"RPExportdaten"];
   //NSLog(@"awake: RPExportdaten; %d",[RPExportdaten description]);
   //NSLog(@"awake: RPExportdaten; %d",[RPExportdaten length]);
   ExportFormatString=(NSMutableString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"RPExportformat"];
   
   //NSLog(@"awake: ExportFormatString; %@",ExportFormatString);
   
   //NSColor * FensterFarbe=[NSColor windowBackgroundColor];
   //   NSColor* FensterFarbe=[NSColor colorWithDeviceRed:100.0/255 green:200.0/255 blue:150.0/255 alpha:1.0];
   //	NSColor* FensterFarbe=[NSColor colorWithDeviceRed:94.0/255 green:249.0/255 blue:94.0/255 alpha:1.0];
  // NSColor* FensterFarbe=[NSColor colorWithDeviceRed: 150.0/255 green:249.0/255 blue:150.0/255 alpha:1.0];
   [[self window] display];
   AufnahmenDicArray=[[NSMutableArray alloc]initWithCapacity:0];
   [[[AufnahmenTable tableColumnWithIdentifier:@"usermark"]dataCell] setEnabled:NO];
   
   if (!(AVAbspielplayer))
   {
      AVAbspielplayer = [[rAVPlayer alloc]init];
   }
   if (AVAbspielplayer)
   {
      AVAbspielplayer.PlayerFenster = [self  window];
   }
   
   RPExportdaten=[NSMutableData dataWithCapacity:0];
   ExportFormatString=[NSMutableString stringWithCapacity:0];
   [ExportFormatString setString:@"AIFF"];

   
   [NamenListe setToolTip:@"Liste der Leser im aktuellen Projekt.\nKann im Menue 'Admin->NamenListe bearbeiten' veraendert werden."];
   [ExportierenTaste setToolTip:@"Exportieren der aktuellen Aufnahme in verschiedenen Formaten."];
   [LoeschenTaste setToolTip:@"Aktuelle Aufnahme mit verschiedenen Optionen entfernen."];
   //[AdminMarkCheckbox setToolTip:@"Aktuelle Aufnahme markieren"];
   [LehrerMarkCheckbox setToolTip:@"Aktuelle Aufnahme markieren"];
   [UserMarkCheckbox setToolTip:@"Zeigt, ob der Leser die aktuelle Aufnahme markiert hat."];
   [AdminKommentarView setToolTip:@"Anmerkungen für den Leser schreiben"];
   [AdminTitelfeld setToolTip:@"Titel der aktuellen Aufnahme"];
   [AdminDatumfeld setToolTip:@"Name des Lesers der aktuellen Aufnahme"];
   [ProjektPop setToolTip:NSLocalizedString(@"",@"")];
   [AbspieldauerFeld setToolTip:@"Dauer der aktuellen Aufnahme"];
   [AdminDatumfeld setToolTip:@"Aufnahmedatum der aktuellen Aufnahme."];
   [zurListeTaste setToolTip:@"Aktuelle Aufnahme aus dem Player entfernen."];
   [PlayTaste setToolTip:@"Ausgewählte Aufnahme in den Player verschieben."];
   [AdminNamenfeld setToolTip:@"Leser der aktuellen Aufnahme."];
   [ProjektPop setToolTip:@"Liste der aktiven Projekte.\nKann im Menü 'Admin->Projektliste bearbeiten' bearbeitet werden."];
   [AufnahmenTable setToolTip:@"Liste der Aufnahmen des ausgewählten Lesers."];
   [LesernamenPop  setToolTip:@"Einen Leser im aktuellen Projekt auswählen."];
   [DeleteTaste setToolTip:@"Ausgewählte Aufnahme an verschiedene Orte verschieben."];
   [MarkAuswahlOption setToolTip:@"Optionen für die Anzeige der Aufnahmen in der Liste."];
   //[  setToolTip:NSLocalizedString(@"",@"")];
   //[  setToolTip:NSLocalizedString(@"",@"")];
   //[[[self.NamenListe tableColumnWithIdentifier:@"anz"]headerCell]contentView setToolTip:NSLocalizedString(@"Number of records of the reader",@"Anzahl Aufnahmen des Lesers")];
   [UserMarkCheckbox setToolTip:@"Vom Leser gesetzte Marke."];
   [AufnahmenTab setDelegate:self];
   // [[self view]addSubview:self.MarkCheckbox ];
   [LehrerMarkCheckbox setEnabled:YES];
   [AdminMarkCheckbox setEnabled:YES];
   //NSLog(@"AdminPlayer awake end \nAdminMarkCheckbox: %@ \nUserMarkCheckbox: %@\nsubviews: %@", [LehrerMarkCheckbox description],[UserMarkCheckbox description], [[[self view]subviews]description]);
   
   [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(MarkCheckboxAktion:)
              name:@"markcheckbox"
            object:nil];
   
  // [AufnahmenTable setDoubleAction:DoppelSelektor];
   //NSLog(@"setAdminplayer AufnahmenDicArray: %@",[AufnahmenDicArray description]);

   [AufnahmenTable setDelegate:self];
   [AufnahmenTable setDataSource:self];
   NSLog(@"farbe");
  // NSColor* FensterFarbe=[NSColor colorWithDeviceRed: 194.0/255 green:249.0/255 blue:194.0/255 alpha:1.0];
   NSColor* FensterFarbe=[NSColor colorWithDeviceRed: 194.0/255 green:249.0/255 blue:220.0/255 alpha:1.0];

//   FensterFarbe=[NSColor colorWithDeviceRed: 150.0/255 green:249.0/255 blue:150.0/255 alpha:1.0];
   [[self window ] setBackgroundColor:FensterFarbe];

}

- (BOOL)setHomeAdminLeseboxPfad:(id)sender
{
	BOOL antwort=NO;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSString* tempLeseboxPfad=[[[NSString stringWithString:NSHomeDirectory()]
								stringByAppendingPathComponent:@"Documents"]
								stringByAppendingPathComponent:@"Lesebox"];
	if ([Filemanager fileExistsAtPath:tempLeseboxPfad])
	  {
		AdminLeseboxPfad=[NSMutableString stringWithString:tempLeseboxPfad];
		antwort=YES;
	  }
	//NSLog(@"setHomeAdminLeseboxPfad antwort: %d",antwort);
	return antwort;
}

- (BOOL)setNetworkAdminLeseboxPfad:(id)sender
{
	BOOL antwort=NO;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSOpenPanel * AdminLeseboxDialog=[NSOpenPanel openPanel];
	[AdminLeseboxDialog setCanChooseDirectories:YES];
	[AdminLeseboxDialog setCanChooseFiles:NO];
	[AdminLeseboxDialog setAllowsMultipleSelection:NO];
	[AdminLeseboxDialog setMessage:@"Auf welchem Computer ist die Lesebox zu finden?"];
	[AdminLeseboxDialog setCanCreateDirectories:NO];
	NSString* tempLeseboxPfad;
   //NSURL* tempLeseboxURL;
	long AdminLeseboxHit=0;
	{
		//LeseboxHit=[LeseboxDialog runModalForDirectory:DocumentsPfad file:@"Lesebox" types:nil];
		AdminLeseboxHit=[AdminLeseboxDialog runModal] ;//]ForDirectory:NSHomeDirectory() file:@"Volumes" types:nil];
      [AdminLeseboxDialog setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
   }
	if (AdminLeseboxHit==NSModalResponseOK)
	  {
        
		tempLeseboxPfad=[[AdminLeseboxDialog URL]path ]; //"home"
		tempLeseboxPfad=[tempLeseboxPfad stringByAppendingPathComponent:@"Documents"];
		NSString* lb=@"Lesebox";
		tempLeseboxPfad=[tempLeseboxPfad stringByAppendingPathComponent:lb];
		
		if ([Filemanager fileExistsAtPath:tempLeseboxPfad ])
		  {
			NSLog(@"setNetworkAdminLeseboxPfad: AdminLeseboxPfad da: %@",tempLeseboxPfad);
			AdminLeseboxPfad=[NSMutableString stringWithString:tempLeseboxPfad];

			antwort=YES;
		  }
	
	  }
	else
	  {
		return NO;
	  }
	
	return antwort;
}

- (void) setAdminPlayer:(NSString*)derLeseboxPfad inProjekt:(NSString*)dasProjekt
{
	NSLog(@"setAdminPlayer LeseboxPfad: %@ Projekt: %@",derLeseboxPfad,dasProjekt);
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	[AdminProjektFeld setStringValue:dasProjekt];
	AdminLeseboxPfad=[NSString stringWithString:derLeseboxPfad];
	AdminArchivPfad=[NSString stringWithString:[derLeseboxPfad stringByAppendingPathComponent:@"Archiv"]];
	
	
	AdminProjektPfad=[AdminArchivPfad stringByAppendingPathComponent:dasProjekt];//Pfad des Archiv-Ordners
	
	NSNotificationCenter * nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:AdminProjektPfad forKey:@"projektpfad"];
	[nc postNotificationName:@"Utils" object:self userInfo:NotificationDic];
	
   //NSLog(@"setAdminPlayer AdminProjektPfad: %@",AdminProjektPfad);
	AdminProjektNamenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:AdminProjektPfad error:NULL]];
	[AdminProjektNamenArray removeObject:@".DS_Store"];
	AnzLeser=[AdminProjektNamenArray count];											//Anzahl Leser
	if (AnzLeser==0)
	{
		
		NSAlert *Warnung = [[NSAlert alloc] init];
		[Warnung addButtonWithTitle:@"OK"];
		//[Warnung addButtonWithTitle:@"Cancel"];
		[Warnung setMessageText:@"Leerer Projektordner"];
		[Warnung setInformativeText:@"Es hat noch keine Projekte im Projektordner. "];
		[Warnung setAlertStyle:NSWarningAlertStyle];
      [Warnung beginSheetModalForWindow:[self window]
                      completionHandler:nil];
		NSLog(@"!!! Es hat noch keine Projekte im Projektordner");
		
		[self AdminBeenden];
		return;
	}
	//NSLog(@"setAdminPlayer AdminProjektNamenArray: %@", AdminProjektNamenArray);
	
	if ([[AdminProjektNamenArray objectAtIndex:0] hasPrefix:@".DS"])					//Unsichtbare Ordner entfernen
	{
		[AdminProjektNamenArray removeObjectAtIndex:0];
		AnzLeser--;
	}
	
	//NSString*LeserNamenListe=[AdminProjektNamenArray description];
	//[LesernamenPop addItemsWithTitles:AdminProjektNamenArray];
	//NSLog(@"setAdminPlayer LeserNamenListe sauber: %@", LeserNamenListe);
	[AbspieldauerFeld setSelectable:NO];
	//*****************
	AdminDaten = [[rAdminDS alloc] initWithRowCount: AnzLeser];
	comboBox = [[NSComboBoxCell alloc] init];
	[comboBox setCompletes: YES];
	[comboBox setEditable: YES];    
	[comboBox setUsesDataSource: NO];
	
	//[comboBox addItemsWithObjectValues: 
	//[NSArray arrayWithObjects: @"integer", @"string", @"date-time", @"blob", nil]];
	NSSize PopButtonSize;
	PopButtonSize.height=20;
	
	AufnahmenPop=[[NSPopUpButtonCell alloc] init];
	[AufnahmenPop setImagePosition:NSImageRight];
	[AufnahmenPop synchronizeTitleAndSelectedItem];
	NSFont* Popfont;
	Popfont=[NSFont fontWithName:@"Helvetica" size: 10];
	[AufnahmenPop setFont:Popfont];
	NSFont* Tablefont;
	Tablefont=[NSFont fontWithName:@"Helvetica" size: 12];
	
	
	
	SEL PopSelektor;
	PopSelektor=@selector(AufnahmeSetzen:);
	[AufnahmenPop setAction:PopSelektor];
	//[AufnahmenPop insertItemWithTitle:@"Neuste Aufnahme" atIndex:0];
	[AufnahmenPop setPullsDown:NO];
   
	//[AufnahmenPop selectItemAtIndex:0];
	//[self.NamenListe setEditable:YES];
	[[NamenListe tableColumnWithIdentifier: @"aufnahmen"]setEditable:NO];
	//[[NamenListe tableColumnWithIdentifier: @"aufnahmen"] setDelegate:self];
	[[NamenListe tableColumnWithIdentifier: @"aufnahmen"] setDataCell: (NSCell*)AufnahmenPop];
	[NamenListe setRowHeight: PopButtonSize.height];
	[[NamenListe tableColumnWithIdentifier: @"namen"]setEditable:NO];
	[[[NamenListe tableColumnWithIdentifier: @"namen"]dataCell]setFont:Tablefont];
	[[[NamenListe tableColumnWithIdentifier: @"anz"]dataCell]setFont:Tablefont];
	int i;
	NSDictionary* NamenDic;
	NSDictionary* AnzDic;
//	NSDictionary* MarkDic;
	NSString* tempLeserPfad;
	NSMutableArray* tempAufnahmenliste;
	double tempAnzAufnahmen;
	NSMutableArray* tempAnzAufnahmenListe;
	tempAnzAufnahmenListe=[[NSMutableArray alloc]initWithCapacity:0];
	NSMutableArray* AufnahmeFilesArray;
	
	[LesernamenPop removeAllItems];
	//[LesernamenPop insertItemWithTitle:@"Namen waehlen" atIndex:0];
	//NSLog(@"\nAdminProjektNamenArray: %@\n\n",[AdminProjektNamenArray description]);
	NSArray* SessionNamenArray=[NSArray array];
	double ProjektIndex=[[AdminProjektArray valueForKey:@"projekt"]indexOfObject:dasProjekt];
	if (ProjektIndex<NSNotFound)
	{
		NSDictionary* tempProjektDic=[AdminProjektArray objectAtIndex:ProjektIndex];
		//NSLog(@"setAdminPlayer: Projekt: %@ tempProjektDic: %@\n\n",dasProjekt,[tempProjektDic description]);
		
		if ([tempProjektDic objectForKey:@"sessionleserarray"])
		{
			SessionNamenArray=[tempProjektDic objectForKey:@"sessionleserarray"];
		}
	}
	//NSLog(@"setAdminPlayer: SessionLeserArray: %@",[SessionNamenArray description]);
	for (i=0; i < [AdminProjektNamenArray count]; i++)
	{
		//LesernamenPop setzen
		[LesernamenPop addItemWithTitle:[AdminProjektNamenArray objectAtIndex:i]];
		NSNumber* inSessionNumber;
		if ([SessionNamenArray containsObject:[AdminProjektNamenArray objectAtIndex:i]])
		{
			inSessionNumber=[NSNumber numberWithBool:YES];
		}
		else
		{
			inSessionNumber=[NSNumber numberWithBool:NO];
		}
		
		
		//Namen einsetzen, inSessionNumber einsetzen
		NamenDic=[NSDictionary dictionaryWithObjectsAndKeys:[AdminProjektNamenArray objectAtIndex:i], @"namen",inSessionNumber,@"insession",nil];
		//NSLog(@"setAdminPlayer    NamenDic: %@",[NamenDic description]);
		
		//Anzahl Aufnahmen für den Namen ausrechnen
		tempLeserPfad=[AdminProjektPfad stringByAppendingPathComponent:[[AdminProjektNamenArray objectAtIndex:i]description]];
		//NSLog(@"tempLeserPfad: %@",tempLeserPfad);
		tempAufnahmenliste=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:tempLeserPfad error:NULL]];
		
		//NSLog(@"setAdminPlayer    tempAufnahmenliste: %@",[tempAufnahmenliste description]);
		
		//Anzahl Aufnahmen:
		tempAnzAufnahmen=[[Filemanager contentsOfDirectoryAtPath:tempLeserPfad error:NULL]count];
		//tempAnzAufnahmen=[tempAufnahmenliste count];											
		//Unsichtbare Ordner entfernen
		
		if (tempAnzAufnahmen&&[[tempAufnahmenliste objectAtIndex:0] hasPrefix:@".DS"])			
		{
			[tempAufnahmenliste removeObjectAtIndex:0];
			tempAnzAufnahmen--;
		}
		
		int k;
		int Kommentarzeile=-1;
		
		//Kommentarordner aus Liste entfernen
		NSString* KommentarString=@"Anmerkungen";
		for(k=0;k<tempAnzAufnahmen;k++)
		{
			if ([[[tempAufnahmenliste objectAtIndex:k]description]isEqualToString: KommentarString])
			{
				//NSLog(@"Kommentar bei %d",k);
				Kommentarzeile=k;
				//[tempAufnahmenliste removeObjectAtIndex:k];
			}
			//bei Löschen im Netz: File 'afpDeletedxxxx' suchen
			//NSLog(@"kein Kommentar bei %d",k);
			
		}
		
		if (Kommentarzeile>=0) //Kommentarordner entfernen
		{
			[tempAufnahmenliste removeObjectAtIndex:Kommentarzeile];
			tempAnzAufnahmen--;
		}
		
		//bei Löschen im Netz: File 'afpDeletedxxxx' suchen
		int afpZeile=-1;
		for(k=0;k<tempAnzAufnahmen;k++)
		{
			if ([[[tempAufnahmenliste objectAtIndex:k]description]characterAtIndex:0]=='.')
			{
				NSLog(@"String mit Punkt: %@ auf Zeile: %d",[[tempAufnahmenliste objectAtIndex:k]description],k);
				afpZeile=k;
			}
			//NSLog(@"kein Kommentar bei %d",k);
			
		}
		if (afpZeile>=0) //afpDelete entfernen
		{
			[tempAufnahmenliste removeObjectAtIndex:afpZeile];
			tempAnzAufnahmen--;
		}
		
		AnzDic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tempAnzAufnahmen],@"anz",nil];
		
		//AufnahmeFilesArray=[NSArray arrayWithArray:	tempAufnahmenliste];
		AufnahmeFilesArray=[NSMutableArray arrayWithCapacity:tempAnzAufnahmen];
		NSString* indexString, *nextIndexString;
		int tausch=1;
		int m;
		while (tausch)
		{
			tausch=0;
			for (m=0;m<tempAnzAufnahmen-1;m++)//sortieren nach nummer
			{
				indexString=[NSString stringWithString:[tempAufnahmenliste objectAtIndex:m]];
				nextIndexString=[NSString stringWithString:[tempAufnahmenliste objectAtIndex:m+1]];
				long n1=[self AufnahmeNummerVon:indexString];
				long n2=[self AufnahmeNummerVon:nextIndexString];
				//NSLog(@"indexTitelString: %@  Nr:%d",indexTitelString,n1);
				//NSLog(@"nextindexTitelString: %@  Nr:%d",nextindexTitelString,n2);
				if(n2<n1)
				{
					[tempAufnahmenliste exchangeObjectAtIndex:m withObjectAtIndex:m+1];
					//NSLog(@"tausch: n1: %d    n2: %d",n1,n2);
					tausch++;
				}
				
			}//for anzahl
		}//while tausch
		
		
		int pos;
		//NSLog(@"setAdminPlayer Leser: %@ tempAufnahmenliste nach sortieren: %@",[tempLeserPfad lastPathComponent],[tempAufnahmenliste description]);
		//Reihenfolge der Aufnahmen umkehren: Neueste zuoberst
		//NSNumber* FileCreatorNumber=[NSNumber numberWithUnsignedLong:'RPDF'];
		//NSLog(@"FileCreatorNumber: %d\r",[FileCreatorNumber intValue]);
		NSMutableArray* tempMarkArray=[[NSMutableArray alloc]initWithCapacity:tempAnzAufnahmen];
		int kk;
		for (kk=0;kk<tempAnzAufnahmen;kk++)
		{
			//NSNumber* tempMark=[NSNumber numberWithBool:0];
			[tempMarkArray addObject:[NSNumber numberWithBool:NO]];
		}
		
		for (m=0;m<tempAnzAufnahmen;m++)
		{
			NSString* tempAnmerkungPfad=[tempLeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
         
			tempAnmerkungPfad=[tempAnmerkungPfad stringByAppendingPathComponent:[tempAufnahmenliste objectAtIndex:m]];
         
         // m4a entfernen, txt anfuegen
         tempAnmerkungPfad = [[tempAnmerkungPfad stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
         
         //NSLog(@"setAdminPlayer tempAnmerkungPfad: %@",tempAnmerkungPfad);
			BOOL AdminMark=NO;
			//
         
			if ([Filemanager fileExistsAtPath:tempAnmerkungPfad])
			{
				//NSLog(@"File exists an Pfad: %@",tempAnmerkungPfad);
            //
            NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempAnmerkungPfad encoding:NSMacOSRomanStringEncoding error:NULL];
            NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
            //NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
            if (tempKommentarArrary &&[tempKommentarArrary count])
            {
               NSNumber* AdminMarkNumber=[tempKommentarArrary objectAtIndex:kAdminMark];
               //NSLog(@"istMarkiert		AdminMarkNumber: %d",[AdminMarkNumber intValue]);
               
               AdminMark=[AdminMarkNumber intValue];
               
            }

            //
				//AdminMark=[self AufnahmeIstMarkiertAnPfad:tempAnmerkungPfad];
				//NSLog(@"AdminMark: %d",AdminMark);
				/*
				NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempAnmerkungPfad];
				NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
				NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
				if (tempKommentarArrary &&[tempKommentarArrary count])
				{
					NSNumber* AdminMarkNumber=[tempKommentarArrary objectAtIndex:3];
					NSLog(@"istMarkiert		AdminMarkNumber: %d",[AdminMarkNumber intValue]);
					
					AdminMark=[AdminMarkNumber intValue];
					
				}
				*/
				
			}//file exists
			
			//
			//NSLog(@"setAdminPlayer zeile: %d Pfad: %@ Mark: %d",m,tempAnmerkungPfad,AdminMark);
			
			[tempMarkArray replaceObjectAtIndex:(tempAnzAufnahmen-m-1) withObject:[NSNumber numberWithBool:AdminMark]];
			
			/*
			 NSDictionary* AufnahmeAttribute=[Filemanager fileAttributesAtPath:tempAttributesPfad traverseLink:YES];
			 if (AufnahmeAttribute )
			 {
			 NSNumber* AufnahmeMarke=[AufnahmeAttribute objectForKey:NSFileHFSCreatorCode];
			 //NSLog(@"Aufnahme: %@ index: %d  Aufn.Marke: %d",[tempAufnahmenliste objectAtIndex:m],m,[AufnahmeMarke intValue]);
			 //NSString * Type=NSHFSTypeOfFile(tempAttributesPfad);
			 if ([AufnahmeMarke intValue]==[FileCreatorNumber intValue])
			 {
			 //NSLog(@"**** Aufnahme: %@ index: %d  Aufn.Marke: %d",[tempAufnahmenliste objectAtIndex:m],m,[AufnahmeMarke intValue]);
			 [tempMarkArray replaceObjectAtIndex:(tempAnzAufnahmen-m-1) withObject:[NSNumber numberWithBool:YES]];
			 //In willDisplayCell wird die Reihenfolge umgekehrt
			 }
			 else
			 {
			 //NSLog(@"Aufnahme: ");
			 }
			 }
			 */
		}
		[AdminDaten setMarkArray:tempMarkArray forRow:i];
		
		if (tempAnzAufnahmen)
		{
			for(pos=0;pos<tempAnzAufnahmen;pos++)
			{
				[AufnahmeFilesArray insertObject:[tempAufnahmenliste objectAtIndex:(tempAnzAufnahmen-1)-pos] atIndex:pos ];
				
			}
		}
		//NSLog(@"AufnahmeFilesArray nach wenden: %@   index: %d",[AufnahmeFilesArray description],i);
		//
		
		[AdminDaten setAufnahmeFiles:AufnahmeFilesArray forRow:i];
		//NSLog(@"setAufnahmeFiles");
		//Aufnahmen ins Pop einsetzen
		//NSPopUpButtonCell* tempPopUpButtonCell;
		//tempPopUpButtonCell =[[self.NamenListe tableColumnWithIdentifier: @"aufnahmen"]dataCellForRow:i];
		//[tempPopUpButtonCell addItemsWithTitles:tempAufnahmenliste];
		
		[AdminDaten setData: NamenDic  forRow:i];
		
		
		//NSLog(@"setData: NamenDic");
		//[NamenDic autorelease];
		[AdminDaten setData: AnzDic  forRow:i];
		//NSLog(@"setData: AnzDic");
		//[AnzDic release];
	}
	
	
	
	//NSButtonCell* PlayNeu;
	//PlayNeu=[[NSButtonCell alloc]init];
	//[PlayNeu setButtonType:NSMomentaryLight];
	//[PlayNeu setTitle:@">"];
	//SEL PlayNeuSelektor;
	//PlayNeuSelektor=@selector(AufnahmeInPlayer:);
	//[PlayNeu setAction:PlayNeuSelektor];
	
	//[PlayNeu setControlSize: NSMiniControlSize];
	//[[self.NamenListe tableColumnWithIdentifier: @"neu"] setDataCell: PlayNeu];
	//for (i=0; i < AnzLeser; i++)
	//{
	//	[[[self.NamenListe tableColumnWithIdentifier: @"neu"]dataCellForRow:i]setTag:i];
	//}
	
	[AdminDaten setEditable:YES];
	[NamenListe setDataSource:AdminDaten];
	[NamenListe setDelegate: AdminDaten];
	[NamenListe reloadData];
   [NamenListe deselectAll:NULL];
	SEL DoppelSelektor;
	DoppelSelektor=@selector(AufnahmeInPlayer:);
	[NamenListe setDoubleAction:DoppelSelektor];
	NSFont* n1;
	n1=[NSFont fontWithName:@"Helvetica" size:10];
	[AbspieldauerFeld setFont:n1];
	//[self.NamenListe setRowHeight: 24];
	NSLog(@"setAdminplayer fertig");
	Moviegeladen=NO;
	[AufnahmenTab setDelegate:self];
	
	[AufnahmenTable setDoubleAction:DoppelSelektor];
   //[AufnahmenTable setDelegate:AdminDaten];
   //[AufnahmenTable setDataSource:AdminDaten];
   NSLog(@"setAdminplayer AdminDaten: %@",[AdminDaten description]);
}

- (IBAction)AufnahmeSetzen:(id)sender
{
//NSLog(@"AufnahmeSetzen: Zeile: %d",[sender selectedRow]);
//[self setLeserFuerZeile:[sender selectedRow]];
}

- (IBAction)setNeuesAdminProjekt:(id)sender
{
  
	NSLog(@"\n\n*********setNeuesAdminProjekt: %@\nAdminProjektArray: %@",[sender titleOfSelectedItem],AdminProjektArray);
	[self setAdminPlayer:AdminLeseboxPfad inProjekt:[sender titleOfSelectedItem]];
	[self setProjektPopMenu:AdminProjektArray];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	
	[NotificationDic setObject:[AdminProjektPfad lastPathComponent] forKey:@"projekt"];
	
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ProjektMenu" object:self userInfo:NotificationDic];
	
}


- (void)setAdminProjektArray:(NSArray*)derProjektArray
{
   //NSLog(@"\n\n			--------setAdminProjektArray: derProjektArray: %@",[derProjektArray description]);
   
   [[self window ] makeKeyAndOrderFront:nil];
   [AdminProjektArray removeAllObjects];
   [AdminProjektArray setArray:derProjektArray];
   //NSLog(@"setAdminProjektArray: AdminProjektArray: %@",[[AdminProjektArray lastObject]description]);
   
   [self setProjektPopMenu:AdminProjektArray];
   
}

- (void)setProjektPopMenu:(NSArray*)derProjektArray
{
  NSString* tempProjektName=[AdminProjektPfad lastPathComponent];
  //NSLog(@"setProjektPop  derProjektArray: %@ ProjektPop: %@",[derProjektArray description],[AdminProjektPop description] );
  double anz=[AdminProjektPop numberOfItems];
 
  if (anz>1)
	{
	while (anz>1)
	  {
	  [AdminProjektPop removeItemAtIndex:1];
	  anz--;
	  }
	}
  if ([derProjektArray count])
	{
//	NSImage* MarkOnImg=[NSImage imageNamed:@"MarkOnImg.tif"];
//	NSImage* MarkOffImg=[NSImage imageNamed:@"MarkOffImg.tif"];

	NSEnumerator* ProjektEnum=[derProjektArray objectEnumerator];
	id einProjektDic;
	
	while (einProjektDic=[ProjektEnum nextObject])
	  {
	  //NSLog(@"*setProjektPopMenu einProjektDic: %@",einProjektDic);
	  NSString* tempTitel=[einProjektDic objectForKey:@"projekt"];
	  if (tempTitel&&[tempTitel length]&&![tempTitel isEqualToString:tempProjektName])
		{
		[AdminProjektPop addItemWithTitle:tempTitel];
		//NSLog(@"*setProjektPopMenu einProjektDic: %@",einProjektDic);

		if ([[einProjektDic objectForKey:@"OK"]boolValue]||[[einProjektDic objectForKey:@"ok"]boolValue])
		  {
		  NSImage* CrossImg=[NSImage imageNamed:@"CrossImg.tif"];
		  [[AdminProjektPop itemWithTitle:tempTitel]setImage:CrossImg];
		  }
		  else
		  {
		  NSImage* BoxImg=[NSImage imageNamed:@"BoxImg.tif"];
		   [[AdminProjektPop itemWithTitle:tempTitel]setImage:BoxImg];
		  }
		  
		}
	  }
	}//ProjektArray count
	
}

- (void) resetAdminPlayer
{
	//NSLog(@"AdminPlayer resetAdminPlayer");
	[NamenListe deselectAll:nil];
	[zurListeTaste setEnabled:NO];
	[PlayTaste setEnabled:NO];
	[AdminDaten deleteAllData];
	[NamenListe reloadData];
   [NamenListe deselectAll:NULL];
	Textchanged=NO;
	Moviegeladen=NO;
   
   /*
	[AdminQTKitPlayer pause:NULL];
	[AdminQTKitPlayer gotoBeginning:nil];
	[AdminQTKitPlayer setMovie:nil];
	[AdminQTKitPlayer setHidden:YES];
        */
   
   
	[self setBackTaste:NO];
	[AbspieldauerFeld setStringValue:@""];
	//NSLog(@"vor saveKommentarFuerLeser");
	if ([self.AdminAktuellerLeser length]&&[AdminAktuelleAufnahme length]&&Textchanged)
	  {
		BOOL OK=[self saveKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
     
        /*
        OK = [self saveAdminMarkFuerLeser:AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme
                           mitAdminMark:(int)[AdminMarkCheckbox state]];
         */
        OK = [self saveMarksFuerLeser:self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme mitAdminMark: (int)[AdminMarkCheckbox state] mitUserMark:(int)[UserMarkCheckbox state]];

  
        
      //  AdminAktuellerLeser=@"";
		//AdminAktuelleAufnahme=@"";
	  }
	[self clearKommentarfelder];	
	[AdminKommentarView setEditable:NO];
	[AdminKommentarView setSelectable:NO];
//	[AdminBewertungfeld setEditable:NO];
	[AdminNotenfeld setEnabled:NO];
	[AdminNotenfeld setEditable:NO];
	[ExportierenTaste setEnabled:NO];
	[LoeschenTaste setEnabled:NO];
	[zurListeTaste setEnabled:NO];
 
}

- (double)selektierteZeile
{
	return [NamenListe selectedRow];
	 
}

- (void) setLeseboxPfad:(NSString*)derPfad inProjekt: (NSString*)dasProjekt
{
	AdminLeseboxPfad=derPfad;
	AdminArchivPfad =[AdminLeseboxPfad stringByAppendingString:@"Archiv"];
	AdminProjektPfad =[AdminArchivPfad stringByAppendingString:dasProjekt];
}

- (NSString*)AdminLeseboxPfad
{
	if (AdminLeseboxPfad)
		return AdminLeseboxPfad;
	else
	  {
		//NSLog(@"++++++++++++++++++++++++++AdminLeseboxPfad NULL");
		return NULL;
	  }
}

- (IBAction)setLeser:(id)sender
{
//	*********************************** wird von AdminListe aufgerufen: Löst Aktion des PopMenues aus !!!
	double hitZeile=[sender selectedRow];
	//NSLog(@"hitZeile: %d ",hitZeile);
	if (hitZeile<0)
		return;
   [self clearAVPlay];
   
	if ([[AdminDaten AufnahmeFilesFuerZeile:hitZeile]count])
	{
		int hit=[[[AdminDaten dataForRow:hitZeile]objectForKey:@"aufnahmen"]intValue];
      
		NSString* Leser=[[AdminProjektNamenArray objectAtIndex:hitZeile]description];
		self.AdminAktuellerLeser=[[AdminProjektNamenArray objectAtIndex:hitZeile]description];
		
      NSLog(@"setLeser Zeile: %ld",[sender selectedRow]);
		NSLog(@"Leser: %@",[[AdminProjektNamenArray objectAtIndex:[sender selectedRow]]description]);
		//NSLog(@"setLeser:     Zeile: %d   hit:%d ",hitZeile,hit);
		//NSLog(@"i:%d ",hitZeile);
		
		[AdminDaten setAuswahl:hit forRow:hitZeile];
		//NSString* tempAufnahmePfad=[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description];
		//NSString* tempAdminAktuelleAufnahme=AdminAktuelleAufnahme;
		if (![AdminAktuelleAufnahme isEqualToString:[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description]])//andere Aufnahme gewählt
		  {
			  //NSLog(@"andere Aufnahme");
			 // if (Moviegeladen)
				{
				  //NSLog(@"save alten Kommentar, Movie geladen");
				  [self Aufnahmezuruecklegen];//Aufnahme zurücklegen
				}
		  }
		//NSLog(@"setLeser   Leser: %@  zeile: %d  hit: %d   File:  %@",Leser, hitZeile, hit, tempAufnahmePfad);
		AdminAktuelleAufnahme=[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description];
      NSLog(@"setLeser   AdminAktuelleAufnahme: %@",AdminAktuelleAufnahme);
      
      
      
//      return;
      
      
		BOOL OK=[self setPfadFuerLeser: Leser FuerAufnahme:AdminAktuelleAufnahme];
      
		OK=[self setKommentarFuerLeser: Leser FuerAufnahme:AdminAktuelleAufnahme];
		
		NSString* tempAufnahmePfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];
		tempAufnahmePfad=[tempAufnahmePfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
       AdminPlayPfad =tempAufnahmePfad ;
      /*
		if ([AdminDaten MarkForRow:hitZeile forItem:hit])
		  {
			[AdminMarkCheckbox setState:YES];
         [LehrerMarkCheckbox setState:YES];
        }
		else
		  {
			[AdminMarkCheckbox setState:NO];
         [LehrerMarkCheckbox setState:NO];

		  }
       */
      [self Aufnahmebereitstellen];
		
	}
	else
	{
		NSLog(@"SetLeser        Keine Aufnahme");
		NSBeep();
		[PlayTaste setEnabled:NO];
		[ExportierenTaste setEnabled:NO];
		[LoeschenTaste setEnabled:NO];
		[AdminMarkCheckbox setState:NO];
      [LehrerMarkCheckbox setState:NO];
		[self clearKommentarfelder];
		
	}
}

- (IBAction)setZeilenAufnahme:(id)sender
{
   //	*********************************** wird von Aufnahmetable aufgerufen: Löst Aktion des PopMenues aus !!!
   double hitZeile=[sender selectedRow];
   NSLog(@"hitZeile: %f ",hitZeile);
   if (hitZeile<0)
      return;
   [self clearAVPlay];
   
   
   return;
   
   if (1)
   {
      int hit=[[[AdminDaten dataForRow:hitZeile]objectForKey:@"aufnahmen"]intValue];
      
      
      NSString* Leser=[[AdminProjektNamenArray objectAtIndex:hitZeile]description];
      self.AdminAktuellerLeser=[[AdminProjektNamenArray objectAtIndex:hitZeile]description];
      
      NSLog(@"setLeser Zeile: %ld",[sender selectedRow]);
      //NSLog(@"Leser: %@",[[AdminProjektNamenArray objectAtIndex:[sender selectedRow]]description]);
      //NSLog(@"setLeser:     Zeile: %d   hit:%d ",hitZeile,hit);
      //NSLog(@"i:%d ",hitZeile);
      
      [AdminDaten setAuswahl:hit forRow:hitZeile];
      //NSString* tempAufnahmePfad=[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description];
      //NSString* tempAdminAktuelleAufnahme=AdminAktuelleAufnahme;
      if (![AdminAktuelleAufnahme isEqualToString:[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description]])//andere Aufnahme gewählt
      {
         //NSLog(@"andere Aufnahme");
         // if (Moviegeladen)
         {
            //NSLog(@"save alten Kommentar, Movie geladen");
            [self Aufnahmezuruecklegen];//Aufnahme zurücklegen
         }
      }
      //NSLog(@"setLeser   Leser: %@  zeile: %d  hit: %d   File:  %@",Leser, hitZeile, hit, tempAufnahmePfad);
      AdminAktuelleAufnahme=[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description];
      //NSLog(@"setLeser   AdminAktuelleAufnahme: %@",AdminAktuelleAufnahme);
      
      
      
      //      return;
      
      
      BOOL OK=[self setPfadFuerLeser: Leser FuerAufnahme:AdminAktuelleAufnahme];
      
      OK=[self setKommentarFuerLeser: Leser FuerAufnahme:AdminAktuelleAufnahme];
      
      NSString* tempAufnahmePfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];
      tempAufnahmePfad=[tempAufnahmePfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
      AdminPlayPfad =tempAufnahmePfad ;
      /*
       if ([AdminDaten MarkForRow:hitZeile forItem:hit])
       {
       [AdminMarkCheckbox setState:YES];
       [LehrerMarkCheckbox setState:YES];
       }
       else
       {
       [AdminMarkCheckbox setState:NO];
       [LehrerMarkCheckbox setState:NO];
       
       }
       */
      [self Aufnahmebereitstellen];
      
   }
   else
   {
      NSLog(@"SetZeilenaufnahme       Keine Aufnahme");
      NSBeep();
      [PlayTaste setEnabled:NO];
      [ExportierenTaste setEnabled:NO];
      [LoeschenTaste setEnabled:NO];
      [AdminMarkCheckbox setState:NO];
      [LehrerMarkCheckbox setState:NO];
      [self clearKommentarfelder];
      
   }
}

- (BOOL)AnzahlAufnahmenFuerZeile:(int)dieZeile
{
	if ([[AdminDaten AufnahmeFilesFuerZeile:dieZeile]count])
		return YES;
	else
		return NO;
}

- (BOOL)AnzahlAufnahmen
{
	double hitZeile;
	hitZeile=[NamenListe selectedRow];
	if (hitZeile<0)
	  return NO;
	//NSLog(@"hitZeile: %d",hitZeile);
	if ([[AdminDaten AufnahmeFilesFuerZeile:hitZeile]count])
		return YES;
	else
		return NO;
}
- (void)setLeserFuerZeile:(long)dieZeile
{
	long hitZeile=dieZeile;
	NSLog(@"setLeserFuerZeile: hitZeile: %ld ",hitZeile);

	if (hitZeile<0) return;
	
	if ([[AdminDaten AufnahmeFilesFuerZeile:hitZeile]count])
	{
		//[AdminKommentarView selectAll:nil];
		//[AdminKommentarView delete:nil];
		[AdminKommentarView setString:@""];
		//NSLog(@"setLeserFuerZeile    Leser Zeile: %d",hitZeile);

		int hit=[[[AdminDaten dataForRow:hitZeile]objectForKey:@"aufnahmen"]intValue];
     
		NSString* Leser=[[AdminProjektNamenArray objectAtIndex:hitZeile]description];
		self.AdminAktuellerLeser=[[AdminProjektNamenArray objectAtIndex:hitZeile]description];
 //     NSLog(@"setLeserFuerZeile AdminAktuellerLeser: %@",self.AdminAktuellerLeser);

		//NSLog(@"setLeserFuerZeile    Leser Zeile: %d",hitZeile);
		//NSLog(@"Leser: %@",[[AdminProjektNamenArray objectAtIndex:[sender selectedRow]]description]);
		//NSLog(@"Zeile: %d   hit:%d ",hitZeile,hit);
		//NSLog(@"i:%d ",hitZeile);
		[AdminDaten setAuswahl:hit forRow:hitZeile];
		NSString* Ziel=[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description];
		AdminAktuelleAufnahme=[[[AdminDaten AufnahmeFilesFuerZeile:hitZeile]objectAtIndex:hit]description];
      NSLog(@"setLeserFuerZeile AdminAktuelleAufnahme: %@",AdminAktuelleAufnahme);
		//NSLog(@"setLeserFuerZeile Leser: %@  zeile: %d  hit: %d   File:  %@",Leser, hitZeile, hit, Ziel);
		BOOL OK;
		OK=[self setPfadFuerLeser: Leser FuerAufnahme:Ziel];
		//Pfad für Aufnahme: AdminPlayPfad
      
 //     return;
      
      
		OK=[self setKommentarFuerLeser: Leser FuerAufnahme:Ziel];
		
		
		
		NSString* tempAufnahmePfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];
		tempAufnahmePfad=[tempAufnahmePfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
       AdminPlayPfad =tempAufnahmePfad ;
      
 //     NSLog(@"setLeserFuerZeile AdminAktuellerLeser: %@ AdminAktuelleAufnahme: %@",self.AdminAktuellerLeser,AdminAktuelleAufnahme);

		//NSFileManager *Filemanager=[NSFileManager defaultManager];
		//if ([Filemanager fileExistsAtPath
      /*
		if ([AdminDaten MarkForRow:hitZeile forItem:hit])
		  {
			[AdminMarkCheckbox setState:YES];
		  }
		else
		  {
			[AdminMarkCheckbox setState:NO];
			
		  }
		*/
		[PlayTaste setEnabled:YES];
		[AdminMarkCheckbox setEnabled:YES];
      
      
      [self Aufnahmebereitstellen];
	}
	else
	{
		//NSLog(@"setLeserFuerZeile		Keine Aufnahme");
		NSBeep();
		self.AdminAktuellerLeser=@"";
		AdminAktuelleAufnahme=@"";
		[self clearKommentarfelder];
		[PlayTaste setEnabled:NO];
		[zurListeTaste setEnabled:NO];
		[zurListeTaste setKeyEquivalent:@""];
		[AdminMarkCheckbox setState:NO];
      [LehrerMarkCheckbox setState:NO];

	//	[AdminMarkCheckbox setEnabled:NO];
	}
}

- (BOOL)setPfadFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme
{
	//NSLog(@"setPfadFuerLeser:%@ dieAufnahme: %@",derLeser, dieAufnahme);
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSString* Leser=[derLeser copy];
	
	
	NSString* Ziel=[dieAufnahme copy];
	NSString* ZielPfad;//=[NSString stringWithString:AdminProjektPfad];
	ZielPfad=[AdminProjektPfad stringByAppendingPathComponent:Leser];
		
		if ([Filemanager fileExistsAtPath:ZielPfad])
		{
			ZielPfad=[ZielPfad stringByAppendingPathComponent:Ziel];
			if ([Filemanager fileExistsAtPath:ZielPfad])
			{

				//NSLog(@"File da: %@",ZielPfad);
				AdminPlayPfad = [NSString stringWithString:ZielPfad];
//            [AVAbspielplayer prepareAdminAufnahmeAnURL:[NSURL fileURLWithPath:AdminPlayPfad]];
			}
			else
			{
				NSLog(@"Kein File da");
				return NO;
			}
		}
		return YES;
}

- (BOOL)setKommentarFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme
{
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSString* Leser=[derLeser copy];
	[AdminNamenfeld setStringValue: Leser];
	//[Leser release];
	NSString* Ziel=[dieAufnahme stringByDeletingPathExtension];
   int Aufnahmenummer = [self AufnahmeNummerVon:Ziel];
   [AdminNummerfeld setIntValue:Aufnahmenummer];
	[AdminTitelfeld setStringValue:[self AufnahmeTitelVon:Ziel]];
	//NSLog(@"setKommentarFuerLeser:%@		FuerAufnahme:%@",derLeser, dieAufnahme);
	BOOL istDirectory;
	NSString* tempKommentarPfad=[NSString stringWithString:AdminProjektPfad];
	NSString* KommentarOrdnerString=@"Anmerkungen";
	NSString* KommentarString;
	tempKommentarPfad=[tempKommentarPfad stringByAppendingPathComponent:Leser];
   self.AdminAktuellerLeser = derLeser;
	[AdminKommentarView setString:@""];

	[AdminKommentarView setEditable:YES];
	[AdminKommentarView setString:@""];
	//[AdminKommentarView selectAll:nil];
	//[AdminKommentarView delete:nil];

	if ([Filemanager fileExistsAtPath:tempKommentarPfad isDirectory:&istDirectory])//Ordner für Leser vorhanden
		{
			if (istDirectory)
			{
				tempKommentarPfad=[tempKommentarPfad stringByAppendingPathComponent:KommentarOrdnerString];
				if ([Filemanager fileExistsAtPath:tempKommentarPfad isDirectory:&istDirectory])//Ordner Kommentar vorhanden
				{
					if (istDirectory)
					{
						tempKommentarPfad=[tempKommentarPfad stringByAppendingPathComponent:Ziel];
                  tempKommentarPfad = [tempKommentarPfad stringByAppendingPathExtension:@"txt"];
						if ([Filemanager fileExistsAtPath:tempKommentarPfad])//Kommentar vorhanden
						  {
							  KommentarString=[NSString stringWithContentsOfFile:tempKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
							  if ([KommentarString length])
								{
								  //NSLog(@"setKommentar KommentarString: %@",KommentarString);
								  //[AdminKommentarfeld setStringValue: KommentarString];
								  
								  [AdminKommentarView setString:[self KommentarVon:KommentarString]];
								  [AdminDatumfeld setStringValue:[self DatumVon:KommentarString]];
								  long index=[AdminBewertungfeld indexOfItemWithTitle:[self BewertungVon:KommentarString]];
								  if (index>=0)
								  {
                             [AdminBewertungfeld selectItemAtIndex:index];
								  }
								  else
								  {
                             //long index=[AdminBewertungfeld indexOfItemWithTitle:@"+"];
								  }
								  [AdminNotenfeld setStringValue:[self NoteVon:KommentarString]];
								  //NSLog(@"UserMarkCheckbox Mark: %d",[self UserMarkVon:KommentarString]);
								  [UserMarkCheckbox setState:[self UserMarkVon:KommentarString]];
                           
                          // NSLog(@"AdminMarkCheckbox aktueller state: %ld",[AdminMarkCheckbox state]);
                          // NSLog(@"UserMarkCheckbox  aktueller state: %ld",[UserMarkCheckbox  state]);
                           
                           int tempmark = [self AdminMarkVon:KommentarString];
                           //NSLog(@"tempmark: %d",tempmark);
                           
                           [AdminMarkCheckbox setState:tempmark];
                           [LehrerMarkCheckbox setState:tempmark];
                           
                           //NSLog(@"AdminMarkCheckbox neuer state: %ld",[AdminMarkCheckbox state]);
                           //NSLog(@"UserMarkCheckbox  neuer state: %ld",[UserMarkCheckbox  state]);
                          
                           
                           NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
                           [NotificationDic setObject:[NSNumber numberWithInt:tempmark] forKey:@"adminstate"];
                           //NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
                          // [nc postNotificationName:@"markcheckbox" object:self userInfo:NotificationDic];

                            
								}
							  else
								{
								  [AdminKommentarView setString:@"neue Anmerkungen:"];
								  //[AdminKommentarView selectAll:nil];
								  [AdminDatumfeld setStringValue:@""];
								//  [AdminBewertungfeld setStringValue:@""];
								  [AdminNotenfeld setStringValue:@""];
								  [UserMarkCheckbox setState:NO];
								}
						  }
						else
						  {
							
							[AdminKommentarView setString:@"Keine Anmerkungen"];
							 //[AdminKommentarView selectAll:nil];
							[AdminDatumfeld setStringValue:@""];
							[AdminBewertungfeld setStringValue:@""];
							[AdminNotenfeld setStringValue:@""];
							 [UserMarkCheckbox setState:NO];
						  }


					}
				}
			}
		}
	[AdminKommentarView setEditable:NO];
	[AdminKommentarView setSelectable:NO];
	[AdminDatumfeld setEditable:NO];
//	[AdminBewertungfeld setEditable:NO];
	[AdminNotenfeld setEditable:NO];



	return YES;
}			


- (BOOL)saveKommentarFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme
{
	NSLog(@"saveKommentarFuerLeser Leser: %@ Aufnahme: %@ Textchanged: %d",derLeser, dieAufnahme, Textchanged);
	
   if (!Textchanged)
   {
      return 1;
   }
	BOOL erfolg;
	BOOL istDirectory; 
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSString* tempLeser=[derLeser copy];
	if ([tempLeser length]==0)
	{
		NSLog(@"saveKommentarFuerLeser: Kein Leser");
		Textchanged=NO;
		return NO;
	}
	NSString* tempAufnahme;
	tempAufnahme=[dieAufnahme copy];
	NSLog(@"");
	NSString* tempAdminAufnahmePfad=[NSString stringWithString:AdminProjektPfad];
	tempAdminAufnahmePfad=[tempAdminAufnahmePfad stringByAppendingPathComponent:tempLeser];
	if ([Filemanager fileExistsAtPath:tempAdminAufnahmePfad])//Ordner für Aufnahmen des Lesers ist da
	{
		tempAdminAufnahmePfad=[tempAdminAufnahmePfad stringByAppendingPathComponent:tempAufnahme];
		if ([Filemanager fileExistsAtPath:tempAdminAufnahmePfad])//Aufnahme gibt es
		{
			//NSLog(@"Aufnahme da");
		}
		else
		{
			//NSLog(@"Aufnahme nicht da");
			return NO;
		}
		
	}
	NSString* KommentarOrdnerString=@"Anmerkungen";
	NSString* tempAdminKommentarPfad=[[AdminProjektPfad copy] stringByAppendingPathComponent:tempLeser];
	NSString* tempKommentarString;
	NSString* tempKopfString;
	//NSLog(@"in saveKommentarFuerLeser 1");
	if ([Filemanager fileExistsAtPath:tempAdminKommentarPfad isDirectory:&istDirectory])//Ordner des Lesers ist da
	{
		if (istDirectory)
		{
			tempAdminKommentarPfad=[tempAdminKommentarPfad stringByAppendingPathComponent:KommentarOrdnerString];
			//NSLog(@"saveKommentarFuerLeser: tempAdminKommentarPfad: %@",tempAdminKommentarPfad);
			if (![Filemanager fileExistsAtPath:tempAdminKommentarPfad isDirectory:&istDirectory])//noch kein Kommentarordner des Lesers ist da
			{
				erfolg=[Filemanager createDirectoryAtPath:tempAdminKommentarPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
				//NSLog(@"saveKommentarFuerLeser: tempAdminKommentarPfad: %@ erfolg: %d",tempAdminKommentarPfad,erfolg);

				if (!erfolg)
				{
					return erfolg;
				}
				
			}
			//NSLog(@"in saveKommentarFuerLeser: Kommentarordner da");
			
			tempAdminKommentarPfad=[tempAdminKommentarPfad stringByAppendingPathComponent:[tempAufnahme stringByDeletingPathExtension]];
			
         tempAdminKommentarPfad= [tempAdminKommentarPfad stringByAppendingPathExtension:@"txt"];
         //NSLog(@"saveKommentarFuerLeser: tempAdminKommentarPfad: %@",tempAdminKommentarPfad);
			//Kopfstring aufbauen
			tempKopfString=[NSString stringWithString:self.AdminAktuellerLeser];
			tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			if ([AdminAktuelleAufnahme length]>1)
			{
				tempKopfString=[tempKopfString stringByAppendingString:AdminAktuelleAufnahme];
			}
			else
			{
				tempKopfString=[tempKopfString stringByAppendingString:@"Kein Titel"];
			}
			tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			
			NSNumber *AufnahmeSize;
			
			NSDictionary *AufnahmeAttrs = [Filemanager attributesOfItemAtPath:tempAdminAufnahmePfad error:NULL];
			if (AufnahmeAttrs) 
			{
				//NSDate* CreationDate = [AufnahmeAttrs objectForKey:NSFileCreationDate];
			}
			else
			{
				NSLog(@"AufnahmeAttrs: Path is incorrect!");
			}
			
			NSDate* CreationDate = [AufnahmeAttrs objectForKey:NSFileCreationDate];
			if (CreationDate)
			{	
				//NSCalendarDate* tempDatum=[CreationDate dateWithCalendarFormat:@"%d.%m.%Y %H:%M:%S" timeZone:nil];
				tempKopfString=[tempKopfString stringByAppendingString:heuteDatumString];
				//NSLog(@"ModDate: %@  Datum: %@",[moddate description],[tempDatum description]);
			}
			else
			{
				tempKopfString=[tempKopfString stringByAppendingString:@"Kein Datum"];
			}
			//NSLog(@"Kopfstring: %@",[tempKopfString description]);
			tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			
			AufnahmeSize = [AufnahmeAttrs objectForKey:NSFileSize];
			if (AufnahmeSize)
			{
				//tempKopfString=[tempKopfString stringByAppendingString:@"Dateigrösse:"];
				//tempKopfString=[tempKopfString stringByAppendingString:[AufnahmeSize stringValue]];
				//tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
				
			}
			
			NSNumber* POSIX = [AufnahmeAttrs objectForKey:NSFilePosixPermissions];
			if (POSIX)
			{
				NSLog(@"POSIX: %d",	[POSIX intValue]);		  
			}
			
			// Bewertung
			  NSString* BewertungString=[AdminBewertungfeld titleOfSelectedItem];
			  NSLog(@"saveKommentar	 BewertungString: %@",BewertungString);
			  if ([BewertungString length]==0)
				{
				  BewertungString=@" ";
				}
			  tempKopfString=[tempKopfString stringByAppendingString:BewertungString];
			  tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			
			NSLog(@"saveKommentar	tempKopfString mit Bewertungstring: %@",tempKopfString);
			
			// Notenstring
			NSString* NotenString=[AdminNotenfeld stringValue];
			NSLog(@"saveKommentar	xx NotenString: %@",NotenString);
			if ([NotenString length]==0)
			{
				NotenString=@"-";
			}
			tempKopfString=[tempKopfString stringByAppendingString:NotenString];
			tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			//NSLog(@"saveKommentar	tempKopfString mit Notenstring: %@",tempKopfString);
			
			//UserMark
			NSString* UserMarkString;
			NSNumber* UserMarkNumber=[NSNumber numberWithBool:[UserMarkCheckbox state]];
			//NSLog(@"saveKommentar	xx MarkString: %@",MarkString);
			if ([UserMarkNumber boolValue]==0)
			{
				UserMarkString=@"0";
			}
			else
			{
				UserMarkString=@"1";
			}
			tempKopfString=[tempKopfString stringByAppendingString:UserMarkString];
			tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			
			// AdminMark
			NSNumber* AdminMarkNumber=[NSNumber numberWithBool:[AdminMarkCheckbox state]];
			//NSLog(@"saveKommentar	xx BewertungString: %@",BewertungString);
			NSString* AdminMarkString;
			if ([AdminMarkNumber boolValue]==0)
			{
				AdminMarkString=@"0";
			}
			else
			{
				AdminMarkString=@"1";
			}
			tempKopfString=[tempKopfString stringByAppendingString:AdminMarkString];
		
			tempKopfString=[tempKopfString stringByAppendingString:@"\r"];
			
			
			
			//			  NSLog(@"+++++++++++++				saveKommentar	tempKopfString mit MarkString: %@",MarkString);
			
			
			if ([Filemanager fileExistsAtPath:tempAdminKommentarPfad])//schon ein Kommentar zur Aufnahme da
			{
				//NSLog(@"saveKommentar: schon ein Kommentar da");
				erfolg=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempAdminKommentarPfad ] error:nil]; 
				if (!erfolg)
				{
					return NO;
				}
				
				//NSLog(@"in saveKommentarFuerLeser alter Kommentar gelöscht");
				
			}
			//NSLog(@"saveKommentar: noch kein Kommentar da");
			
			NSString* tempKommentarViewString=[NSString stringWithString:[AdminKommentarView string]];
			if ([tempKommentarViewString length])
			{
            NSCharacterSet *s= [NSCharacterSet alphanumericCharacterSet];
            
            if ([s characterIsMember:[tempKommentarViewString characterAtIndex:0]])
            {
               NSLog(@"member");
            }
               
            NSUInteger position = [tempKommentarViewString rangeOfString:@"*0"].location;
            NSLog(@"position: %lul",(unsigned long)position);
            //unichar textCharacter = '*';
            NSLog(@"tempKommentarViewString: 0: %C",[tempKommentarViewString characterAtIndex:0]);
            
            while ([tempKommentarViewString length] && (!([s characterIsMember:[tempKommentarViewString characterAtIndex:0]])))
            {
               tempKommentarViewString = [tempKommentarViewString substringFromIndex:1];
               NSLog(@"tempKommentarViewString: substring: %@",tempKommentarViewString);
            }
            
           // NSLog(@"tempKommentarViewString: substring bis 2: %@  substring ab 2: %@",[tempKommentarViewString substringToIndex:2],[tempKommentarViewString substringFromIndex:2]);
           
				if ([tempKommentarViewString length] && ([[tempKommentarViewString substringToIndex:1] isEqualToString:@"--"]))//entfernen
				{
               
					tempKommentarViewString=[tempKommentarViewString substringFromIndex:2];
				}
            
            
				tempKommentarString=[tempKopfString stringByAppendingString:tempKommentarViewString];
				//NSLog(@"saveKommentar:      tempKommentarString:\r %@",tempKommentarString);
			}
			else
			{
				tempKommentarString=[tempKopfString stringByAppendingString:@"--"];
				NSLog(@"saveKommentar                       tempKommentarString ist leer: %@",tempKommentarString);
			}
			
			NSData* tempData=[tempKommentarString dataUsingEncoding:NSMacOSRomanStringEncoding allowLossyConversion:NO];
			NSMutableDictionary* AufnahmeAttribute=[[NSMutableDictionary alloc]initWithCapacity:0];
			NSNumber* POSIXNumber=[NSNumber numberWithInt:438];
			[AufnahmeAttribute setObject:POSIXNumber forKey:NSFilePosixPermissions];
			
			erfolg=[Filemanager createFileAtPath:tempAdminKommentarPfad contents:tempData attributes:AufnahmeAttribute]; 
         NSLog(@"saveKommentar   save erfolg: %d",erfolg);
		}
	}
	[self clearKommentarfelder];
	Textchanged=NO;
	
	return erfolg;
	
}//saveKommentar


- (BOOL)saveAdminMarkFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme 
			  mitAdminMark:(long)dieAdminMark
			  
{
	NSLog(@"in saveAdminMarkFuerLeser Anfang Leser: %@ Aufnahme: %@ AdminMark: %d",derLeser,dieAufnahme,dieAdminMark);
	
	BOOL erfolg;
	BOOL istDirectory; 
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSString* tempLeser=[derLeser copy];
	if ([tempLeser length]==0)
	{
		NSLog(@"saveAdminMarkFuerLeser: Kein Leser");
		return NO;
	}
	NSString* tempAufnahme;
	tempAufnahme=[dieAufnahme copy];
	NSLog(@"\n");
	NSString* tempAdminAufnahmePfad=[NSString stringWithString:AdminProjektPfad];
	tempAdminAufnahmePfad=[tempAdminAufnahmePfad stringByAppendingPathComponent:tempLeser];
	
	NSString* KommentarOrdnerString=@"Anmerkungen";
	NSString* tempAdminKommentarPfad=[[AdminProjektPfad copy] stringByAppendingPathComponent:tempLeser];
	NSLog(@"in saveAdminMarkFuerLeser tempAdminKommentarPfad: %@",tempAdminKommentarPfad);
	if ([Filemanager fileExistsAtPath:tempAdminKommentarPfad isDirectory:&istDirectory])//Ordner des Lesers ist da
	{
		if (istDirectory)
		{
			tempAdminKommentarPfad=[tempAdminKommentarPfad stringByAppendingPathComponent:KommentarOrdnerString];
         NSString* tempAnmerkungname = [[dieAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
			tempAdminKommentarPfad=[tempAdminKommentarPfad stringByAppendingPathComponent:tempAnmerkungname];
         NSLog(@"in saveAdminMarkFuerLeser tempAdminKommentarPfad: %@",tempAdminKommentarPfad);
			if ([Filemanager fileExistsAtPath:tempAdminKommentarPfad])
			{
				NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempAdminKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
				NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
				//NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
				if (tempKommentarArrary &&[tempKommentarArrary count]>7)
				{
						NSNumber* AdminMarkNumber=[NSNumber numberWithInt:dieAdminMark];
						NSLog(@"saveMark		replaceObjectAtIndex1");
						[tempKommentarArrary replaceObjectAtIndex:kAdminMark withObject:[AdminMarkNumber stringValue]];
						NSLog(@"tempKommentarArrary nach: %@ AdminMark:%d",[tempKommentarArrary description],[AdminMarkNumber intValue]);


				}
				NSString* newKommentarString=[tempKommentarArrary componentsJoinedByString:@"\r"]; 
				//NSLog(@"newKommentarString: %@",newKommentarString);
			[newKommentarString writeToFile:tempAdminKommentarPfad atomically:YES encoding:NSMacOSRomanStringEncoding error:NULL];
			}//if Kommentar da
			else
			{
			NSLog(@"Kein Kommentar an tempAdminKommentarPfad");
			}
			
		}
		else
		{
		NSLog(@"Kein Directory an tempAdminKommentarPfad");
		}
	}
	else
	{
	NSLog(@"Kein Ordner an tempAdminKommentarPfad");
	}
	
	return erfolg;
	
}

- (BOOL)saveMarksFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme 
			  mitAdminMark:(long)dieAdminMark
			   mitUserMark:(long)dieUserMark
{
	NSLog(@"in saveMarksFuerLeser Anfang Leser: %@ Aufnahme: %@ AdminMark: %ld UserMark: %ld",derLeser,dieAufnahme,dieAdminMark,dieUserMark);
	
	BOOL erfolg;
	BOOL istDirectory; 
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSString* tempLeser=[derLeser copy];
	if ([tempLeser length]==0)
	{
		NSLog(@"saveAdminMarkFuerLeser: Kein Leser");
		return NO;
	}
	NSString* tempAufnahme;
	tempAufnahme=[dieAufnahme copy];
	NSLog(@"\n");
	NSString* tempAdminAufnahmePfad=[NSString stringWithString:AdminProjektPfad];
	tempAdminAufnahmePfad=[tempAdminAufnahmePfad stringByAppendingPathComponent:tempLeser];
	if ([Filemanager fileExistsAtPath:tempAdminAufnahmePfad])//Ordner für Aufnahmen des Lesers ist da
	{
		tempAdminAufnahmePfad=[tempAdminAufnahmePfad stringByAppendingPathComponent:tempAufnahme];
		
	}
	NSString* KommentarOrdnerString=@"Anmerkungen";
	NSString* tempAdminKommentarPfad=[[AdminProjektPfad copy] stringByAppendingPathComponent:tempLeser];
	//NSLog(@"in saveKommentarFuerLeser 1");
	if ([Filemanager fileExistsAtPath:tempAdminKommentarPfad isDirectory:&istDirectory])//Ordner des Lesers ist da
	{
		if (istDirectory)
		{
			tempAdminKommentarPfad=[tempAdminKommentarPfad stringByAppendingPathComponent:KommentarOrdnerString];
			tempAdminKommentarPfad=[tempAdminKommentarPfad stringByAppendingPathComponent:tempAufnahme];
			if ([Filemanager fileExistsAtPath:tempAdminKommentarPfad])
			{
				NSString* tempKommentarString=[NSString stringWithContentsOfFile:tempAdminKommentarPfad encoding:NSMacOSRomanStringEncoding error:NULL];
				NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
				//NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
				if (tempKommentarArrary &&[tempKommentarArrary count])
				{
					if ([tempKommentarArrary count]==8)//Zeile für Mark ist da
					{
						NSNumber* AdminMarkNumber=[NSNumber numberWithLong:dieAdminMark];
						NSLog(@"saveMark		replaceObjectAtIndex1");
						[tempKommentarArrary replaceObjectAtIndex:kAdminMark withObject:[AdminMarkNumber stringValue]];
						NSLog(@"tempKommentarArrary nach: %@ AdminMark:%@",[tempKommentarArrary description],[AdminMarkNumber stringValue]);

						NSNumber* UserMarkNumber=[NSNumber numberWithLong:dieUserMark];
						NSLog(@"saveMark		replaceObjectAtIndex1");
						[tempKommentarArrary replaceObjectAtIndex:kUserMark withObject:[UserMarkNumber stringValue]];
						NSLog(@"tempKommentarArrary nach: %@ UserMark:%@",[tempKommentarArrary description],[UserMarkNumber stringValue]);

					}
					else if([tempKommentarArrary count]==6)//Zeile für Mark ist noch nicht da
					{
						NSNumber* UserMarkNumber=[NSNumber numberWithLong:dieUserMark];
						[tempKommentarArrary insertObject:[UserMarkNumber stringValue] atIndex:5];

}
				}
				NSString* newKommentarString=[tempKommentarArrary componentsJoinedByString:@"\r"]; 
				//NSLog(@"newKommentarString: %@",newKommentarString);
			[newKommentarString writeToFile:tempAdminKommentarPfad atomically:YES encoding:NSMacOSRomanStringEncoding error:NULL];
			}//if Kommentar da
			
		}
	}
	
	return erfolg;
	
}//saveKommentar


- (IBAction)startAdminPlayer:(id)sender
{
   //[AdminQTKitPlayer setControllerVisible:YES];
   //	if (![AdminQTKitPlayer movie])
   {
      //NSLog(@"startAdminPlayer: AdminPlayPfad: %@",AdminPlayPfad);
      //NSLog(@"Sender: %@",[sender description]);
      //NSLog(@"Noch kein Movie da");
      
      
      
      [AbspieldauerFeld setStringValue:[self Zeitformatieren:AdminAbspielzeit]];
      [AbspieldauerFeld setNeedsDisplay:YES];
      
      
   }
   [AdminKommentarView setEditable:YES];
   //	[AdminBewertungfeld setEditable:YES];
   [AdminNotenfeld setEnabled:YES];
   [AdminNotenfeld setEditable:YES];
   
   [PlayTaste setEnabled:NO];
   [self setBackTaste:YES];
   
}
- (void)setBackTaste:(BOOL)istDefault
{
	
	if (istDefault)
	{
		
		[zurListeTaste setEnabled:YES];
		//NSLog(@"setBackTaste:    def");

		[zurListeTaste setKeyEquivalent:@"\r"];
	}
	else
	{
		
		[zurListeTaste setEnabled:YES];
		//NSLog(@"setBackTaste:nicht def");
		[zurListeTaste setKeyEquivalent:@""];
	}

}

- (void)TableDoppelAktion
{
	NSLog(@"Doppelaktion");
   
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


- (void)AufnahmeInPlayer:(id)sender
{
   NSLog(@"AufnahmeInPlayer: AufnahmenTab tab: %d",[[[AufnahmenTab selectedTabViewItem]identifier]intValue]);
   
   // von setLeser
   
 //  NSLog(@"AufnahmeInPlayer AdminAktuellerLeser: %@ AdminAktuelleAufnahme: %@",self.AdminAktuellerLeser,AdminAktuelleAufnahme);
   
   //   BOOL OK=[self setKommentarFuerLeser: AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
   
   
   
   NSString* tempAufnahmePfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];
   tempAufnahmePfad=[tempAufnahmePfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
   
   AdminPlayPfad =tempAufnahmePfad ;
   //NSFileManager *Filemanager=[NSFileManager defaultManager];
   //if ([Filemanager fileExistsAtPath
   /*
    if ([AdminDaten MarkForRow:hitZeile forItem:hit])
    {
    [AdminMarkCheckbox setState:YES];
    }
    else
    {
    [AdminMarkCheckbox setState:NO];
    
    }
    */
   [PlayTaste setEnabled:YES];
   
   NSLog(@"AufnahmeInPlayer tempAufnahmePfad: %@ AdminPlayPfad: %@",tempAufnahmePfad,AdminPlayPfad);
   
   //
   [self.StartPlayKnopf setEnabled:YES];
   [PlayTaste setEnabled:NO];
   switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
   {
      case 1://Alle Aufnahmen
      {
         BOOL erfolg;
         //NSLog(@"		Quelle: AufnahmeInPlayer->QTPlayer: erfolg: %d",erfolg);
         //NSLog(@"AufnahmeInPlayer	clickedRow: %d",[self.NamenListe numberOfSelectedRows]);
         // 8.12.08
         if ( [NamenListe numberOfSelectedRows] && [self AnzahlAufnahmen])
         {
            [AVAbspielplayer prepareAdminAufnahmeAnURL:[NSURL fileURLWithPath:AdminPlayPfad]];
            erfolg=[AdminFenster makeFirstResponder:zurListeTaste];
            //NSLog(@"		Quelle: AufnahmeInPlayer->QTPlayer: erfolg: %d",erfolg);
            [AdminKommentarView setEditable:YES];
            [AdminKommentarView setSelectable:YES];
            [self setLeserFuerZeile:selektierteZeile];
            //[AdminKommentarView setEditable:NO];
            [self setBackTaste:YES];
            Moviegeladen=YES;
            [ExportierenTaste setEnabled:YES];
            [LoeschenTaste setEnabled:YES];
            [AdminMarkCheckbox setEnabled:YES];
            [AdminBewertungfeld setEnabled:YES];
            
            [PlayTaste setEnabled:NO];
            [zurListeTaste setEnabled:YES];
         }
         else
         {
            NSBeep();
            [self Aufnahmezuruecklegen];
            [PlayTaste setEnabled:NO];
         }
      }break;
         
      case 2://Aufnahmen nach Namen
      {
         if ([AufnahmenTable numberOfSelectedRows])//eine Aufnahme ist selektiert
         {
            [AdminKommentarView setEditable:YES];
            [AdminKommentarView setSelectable:YES];
            
            long AufnahmenIndex=[AufnahmenTable selectedRow];
            AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:AufnahmenIndex]objectForKey:@"aufnahme"];
            self.AdminAktuellerLeser=[LesernamenPop titleOfSelectedItem];
            [self setPfadFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
            [self setKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
            
            /*
            if ([[[AufnahmenDicArray objectAtIndex:AufnahmenIndex]objectForKey:@"adminmark"]intValue])
            {
               [AdminMarkCheckbox setState:YES];
            }
            else
            {
               [AdminMarkCheckbox setState:NO];
               
            }
             */
            //				[AdminQTKitPlayer setHidden:NO];
            [self startAdminPlayer:nil];
            //				[AdminQTKitPlayer play:nil];
            [self setBackTaste:YES];
            Moviegeladen=YES;
            [ExportierenTaste setEnabled:YES];
            [LoeschenTaste setEnabled:YES];
            [AdminMarkCheckbox setEnabled:YES];
            [AdminBewertungfeld setEnabled:YES];
            //[self.PlayTaste setEnabled:NO];
         }
         else
         {
            NSBeep();
            [self Aufnahmezuruecklegen];
            [PlayTaste setEnabled:NO];
            self.AdminAktuellerLeser=@"";
            AdminAktuelleAufnahme=@"";
            [self clearKommentarfelder];
            [zurListeTaste setEnabled:NO];
            [zurListeTaste setKeyEquivalent:@""];
            [AdminMarkCheckbox setState:NO];
            [LehrerMarkCheckbox setState:NO];

            [AdminBewertungfeld setEnabled:NO];
            
            
         }
      }break;
   }//switch
}

- (void)Aufnahmebereitstellen
{
   NSLog(@"AdminProjektPfad: %@",AdminProjektPfad);
	NSLog(@"\n\nAufnahmebereitstellen: AufnahmenTab tab: %d textchanged: %d",[[[AufnahmenTab selectedTabViewItem]identifier]intValue],Textchanged);
   if (Textchanged)
   {
      [self Aufnahmezuruecklegen];
      
   }
   
   // von setLeser
  
 //  NSLog(@"Aufnahmebereitstellen AdminAktuellerLeser: %@ AdminAktuelleAufnahme: %@",self.AdminAktuellerLeser,AdminAktuelleAufnahme);
   
//   BOOL OK=[self setKommentarFuerLeser: AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
   
  
   
 //  NSString* tempAufnahmePfad=[AdminProjektPfad stringByAppendingPathComponent:AdminAktuellerLeser];
//   tempAufnahmePfad=[tempAufnahmePfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
   
 //  AdminPlayPfad =tempAufnahmePfad ;
   //NSFileManager *Filemanager=[NSFileManager defaultManager];
   //if ([Filemanager fileExistsAtPath
   /*
   if ([AdminDaten MarkForRow:hitZeile forItem:hit])
   {
      [AdminMarkCheckbox setState:YES];
   }
   else
   {
      [AdminMarkCheckbox setState:NO];
      
   }
   */
   
   [PlayTaste setEnabled:YES];

 //  NSLog(@"Aufnahmebereitstellen tempAufnahmePfad: %@ AdminPlayPfad: %@",tempAufnahmePfad,AdminPlayPfad);

   //
   [self.StartPlayKnopf setEnabled:YES];
   [PlayTaste setEnabled:NO];
	switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
	{
		case 1://Alle Aufnahmen
		{
			BOOL erfolg;
			//NSLog(@"		Quelle: AufnahmeInPlayer->QTPlayer: erfolg: %d",erfolg);
			//NSLog(@"Aufnahmebereitstellen	clickedRow: %d",[self.NamenListe numberOfSelectedRows]);
			// 8.12.08
			if ( [NamenListe numberOfSelectedRows] && [self AnzahlAufnahmen])
			{
           // NSLog(@"case 1 Aufnahmebereitstellen AdminAktuellerLeser: %@ AdminAktuelleAufnahme: %@",self.AdminAktuellerLeser,AdminAktuelleAufnahme);

               [AVAbspielplayer prepareAdminAufnahmeAnURL:[NSURL fileURLWithPath:AdminPlayPfad]];
            
         //   NSLog(@"Aufnahmebereitstellen AVAbspielplayer url: %@",[[AVAbspielplayer AufnahmeURL]path]);
            
         
            
           

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

            
            erfolg=[AdminFenster makeFirstResponder:zurListeTaste];
				//NSLog(@"		Quelle: Aufnahmebereitstellen->QTPlayer: erfolg: %d",erfolg);
				[AdminKommentarView setEditable:YES];
				[AdminKommentarView setSelectable:YES];
//				[self setLeserFuerZeile:selektierteZeile];
				//[AdminKommentarView setEditable:NO];
				[self setBackTaste:YES];
				Moviegeladen=YES;
				[ExportierenTaste setEnabled:YES];
				[LoeschenTaste setEnabled:YES];
				[AdminMarkCheckbox setEnabled:YES];
				[AdminBewertungfeld setEnabled:YES];
            
            [PlayTaste setEnabled:NO];
            [zurListeTaste setEnabled:YES];
			}
			else
			{
				NSBeep();
				[self Aufnahmezuruecklegen];
				[PlayTaste setEnabled:NO];
			}
		}break;
			
		case 2://Aufnahmen nach Namen
		{
         NSLog(@"Aufnahmen nach Namen");
			if ([AufnahmenTable numberOfSelectedRows])//eine Aufnahme ist selektiert
         {
            
            [AdminKommentarView setEditable:YES];
            [AdminKommentarView setSelectable:YES];
            
            double AufnahmenIndex=[AufnahmenTable selectedRow];
            AdminAktuelleAufnahme=[[AufnahmenDicArray objectAtIndex:AufnahmenIndex]objectForKey:@"aufnahme"];
            NSLog(@"AdminAktuelleAufnahme: %@",AdminAktuelleAufnahme);
            if ([LesernamenPop indexOfSelectedItem]>=0)
            {
               self.AdminAktuellerLeser=[LesernamenPop titleOfSelectedItem];
               [self setPfadFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
               [self setKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
               
               
               [AVAbspielplayer prepareAdminAufnahmeAnURL:[NSURL fileURLWithPath:AdminPlayPfad]];
               
               [self startAdminPlayer:nil];
               [self setBackTaste:YES];
               Moviegeladen=YES;
               [ExportierenTaste setEnabled:YES];
               [LoeschenTaste setEnabled:YES];
               [AdminMarkCheckbox setEnabled:YES];
               [AdminBewertungfeld setEnabled:YES];
            }
            else
            {
               NSLog(@"kein Leser aus LesernamenPop");
            }
         }
			else
			{
				NSBeep();
				[self Aufnahmezuruecklegen];
				[PlayTaste setEnabled:NO];
            self.AdminAktuellerLeser=@"";
				AdminAktuelleAufnahme=@"";
				[self clearKommentarfelder];
				[zurListeTaste setEnabled:NO];
				[zurListeTaste setKeyEquivalent:@""];
				[AdminMarkCheckbox setState:NO];
				[AdminBewertungfeld setEnabled:NO];

				
			}
		}break;
	}//switch
}

- (void)Aufnahmezuruecklegen
{
   NSLog(@"\n\nAufnahmezuruecklegen start  URL: %@",[[AVAbspielplayer AufnahmeURL]path]);
   
   if (AVAbspielplayer && [AVAbspielplayer AufnahmeURL])
   {
      NSLog(@"Aufnahmezuruecklegen start AVAbspielplayer belegt");
   }
   else
   {
       NSLog(@"Aufnahmezuruecklegen start AVAbspielplayer nicht belegt");
      return;
   }
   NSLog(@"Aufnahmezuruecklegen start  belegt");
   [AVAbspielplayer toStartTempAufnahme];
   
   [self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:NO];
   [self.RewindKnopf setEnabled:NO];
   [self.ForewardKnopf setEnabled:NO];
   [self.StartPlayKnopf setEnabled:NO];
   [AbspieldauerFeld setStringValue:@"00:00"];
   [AufnahmedauerFeld setStringValue:@"00:00"];
   [Abspielanzeige setLevel:0.0];
   [Abspielanzeige setNeedsDisplay:YES];

    [self setBackTaste:NO];
   [zurListeTaste setEnabled:NO];
   [PlayTaste setEnabled:[NamenListe numberOfSelectedRows]];
   
   [AbspieldauerFeld setStringValue:@""];
   //NSLog(@"vor saveKommentarFuerLeser");
   if ([self.AdminAktuellerLeser length]&&[AdminAktuelleAufnahme length]&&Textchanged)
	  {
        BOOL OK=[self saveKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
        if(OK)
        {
           Kommentarsaved = YES;
        }
         //AdminAktuellerLeser=@"";//herausgenommen infolge KommentarfürLeser
        
        AdminAktuelleAufnahme=@"";
        NSLog(@"Aufnahmezuruecklegen AdminMark: %ld UserMark: %ld",(long)[AdminMarkCheckbox state],(long)[UserMarkCheckbox state]);
        BOOL saveKommentarOK = [self saveMarksFuerLeser:self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme mitAdminMark: [AdminMarkCheckbox state] mitUserMark:[UserMarkCheckbox state]];
        
        NSLog(@"Aufnahmezuruecklegen saveKommentarOK: %d",saveKommentarOK);
     }
   [self clearKommentarfelder];
   [AdminKommentarView setEditable:NO];
   [AdminKommentarView setSelectable:NO];
   [AdminBewertungfeld setEnabled:NO];
   [AdminNotenfeld setEnabled:NO];
   [AdminNotenfeld setEditable:NO];
   Moviegeladen=NO;
   [ExportierenTaste setEnabled:NO];
   [LoeschenTaste setEnabled:NO];
   Textchanged=NO;
   
   //[AdminMarkCheckbox setState:NO];
   //[self.MarkCheckbox setEnabled:NO];
   
    NSLog(@"Aufnahmezuruecklegen end\n\n");
}

- (void)backZurListe:(id)sender
{
	/*
	[AdminQTKitPlayer pause :nil];
	[AdminQTKitPlayer gotoBeginning:nil];
	[AdminQTKitPlayer setMovie:nil];
    */
   
   [AVAbspielplayer stopTempAufnahme];
   
	NSString* EnterKeyQuelle;
	EnterKeyQuelle=@"MovieView";
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AdminEnterKey" object:EnterKeyQuelle];
//	[AdminQTKitPlayer setHidden:YES];
	[self setBackTaste:NO];
	[zurListeTaste setEnabled:NO];
	[PlayTaste setEnabled:[NamenListe numberOfSelectedRows]];
	
	[AbspieldauerFeld setStringValue:@""];
	//NSLog(@"vor saveKommentarFuerLeser");
	if ([self.AdminAktuellerLeser length]&&[AdminAktuelleAufnahme length]&&Textchanged)
	  {
		BOOL OK=[self saveKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
		
		//AdminAktuellerLeser=@"";//herausgenommen infolge KommentarfürLeser
		
		AdminAktuelleAufnahme=@"";
		NSLog(@"backZurListe AdminMark: %ld UserMark: %ld",(long)[AdminMarkCheckbox state],(long)[UserMarkCheckbox state]);
		[self saveMarksFuerLeser:self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme mitAdminMark: [AdminMarkCheckbox state] mitUserMark:[UserMarkCheckbox state]];

	  }
	[self clearKommentarfelder];	
	[AdminKommentarView setEditable:NO];
	[AdminKommentarView setSelectable:NO];
	[AdminBewertungfeld setEnabled:NO];
	[AdminNotenfeld setEnabled:NO];
	[AdminNotenfeld setEditable:NO];
	Moviegeladen=NO;
	[ExportierenTaste setEnabled:NO];
	[LoeschenTaste setEnabled:NO];
	Textchanged=NO;
	
	//[AdminMarkCheckbox setState:NO];
//	[AdminMarkCheckbox setEnabled:NO];
}
- (IBAction)reportFensterschliessen:(id)sender
{
   [self resetAdminPlayer];
      [self dismissController:NULL];
  // [[self.view window]orderOut:nil];
}

#pragma mark Player

#pragma mark Player

- (void)setPlayerURL:(NSURL*)dieURL
{
   
   [AVAbspielplayer prepareAdminAufnahmeAnURL:dieURL];
   
   //double dur = AVAbspielplayer.duration;
   

//   NSLog(@"setPlayerURL prepareAdminAufnahmeAnURL err: %@ dur: %f",err, dur);
   
}

- (IBAction)startAVPlay:(id)sender
{
   NSLog(@"startAVPlay URL: %@",[AVAbspielplayer AufnahmeURL]);
   // [AVRecorder setPlaying:YES];
   [self.BackKnopf setEnabled:YES];
   [self.StopPlayKnopf setEnabled:YES];
   [self.RewindKnopf setEnabled:YES];
   [self.ForewardKnopf setEnabled:YES];
   
   [AbspieldauerFeld setStringValue:@"00:00"];
   
   [AVAbspielplayer playAdminAufnahme];
   float dur = ([AVAbspielplayer duration]);
   [Abspielanzeige setMax:dur];
   NSLog(@"startAVPlay dur: %f",dur);
   [Abspielanzeige setNeedsDisplay:YES];
   //[self.Fortschritt setDoubleValue:0];
   [self invalTimer];

   posTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(posAnzeigeFunktion:)
                                           userInfo:nil
                                            repeats:YES];
   
   //NSRunLoop* runloop = [NSRunLoop currentRunLoop];
//   [runloop addTimer:posTimer forMode:NSRunLoopCommonModes];
 
}

- (void)invalTimer
{
   if ( [posTimer isValid])
   {
      [posTimer invalidate];
   }
}

- (void)posAnzeigeFunktion:(NSTimer*)timer
{
   NSTimeInterval pos =AVAbspielplayer.position;
   NSTimeInterval dur =AVAbspielplayer.duration;
   if (pos)
   {
      //NSLog(@"AdminPlayer posAnzeigeFunktion pos: %f dur: %f",pos,dur);
      [self setAbspielanzeigeAnPos:pos mitDur:dur];
     // NSNotificationCenter * nc=[NSNotificationCenter defaultCenter];
      //[nc postNotificationName:@"abspielpos" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
       //                                                            [NSNumber numberWithDouble:pos] ,@"pos",
        //                                                           [NSNumber numberWithDouble:dur] ,@"dur",nil]];
      
      if (pos == dur)
      {
         [posTimer invalidate];
      }
   }
}


- (IBAction)stopAVPlay:(id)sender
{
   NSLog(@"stopAVPlay");
   [AVAbspielplayer stopTempAufnahme];
   [self.BackKnopf setEnabled:YES];
   // [self.StopPlayKnopf setEnabled:NO];
   
}

- (IBAction)backAVPlay:(id)sender
{
   NSLog(@"backAVPlay");
   [AVAbspielplayer toStartTempAufnahme];
   
   //[self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:YES];
}

- (IBAction)rewindAVPlay:(id)sender
{
   NSLog(@"backAVPlay");
   [AVAbspielplayer rewindTempAufnahme];
  // [self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:YES];
}

- (IBAction)forewardAVPlay:(id)sender
{
   NSLog(@"backAVPlay");
   [AVAbspielplayer forewardTempAufnahme];
   //[self.BackKnopf setEnabled:NO];
   [self.StopPlayKnopf setEnabled:YES];
}

- (void)clearAVPlay
{
   [AVAbspielplayer toStartTempAufnahme];
   [Abspielanzeige setLevel:0.0];
   [Abspielanzeige setNeedsDisplay:YES];

}

- (void)setAbspielanzeigeAnPos:(double)pos mitDur:(double)dur

{
   
 //  double pos;
 //  double dur;
   int posint;
   
    posint =(int)pos;

   //NSLog(@"AdminPlayer setAbspielanzeigeAnPos dur: %2.2f pos: %2.2f posint: %d",dur,pos,posint);
   
   if (dur - pos < 0.1)
   {
      NSLog(@"Ende erreicht");
      NSNumber* durationNumber=[NSNumber numberWithDouble:[AVAbspielplayer duration]];
      posint=[durationNumber intValue];
      
   }
   //NSLog(@"duration: %2.2d",AufnahmeZeit);
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
   //NSLog(@"MinutenString: %@ SekundenString: %@",MinutenString,SekundenString);
   [AbspieldauerFeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   
   
   
   //   int max =[self.Fortschritt maxValue];
   //NSLog(@"AbspielPosAktion pos: %f dur: %f wert: %f",pos,dur,pos/dur*1024 );
   //  [self.Abspielanzeige setMax:dur];
   [Abspielanzeige setLevel:pos];
   [Abspielanzeige display];
   
   
   
   //  [self.Fortschritt setDoubleValue:(pos+1)/dur*max];
}

- (void)AbspielPosAktion:(NSNotification*)note
{
   
   double pos;
   double dur;
   int posint=0;
   if ([[note userInfo]objectForKey:@"pos"])
   {
      NSNumber* posNumber=[[note userInfo]objectForKey:@"pos"];
      pos=[posNumber doubleValue];
      posint =[posNumber intValue];
      
   }
   if ([[note userInfo]objectForKey:@"dur"])
   {
      NSNumber* durNumber=[[note userInfo]objectForKey:@"dur"];
      dur=[durNumber doubleValue];
   }
//   NSLog(@"AdminPlayer AbspielPosAktion dur: %2.2f pos: %2.2f",dur,pos);
   
   if (dur - pos < 0.1)
   {
      NSLog(@"Ende erreicht");
      NSNumber* durationNumber=[NSNumber numberWithDouble:[AVAbspielplayer duration]];
      posint=[durationNumber intValue];

   }
   //NSLog(@"duration: %2.2d",AufnahmeZeit);
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
   [AbspieldauerFeld setStringValue:[NSString stringWithFormat:@"%@:%@",MinutenString, SekundenString]];
   
   
   
//   int max =[self.Fortschritt maxValue];
   //NSLog(@"AbspielPosAktion pos: %f dur: %f wert: %f",pos,dur,pos/dur*1024 );
   //  [self.Abspielanzeige setMax:dur];
   [Abspielanzeige setLevel:pos];
   [Abspielanzeige display];
   
   
   
 //  [self.Fortschritt setDoubleValue:(pos+1)/dur*max];
}




# pragma mark end Player

- (void)setMark:(BOOL)derStatus
{
	[AdminMarkCheckbox setState:derStatus];
}

- (long)Mark
{
	return [AdminMarkCheckbox state];
}

- (void)AufnahmeMarkieren:(id)sender
{

	NSLog(@"Aufnahmemarkieren: setMark: %ld zeile: %ld",(long)[sender state],(long)[NamenListe selectedRow]);
		switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
		{
		case 1://Alle Aufnahmen
		{
			long tempZeile=[NamenListe selectedRow];
			if(tempZeile>=0)
			{
				int tempItem=[[[AdminDaten dataForRow:tempZeile]objectForKey:@"aufnahmen"]intValue];
				
				[AdminDaten setMark:[sender state] forRow:[NamenListe selectedRow] forItem:tempItem];
				[NamenListe reloadData];
			}
			else
			{
				NSLog(@"keine Zeile aktiviert");
				[sender setState:NO];
				return;
			}
			
			
			
			
			
		}break;
		
		case 2://nach Namen
		{
		NSString* tempLeser=[LesernamenPop titleOfSelectedItem];
		int LeserZeile=[AdminDaten ZeileVonLeser:tempLeser];//Zeile von tempLeser in AdminDaten
		long AufnahmenZeile=[AufnahmenTable selectedRow];		//Zeile in der AufnahmenTable,
		// ist auch Zeile der Aufnahme für tempLeser im AufnahmenArray in AdminDaten
		//NSLog(@"AufnahmeMarkieren tempLeser: %@ LeserZeile: %d AufnahmenZeile: %d",tempLeser,LeserZeile,AufnahmenZeile);
		[AdminDaten setMark:[sender state] forRow:LeserZeile forItem:AufnahmenZeile];
		[self setAdminMark:[sender state] fuerZeile:[AufnahmenTable selectedRow]];
		
		
		}break;
		}//switch
		
		
		NSFileManager *Filemanager=[NSFileManager defaultManager];
		
		NSString* tempAufnahmePfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];
		tempAufnahmePfad=[tempAufnahmePfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
		
		NSLog(@"Aufnahmemarkieren: tempAufnahmePfad: %@",tempAufnahmePfad);
		
		
		
		
		if ([Filemanager fileExistsAtPath:tempAufnahmePfad])
		  {
			//NSLog(@"File exists");
			[self saveAdminMarkFuerLeser:self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme
			  mitAdminMark:[AdminMarkCheckbox state]];
			
			
			
		  }//file exists
}

- (BOOL)AufnahmeIstMarkiertAnPfad:(NSString*)derAufnahmePfad
{
	BOOL istMarkiert=NO;
   
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSString* AnmerkungenPfad=[[derAufnahmePfad stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Anmerkungen"];
	
   NSString* tempPfad =[[[derAufnahmePfad lastPathComponent]stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
	AnmerkungenPfad=[AnmerkungenPfad stringByAppendingPathComponent:tempPfad];
	
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

- (BOOL)AufnahmeIstVomUserMarkiertAnPfad:(NSString*)derAufnahmePfad
{
   BOOL istMarkiert=NO;
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSString* AnmerkungenPfad=[[derAufnahmePfad stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Anmerkungen"];
   
   NSString* tempPfad =[[[derAufnahmePfad lastPathComponent]stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
   AnmerkungenPfad=[AnmerkungenPfad stringByAppendingPathComponent:tempPfad];
   
   if ([Filemanager fileExistsAtPath:AnmerkungenPfad])
   {
      //NSLog(@"File exists an Pfad: %@",derAufnahmePfad);
      NSString* tempKommentarString=[NSString stringWithContentsOfFile:AnmerkungenPfad encoding:NSMacOSRomanStringEncoding error:NULL];
      NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
      //NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
      if (tempKommentarArrary &&[tempKommentarArrary count])
      {
         NSNumber* UserMarkNumber=[tempKommentarArrary objectAtIndex:kUserMark];
         //NSLog(@"istMarkiert		AdminMarkNumber: %d",[AdminMarkNumber intValue]);
         
         istMarkiert=[UserMarkNumber intValue];
         
      }
      
      
   }//file exists
   return istMarkiert;
}



- (BOOL)AufnahmeIstMarkiertAnAnmerkungPfad:(NSString*)derAnmerkungPfad
{
	BOOL istMarkiert=NO;
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	if ([Filemanager fileExistsAtPath:derAnmerkungPfad])
	{
		//NSLog(@"File exists an Pfad: %@",derAnmerkungPfad);
		NSString* tempKommentarString=[NSString stringWithContentsOfFile:derAnmerkungPfad encoding:NSMacOSRomanStringEncoding error:NULL];
		NSMutableArray* tempKommentarArrary=(NSMutableArray *)[tempKommentarString componentsSeparatedByString:@"\r"];
		//NSLog(@"tempKommentarArrary vor: %@",[tempKommentarArrary description]);
		if (tempKommentarArrary &&[tempKommentarArrary count]>7)
		{
			NSNumber* AdminMarkNumber=[tempKommentarArrary objectAtIndex:kAdminMark];
			//NSLog(@"istMarkiert		AdminMarkNumber: %d",[AdminMarkNumber intValue]);
			
			istMarkiert=[AdminMarkNumber intValue];
			
		}
		
		
	}//file exists
	return istMarkiert;
}



- (void)AlleMarkierungenEntfernen
{
	NSAlert *Warnung = [[NSAlert alloc] init];
	[Warnung addButtonWithTitle:@"Markierungen entfernen"];
	[Warnung addButtonWithTitle:@"Abbrechen"];
	[Warnung setMessageText:@"Markierungen entfernen?"];
	[Warnung setInformativeText:@"Sollen wirklich alle Markierungen von allen Lesern entfernt werden?"];
	[Warnung setAlertStyle:NSWarningAlertStyle];
   
   NSModalResponse antwort = [Warnung runModal];
   if (antwort==NSAlertFirstButtonReturn)
   {
      //NSLog(@"alertDidEnd: NSAlertFirstButtonReturn");
      [self Markierungenreset];
      
   }
}


- (void)MarkierungEntfernenFuerZeile:(long)dieZeile
{
	NSDictionary* tempZeilenDic=[AdminDaten dataForRow:dieZeile];
	NSLog(@"tempZeilenDic: %@",[tempZeilenDic description]);

	NSString* tempName=[tempZeilenDic objectForKey:@"namen"];
	int tempAnzahlAufnahmen=[[tempZeilenDic objectForKey:@"anz"]intValue];
	
		
		//int x=[[[self.NamenListe tableColumnWithIdentifier:@"aufnahmen"]dataCellForRow:tempZeile]indexOfSelectedItem];
		//NSLog(@"tempZeile: %d  tempItem: %d  x: %d",tempZeile,tempItem,x);
		if (tempAnzahlAufnahmen>0)
		{
			int i=0;
			for (i=0;i<tempAnzahlAufnahmen;i++)
			{
				[AdminDaten setMark:NO forRow:dieZeile forItem:i];
				
			}//for i
			
		}//tempItem>0
		[NamenListe reloadData];
		NSFileManager *Filemanager=[NSFileManager defaultManager];
		NSString* tempLeserArchivPfad=[AdminProjektPfad stringByAppendingPathComponent:tempName];
		NSLog(@"MarkierungEntfernenFuerZeile: tempLeserArchivPfad: %@",tempLeserArchivPfad);

		BOOL istOrdner=NO;
		if ([Filemanager fileExistsAtPath:tempLeserArchivPfad isDirectory:&istOrdner]&&istOrdner)//Ordner ist da
		{
		// Markierung in Anmerkungen loeschen
		NSString* tempAnmerkungenPfad=[tempLeserArchivPfad stringByAppendingPathComponent:@"Anmerkungen"];
		if ([Filemanager fileExistsAtPath:tempAnmerkungenPfad isDirectory:&istOrdner]&&istOrdner)//Ordner ist da
		{
		NSLog(@"Anmerkungen sind da");
		NSMutableArray* tempAnmerkungenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:tempAnmerkungenPfad error:NULL]];

			if ([tempAnmerkungenArray count])
			{
				if ([[tempAnmerkungenArray objectAtIndex:0] hasPrefix:@".DS"])					//Unsichtbare Ordner entfernen
				{
					[tempAnmerkungenArray removeObjectAtIndex:0];
				}
				if ([tempAnmerkungenArray containsObject:@"Anmerkungen"]) // Ordner Kommentar entfernen
				{
					[tempAnmerkungenArray removeObject:@"Anmerkungen"];
				}
				
				NSEnumerator* AnmerkungenEnum=[tempAnmerkungenArray objectEnumerator];
				id eineAnmerkung;
				while(eineAnmerkung=[AnmerkungenEnum nextObject])
				{
					NSString* tempAnmerkungPfad=[tempAnmerkungenPfad stringByAppendingPathComponent:eineAnmerkung];
					if ([Filemanager fileExistsAtPath:tempAnmerkungPfad])
					{
						
						NSLog(@"File exists: %@",tempAnmerkungPfad);
						[self saveAdminMarkFuerLeser:tempName FuerAufnahme:eineAnmerkung 
							mitAdminMark:0];

						
					}//file exists
					
				}//while
			}//count

		}
		
		
		
		
		
		
		
		
		// Markierung in Aufnahme loeschen
			NSMutableArray* tempAufnahmenArray=[[NSMutableArray alloc] initWithArray:[Filemanager contentsOfDirectoryAtPath:tempLeserArchivPfad error:NULL]];

			if ([tempAufnahmenArray count])
			{
				if ([[tempAufnahmenArray objectAtIndex:0] hasPrefix:@".DS"])					//Unsichtbare Ordner entfernen
				{
					[tempAufnahmenArray removeObjectAtIndex:0];
				}
				if ([tempAufnahmenArray containsObject:@"Anmerkungen"]) // Ordner Kommentar entfernen
				{
					[tempAufnahmenArray removeObject:@"Anmerkungen"];
				}
				
			}//count
		}//Ordner ist da
		else
		{
			NSLog(@"Kein Ordner da");	
		}
		[NamenListe reloadData];

}


- (void)MarkierungenEntfernen
{
	long tempZeile=[NamenListe selectedRow];
	if(tempZeile>=0)
	  {
		NSString* tempLeser=[[AdminDaten dataForRow:tempZeile]objectForKey:@"namen"];
		
		MarkierungFenster=[[rMarkierung alloc]init];
	    long modalAntwort;
		SEL MarkierungSelektor;
		MarkierungSelektor=@selector(sheetDidEnd: returnCode: contextInfo:);
		NSLog(@"MarkierungenWeg: tempLeser: %@",tempLeser);
		[MarkierungFenster setNamenString:tempLeser];
		[NSApp beginSheet:[MarkierungFenster window]
		   modalForWindow:AdminFenster
			modalDelegate:MarkierungFenster
		 //didEndSelector:EntfernenSelektor 
		   didEndSelector:NULL
			  contextInfo:@"Markierung"];
		[MarkierungFenster setNamenString:tempLeser];
		modalAntwort = [NSApp runModalForWindow:[MarkierungFenster window]];
		
		
		[NSApp endSheet:[MarkierungFenster window]];
		
		[[MarkierungFenster window] orderOut:NULL];   
		NSLog(@"endSheet: Antwort: %ld",modalAntwort);
		
	  }//tempZeile>=0

}



- (void)reportUserMark:(id)sender
{
    NSLog(@"reportUserMark state: %ld tab: %d",(long)[sender state],[[[AufnahmenTab selectedTabViewItem]identifier]intValue] );
   Textchanged = YES;
	switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
	{
		case 2:// Aufnahmen nach Namen
		{
			long ZeilenIndex=[AufnahmenTable selectedRow];
         
			[self setUserMark:[sender state] fuerZeile:ZeilenIndex];
		}break;
	}//switch
}

- (void)reportAdminMark:(id)sender
{
   NSLog(@"reportAdminMark state: %ld tab: %d row: %f",(long)[sender state],[[[AufnahmenTab selectedTabViewItem]identifier]intValue],[self selektierteZeile] );
   Textchanged = YES;
   
   switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
	{
   case 1:
      {
         
         int ZeilenIndex=[NamenListe selectedRow];
         //int datenZeilenIndex=[[NamenListe dataSource] objectAtIndex:ZeilenIndex];
         
         //NSLog(@"AdminProjektArray data: %@",[[(rAdminDS*)[NamenListe dataSource]dataForRow:ZeilenIndex]description]);

         [self setAdminMark:[sender state] fuerZeile:ZeilenIndex];

      }break;
		case 2:// Aufnahmen nach Namen
		{
			int ZeilenIndex=[AufnahmenTable selectedRow];
			[self setAdminMark:[sender state] fuerZeile:ZeilenIndex];
		}break;
	}//switch
}

#pragma mark AufnahmeLoeschen

- (IBAction) AufnahmeLoeschen:(id)sender
{
   NSLog(@"Projekt: %@",[AdminProjektPfad lastPathComponent]);
   long projektindex = [[AdminProjektArray valueForKey:@"projekt"]indexOfObject:[AdminProjektPfad lastPathComponent]];
   NSLog(@"Admin: %@",[[AdminProjektArray objectAtIndex:projektindex ] description]);
   
   
   NSMutableDictionary* EntfernenDic=[NSMutableDictionary dictionaryWithObject:[AdminProjektPfad lastPathComponent] forKey:@"projekt"];
   [EntfernenDic setObject: AdminAktuelleAufnahme forKey:@"aufnahme"];
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"adminentfernen" object:self userInfo:EntfernenDic];

   int zeile =[AdminDaten ZeileVonLeser:[LesernamenPop titleOfSelectedItem]];
   NSLog(@"AufnahmeLoeschen Daten vor: %@",[[AdminDaten AufnahmeFilesFuerZeile: zeile]description]);
   
   NSMutableArray* tempAufnahmeFilesArray = (NSMutableArray*)[AdminDaten AufnahmeFilesFuerZeile: zeile];
   long entfernenzeile = [tempAufnahmeFilesArray indexOfObject:AdminAktuelleAufnahme];
   NSLog(@"AufnahmeLoeschen Daten auf Zeile: %d",entfernenzeile);
   
  // return;
	EntfernenFenster=[[rEntfernen alloc]init];
	//NSLog(@"AdminPlayer EntfernenFenster init");
	
	//[EntfernenFenster showWindow:self];
	
    long modalAntwort;
	SEL EntfernenSelektor;
	//EntfernenSelektor=@selector(sheetDidEnd: returnCode: contextInfo:);
   
   /*
    [NSApp beginSheet:[EntfernenFenster window]
	   modalForWindow:AdminFenster
		modalDelegate:EntfernenFenster
	 //didEndSelector: EntfernenSelektor
	   didEndSelector:NULL
		  contextInfo:@"Entfernen"];
   
   */
	
    modalAntwort = [NSApp runModalForWindow:[EntfernenFenster window]];
   switch (modalAntwort)
   {
      case 0:
      {
         NSLog(@"AufnahmeLoeschen cancel antwort: %ld AdminAktuelleAufnahme: %@",modalAntwort,AdminAktuelleAufnahme);
         
      }break;
      case 10://in den Papierkorb
      {
         NSLog(@"AufnahmeLoeschen in den Papierkorb antwort: %ld AdminAktuelleAufnahme: %@",modalAntwort,AdminAktuelleAufnahme);
         
         [self inPapierkorb:AdminAktuelleAufnahme];
      }break;
      case 11://ins Magazin
      {
         NSLog(@"AufnahmeLoeschen ins Magazin antwort: %ld AdminAktuelleAufnahme: %@",modalAntwort,AdminAktuelleAufnahme);
         [self insMagazin:AdminAktuelleAufnahme];
      }break;
      case 12://ex und hopp
      {
         [self ex:AdminAktuelleAufnahme];
      }break;
   }
   
 
   
	NSLog(@"AufnahmeLoeschen: Antwort: %d",modalAntwort);
	//NSLog(@"beginSheet: Antwort: %d",modalAntwort);
  //  [NSApp endSheet:[self.view window]];
   
   
 
	
	[[EntfernenFenster window] orderOut:NULL];
   
   
   NSString* tempAnmerkungName = [[AdminAktuelleAufnahme stringByDeletingPathExtension]stringByAppendingPathExtension:@"txt"];
   NSString* tempAnmerkungenPfad = [[[AdminPlayPfad stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Anmerkungen"]stringByAppendingPathComponent:tempAnmerkungName];
   
   //NSLog(@"tempAnmerkungenPfad: %@",tempAnmerkungenPfad);
   BOOL erfolg=NO;
   NSError* err;
   if ([[NSFileManager defaultManager]fileExistsAtPath:tempAnmerkungenPfad])
   {
      NSLog(@"Anmerkung noch da");
      erfolg =[[NSFileManager defaultManager]removeItemAtPath:tempAnmerkungenPfad error: &err];
      NSLog(@"Anmerkung erfolg: %d error: %@",erfolg,err);

   }
   else
   {
      NSLog(@"Anmerkung nicht mehr da");
     }
   
   if ([[NSFileManager defaultManager]fileExistsAtPath:AdminPlayPfad])
   {
      NSLog(@"Aufnahme noch da");
      erfolg =[[NSFileManager defaultManager]removeItemAtPath:AdminPlayPfad error: &err];
      NSLog(@"Aufnahme erfolg: %d error: %@",erfolg,err);

   }
   else
   {
      NSLog(@"Aufnahme nicht mehr da");
   }

   [tempAufnahmeFilesArray removeObjectAtIndex:entfernenzeile];
   
   NSLog(@"AufnahmeLoeschen tempAufnahmeFilesArray nach: %@",[tempAufnahmeFilesArray description]);
   
   zeile =[AdminDaten ZeileVonLeser:[LesernamenPop titleOfSelectedItem]];
   NSLog(@"AufnahmeLoeschen Daten nach: %@",[[AdminDaten AufnahmeFilesFuerZeile: zeile]description]);

   //NSLog(@"AufnahmeLoeschen rowData: %@",[[AdminDaten rowData]description]);
   
  // [AdminDaten deleteZeileMitAufnahme:AdminAktuelleAufnahme];
//   NSLog(@"AufnahmeLoeschen deleteZeileMitAufnahme: %d", [AdminDaten deleteZeileMitAufnahme:AdminAktuelleAufnahme]);
   NSLog(@"AufnahmeLoeschen AufnahmeFiles: %@",[[AdminDaten AufnahmeFiles]description]);
  //[AdminDaten set];
   [AufnahmenTable reloadData];
   
   [NamenListe reloadData];
	
	return;	
	
}

- (void)MarkCheckboxAktion:(NSNotification*)note
{
   NSLog(@"AdminPlayer MarkCheckboxAktion  note: %@",[[note userInfo]description]);
   int tempmark = [[[note userInfo]objectForKey:@"adminstate"]intValue];
   
//   [UserMarkCheckbox setState:tempmark];
   [AdminMarkCheckbox setState:tempmark];
}

- (void)EntfernenNotificationAktion:(NSNotification*)note
{
	int var=[[[note userInfo]objectForKey:@"EntfernenVariante"]intValue];
	NSLog(@"AdminPlayer EntfernenNotificationAktion  Variante: %d AdminAktuelleAufnahme: %@",var,AdminAktuelleAufnahme);
	switch (var)
	  {
		case 0://in den Papierkorb
		  {
			  //NSLog(@"EntfernenNotificationAktion AdminAktuelleAufnahme: %@",AdminAktuelleAufnahme);
			  
			  [self inPapierkorb:AdminAktuelleAufnahme];
		  }break;
		case 1://ins Magazin
		  {
			  [self insMagazin:AdminAktuelleAufnahme];
		  }break;
		case 2://ex und hopp
		  {
			  [self ex:AdminAktuelleAufnahme];
		  }break;
	  }//switch
	[self resetAdminPlayer];
	//NSLog(@"EntfernenNotificationAktion: AdminLeseboxPfad: %@",AdminLeseboxPfad);
	[self setAdminPlayer:AdminLeseboxPfad inProjekt:[AdminProjektPfad lastPathComponent]];

}

- (void) moveFileToUserTrash:(NSString *)filePath 
{
    CFURLRef        trashURL;
    FSRef           trashFolderRef;
    CFStringRef     trashPath;
    OSErr           err;
    NSFileManager   *mgr = [NSFileManager defaultManager];
    err = FSFindFolder(kUserDomain, kTrashFolderType, kDontCreateFolder, &trashFolderRef);
    if (err == noErr) 
	  {
		trashURL = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &trashFolderRef);
		if (trashURL) 
		  {
			trashPath = CFURLCopyFileSystemPath (trashURL, kCFURLPOSIXPathStyle);
			//if (![mgr movePath:filePath toPath:[(NSString *)trashPath stringByAppendingPathComponent:[filePath lastPathComponent]] handler:nil])
         //{
			if (![mgr moveItemAtURL:[NSURL fileURLWithPath:filePath]  toURL:[NSURL fileURLWithPath:[(__bridge NSString*)trashPath stringByAppendingPathComponent:[filePath lastPathComponent]]] error:nil])	
                                                                                             
         {
            NSLog(@"Move operation did not succeed!");
        }
        }// if trashURL
    }
	
}

- (int) fileInPapierkorb:(NSString*) derFilepfad
{
	long tag;
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
        //trashDir=[trashDir stringByAppendingPathComponent:@".Trash"];
        
        NSString* sourceDir=[derFilepfad stringByDeletingLastPathComponent];
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        
        NSArray * vols=[workspace mountedLocalVolumePaths];
        NSLog(@"fileInPapierkorb volumes: %@   sourceDir:%@ trashDir: %@",[vols description],sourceDir, trashDir);
        
        NSArray *files = [NSArray arrayWithObject:[derFilepfad lastPathComponent]];
        succeeded = [workspace performFileOperation:NSWorkspaceRecycleOperation
                                             source:sourceDir
                                        destination:@""
                                              files:files
                                                tag:&tag];
        return tag;//0 ist OK
     }
	else
	  {	

		NSString* sourceDir=derFilepfad;
		int removeIt=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:sourceDir] error:nil];
		//NSLog(@"removePath: removeIt: %d",removeIt);
		return 0;

	  }
}


- (void)inPapierkorb:(NSString*)dieAufnahme
{
   BOOL istDirectory;
   NSFileManager* Filemanager=[NSFileManager defaultManager];
   NSLog(@"Papierkorb: %@",dieAufnahme);
   NSString* tempLeserPfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];//Leserordner im Archiv
   if ([self.AdminAktuellerLeser length]&&[Filemanager fileExistsAtPath:tempLeserPfad isDirectory:&istDirectory]&&istDirectory)
   {
      NSString* tempAufnahmePfad=[tempLeserPfad stringByAppendingPathComponent:dieAufnahme];//Pfad akt. Aufn.
      NSLog(@"Papierkorb tempAufnahmePfad: %@",tempAufnahmePfad);
      if ([AdminAktuelleAufnahme length]&&[Filemanager fileExistsAtPath:tempAufnahmePfad isDirectory:&istDirectory]&&!istDirectory)
      {
         //[self moveFileToUserTrash:tempAufnahmePfad];
         int result=[self fileInPapierkorb:tempAufnahmePfad];//0 ist OK
         NSLog(@"inPapierkorb result von Aufnahme: %d",result);
      }
      NSString* tempKommentarPfad=[tempLeserPfad   stringByAppendingPathComponent:@"Anmerkungen"];
      NSLog(@"Papierkorb tempKommentarPfad: %@",tempKommentarPfad);
      if ([Filemanager fileExistsAtPath:tempKommentarPfad isDirectory:&istDirectory]&&istDirectory)
      {
         tempKommentarPfad=[tempKommentarPfad stringByAppendingPathComponent:[dieAufnahme stringByDeletingPathExtension]];
         NSLog(@"Papierkorb tempKommentarPfad 2: %@",tempKommentarPfad);
         if ([Filemanager fileExistsAtPath:tempKommentarPfad])
         {
            //[self moveFileToUserTrash:tempKommentarPfad];
            int result=[self fileInPapierkorb:tempKommentarPfad];
            NSLog(@"inPapierkorb ohne extension result von Kommentar: %d",result);
         }
         else
         {
            tempKommentarPfad=[tempKommentarPfad stringByAppendingPathExtension:@"txt"];
            if ([Filemanager fileExistsAtPath:tempKommentarPfad])
            {
               //[self moveFileToUserTrash:tempKommentarPfad];
               int result=[self fileInPapierkorb:tempKommentarPfad];
               NSLog(@"inPapierkorb mit extension result von Kommentar: %d",result);
               
            }
            
         }
         
      }
   }
}

- (void)inPapierkorbMitPfad:(NSString*)derAufnahmePfad
{
	BOOL istDirectory;
	NSString* tempAufnahmePfad=[derAufnahmePfad copy];//Pfad akt. Aufn.
	NSFileManager* Filemanager=[NSFileManager defaultManager];
	//NSLog(@"inPapierkorbmitPfad: %@",derAufnahmePfad);
	NSString* tempLeserOrdnerPfad=[tempAufnahmePfad stringByDeletingLastPathComponent];//Leserordner im Archiv
	if ([Filemanager fileExistsAtPath:tempLeserOrdnerPfad isDirectory:&istDirectory]&&istDirectory)
		{
		if ([Filemanager fileExistsAtPath:tempAufnahmePfad])
			{
				//[self moveFileToUserTrash:tempAufnahmePfad];	
				int result=[self fileInPapierkorb:tempAufnahmePfad];//0 ist OK
				//NSLog(@"inPapierkorb result von Aufnahme: %d",result);
			}
			NSString* tempKommentarOrdnerPfad=[tempLeserOrdnerPfad stringByAppendingPathComponent:@"Anmerkungen"];
			if ([Filemanager fileExistsAtPath:tempKommentarOrdnerPfad isDirectory:&istDirectory]&&istDirectory)
			{
				NSString* tempKommentarPfad=[tempKommentarOrdnerPfad stringByAppendingPathComponent:[tempAufnahmePfad lastPathComponent]];
				if ([Filemanager fileExistsAtPath:tempKommentarPfad])
				{
					//[self moveFileToUserTrash:tempKommentarPfad];
					int result=[self fileInPapierkorb:tempKommentarPfad];
					//NSLog(@"inPapierkorb result von Kommentar: %d",result);
				}
				
			}
			
		}
}

- (void)insMagazin:(NSString*)dieAufnahme
{
   NSLog(@"Magazin");
   BOOL istDirectory;
   NSFileManager* Filemanager=[NSFileManager defaultManager];
   NSString* tempMagazinPfad=[[[AdminProjektPfad stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Magazin"];
   NSLog(@"insMagazin: AdminProjektPfad: %@ tempMagazinPfad: \n%@\n",AdminProjektPfad,tempMagazinPfad);
   if (![Filemanager fileExistsAtPath:tempMagazinPfad isDirectory:&istDirectory])
	  {
        BOOL magazinOK=[Filemanager createDirectoryAtPath:tempMagazinPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
        if (!magazinOK)
        {
           NSString* s1=@"Der Ordner 'Magazin' im Ordner 'Lesebox' ist nicht eingerichtet";
           NSString* s2=@"Der Ordner von %@ konnte nicht verschoben werden.";
           NSString* MagazinString=[NSString stringWithFormat:@"%@%@%@%@",s1,@"\r",s2,dieAufnahme];
           //NSLog(@"MagazinString: %@",MagazinString);
           NSString* TString=@"Magazin einrichten";
           
           
           int magazinAntwort=NSRunAlertPanel(TString, MagazinString,@"OK", NULL,NULL);
           
           return;
        }
     }
   
   NSString* tempLeserPfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];//Leserordner im Archiv
   if ([self.AdminAktuellerLeser length]&&[Filemanager fileExistsAtPath:tempLeserPfad isDirectory:&istDirectory]&&istDirectory)
   {
      NSString* tempZielPfad=[tempMagazinPfad stringByAppendingPathComponent:[dieAufnahme stringByAppendingString:@" alt"]];
      NSString* tempAufnahmePfad=[tempLeserPfad stringByAppendingPathComponent:dieAufnahme];//Pfad akt. Aufn.
      if ([AdminAktuelleAufnahme length]&&[Filemanager fileExistsAtPath:tempAufnahmePfad])
      {
         if ([Filemanager fileExistsAtPath:tempZielPfad])//File ist schon vorhanden: ex
         {
            BOOL del=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempZielPfad ] error:nil];
         }
         
         BOOL result=[Filemanager moveItemAtURL:[NSURL fileURLWithPath:tempAufnahmePfad]  toURL:[NSURL fileURLWithPath:tempZielPfad] error:nil];
         NSLog(@"result von Aufnahme insMagazin: %d",result);
      }
      NSString* tempMagazinKommentarPfad=[tempLeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
      
      //
      NSLog(@"insMagazin tempMagazinKommentarPfad: %@",tempMagazinKommentarPfad);
      if ([Filemanager fileExistsAtPath:tempMagazinKommentarPfad isDirectory:&istDirectory]&&istDirectory)
      {
         tempMagazinKommentarPfad=[tempMagazinKommentarPfad stringByAppendingPathComponent:[dieAufnahme stringByDeletingPathExtension]];
         NSLog(@"insMagazin tempKommentarPfad 2: %@",tempMagazinKommentarPfad);
         if ([Filemanager fileExistsAtPath:tempMagazinKommentarPfad])
         {
            //[self moveFileToUserTrash:tempKommentarPfad];
            int result=[self fileInPapierkorb:tempMagazinKommentarPfad];
            NSLog(@"insMagazin ohne extension result von Kommentar: %d",result);
         }
         else
         {
            tempMagazinKommentarPfad=[tempMagazinKommentarPfad stringByAppendingPathExtension:@"txt"];
            if ([Filemanager fileExistsAtPath:tempMagazinKommentarPfad])
            {
               //[self moveFileToUserTrash:tempKommentarPfad];
               int result=[self fileInPapierkorb:tempMagazinKommentarPfad];
               NSLog(@"insMagazin mit extension result von Kommentar: %d",result);
               
            }
            
         }
         
      }
      
      
   }
   
}


- (void)insMagazinMitPfad:(NSString*)derAufnahmePfad
{
	NSLog(@"insMagazinMitPfad: %@",derAufnahmePfad);
	NSString* tempAufnahmePfad=[derAufnahmePfad copy];//Pfad akt. Aufn.

	BOOL istDirectory;
	NSFileManager* Filemanager=[NSFileManager defaultManager];
	NSString* tempMagazinPfad=[[AdminArchivPfad stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Magazin"]; 
	NSLog(@"tempMagazinPfad: %@",tempMagazinPfad);
	if (![Filemanager fileExistsAtPath:tempMagazinPfad])
	  {
		BOOL magazinOK=[Filemanager createDirectoryAtPath:tempMagazinPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
		if (!magazinOK)
		  {
			NSString* s1=@"Der Ordner 'Magazin' im Ordner 'Lesebox' konnte nicht eingerichtet werden.";
			NSString* s2=@"Die Aufnahme wurde nicht verschoben";
			NSString* MagazinString=[NSString stringWithFormat:@"%@%@%@",s1,@"\r",s2];
			int magazinAntwort=NSRunAlertPanel(@"Magazin einrichten", MagazinString,@"OK", NULL,NULL);
			
			return;
		  }
	  }
	
	NSString* tempLeserPfad=[tempAufnahmePfad stringByDeletingLastPathComponent];//Leserordner im Archiv
		if ([Filemanager fileExistsAtPath:tempLeserPfad isDirectory:&istDirectory]&&istDirectory)
		  {
			NSString* tempZielPfad=[tempMagazinPfad stringByAppendingPathComponent:[[tempAufnahmePfad lastPathComponent] stringByAppendingString:@" alt"]];
				if ([Filemanager fileExistsAtPath:tempAufnahmePfad])
				  {
					if ([Filemanager fileExistsAtPath:tempZielPfad])//File ist schon vorhanden: ex
					  {
						  BOOL del=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempZielPfad ]error:nil];
					  }
					//BOOL result=[Filemanager movePath:tempAufnahmePfad toPath:tempZielPfad handler:nil];
                 BOOL result=[Filemanager moveItemAtURL:[NSURL fileURLWithPath:tempAufnahmePfad]  toURL:[NSURL fileURLWithPath:tempZielPfad] error:nil];

					NSLog(@"result von Aufnahme insMagazin: %d",result);
				  }
				NSString* tempMagazinKommentarPfad=[tempLeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
				NSArray* Inhalt=[Filemanager contentsOfDirectoryAtPath:tempMagazinKommentarPfad error:NULL];
				//NSLog(@"tempKommentarPfad: %@",[Inhalt description]);
				
				if ([Filemanager fileExistsAtPath:tempMagazinKommentarPfad isDirectory:&istDirectory]&&istDirectory)
				  {
					NSString* tempZielPfad=[tempMagazinPfad stringByAppendingPathComponent:[[tempAufnahmePfad lastPathComponent] stringByAppendingString:@" Komm alt"]];
					tempMagazinKommentarPfad=[tempMagazinKommentarPfad stringByAppendingPathComponent:[tempAufnahmePfad lastPathComponent]];
					BOOL da=[Inhalt containsObject:tempMagazinKommentarPfad];
					NSLog(@"Inhalt da: %d",da);
					if ([Filemanager fileExistsAtPath:tempMagazinKommentarPfad])
					  {
						if ([Filemanager fileExistsAtPath:tempZielPfad])//File ist schon vorhanden: ex
						  {
							  BOOL del=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempZielPfad ] error:nil];
						  }
						da=[Filemanager fileExistsAtPath:tempMagazinKommentarPfad];
						//BOOL result=[Filemanager movePath:tempMagazinKommentarPfad toPath:tempZielPfad handler:NULL];
                    BOOL result=[Filemanager moveItemAtURL:[NSURL fileURLWithPath:tempMagazinKommentarPfad]  toURL:[NSURL fileURLWithPath:tempZielPfad] error:nil];

                    NSLog(@"result von Kommentar insMagazin: %d",result);
					  }
					
				  }
				
		  }
		
}


- (void)ex:(NSString*)dieAufnahme
{
	BOOL istDirectory;
	NSFileManager* Filemanager=[NSFileManager defaultManager];
	NSLog(@"ex");
	NSString* tempLeserPfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];//Leserordner im Archiv
		if ([self.AdminAktuellerLeser length]&&[Filemanager fileExistsAtPath:tempLeserPfad isDirectory:&istDirectory]&&istDirectory)
		  {
			NSString* tempAufnahmePfad=[tempLeserPfad stringByAppendingPathComponent:AdminAktuelleAufnahme];//Pfad akt. Aufn.
			if ([AdminAktuelleAufnahme length]&&[Filemanager fileExistsAtPath:tempAufnahmePfad isDirectory:&istDirectory]&&!istDirectory)
			  {
				//[self moveFileToUserTrash:tempAufnahmePfad];	
				int result=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempAufnahmePfad] error:nil];
				NSLog(@"result von Aufnahme: %d",result);
			  }
			NSString* tempKommentarPfad=[tempLeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
			if ([Filemanager fileExistsAtPath:tempKommentarPfad isDirectory:&istDirectory]&&istDirectory)
			  {
				tempKommentarPfad=[tempKommentarPfad stringByAppendingPathComponent:AdminAktuelleAufnahme];
				if ([Filemanager fileExistsAtPath:tempKommentarPfad])
				  {
					//[self moveFileToUserTrash:tempKommentarPfad];
					int result=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempKommentarPfad ] error:nil];
					NSLog(@"result von Kommentar: %d",result);
				  }
				
			  }
			
		  }
		
}

- (void)exMitPfad:(NSString*)derAufnahmePfad
{
	NSString* tempAufnahmePfad=[derAufnahmePfad copy];//Pfad akt. Aufn.
	BOOL istDirectory;
	NSFileManager* Filemanager=[NSFileManager defaultManager];
	NSLog(@"exMitPfad");
	NSString* tempLeserPfad=[tempAufnahmePfad stringByDeletingLastPathComponent];//Leserordner im Archiv
		if ([Filemanager fileExistsAtPath:tempLeserPfad isDirectory:&istDirectory]&&istDirectory)
		  {
			if ([Filemanager fileExistsAtPath:tempAufnahmePfad isDirectory:&istDirectory]&&!istDirectory)
			  {
				//[self moveFileToUserTrash:tempAufnahmePfad];	
				int result=[Filemanager removeItemAtURL:[NSURL fileURLWithPath:tempAufnahmePfad]error:nil];
				NSLog(@"ex: result von Aufnahme: %d",result);
			  }
			NSString* tempKommentarPfad=[tempLeserPfad stringByAppendingPathComponent:@"Anmerkungen"];
			if ([Filemanager fileExistsAtPath:tempKommentarPfad isDirectory:&istDirectory]&&istDirectory)
			  {
				tempKommentarPfad=[tempKommentarPfad stringByAppendingPathComponent:[tempAufnahmePfad lastPathComponent]];
				if ([Filemanager fileExistsAtPath:tempKommentarPfad])
				  {
					//[self moveFileToUserTrash:tempKommentarPfad];
                 int result=[Filemanager removeItemAtURL:[NSURL fileURLWithPath :tempKommentarPfad] error:nil];
					NSLog(@"result von Kommentar: %d",result);
				  }
				
			  }
			
		  }
		
}



- (IBAction)reportAktualisieren:(id)sender

{

  NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"aktualisieren"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"ListeAktualisieren" object:self userInfo:NotificationDic];


}

- (void)Leseboxordnen
{
	BOOL istDirectory;
	NSFileManager* Filemanager=[NSFileManager defaultManager];
	NSString* tempLeserPfad=[AdminProjektPfad stringByAppendingPathComponent:self.AdminAktuellerLeser];//Leserordner im Archiv
		
		if ([self.AdminAktuellerLeser length]&&[Filemanager fileExistsAtPath:tempLeserPfad isDirectory:&istDirectory]&&istDirectory)
		  {
			[self neuNummerierenVon:self.AdminAktuellerLeser];
		  }
		else
		  {
		  NSString* s1=@"Welcher Ordner?";
		  NSString* s2=@"Ein Name muss ausgewählt sein";
			NSAlert* OrdnenAlert=[NSAlert alertWithMessageText:@"Welcher Ordner?"
													defaultButton:@"OK" 
												  alternateButton:NULL
													  otherButton:NULL
										informativeTextWithFormat:@"Ein Name muss ausgewählt sein"];
			
			[OrdnenAlert beginSheetModalForWindow:AdminFenster 
									   modalDelegate:self 
									  didEndSelector: @selector(alertDidEnd: returnCode: contextInfo:)
										 contextInfo:@""];
			
		  }
}

- (void)neuNummerierenVon:(NSString*) derLeser
{
	BOOL istDirectory;
	BOOL erfolg=YES;
	NSFileManager* Filemanager=[NSFileManager defaultManager];
	NSString* LeserPfad=[AdminProjektPfad stringByAppendingPathComponent:derLeser];//Leserordner im Archiv
	
	if ([Filemanager fileExistsAtPath:LeserPfad isDirectory:&istDirectory]&&istDirectory)
	  {
		NSString* LeserKommentarPfad=[LeserPfad stringByAppendingPathComponent:@"Anmerkungen"];//Kommentarordner des Lesers
		NSMutableArray* AufnahmenArray=[[Filemanager contentsOfDirectoryAtPath:LeserPfad error:NULL]mutableCopy];
		if ([AufnahmenArray count])
		  {
			if ([[AufnahmenArray objectAtIndex:0]hasPrefix:@".DS"])//Unsichtbarer Ordner
			  {
				  [AufnahmenArray removeObjectAtIndex:0];
			  }
			int Kommentarindex=-1;
			Kommentarindex=[AufnahmenArray indexOfObject:@"Anmerkungen"];
			if (!(Kommentarindex==-1))
			  {
				NSLog(@"Kommentarordner da");
				[AufnahmenArray removeObjectAtIndex:Kommentarindex];//Kommentarordner nicht ändern
				
			  }
			
			NSLog(@"AufnahmenArray sauber: %@",[AufnahmenArray description]);
			int index=0;
			for(index=0;index<[AufnahmenArray count];index++)
			  {
				NSString* tempAufnahme=[AufnahmenArray objectAtIndex:index];
				NSString* alterPfad=[LeserPfad stringByAppendingPathComponent:tempAufnahme];
				NSString* neuerName=[self neuerNameVonAufnahme:tempAufnahme mitNummer:index+1];
				NSLog(@"neuerName: %@ index: %d",neuerName,index);
				NSString* neuerPfad=[LeserPfad stringByAppendingPathComponent:neuerName];
				if (![neuerPfad isEqualToString: alterPfad])
				  {
					//erfolg=[Filemanager movePath:alterPfad toPath:neuerPfad handler:nil];
					
                 erfolg=[Filemanager moveItemAtURL:[NSURL fileURLWithPath:alterPfad]  toURL:[NSURL fileURLWithPath:neuerPfad] error:nil];
  
                 if (!erfolg)//Umnumerieren erfolglos
					  {
						NSString* s1=@"Die Aufnahme %@ konnte nicht neu nummeriert werden.";
						 NSString* s2=@"Fehler beim Umnummerieren";
						   NSString* FehlerString=[NSString stringWithFormat:s1,tempAufnahme];
						  NSAlert *Warnung = [[NSAlert alloc] init];
						  [Warnung addButtonWithTitle:@"OK"];
						  //[Warnung addButtonWithTitle:@"Cancel"];
						  [Warnung setMessageText:s2];
						  [Warnung setInformativeText:FehlerString];
						  [Warnung setAlertStyle:NSWarningAlertStyle];
						  [Warnung beginSheetModalForWindow:AdminFenster
											  modalDelegate:nil
											 didEndSelector:nil
												contextInfo:nil];
						  
						  //int Antwort=NSRunAlertPanel(@"Fehler beim Umnummerieren", FehlerString,@"OK", NULL,NULL);
						  return;
					  }
					NSString*alterKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:tempAufnahme];
					if([Filemanager fileExistsAtPath:alterKommentarPfad])//Kommentar für diese Aufn. existiert
					  {
						  //NSLog(@"Kommentar für Aufnahme %@ existiert",tempAufnahme);
						  NSString* neuerKommentarPfad=[LeserKommentarPfad stringByAppendingPathComponent:neuerName];
						  if (![neuerKommentarPfad isEqualToString: alterKommentarPfad])
							{
							  //erfolg=[Filemanager movePath:alterKommentarPfad toPath:neuerKommentarPfad handler:nil];
                       erfolg =[Filemanager moveItemAtURL:[NSURL fileURLWithPath:alterKommentarPfad]  toURL:[NSURL fileURLWithPath:neuerKommentarPfad] error:nil];

							  if (!erfolg)//Umnumerieren erfolglos
								{
									NSString* FehlerString=[NSString stringWithFormat:@"Der Kommentar zur Aufnahme %@ konnte nicht neu nummeriert werden.",tempAufnahme];
									NSAlert *Warnung = [[NSAlert alloc] init];
									[Warnung addButtonWithTitle:@"OK"];
									//[Warnung addButtonWithTitle:@"Cancel"];
									[Warnung setMessageText:@"Fehler beim Umnummerieren des Kommentars"];
									[Warnung setInformativeText:FehlerString];
									[Warnung setAlertStyle:NSWarningAlertStyle];
									[Warnung beginSheetModalForWindow:AdminFenster 
														modalDelegate:nil
													   didEndSelector:nil
														  contextInfo:nil];
									
									//int Antwort=NSRunAlertPanel(@"", FehlerString,@"OK", NULL,NULL);
									return;
								}
							}
						  
					  }//if alterKommentarPfad
					
				  }
				
			  }//for index
			
		  }//count
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
		
		
}// Leserordner da
}

- (NSString*)neuerNameVonAufnahme:(NSString*)dieAufnahme mitNummer:(int)dieNummer
{
	NSString* tempAufnahme=[dieAufnahme copy];
	NSString* tempInitialen=[tempAufnahme substringToIndex:2];
	NSString* tempTitel=[NSString stringWithString:[self AufnahmeTitelVon:tempAufnahme]];
	
	NSString* neuerName=[NSString stringWithFormat:@"%@ %d %@",tempInitialen,dieNummer,tempTitel];
	NSLog(@"neuerNameVonName: neuerName: %@",neuerName);
	return neuerName;
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	//NSLog(@"returnCode: %d  contextInfo: %@: ",returnCode,contextInfo);
	NSString* locKommentar=@"Anmerkungen";
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	if ([(__bridge NSString*)contextInfo isEqualToString:@"TextchangedWarnung"])
	  {
		switch (returnCode)
		  {
			case 	NSAlertFirstButtonReturn:
			  {
				  //NSLog(@"NSAlertFirstButtonReturn: Sichern %d",returnCode);
				  [[alert window]orderOut:NULL];
				  if ([self saveKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme])
					  {
                    if (  [self saveMarksFuerLeser:self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme mitAdminMark: (int)[AdminMarkCheckbox state] mitUserMark:(int)[UserMarkCheckbox state]])
                    {

                       [self AdminBeenden];
                    }
					  }
					  
			  }break;
				
			case NSAlertSecondButtonReturn:
			  {
				//NSLog(@"NSAlertSecondButtonReturn: nicht Sichern %d",returnCode);
				[[alert window]orderOut:NULL];
				[self AdminBeenden];
			  }break;
			case NSAlertThirdButtonReturn:
			  {
				  
			  }break;
				
		  }
	  }//TextchangedWarnung
	
	if ([(__bridge NSString*)contextInfo isEqualToString:@"Entfernen"])
	  {
		switch (returnCode)
		  {
			case  NSAlertDefaultReturn://Papierkorb
         case NSAlertFirstButtonReturn:
			  {
				  //NSLog(@"NSAlertDefaultReturn: Papier %d",returnCode);
				  if ([Filemanager fileExistsAtPath:AdminPlayPfad])
					{
					  
					}
				  break;
			  }
			case  NSAlertAlternateReturn://Löschen
			  {
				  //NSLog(@"NSAlertAlternateReturn: Löschen %d",returnCode);
				  if ([Filemanager fileExistsAtPath:AdminPlayPfad])
					{
					  [Filemanager removeItemAtURL:[NSURL fileURLWithPath:AdminPlayPfad] error:nil];
					  NSString* DeleteAufnahmeName=[AdminPlayPfad lastPathComponent];
					  NSString* KommentarPfad=[NSString stringWithString:[AdminPlayPfad stringByDeletingLastPathComponent]];
					  KommentarPfad=[KommentarPfad stringByAppendingPathComponent:locKommentar];
					  KommentarPfad=[KommentarPfad stringByAppendingPathComponent:DeleteAufnahmeName];
					  if ([Filemanager fileExistsAtPath:KommentarPfad])
						{
						  [Filemanager removeItemAtURL:[NSURL fileURLWithPath:KommentarPfad ] error:nil];
						  [zurListeTaste setEnabled:NO];
						  [NamenListe reloadData];
						}
					  
					}
				  
				  break;
			  }
			case  NSAlertOtherReturn://Magazin
			  {
				  //NSLog(@"NSAlertOtherReturn: Magazin %d",returnCode);
				  if ([Filemanager fileExistsAtPath:AdminPlayPfad])
					{
					  int erfolg=1;
					  NSString* MagazinPfad=[NSString stringWithString:AdminPlayPfad];
					  MagazinPfad=[MagazinPfad stringByDeletingLastPathComponent];
					  
					  MagazinPfad=[MagazinPfad stringByDeletingLastPathComponent];
					  MagazinPfad=[MagazinPfad stringByDeletingLastPathComponent];
					  MagazinPfad=[MagazinPfad stringByAppendingPathComponent:@"Magazin"];
					  if (![Filemanager fileExistsAtPath:MagazinPfad])
						  erfolg=[Filemanager createDirectoryAtPath:MagazinPfad  withIntermediateDirectories:NO attributes:NULL error:NULL];
					  if (erfolg)
						{
						  MagazinPfad=[MagazinPfad stringByAppendingPathComponent:[AdminPlayPfad lastPathComponent]];
						  //[Filemanager movePath: AdminPlayPfad toPath:MagazinPfad handler:nil];
                     BOOL MagazinOK=[Filemanager moveItemAtURL:[NSURL fileURLWithPath:AdminPlayPfad]  toURL:[NSURL fileURLWithPath:MagazinPfad] error:nil];

                     [NamenListe reloadData];
						  [zurListeTaste setEnabled:NO];
						}
					  NSString* KommentarPfad=[[AdminPlayPfad copy] stringByDeletingLastPathComponent];
					  KommentarPfad=[KommentarPfad stringByAppendingPathComponent:@"Anmerkungen"];
					  if ([Filemanager fileExistsAtPath:KommentarPfad])
						{
						  KommentarPfad=[KommentarPfad stringByAppendingPathComponent:[AdminPlayPfad lastPathComponent]];
						  if ([Filemanager fileExistsAtPath:KommentarPfad])
							{
                        erfolg= [Filemanager removeItemAtURL:[NSURL fileURLWithPath:KommentarPfad] error:NULL];						
                     }
                  }
				  
			  }
		  }break;
        } // switch
	  }//Entfernen
	if ([(__bridge NSString*)contextInfo isEqualToString:@"keineLeser"])
	  {
		NSLog(@"shouldEnd: keineLeser");
		[self AdminBeenden];
	  }
	[[alert window]orderOut:NULL];
}

/*
- (QTMovieView*)AdminQTKitPlayer
{
	return AdminQTKitPlayer;
}
*/
- (void)keyDown:(NSEvent *)theEvent
{
	int nr=[theEvent keyCode];
	
	NSLog(@"AdminPlayer  keyDown: nr: %d  char: %@",nr,[theEvent characters]);
	switch (nr)
	{
		case 51://delete
		{
			if ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])//Aufanhmen nach Namen
			{
				if (([AufnahmenDicArray count])&&([AufnahmenTable numberOfSelectedRows]))//nicht leer und eine Zeile selektiert
				{
				int index=[AufnahmenTable selectedRow];
				if (![[[AufnahmenDicArray objectAtIndex:index] objectForKey:@"aufnahme"]isEqualToString:@"Keine Aufnahme"])
				{
					NSLog(@"AdminPlayer  delete:Zeile:%d",[AufnahmenTable selectedRow]);
					
					}
				}
				
			}
		}break;
			
		case 36://return
		{
		if ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
		{
			NSLog(@"return");
			NSNotificationCenter * nc;
			nc=[NSNotificationCenter defaultCenter];
			
			NSString* EnterKeyQuelle;
			EnterKeyQuelle=@"AufnahmenTable";
			[nc postNotificationName:@"AdminEnterKey" object:EnterKeyQuelle];
			
			
			
			//[AdminQTPlayer becomeFirstResponder];
			//[self setLeserFuerZeile:selektierteZeile];
			
			//[AdminQTPlayer setHidden:NO];
			//[self startAdminPlayer:nil];
			//[AdminQTPlayer start:nil];
		}break;
		}
		case 123:
		case 124:
			break;
			
		default:
		{
			NSLog(@"default");
			[super keyDown:theEvent];
		}
	}//switch
}
- (void)AdminKeyNotifikationAktion:(NSNotification*)note
{
	NSLog(@"KeyNotifikationAktion: note: %@",[note object]);
	NSNumber* KeyNummer=[note object];
	int keyNr=(int)[KeyNummer floatValue];
	NSLog(@"keyDown KeyNotifikationAktion description: %@",[KeyNummer description]);
	//NSLog(@"keyDown KeyNotifikationAktion keyNr: %d",keyNr);
	[self setLeser:NamenListe ];
	//[self startAdminPlayer:AdminQTPlayer];
}

- (void) AdminZeilenNotifikationAktion:(NSNotification*)note
{
	BOOL erfolg;
//	NSLog(@"AdminZeilenNotifikationAktion: note: %@",[[note object]description]);
	NSDictionary* QuellenDic=[note object];

	//[AdminMarkCheckbox setEnabled:NO];
	//[AdminMarkCheckbox setEnabled:YES];
	NSString* Quelle=[QuellenDic objectForKey:@"Quelle"];
	//NSLog(@"AdminZeilenNotifikationAktion: Quelle: %@",Quelle);
	
   
   [self Aufnahmezuruecklegen];
   
	if ([Quelle isEqualToString:@"AdminView"]) // Alle Aufnahmen
	  {
		//NSLog(@"AdminPlayer AdminZeilenNotifikationAktion:  AdminView  Quelle: %@",Quelle);
	  	
		int lastZeilenNr=[[QuellenDic objectForKey:@"AdminLastZeilenNummer"] intValue];
		int nextZeilenNr=[[QuellenDic objectForKey:@"AdminNextZeilenNummer"] intValue];
		//NSLog(@"lastZeilenNr: %d, lastZeilenNr: %d",lastZeilenNr,nextZeilenNummer);
		//NSLog(@"keyDown AdminZeilenNotifikationAktion lastZeilenNr: %d",lastZeilenNr);

		if ((selektierteZeile>=0)&&(selektierteZeile != nextZeilenNr))//selektierte zeile ist nicht -1 wie beim ersten Klick
		  {
			//NSLog(@"AdminAktuellerLeser: %@  AdminAktuelleAufnahme: %@",self.AdminAktuellerLeser,AdminAktuelleAufnahme);

			if ([self.AdminAktuellerLeser length]&&[AdminAktuelleAufnahme length]&&Textchanged)
			  {
				//NSLog(@"AdminZeilenNotifikationAktion: save Kommentar in Notification");
				BOOL OK=[self saveKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
				Moviegeladen=NO;
				//Textchanged=NO;
			  }
			
			//[self backZurListe:nil];
			

		  }
        
		  selektierteZeile=nextZeilenNr;
		  if (lastZeilenNr<0)//erster Klick, ZeilenNr ist -1
		  {
		  lastZeilenNr=0;
		  }
        
//		[self setLeserFuerZeile:nextZeilenNr];
		int AnzahlAufnahmenFuerZeile=[self AnzahlAufnahmenFuerZeile:nextZeilenNr];
		//NSLog(@"AdminZeilenNotifikationAktion: nextZeilenNr: %d AnzahlAufnahmenFuerZeile: %d",nextZeilenNr,AnzahlAufnahmenFuerZeile);
		if ((nextZeilenNr>=0)&&AnzahlAufnahmenFuerZeile)
		  {
			[PlayTaste setEnabled:YES];
			//erfolg=[AdminFenster makeFirstResponder:self.PlayTaste];
			[PlayTaste setKeyEquivalent:@"\r"];
			//[AdminMarkCheckbox setEnabled:YES];
			int hit=[[[AdminDaten dataForRow:nextZeilenNr]objectForKey:@"aufnahmen"]intValue];

			NSLog(@"AdminZeilenNotifikationAktion hit: %d",hit);
		  }
		else
		  {
			[self->PlayTaste setEnabled:NO];
			[self->PlayTaste setKeyEquivalent:@""];
			//[AdminMarkCheckbox setEnabled:NO];
		  }
		
		[ExportierenTaste setEnabled:NO];
		[LoeschenTaste setEnabled:NO];
		[zurListeTaste setEnabled:NO];
        
		//NSTableColumn* tempKolonne;
		//tempKolonne=[self.NamenListe tableColumnWithIdentifier:@"neu"];
		//[[tempKolonne dataCellForRow:selektierteZeile]setTitle:@"Los"];
		Textchanged=NO;
		//NSLog(@"AdminZeilenNotifikationAktion selektierteZeile: %d",selektierteZeile);
	  }
	  
	if ([Quelle isEqualToString:@"AufnahmenTable"])
	{
      NSDictionary* QuellenDic=[note object];
		//NSLog(@"\n\nAdminZeilenNotifikationAktion:  AufnahmenTable  Quelle: %@",Quelle);
		NSNumber* ZeilenNummer=[QuellenDic objectForKey:@"zeilennummer"];
	  	
		int zeilenNr=[ZeilenNummer intValue];
		
		[zurListeTaste setEnabled:NO];
		[PlayTaste setEnabled:YES];
		[PlayTaste setKeyEquivalent:@"\r"];
		
		[AdminMarkCheckbox setState:NO];
		
		NSString* tempAktuellerLeser=[QuellenDic objectForKey:@"leser"];
		NSString* tempAktuelleAufnahme=[QuellenDic objectForKey:@"aufnahme"];
		
		//NSLog(@" zeilenNr: %d tempAktuellerLeser: %@  tempAktuelleAufnahme: %@",zeilenNr,tempAktuellerLeser,tempAktuelleAufnahme);
		if ([tempAktuellerLeser length]&&[tempAktuelleAufnahme length] &&Textchanged)
		{
			//NSLog(@"save in Notification");
			BOOL OK=[self saveKommentarFuerLeser: tempAktuellerLeser FuerAufnahme:tempAktuelleAufnahme];
			Moviegeladen=NO;
			//Textchanged=NO;
		}
		
		//[self backZurListe:nil];
		
		if ([AufnahmenDicArray count]>selektierteAufnahmenTableZeile)//neu selektierte Zeile
		{
			NSDictionary* tempAufnahmenDic=[AufnahmenDicArray objectAtIndex:selektierteAufnahmenTableZeile];
			NSLog(@"AdminZeilenNotifikationAktion NamenTable neuer AufnahmenDic: %@",[tempAufnahmenDic description]);
			NSString* tempAufnahme=[tempAufnahmenDic objectForKey:@"aufnahme"];
			BOOL OK;
			//NSLog(@"AdminAktuellerLeser: %@ tempAufnahme: %@",AdminAktuellerLeser,tempAufnahme);
			OK=[self setPfadFuerLeser: tempAktuellerLeser FuerAufnahme:tempAufnahme];//Movie geladen, wenn OK
			OK=[self setKommentarFuerLeser: tempAktuellerLeser FuerAufnahme:tempAufnahme];
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
		[self.StartPlayKnopf setEnabled:YES];
		Textchanged=NO;
	//	[self.MarkCheckbox setEnabled:NO];

	}//if Quelle==AufnahmenTable
	
}

- (void) AdminTabNotifikationAktion:(NSNotification*)note
{
	BOOL erfolg;
	//NSLog(@"AdminTabNotifikationAktion: note: %@",[note object]);
	NSDictionary* QuellenDic=[note object];
   //NSLog(@"QuellenDic :%@",[QuellenDic description]);
	//[AdminMarkCheckbox setEnabled:YES];
	NSString* Quelle=[QuellenDic objectForKey:@"Quelle"];
	
	if ([Quelle isEqualToString:@"AdminView"]) // von 'Alle Aufnahmen' zu 'nach Namen'
	  {
        //NSLog(@"AdminTabNotifikationAktion:  AdminView  Quelle: %@",Quelle);
        [AdminMarkCheckbox setState:NO];
        [LehrerMarkCheckbox setState:NO];
        if ([self.AdminAktuellerLeser length]&&[AdminAktuelleAufnahme length]&&Textchanged)
        {
           [self Aufnahmezuruecklegen];
        }
        [ExportierenTaste setEnabled:NO];
        [LoeschenTaste setEnabled:NO];
        Textchanged=NO;
     }
	  
	if ([Quelle isEqualToString:@"AufnahmenTable"]) // nach Namen
	{
		//NSLog(@"AdminTabNotifikationAktion:  AufnahmenTable  Quelle: %@",Quelle);
		
		NSNumber* ZeilenNummer=[QuellenDic objectForKey:@"zeilennummer"];
	  	
		int zeilenNr=[ZeilenNummer intValue];
		//if (selektierteAufnahmenTableZeile != zeilenNr)
		{
			[zurListeTaste setEnabled:NO];
			//[self.PlayTaste setEnabled:YES];
			
			
			[AdminMarkCheckbox setState:NO];
			//NSLog(@" Zeile: %d AdminAktuellerLeser: %@  AdminAktuelleAufnahme: %@",zeilenNr,AdminAktuellerLeser,AdminAktuelleAufnahme);
			
			if ([self.AdminAktuellerLeser length]&&[AdminAktuelleAufnahme length]&&Textchanged)
			{
				NSLog(@"save in Notification");
				BOOL OK=[self saveKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:AdminAktuelleAufnahme];
				Moviegeladen=NO;
				//Textchanged=NO;
			}
			
			//[self backZurListe:nil];
			selektierteAufnahmenTableZeile=0;
         NSLog(@"AdminTabNotifikationAktion AufnahmenDicArray: %@",[AufnahmenDicArray description]);

			if ([AufnahmenDicArray count]>selektierteAufnahmenTableZeile)
			{
				NSDictionary* tempAufnahmenDic=[AufnahmenDicArray objectAtIndex:selektierteAufnahmenTableZeile];
				NSLog(@"AdminTabNotifikationAktion tempAufnahmenDic: %@",[tempAufnahmenDic description]);
				NSString* tempAufnahme=[tempAufnahmenDic objectForKey:@"aufnahme"];
				BOOL OK;
				
				OK=[self setPfadFuerLeser: self.AdminAktuellerLeser FuerAufnahme:tempAufnahme];
				OK=[self setKommentarFuerLeser: self.AdminAktuellerLeser FuerAufnahme:tempAufnahme];
				if([[tempAufnahmenDic objectForKey:@"adminmark"]intValue])
				{
					[AdminMarkCheckbox setState:YES];
				}
				else
				{
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
		}
		
		[ExportierenTaste setEnabled:NO];
		[LoeschenTaste setEnabled:NO];
		//[self.PlayTaste setEnabled:YES];
		Textchanged=NO;
	}//if Quelle==AufnahmenTable
	
}

- (void)AdminEnterKeyNotifikationAktion:(NSNotification*)note
{
	//NSLog(@"Adminliste    EnterKeyNotifikationAktion: note: %@",[note object]);
	NSString* Quelle=[[note object]description];
	//NSLog(@"EnterKeyNotifikationAktion: Quelle: %@",Quelle);
	BOOL erfolg;
	if ([Quelle isEqualToString:@"MovieView"])
	{
		switch ([[[AufnahmenTab selectedTabViewItem]identifier]intValue])
		{
		case 1://alle Aufnahmen
		{
		erfolg=[AdminFenster makeFirstResponder:NamenListe];
		}break;
		case 2://nach 
		{
		erfolg=[AdminFenster makeFirstResponder:AufnahmenTable];
		}break;
		
		
		}//switch
		[self setBackTaste:NO];
		[zurListeTaste setEnabled:NO];
		[PlayTaste setEnabled:YES];
	}
	
	if ([Quelle isEqualToString:@"AdminListe"])
	  {
		NSLog(@"(AdminEnterKeyNotifikationAktion  selektierteZeile): %d",selektierteZeile);
		if (selektierteZeile>=0)
		  {
			if ([[AdminDaten AufnahmeFilesFuerZeile:selektierteZeile]count])
			  {
				NSLog(@"1");
				[self setBackTaste:YES];
				erfolg=[AdminFenster makeFirstResponder:zurListeTaste];
				//erfolg=[[self window]makeFirstResponder:self.PlayTaste];
				[PlayTaste setEnabled:NO];
				[AdminMarkCheckbox setEnabled:YES];
				[self setLeserFuerZeile:selektierteZeile];
				NSLog(@"2");
//				[AdminQTKitPlayer setHidden:NO];
				[self startAdminPlayer:nil];
//				[AdminQTKitPlayer play:nil];
				//NSLog(@"		Quelle: AdminListe->QTPlayer: erfolg: %d",erfolg);
				
			  }
			else
			  {
				NSBeep();
				[PlayTaste setEnabled:NO];
				[AdminMarkCheckbox setEnabled:NO];
				[ExportierenTaste setEnabled:NO];
				[LoeschenTaste setEnabled:NO];
				[zurListeTaste setEnabled:NO];
				[zurListeTaste setKeyEquivalent:@""];
				
				
			  }
		  }
		
	  }//if AdminListe
	  
	if ([Quelle isEqualToString:@"AufnahmenTable"])
	{
	NSLog(@"Quelle: AufnahmenTable");
	[self AufnahmeInPlayer:NULL];
	
	}//if AufnahmenTable
}

- (void)DidChangeNotificationAktion:(NSNotification*)note
{
	//NSLog(@"rAdminPlayer: NSTextDidChangeNotification note: %@",[[note object]description]);
	if ([note object]==AdminKommentarView)
		
	  {
		NSLog(@"rAdminPlayer: NSTextDidChangeNotification textchanged YES");
		Textchanged=YES;
        Kommentarsaved=NO;
	  }
}

- (void)NSTableViewSelectionDidChangeNotification:(NSNotification*)note
{
	NSLog(@"rAdminPlayer: NSTableViewSelectionDidChangeNotification note: %@",[[note object]description]);
	if ([note object]==AdminKommentarView)
		
	  {
        NSLog(@"rAdminPlayer: NSTableViewSelectionDidChangeNotification textchanged YES");
        //Textchanged=YES;
        //Kommentarsaved=NO;
	  }
}



- (void) Umgebung:(NSNotification*)note
{
NSNumber* UmgebungNumber=[[note userInfo]objectForKey:@"Umgebung"];
	Umgebung=(int)[UmgebungNumber floatValue];
}


- (NSString*)Zeitformatieren:(long) dieSekunden
{
	short Sekunden=dieSekunden%60;
	short Minuten=dieSekunden/60;
	NSNumber * n=0;
	n=[NSNumber numberWithLong:Minuten];
	NSString * stringMinuten=[n stringValue];
	n=[NSNumber numberWithLong:Sekunden];
	//NSLog(@"Zeitform:%d",n);
	NSString*  stringSekunden=[n stringValue];
	NSString* stringZeit;
	if (Minuten<10)
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
	
	return stringZeit;
	
}


- (void)clearKommentarfelder
{
	BOOL editierbar=[AdminKommentarView isEditable];
	BOOL selektierbar=[AdminKommentarView isSelectable];
	[AdminKommentarView setEditable:YES];
	//[AdminKommentarView selectAll:nil];
	//[AdminKommentarView delete:nil];
	[AdminKommentarView setString:@""];
	[AdminKommentarView setEditable:editierbar];
	[AdminKommentarView setSelectable:selektierbar];
	
	[AdminNamenfeld setStringValue: @""];
	[AdminDatumfeld setStringValue: @""];
	[AdminTitelfeld setStringValue: @""];
	[AdminBewertungfeld setStringValue: @""];
	[AdminNotenfeld setStringValue: @""];
   [LehrerMarkCheckbox setState:NO];
	[UserMarkCheckbox setState:NO];
	


}

- (OSErr)ExportMovieVonPfad:(NSString*) derAufnahmePfad
{	
	OSErr erfolg=0;
	FSSpec	*tempExportFSSpec;
	FSRef tempExportRef;
	short status;
	UniChar buffer[255]; // HFS+ filename max is 255
	
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	NSString* ExportAufnahmeName=[[derAufnahmePfad copy] lastPathComponent];
	//NSLog(@"ExportAufnahmeName: %@",ExportAufnahmeName);
	[ExportAufnahmeName getCharacters:buffer];
	//NSString* tempExportOrdnerPfad=[NSString stringWithString:NSHomeDirectory()];
	//tempExportOrdnerPfad=[ExportOrdnerPfad stringByAppendingPathComponent:@"Documents"];
	NSString* tempExportOrdnerPfad=[AdminLeseboxPfad stringByDeletingLastPathComponent];
	status = FSPathMakeRef((UInt8*)[tempExportOrdnerPfad fileSystemRepresentation],  &tempExportRef, NULL);
	
	// QTKit
	NSError* loadErr;
	NSURL *movieURL = [NSURL fileURLWithPath:derAufnahmePfad];
//	QTMovie* tempMovie= [[QTMovie alloc]initWithURL:movieURL error:&loadErr];
	if (loadErr)
	{
		NSAlert *theAlert = [NSAlert alertWithError:loadErr];
		[theAlert runModal]; // Ignore return value.
	}
   /*
	if (!tempMovie)
		NSLog(@"Kein Movie da");
	// retrieve the QuickTime-style movie (type "Movie" from QuickTime/Movies.h) 
	Movie tempExportMovie =[tempMovie quickTimeMovie];
	
	long exportFlags = showUserSettingsDialog |
	movieToFileOnlyExport |
	movieFileSpecValid |
	createMovieFileDeleteCurFile;
	
	// If the movie is currently playing stop it
	if (GetMovieRate(tempExportMovie))
		StopMovie(tempExportMovie);
	
	// use the default progress procedure, if any
	SetMovieProgressProc(tempExportMovie,					// the movie specifier
								(MovieProgressUPP)-1L,		// pointer to a progress function; -1 indicades default
								0);						// reference constant
	
	// export the movie into a file
	ConvertMovieToFile(tempExportMovie,					// the movie to convert
							 NULL,						// all tracks in the movie
							 tempExportFSSpec,					// the output file
							 0,							// the output file type
							 0,							// the output file creator
							 smSystemScript,				// the script
							 NULL, 						// no resource ID to be returned
							 exportFlags,					// no flags
							 NULL);						// no specific component
	//NSOKButton
    
    */
	return erfolg;
}//Export





- (BOOL) FensterschliessenOK
{
	BOOL OK=YES;
	
	//if (Textchanged)
	{
      [self Aufnahmezuruecklegen];
	}
	
	return OK;
}

- (BOOL)windowShouldClose:(id)sender
{
	
   //[self dismissController:nil];
   
	BOOL OK=[self FensterschliessenOK];
	NSLog(@"windowShouldClose");
	if (OK)
	  {
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"beenden"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		//[nc postNotificationName:@"externbeenden" object:self userInfo:NotificationDic];

	  }
	return OK;
}


-(void)AdminBeenden
{
	if ([self FensterschliessenOK])
	{
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"beenden"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"externbeenden" object:self userInfo:NotificationDic];
	}
}

- (void)showCleanFenster:(int)tab
{
	NSLog(@"AdminPlayer showClean  AnzNamen: %d",[AdminProjektNamenArray count]);
	if (!CleanFenster)
	  {
//		CleanFenster=[[rClean alloc]initWithRowCount:[AdminProjektNamenArray count]];
	}
	
	//NSLog(@"AdminPlayer showClean: tab: %d",tab);

	nurTitelZuNamenOption=0;

	[CleanFenster showWindow:self];

	//[CleanFenster setAnzahlPopMenu:AnzahlOption];
		
		NSMutableDictionary* SettingDic=[NSMutableDictionary dictionaryWithObject:ExportFormatString 
																		   forKey:@"exportformat"];
		[CleanFenster setClean:SettingDic];
		[CleanFenster setNamenArray:AdminProjektNamenArray];
			  
	
	

	
}

- (void)setCleanTask:(int)dieTask
{
//NSLog(@"AdminPlayer: vor setTaskTab: %d",dieTask);

[CleanFenster setTaskTab:dieTask];
//NSLog(@"AdminPlayer: nach setTaskTab");
}

- (void)MarkierungNotificationAktion:(NSNotification*)note
{
	int var=[[[note userInfo]objectForKey:@"MarkierungVariante"]intValue];
	NSLog(@"MarkierungNotificationAktion  Variante: %d ",var);
	switch (var)
	{
		case 0://Nur Leser
		{
			[AufnahmenTab selectTabViewItemAtIndex:0];
			NSLog(@"MarkierungNotificationAktion Nur markierungen von einem Leser");
			[self MarkierungEntfernenFuerZeile:[self->NamenListe selectedRow]];
			
		}break;
		case 1://alle
		{
			NSLog(@"MarkierungNotificationAktion alle  markierungen");
			[self Markierungenreset];
		}break;
	}//switch
	
}
- (void)AdminProjektListeAktion:(NSNotification*)note
{
  //aus Projektwahl
  //NSLog(@"AdminProjektListeAktion: %@",[[note userInfo]description]);
}

- (void)anderesAdminProjektAktion:(NSNotification*)note
{
  NSLog(@"AdminProjektListeAktion: %@",[[note userInfo]description]);
  
}

- (void)ProjektArrayNotificationAktion:(NSNotification*)note
{
	NSArray* tempProjektArray =[[note userInfo]objectForKey:@"ProjektArray"];
	NSLog(@"ProjektArrayNotificationAktion  tempProjektArray: %@ ",tempProjektArray);
	if (tempProjektArray)
	{
		if ([tempProjektArray count])
		{
			[AdminProjektArray removeAllObjects];
			[AdminProjektArray setArray:tempProjektArray];
		}
	}//if tempProjektArray
}


- (void)NameIstEntferntAktion:(NSNotification*)note
{
   NSLog(@"NameIstEntferntAktion: %@",[[note userInfo]description]);
	NSString* tempEntfernenName;
	int entfernenOK=-1;
	if ([[note userInfo] objectForKey:@"namen"])
	{
		//NSLog(@"// Name: %@",[[note userInfo] objectForKey:@"namen"]);
		tempEntfernenName=[[note userInfo] objectForKey:@"namen"];
		
	}
	if ([[note userInfo] objectForKey:@"entfernenOK"])
	{
		//NSLog(@"*AdminPlayer NamenEntfernenAktion entfernenOK: %@",[[note userInfo] objectForKey:@"entfernenOK"]);
		entfernenOK=[[[note userInfo] objectForKey:@"entfernenOK"]intValue];
	}	
if (entfernenOK==0)//allesOK
	{
     // [self setAdminPlayer:AdminLeseboxPfad inProjekt:[AdminProjektPfad lastPathComponent]];

	[AdminDaten deleteDataZuName:tempEntfernenName];
	//[self.NamenListe reloadData];
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
			[self setAdminPlayer:AdminLeseboxPfad inProjekt:[AdminProjektPfad lastPathComponent]];
		}//if 
	}//note
}


- (void)SelectionDidChangeAktion:(NSNotification*)note
{
	//NSLog(@"SelectionDidChangeAktion note: %d",[[note object]numberOfSelectedRows]);
	//[self.PlayTaste setEnabled:[[note object]numberOfSelectedRows]];
	if ([[note object]numberOfSelectedRows])
	{
	[self->PlayTaste setEnabled:YES];
	
	}
	else
	{
		//NSLog(@"rAdminPlayer: SelectionDidChangeAktion textchanged YES");
		[self Aufnahmezuruecklegen];
		[self->PlayTaste setEnabled:NO];
		//Textchanged=YES;
      //Kommentarsaved=NO;
	}
}

- (void)ButtonWillPopUpAktion:(NSNotification*)note
{
	NSLog(@"ButtonWillPopUpAktion note: %d",[[note object]tag]);
   [AdminNamenfeld setStringValue:@"Ein Name soll es sein"];
	switch([[note object]tag])
	{
	case 11:
	case 12:
	{
	NSLog(@"rAdminPlayer: ButtonWillPopUpAktion textchanged YES");
	Textchanged=YES;
      Kommentarsaved=NO;
	}break;
	
	}//switch tag
	
	
}

- (void)ComboBoxAktion:(NSNotification*)note
{
	//NSLog(@"ComboBoxAktion note: %d",[[note object]stringValue]);
	NSLog(@"rAdminPlayer: ComboBoxAktion textchanged YES");
	Textchanged=YES;
	Kommentarsaved=NO;
   
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



@end

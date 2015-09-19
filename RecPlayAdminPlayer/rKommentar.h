/* rKommentar */

#import <Cocoa/Cocoa.h>

@interface rKommentar : NSWindowController <NSMatrixDelegate>
{
	
	IBOutlet	id					KommentarFenster;
    IBOutlet	id					KommentarView;
	
	IBOutlet	id					Anz;
	IBOutlet	id					OptionDrawer;
	IBOutlet	NSPopUpButton*		AuswahlPopMenu;
	IBOutlet	NSPopUpButton*		PopAMenu;	
	IBOutlet	NSPopUpButton*		PopBMenu;
	IBOutlet	NSPopUpButton*		AnzahlPop;
	IBOutlet	NSPopUpButton*		ProjektPopMenu;
   IBOutlet	NSPopUpButton*		ZusatzPop;
	IBOutlet	id					PopAPrompt;
	IBOutlet	id					PopBPrompt;
	IBOutlet	id					ProjektPopPrompt;
	IBOutlet	id					nurMarkierteCheck;
	IBOutlet	NSMatrix*			AbsatzMatrix;
	IBOutlet	NSMatrix*			AuswahlMatrix;
	IBOutlet	NSMatrix*			ProjektMatrix;
	int								AuswahlOption;
	int								AbsatzOption;
	int								AnzahlOption;
	int								ProjektOption;

   // aus AdminPlayer
   int							ProjektNamenOption;
   int							ProjektAuswahlOption;
  // int							nurMarkierteOption;
   NSString*					ProjektPfadOptionString;

    // end aus AdminPlayer
   //
   NSString*						TitelString;
//	NSString*						OptionAString;
	NSString*						OptionBString;
	NSString*						NamenOptionString;
	NSString*						TitelOptionString;

	NSString*						KommentarString;
	
	NSMutableArray*					NamenArray;
	NSMutableArray*					TitelArray;
   NSString*               heuteDatumString;
   
   // aus AdminPlayer
   NSString*					AdminLeseboxPfad;
   NSString*					AdminArchivPfad;
   NSString*					AdminProjektPfad;
   NSPopUpButton*				ProjektPop;
   
   NSString*					AdminAktuellesProjekt;
   
   NSString*					AdminAktuellerLeser;
   NSString*					AdminAktuelleAufnahme;
   
   
   NSString*					AdminPlayPfad;
   NSMutableArray *			AdminProjektNamenArray;
   NSMutableArray *			AdminProjektArray;
   BOOL                    AdminProjektAktiviert;
   // end aus AdminPlayer
	
}
- (IBAction)toggleDrawer:(id)sender;
- (void)setKommentar:(NSString*)derKommentarString;
- (void)setKommentarMitKommentarDicArray:(NSArray*)derKommentarDicArray;

- (int)AuswahlOption;
- (int)AbsatzOption;
- (BOOL)nurMarkierte;
- (NSString*)PopAOption;
- (NSString*)PopBOption;
- (IBAction)nurMarkierteOption:(id)sender;
- (IBAction)reportKommentarOption:(id)sender;
- (NSView*)KommentarView;
- (NSTextView*)setDruckKommentarMitKommentarDicArray:(NSArray*)derKommentarDicArray
											 mitFeld:(NSRect)dasFeld;

- (IBAction)reportAuswahl:(id)sender;
- (IBAction)reportAnzahl:(id)sender;
- (IBAction)reportProjektNamenOption:(id)sender;
- (IBAction)reportProjektAuswahlOption:(id)sender;
- (void)setAuswahlPop:(int)dieAuswahlOption;
- (void)setPopAMenu:(NSArray*)derArray erstesItem:(NSString*)dasItem aktuell:(NSString*)aktuellerString;
- (void)resetPopAMenu;
- (void)setPopBMenu:(NSArray*)derArray erstesItem:(NSString*)dasItem aktuell:(NSString*)aktuellerString mitPrompt:(NSString*)dasPrompt;
- (void)resetPopBMenu;
- (void)setAnzahlPopMenu:(int)dieAnzahl;
- (void)setProjektMenu:(NSArray*)derProjektMenuArray mitItem:(NSString*)dasProjektItem;
- (NSTextView*)setDruckViewMitFeld:(NSRect)dasDruckFeld
	   mitKommentarDicArray:(NSArray*)derKommentarDicArray;
- (void)KommentarDruckenMitProjektDicArray:(NSArray*)derProjektDicArray;
- (void)KommentarSichernMitProjektDicArray:(NSArray*)derProjektDicArray;

// aus Kommentarkontroller
- (NSString*)lastKommentarVonLeser:(NSString*)derLeser anProjektPfad:(NSString*)derProjektPfad;
- (void)setKommentarMitProjektArray:(NSArray*)derProjektArray mitLeser:(NSString*)aktuellerLeser anPfad:(NSString*)aktuellerProjektPfad;
@end

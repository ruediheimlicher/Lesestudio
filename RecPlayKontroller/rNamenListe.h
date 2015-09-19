/* rNamenListe */

#import <Cocoa/Cocoa.h>
#import "rEingabeFeld.h"
@interface rNamenListe : NSWindowController <NSComboBoxDataSource, NSTextFieldDelegate, NSTabViewDelegate>
{
  rEingabeFeld*      NameFeld;
  rEingabeFeld*      VornameFeld;
	IBOutlet id       UbernehmenTaste;
    IBOutlet id      EntfernenTaste;
	IBOutlet id       BearbeitenTaste;
	IBOutlet id       SchliessenTaste;
    IBOutlet id      ImportTaste;
    IBOutlet id      NameInListeTaste;
    IBOutlet id      NameAusListeTaste;
	IBOutlet id       NamenTable;
   IBOutlet NSTabView* NamenTab;
	IBOutlet id neueNamenTable;
    IBOutlet id window;
	IBOutlet id TitelString;
	IBOutlet id LesestudioString;
	IBOutlet id StartString;
	IBOutlet id EntfernenVariante;
	IBOutlet id AusAllenProjektenCheck;
	IBOutlet id InAlleProjekteCheck;
	IBOutlet id EingebenVariante;
	IBOutlet id EinsetzenVariante;
	IBOutlet id PfadFeld;
	
	NSMutableArray*			NamenArray;
	NSMutableArray*			neueNamenArray;
	NSMutableDictionary*	NamenDic;
	NSString*				aktuellesProjekt;
}
- (IBAction)reportCancel:(id)sender;
- (IBAction)reportClose:(id)sender;
//- (IBAction)reportAuswahlen:(id)sender;
- (IBAction)reportEntfernen:(id)sender;
- (IBAction)reportNamenUbernehmen:(id)sender;
- (IBAction)reportNameInListe:(id)sender;
- (IBAction)reportNameAusListe:(id)sender;

- (IBAction)reportImportieren:(id)sender;
- (IBAction)reportEingebenVariante:(id)sender;
- (IBAction)reportEinsetzenVariante:(id)sender;
- (void)setNamenListeArray:(NSArray*)derArray vonProjekt:(NSString*)dasProjekt;
-(void)neuerNameInArray:(NSString*)derName;

@end

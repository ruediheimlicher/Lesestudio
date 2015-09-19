/* rVolumes */

#import <Cocoa/Cocoa.h>
//#import "rNetzwerkDrawer.h"
@interface rVolumes : NSWindowController  <NSComboBoxDataSource>
{
	IBOutlet id window;
    IBOutlet id AbbrechenKnopf;
	IBOutlet id AuswahlenKnopf;
    IBOutlet id NetzwerkKnopf;
    IBOutlet id SuchenKnopf;
	IBOutlet id AnmeldenKnopf;
	IBOutlet id PrufenKnopf;
	IBOutlet id UserTable;
	IBOutlet id NetworkTable;

	IBOutlet id VolumesPop;
	IBOutlet id OderString;
	IBOutlet id ComputerimNetzString;	
	IBOutlet id TitelString;
	IBOutlet id LesestudioString;
	IBOutlet id StartString;
	IBOutlet id NetzwerkDrawer;
	
	IBOutlet id PfadFeld;
	IBOutlet id LeseboxerfolgFeld;

 
	NSMutableArray*			UserArray;
	NSMutableArray*			NetworkArray;
	NSMutableDictionary*    UserDic;
	NSString*               LeseboxPfad;
	NSTextFieldCell*        NamenCell;
	NSImageCell*            RecPlayIcon;
	NSMutableString*        neuerHostName;
	
	BOOL                 istSystemVolume;
}

- (IBAction)Abbrechen:(id)sender;
- (IBAction)HomeDirectory:(id)sender;
- (NSString*)chooseNetworkLeseboxPfad;
- (IBAction)toggleDrawer:(id)sender;
- (IBAction)VolumeOK:(id)sender;
- (IBAction)reportAuswahlen:(id)sender;
- (IBAction)reportAnmelden:(id)sender;
- (IBAction)checkUser:(id)sender;
- (BOOL)checkUserAnPfad:(NSString*)derUserPfad;

- (int) anzVolumes;
- (void) setHomeStatus:(BOOL) derStatus;
- (void) setUserArray:(NSArray*) dieUser;
- (void)setNetworkArray:(NSArray*) derNetworkArray;

- (NSString*)LeseboxPfad;
- (BOOL)istSystemVolume;
@end

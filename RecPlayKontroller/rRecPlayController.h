/* rRecPlayController */

#import <Cocoa/Cocoa.h>
//#include "Quicktime/Quicktime.h"
#include "QTKit/QTKit.h"

#include "rLevelmeter.h"
//#include "rRecorder.h"
//#include "rPlayer.h"
#include "rAbspielanzeige.h"
#import "rAdminPlayer.h"
//#import "rAdminDS.h"
//#import "rAufnahmenDrawer.h"
#import "rArchivDS.h"
#import "rArchivView.h"
#import "rEinstellungen.h"
#import "rVolumes.h"
#import "rProjektListe.h"
#import "rEingabeFeld.h"
//#import "rProjektListePanel.h"
#import "rProjektNamen.h"
#import "rProjektStart.h"
#import "rUtils.h"
#import "rNamenListe.h"
#import "rPasswortListe.h"
#import "rTitelListe.h"
#import "rEinzelNamen.h"


@class QTCaptureView;
@class QTCaptureSession;
@class QTCaptureDeviceInput;
@class QTCaptureMovieFileOutput;
@class QTCaptureAudioPreviewOutput;
@class QTCaptureConnection;
@class QTCaptureDevice;


@interface rRecPlayController : NSWindowController <NSTabViewDelegate, NSWindowDelegate, NSMenuDelegate>
{
	// QTKit
	IBOutlet QTCaptureView *mCaptureView;
	IBOutlet NSLevelIndicator	*audioLevelMeter;
	
	
	QTCaptureSession            *mCaptureSession;
	QTCaptureMovieFileOutput    *mCaptureMovieFileOutput;
	QTCaptureDeviceInput        *mCaptureVideoDeviceInput;
	QTCaptureDeviceInput        *mCaptureAudioDeviceInput;
	
	// aus QTRecorder
	QTCaptureMovieFileOutput		*movieFileOutput;
	QTCaptureAudioPreviewOutput	*audioPreviewOutput;
	NSTimer								*audioLevelTimer;
	NSTimer								*playBalkenTimer;
	NSTimer								*playArchivBalkenTimer;
	// End QTKit
	
	
	
	IBOutlet NSTextField*				TitelString;
	IBOutlet NSTextField*				ModusString;
	IBOutlet NSTextField *				Zeitfeld;
	IBOutlet NSTextField *				Levelfeld;
	IBOutlet NSTextField *				Leserfeld;
	IBOutlet NSTextField *				Abspieldauerfeld;
	IBOutlet NSTextField *				Kommentarfeld;
	IBOutlet NSTextView*					KommentarView;
	IBOutlet NSProgressIndicator*		Levelbalken;
	IBOutlet NSPopUpButton *			ArchivnamenPop;
	IBOutlet NSComboBox *				TitelPop;
	IBOutlet NSComboBox *				NeueTitelPop;
	
	IBOutlet NSWindow*					RecPlayFenster;
	IBOutlet NSTabView*					RecPlayTab;
	IBOutlet NSTextField *				Testfeld;
	IBOutlet NSButton*					StartRecordKnopf;
	IBOutlet NSButton*					StopRecordKnopf;
	IBOutlet NSButton*					StartPlayKnopf;
	IBOutlet NSButton*					StopPlayKnopf;
	IBOutlet NSButton*					StartStopKnopf;
	IBOutlet NSTextField*				StartStopString;
	
	IBOutlet NSButton*					BackKnopf;
	IBOutlet NSButton*					SichernKnopf;
	IBOutlet NSButton*					WeitereAufnahmeKnopf;
	IBOutlet NSButton*					LogoutKnopf;
	IBOutlet NSPopUpButton*				KommentarPop;
	
	IBOutlet rArchivView*				ArchivView;
	IBOutlet NSButton*					ArchivPlayTaste;
	IBOutlet NSButton*					ArchivStopTaste;
	IBOutlet NSButton*					ArchivZumStartTaste;
	IBOutlet NSButton*					ArchivInListeTaste;
	IBOutlet NSButton*					ArchivInPlayerTaste;
	IBOutlet NSTextField*				ArchivTitelfeld;
	IBOutlet NSTextField*				ArchivDatumfeld;
	IBOutlet NSTextField*				ArchivBewertungfeld;
	IBOutlet NSTextField*				ArchivNotenfeld;
	IBOutlet NSButton*					UserMarkCheckbox;
	IBOutlet NSTextField*				ArchivAbspieldauerFeld;
	IBOutlet rAbspielanzeige*			ArchivAbspielanzeige;
	// QTKit
	IBOutlet QTCaptureView*				RecordQTKitView;
	
	IBOutlet QTMovieView*				RecordQTKitPlayer;
	IBOutlet QTMovieView*				ArchivQTKitPlayer;
	IBOutlet NSButton*					StartRecordQTKitKnopf;
	IBOutlet NSButton*					StopRecordQTKitKnopf;
	IBOutlet NSButton*					StartPlayQTKitKnopf;
	IBOutlet NSButton*					StopPlayQTKitKnopf;
	IBOutlet NSButton*					StartStopQTKitKnopf;
	IBOutlet NSButton*					BackQTKitKnopf;
	
	QTMovie*									QTKitMovie;
	
	NSURL*								LeseboxURL;
	NSURL*								ArchivURL;
	
	TimeValue							Dauer;
	TimeValue							Laufzeit;
	TimeValue							ArchivLaufzeit;
	
	rArchivDS*							ArchivDaten;
	int									ArchivSelektierteZeile;
	UInt32								ArchivAbspielzeit;
	NSString*							ArchivPlayPfad;
	NSString*							ArchivKommentarPfad;
	NSTextView*							ArchivKommentarView;
	BOOL									ArchivZeilenhit;
	BOOL									NoteZeigen;
	BOOL									BewertungZeigen;
	
	NSMutableString*					LeseboxPfad;//Pfad zur aktuellen Lesebox
	NSString*                     ArchivPfad;
	NSString*                     ProjektPfad;
	NSMutableArray*					ProjektArray;
	NSMutableArray*						PListProjektArray;
	NSMutableDictionary*				PListDic;
	BOOL                          istSystemVolume;
	BOOL                          AdminZugangOK;
	
	IBOutlet NSTextField*			ProjektFeld;
	NSMenu*								ProjektMenu;
	NSMutableArray*					ProjektNamenArray;
	NSMutableString*					KommentarOrdnerPfad;
	BOOL                          LeseboxDa;
	NSString*							Leser;
	NSString*							LeserPfad;
	
	FSSpec								neueAufnahmeSpec;
	FSRef									neueAufnahmeRef;
	short									MovieRef;
	NSString*							neueAufnahmePfad;
	NSSound *							neueAufnahme;
	
	
	
	NSTimer *							timer;
	NSTimer *							AufnahmezeitTimer;
	NSTimer *							AbspielzeitTimer;
	UInt32								GesamtAufnahmezeit;
	
	NSString*						hiddenAufnahmePfad;
	
	float								QTKitGesamtAufnahmezeit;
	float								QTKitDauer;
	float								QTKitPause;
	UInt32								Aufnahmedauer;
	UInt32								GesamtAbspielzeit;
	float									QTKitGesamtAbspielzeit;
	UInt32								Abspieldauer;
	UInt32								Pause;
	int									Durchgang;

	BOOL								MoviePlayerbusy;
	BOOL								ArchivPlayerGeladen;
	
	
	Handle								RecordereinstellungenH;
	NSMutableData*						RPDevicedaten;
	NSMutableData*						SystemDevicedaten;
	
	
	
	
	IBOutlet NSSlider *					Volumesteller;
	IBOutlet rLevelmeter*				Levelmeter;
	IBOutlet rAbspielanzeige*			Abspielanzeige;
	IBOutlet	id								PWFeld;
	
	IBOutlet NSMenu*					AblaufMenu;
	IBOutlet NSMenu*					ModusMenu;
	IBOutlet NSMenu*					RecorderMenu;
	
	int									Wert1, Wert2, Wert3;
	int									aktuellAnzAufnahmen;
	int									RPDevicedatenlaenge;
	int									istAdmin;
	int									RPModus;
	BOOL									InputDeviceOK;
	rAdminPlayer*						AdminPlayer;
	
	//rKommentar*							KommentarFenster;
	rEinstellungen*						EinstellungenFenster;
	rVolumes*							VolumesPanel;
	rProjektListe*						ProjektPanel;
	rProjektNamen*						ProjektNamenPanel;
	rProjektStart*						ProjektStartPanel;
	rPasswortListe*						PasswortListePanel;
	rTitelListe*						TitelListePanel;
	//NSString*							ProjektName;
	BOOL								ProjektAktiviert;
	rEinzelNamen*						EinzelNamenPanel;
	rNamenListe*						NamenPanel;
	
	NSString*							LeseboxVolume;
	int									Umgebung;
	
	rPasswortDialog*					PasswortDialogPanel;
	NSMutableArray*						UserPasswortArray;
	BOOL								mitAdminPasswort;
	NSMutableDictionary*				AdminPasswortDic;
	
	BOOL								mitUserPasswort;
	BOOL								istErsteRunde;
	
	rUtils*								Utils;
	IBOutlet id TestDrawer;
	NSTimeInterval						TimeoutDelay;
	NSData*								GrabberOutputDaten;
	BOOL								neueSettings;
	BOOL								istNeueAufnahme;
	long								KnackDelay;
}
#pragma mark Player
- (IBAction)startPlay:(id)sender;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopPlay:(id)sender;
- (IBAction)stopRecord:(id)sender;
- (IBAction)startStop:(id)sender;
- (IBAction)goStart:(id)sender;
- (void)setLevel:(int)derLevel;
- (IBAction)showSettingsDialog:(id)sender;
- (IBAction)restoreSettings:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)setLeser:(id)sender;
- (IBAction)setLesebox:(id)sender;
- (IBAction)resetLesebox:(id)sender;
- (void)ListeAktualisierenAktion:(NSNotification*)note;
- (IBAction)setLeserliste:(id)sender;
- (IBAction)Logout:(id)sender;
- (IBAction)setTitel:(id)sender;
- (int)AufnahmeNummerVon:(NSString*) dieAufnahme;
- (NSString*)DatumVon:(NSString*) derKommentarString;

#pragma mark QTKit Functions
- (IBAction)startQTKitRecord:(id)sender;
- (IBAction)stopQTKitRecord:(id)sender;
- (IBAction)startQTKitStop:(id)sender;
- (IBAction)goQTKitStart:(id)sender;
- (void)updateAudioLevels:(NSTimer *)timer;
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;

#pragma mark Kommentar
- (NSString*)BewertungVon:(NSString*) derKommentarString;
- (NSString*)KommentarVon:(NSString*) derKommentarString;
- (NSString*)NoteVon:(NSString*) derKommentarString;
//- (int)Mark;
//- (void)setMark:(BOOL)derStatus;

- (NSString*)titel;
- (IBAction)PrefsLesen:(id)sender;
- (IBAction)PrefsSchreiben:(id)sender;
- (void)setRecPlay;
- (IBAction)ReadDeviceEinstellungen:(id)sender;
- (IBAction)WriteDeviceEinstellungen:(id)sender;
- (BOOL)WriteSystemDeviceEinstellungen;
- (IBAction)Einstellungentest:(id)sender;
- (OSErr) finishMovie:(NSString*)derAufnahmePfad zuPfad:(NSString*)derFinishPfad;

- (void)setTimerfunktion:(NSTimer*) derTimer;
//- (void)setAufnahmetimerfunktion:(NSTimer*) derTimer;
- (void)Abspieltimerfunktion:(NSTimer *)derTimer;
- (OSErr)Aufnahmevorbereiten;
- (BOOL)Leseboxvorbereiten;
- (OSErr)Leseboxeinrichten;
- (void)setArchivNamenPop;
- (BOOL)setNetworkLeseboxPfad:(id)sender;
- (BOOL)setHomeLeseboxPfad:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem*)anItem;

- (BOOL)setKommentarFuerLeser:(NSString*) derLeser FuerAufnahme:(NSString*)dieAufnahme;
- (NSString*)Zeitformatieren:(long) dieSekunden;
- (void) VolumesAktion:(NSNotification*)note;
- (NSString*) chooseLeseboxPfadMitUserArray:(NSArray*)derUserArray undNetworkArray:(NSArray*)derNetworkArray;
- (BOOL)NamenlisteValidAnPfad:(NSString*)derProjektPfad;
- (void)updateProjektArray;
//- (NSArray*) checkUsersMitLesebox;
- (BOOL)AdminPW;
- (IBAction)setVolume:(id)sender;
- (NSString*)Initialen:(NSString*)derName;
- (NSString*)AufnahmeTitelVon:(NSString*) dieAufnahme;
//- (int)AufnahmeNummerVon:(NSString*) dieAufnahme;

- (BOOL)AdminMarkVon:(NSString*) derKommentarString;
- (BOOL)UserMarkVon:(NSString*) derKommentarString;
- (IBAction)reportUserMark:(id)sender;
- (void)saveUserMarkFuerAufnahmePfad:(NSString*)derAufnahmePfad;
- (void)saveAdminMarkFuerAufnahmePfad:(NSString*)derAufnahmePfad;

//- (NSMutableArray*)OrdnernamenArrayVonKlassenliste;
- (NSArray*)ProjektNamenArrayVon:(NSString*)derArchivPfad;
- (void)keyDown:(NSEvent *)theEvent;

- (void)setArchivView;
- (IBAction)ArchivaufnahmeInPlayer:(id)sender;
- (IBAction)ArchivZurListe:(id)sender;
- (IBAction)startArchivPlayer:(id)sender;
- (IBAction)stopArchivPlayer:(id)sender;
- (IBAction)backArchivPlayer:(id)sender;
- (IBAction)resetArchivPlayer:(id)sender;
- (IBAction)keyDownAktion:(id)sender;
- (void)setArchivKommentarFuerAufnahmePfad:(NSString*)derAufnahmePfad;
- (void)clearArchivKommentar;
- (void)clearArchiv;
- (IBAction)MarkierungenWeg:(id)sender;
- (void) ZeilenNotifikationAktion:(NSNotification*)note;

- (IBAction)beginAdminPlayer:(id)sender;
- (IBAction)switchAdminPlayer:(id)sender;
- (IBAction) Testknopf:(id)sender;
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;

- (IBAction)showEinzelNamen;
- (IBAction)showNamenListe:(id)sender;
- (IBAction)showEinzelNamen:(id)sender;
- (IBAction)showPasswortListe:(id)sender;

- (IBAction)showEinstellungen:(id)sender;

- (void)BewertungNotifikationAktion:(NSNotification*)note;
- (void)NotenNotifikationAktion:(NSNotification*)note;
- (void)resetRecPlay;
- (BOOL)beenden;
- (IBAction)terminate:(id)sender;
- (BOOL)savePList:(NSDictionary*)diePList anPfad:(NSString*)derLeseboxPfad;
- (BOOL)windowShouldClose:(id)sender;
- (IBAction)print:(id)sender;
- (IBAction)neuOrdnen:(id)sender;
- (IBAction)showClean:(id)sender;

- (void)ProjektListeAktion:(NSNotification*)note;
- (void)setProjektMenu;
- (IBAction)showProjektListe:(id)sender;
- (void)showProjektListeVomStart;
- (IBAction)showTitelListe:(id)sender;
- (void)TitelListeAktion:(NSNotification*)note;

- (IBAction)showProjektStart:(id)sender;
- (void)ProjektStartAktion:(NSNotification*)note;
- (BOOL)anderesProjektEinrichtenMit:(NSString*)dasProjekt;
- (IBAction)anderesProjektMitTitel:(NSString*)derTitel;
- (IBAction)setNeuesProjekt:(id)sender;
- (void)savePListAktion:(NSNotification*)note;
- (IBAction)showChangePasswort:(id)sender;
- (IBAction)showChangeAdminPasswort:(id)sender;
- (IBAction)AlleMarkierungenWeg:(id)sender;
- (BOOL)checkAdminZugang;
- (int) fileInPapierkorb:(NSString*) derFilepfad;

- (NSArray*)AufnahmeRetten;
- (IBAction)KommentarSichern:(id)sender;
- (void)SaveKommentarAktion:(NSNotification*)note;
- (void)checkSessionDatumFor:(NSString*)dasProjekt;
- (IBAction)neueSession:(id)sender;
- (void)saveUserPasswortArray:(NSArray*)derPasswortArray;
- (void)saveSessionForUser:(NSString*)derUser inProjekt:(NSString*)dasProjekt;
- (void)saveSessionDatum:(NSDate*)dasDatum inProjekt:(NSString*)dasProjekt;
- (void)saveNeuesProjekt:(NSDictionary*)derProjektDic;
- (void)saveUserPasswortDic:(NSDictionary*)derPasswortDic;
- (void)saveTitelListe:(NSArray*)dieTitelListe inProjekt:(NSString*)dasProjekt;
- (void)saveTitelFix:(BOOL)derStatus inProjekt:(NSString*)dasProjekt;
- (void)saveNeuenProjektArray:(NSArray*)derProjektArray;
- (void)clearSessionInProjekt:(NSString*)dasProjekt;
- (NSArray*)SessionLeserListeVonProjekt:(NSString*)dasProjekt;
- (void)SessionListeAktualisieren;


@end

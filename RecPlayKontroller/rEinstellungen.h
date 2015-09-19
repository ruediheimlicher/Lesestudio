/* rEinstellungen */

#import <Cocoa/Cocoa.h>

@interface rEinstellungen : NSViewController <NSTabViewDelegate, NSWindowDelegate, NSMenuDelegate>
{
    IBOutlet id BewertungZeigen;
    IBOutlet id NoteZeigen;
	IBOutlet id mitUserPasswort;
	IBOutlet id TimeoutCombo;

}
@property (nonatomic, strong) IBOutlet NSTextField*				AnzeigeFeld; 

- (IBAction)reportClose:(id)sender;
- (IBAction)reportCancel:(id)sender;
- (void)setMitPasswort:(BOOL)mitPW;

- (void)setBewertung:(BOOL)mitBewertung;
- (void)setNote:(BOOL)mitNote;
- (void)setTimeoutDelay:(NSTimeInterval)derDelay;
- (void)setzeAnzeigeFeld:(NSString *)anzeige;
@end

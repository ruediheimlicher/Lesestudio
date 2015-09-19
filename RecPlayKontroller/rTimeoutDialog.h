/* rTimeoutDialog */

#import <Cocoa/Cocoa.h>

@interface rTimeoutDialog : NSWindowController
{
    IBOutlet id Icon;
    IBOutlet id Zeitfeld;
	
	IBOutlet id	LesestudioString;
	IBOutlet NSTextField*	StartFeld;
	IBOutlet id		TitelString;
	NSTimer*		TimeoutDialogTimer;
	int				TimeoutCount;
}
- (void)setDialogTimer:(int)dieWarteZeit;
- (void)setText:(NSString*)derTextString;
- (void)setZeit:(int)dieZeit;
- (IBAction)reportAbmelden:(id)sender;
- (IBAction)reportUnterbrechen:(id)sender;
- (void)stopTimeoutDialogTimer:(id)sender;
@end

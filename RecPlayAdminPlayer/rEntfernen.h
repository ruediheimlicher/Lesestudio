/* rEntfernen */

#import <Cocoa/Cocoa.h>

@interface rEntfernen : NSWindowController
{
    IBOutlet id EntfernenVariante;
	IBOutlet id TitelString;
	IBOutlet id TextString;
}
- (IBAction)OKSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

@end

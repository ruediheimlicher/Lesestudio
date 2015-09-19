#import "rPasswortEingabeFeld.h"

@implementation rPasswortEingabeFeld 

- (id) init
{
    if ((self = [super init]))
	return self;
   return 0;
}

/*
- (void)keyDown:(NSEvent*)theEvent
{
[super keyDown:theEvent];
return;
	int nr=[theEvent keyCode];
	NSString* Taste=[theEvent characters];
	NSLog(@"rPasswortEingabeFeld keyDown: %@   %@",[theEvent characters],Taste);	
	//if([[Taste description]isEqualToString:@"\r"])
	//	NSLog(@"                    Enter");
	NSNumber* KeyNummer;
	KeyNummer=[NSNumber numberWithInt:nr];
	NSLog(@"keyDown: %@",[theEvent characters]);
	//NSLog(@"ArchivListe keyDown nr: %d  char: %@",nr,[theEvent characters]);
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	//[nc postNotificationName:@"Pfeiltaste" object:KeyNummer];
	
	[super keyDown:theEvent];
}
*/

- (void) awakeFromNib
{

}



 -(BOOL)textShouldBeginEditing:(NSText *)textObject
 {
 //NSLog(@"textShouldBeginEditing");
 	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];

//[nc postNotificationName:@"altesPW" object:self];
    return YES;
 }
 
  - (BOOL)becomeFirstResponder
 {
 
  	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];

[nc postNotificationName:@"altesPW" object:self];

 BOOL antwort=[super becomeFirstResponder];
 return antwort;
}
/* 
 - (BOOL)becomeFirstResponder
 {
  NSLog(@"rPasswortEingabeFeld becomeFirstResponder");

	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];

[nc postNotificationName:@"altesPW" object:self];

 return YES;
 }
 */
@end

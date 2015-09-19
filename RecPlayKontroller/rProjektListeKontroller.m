//
//  rProjektListeKontroller.m
//  RecPlayII
//
//  Created by sysadmin on 11.06.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "rRecPlayController.h"


@implementation rRecPlayController(rProjektListeKontroller)

- (IBAction)showProjektListe:(id)sender
{
	if (!ProjektPanel)
	  {
		ProjektPanel=[[rProjektListe alloc]init];
	  }
	
	NSLog(@"showProjektListe");
	//[ProjektPanel showWindow:self];
	NSModalSession ProjektSession=[NSApp beginModalSessionForWindow:[ProjektPanel window]];
	int modalAntwort = [NSApp runModalForWindow:[ProjektPanel window]];
	
	[NSApp endModalSession:ProjektSession];
	[[ProjektPanel window] orderOut:NULL];   
	
}



- (void)ProjektListeAktion:(NSNotification*)note
{
	NSLog(@"ProjektListeAktion: %@",[[[note userInfo] objectForKey:@"projektarray"]description]);
	
}

@end

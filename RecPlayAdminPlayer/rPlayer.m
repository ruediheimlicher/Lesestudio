//
//  rPlayer.m
//  RecPlayC
//
//  Created by Ruedi Heimlicher on 05.09.04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "rPlayer.h"


@implementation rPlayer
- init
{
	[[self super]init];
	return self;
}
- (OSErr)	setPfad:(NSString*) derPfad
{
	OSErr err=0;
    NSURL *AufnahmeURL = [NSURL fileURLWithPath:derPfad];
    /* create an NSMovie object from our QuickTime movie */
    NSMovie *tempMovie = [[NSMovie alloc] initWithURL:AufnahmeURL byReference:YES];
    /* retrieve the QuickTime-style movie (type "Movie" from QuickTime/Movies.h) */
    Movie tempQTMovie = [tempMovie QTMovie];
    /* save (for later use) the QuickTime-style movie type for our NSMovie */
    Aufnahme = tempQTMovie;
	
	return err;
}//PlayerVorbereiten

@end

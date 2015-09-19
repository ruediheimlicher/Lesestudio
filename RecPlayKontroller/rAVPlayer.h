//
//  rAVPlayer.h
//  Lesestudio
//
//  Created by Ruedi Heimlicher on 23.08.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface rAVPlayer : NSObject
{
   AVAudioPlayer *                     AVAbspielplayer;
   NSTimer* posTimer;
   NSTimer* adminposTimer;
   NSTimeInterval haltzeit;
}
@property (assign) NSWindow *          PlayerFenster;
@property (weak) NSURL*                tempDirURL;
@property  NSString*                   hiddenAufnahmePfad;


- (void)playAufnahme;
- (void)playArchivAufnahme;
- (void)playAdminAufnahme;
- (void)stopTempAufnahme;
- (void)rewindTempAufnahme;
- (void)forewardTempAufnahme;
- (void)toStartTempAufnahme;

- (void)prepareAufnahmeAnURL:(NSURL*)url;
- (void)prepareArchivAufnahmeAnURL:(NSURL*)url;
- (void)prepareAdminAufnahmeAnURL:(NSURL*)url;
- (NSURL*)AufnahmeURL;
- (BOOL)isPlaying;
- (void)invalTimer;
- (double)duration;
- (double)position;
- (void)resetTimer;
@end

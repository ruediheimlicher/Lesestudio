//
//  AppDelegate.m
//  Lesestudio_20
//
//  Created by Ruedi Heimlicher on 01.09.2015.
//  Copyright (c) 2015 Ruedi Heimlicher. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   // Insert code here to initialize your application
   NSImage* ProgrammImage = [NSImage imageNamed: @"MicroIcon"];
   [NSApp setApplicationIconImage: ProgrammImage];
   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
  
    }

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
   // Insert code here to tear down your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
   NSMutableDictionary* BeendenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [BeendenDic setObject:[NSNumber numberWithInt:1] forKey:@"beenden"];
   NSNotificationCenter* beendennc=[NSNotificationCenter defaultCenter];
   [beendennc postNotificationName:@"externbeenden" object:self userInfo:BeendenDic];
   
   return NO;
}

@end

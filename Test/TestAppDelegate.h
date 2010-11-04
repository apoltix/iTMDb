//
//  TestAppDelegate.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <iTMDb/iTMDb.h>

@interface TestAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, TMDBDelegate> {
	IBOutlet NSWindow *window;

	TMDB *tmdb;

	// IBOutlets
	IBOutlet NSTextField *apiKey;
	IBOutlet NSTextField *movieID;
	IBOutlet NSTextField *movieTitle;
	IBOutlet NSTextView  *movieOverview;
	IBOutlet NSTextField *movieRuntime;

	IBOutlet NSButton *goButton;
	IBOutlet NSProgressIndicator *throbber;
}

@property (nonatomic, retain, readonly) NSWindow *window;
@property (nonatomic, assign, readonly) BOOL isGoButtonEnabled;

- (IBAction)go:(id)sender;

- (BOOL)isGoButtonEnabled;

@end
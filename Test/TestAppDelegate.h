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
	TMDB *tmdb;

	NSArray *allData;

	// IBOutlets
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *allDataWindow;

	IBOutlet NSTextField *apiKey;
	IBOutlet NSTextField *movieID;
	IBOutlet NSTextField *movieTitle;
	IBOutlet NSTextView  *movieOverview;
	IBOutlet NSTextField *movieRuntime;

	IBOutlet NSButton *goButton;
	IBOutlet NSProgressIndicator *throbber;
	IBOutlet NSButton *viewAllDataButton;

	IBOutlet NSTextView *allDataTextView;
}

@property (nonatomic, retain, readonly) NSWindow *window;

- (IBAction)go:(id)sender;
- (IBAction)viewAllData:(id)sender;

@end
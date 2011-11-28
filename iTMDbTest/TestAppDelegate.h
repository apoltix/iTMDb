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
	TMDBMovie *movie;

	NSArray *allData;

	// IBOutlets
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *allDataWindow;

	IBOutlet NSTextField *apiKey;
	IBOutlet NSTextField *movieID;
	IBOutlet NSTextField *movieName;
	IBOutlet NSTextField *language;

	IBOutlet NSTextField *movieTitle;
	IBOutlet NSTextView  *movieOverview;
	IBOutlet NSTokenField*movieKeywords;
	IBOutlet NSTextField *movieRuntime;
	IBOutlet NSTextField *movieReleaseDate;
	IBOutlet NSTextField *moviePostersCount;
	IBOutlet NSTextField *movieBackdropsCount;

	IBOutlet NSButton *goButton;
	IBOutlet NSProgressIndicator *throbber;
	IBOutlet NSButton *viewAllDataButton;

	IBOutlet NSTextView *allDataTextView;
}

@property (nonatomic, strong, readonly) NSWindow *window;

- (IBAction)go:(id)sender;
- (IBAction)viewAllData:(id)sender;

@end
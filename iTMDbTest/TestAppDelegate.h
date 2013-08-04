//
//  TestAppDelegate.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <iTMDb/iTMDb.h>

@interface TestAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, TMDBDelegate>

@property (nonatomic, strong) IBOutlet NSWindow *window;

@property (nonatomic, weak) IBOutlet NSWindow *allDataWindow;

@property (nonatomic, weak) IBOutlet NSTextField *apiKey;
@property (nonatomic, weak) IBOutlet NSTextField *movieID;
@property (nonatomic, weak) IBOutlet NSTextField *movieName;
@property (nonatomic, weak) IBOutlet NSTextField *movieYear;
@property (nonatomic, weak) IBOutlet NSTextField *language;

@property (nonatomic, weak) IBOutlet NSTextField *movieTitle;
@property (nonatomic, strong) IBOutlet NSTextView *movieOverview;
@property (nonatomic, weak) IBOutlet NSTokenField*movieKeywords;
@property (nonatomic, weak) IBOutlet NSTextField *movieRuntime;
@property (nonatomic, weak) IBOutlet NSTextField *movieReleaseDate;
@property (nonatomic, weak) IBOutlet NSTextField *moviePostersCount;
@property (nonatomic, weak) IBOutlet NSTextField *movieBackdropsCount;

@property (nonatomic, weak) IBOutlet NSButton *goButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *throbber;
@property (nonatomic, weak) IBOutlet NSButton *viewAllDataButton;

@property (nonatomic, strong) IBOutlet NSTextView *allDataTextView;

- (IBAction)go:(id)sender;
- (IBAction)viewAllData:(id)sender;

@end
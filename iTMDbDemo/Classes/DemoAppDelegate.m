//
//  DemoAppDelegate.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "DemoAppDelegate.h"
#import <iTMDb/iTMDb.h>

@interface DemoAppDelegate () <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, TMDBDelegate>

@property (nonatomic, strong) IBOutlet NSWindow *window;

@property (nonatomic, weak) IBOutlet NSWindow *allDataWindow;

@property (nonatomic, weak) IBOutlet NSTextField *apiKey;
@property (nonatomic, weak) IBOutlet NSTextField *searchMovieID;
@property (nonatomic, weak) IBOutlet NSTextField *searchMovieName;
@property (nonatomic, weak) IBOutlet NSTextField *movieYear;
@property (nonatomic, weak) IBOutlet NSTextField *language;
@property (nonatomic, weak) IBOutlet NSButton *fetchCastAndCrewCheckbox;
@property (nonatomic, weak) IBOutlet NSButton *fetchKeywordsCheckbox;
@property (nonatomic, weak) IBOutlet NSButton *fetchImageURLsCheckbox;

@property (nonatomic, weak) IBOutlet NSTextField *movieTitle;
@property (nonatomic, strong) IBOutlet NSTextView *movieOverview;
@property (nonatomic, weak) IBOutlet NSTokenField *movieKeywords;
@property (nonatomic, weak) IBOutlet NSTextField *movieRuntime;
@property (nonatomic, weak) IBOutlet NSTextField *movieReleaseDate;
@property (nonatomic, weak) IBOutlet NSTextField *moviePostersCount;
@property (nonatomic, weak) IBOutlet NSTextField *movieBackdropsCount;

@property (nonatomic, weak) IBOutlet NSButton *goButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *throbber;
@property (nonatomic, weak) IBOutlet NSButton *viewAllDataButton;

@property (nonatomic, weak) IBOutlet NSTableView *castAndCrewTableView;

@property (nonatomic, weak) IBOutlet NSCollectionView *postersCollectionView;

@property (nonatomic, strong) IBOutlet NSTextView *allDataTextView;

@property (nonatomic, copy) IBOutlet NSArray *posters;

@property (nonatomic, strong) TMDB *tmdb;
@property (nonatomic, strong) TMDBMovie *movie;
@property (nonatomic, strong) NSDictionary *allData;

@end

@implementation DemoAppDelegate {
@private
	NSCache *_cache;
}

+ (void)initialize
{
	NSDictionary *defaults = @{
		@"appKey": @"",
		@"movieID": @0,
		@"movieName": @"",
		@"language": @""
	};
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	_cache = [[NSCache alloc] init];
	_tmdb = nil;

	NSFont *font = [NSFont fontWithName:@"Lucida Console" size:11.0];
	if (!font)
		font = [NSFont fontWithName:@"Courier" size:11.0];
	[_allDataTextView setFont:font];
}

#pragma mark -

- (IBAction)go:(id)sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];

	NSString *apiKey = [self.apiKey stringValue];

	if (!([apiKey length] > 0 && ([self.searchMovieID integerValue] > 0 || [[self.searchMovieName stringValue] length] > 0)))
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Missing either API key, movie ID or title"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Please enter both API key, and a movie ID or title.\n\nYou can obtain an API key from themoviedb.org."];
		[alert beginSheetModalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];

		return;
	}

	[self.throbber startAnimation:self];
	self.goButton.enabled = NO;
	self.viewAllDataButton.enabled = NO;

	// Initialize or update the framework setup
	if (!self.tmdb || ![self.tmdb.apiKey isEqualToString:apiKey])
		self.tmdb = [[TMDB alloc] initWithAPIKey:apiKey delegate:self language:nil];

	// Clear previous data, if any
	if (_allData)
		_allData = nil;

	// Set the language, if specified
	NSString *lang = [self.language stringValue];
	if ([lang length] > 0)
		self.tmdb.language = lang;
	else
		self.tmdb.language = @"en";

	// Define the amount of detail we want to fetch
	TMDBMovieFetchOptions fetchOptions = TMDBMovieFetchOptionBasic;

	if (self.fetchCastAndCrewCheckbox.state == NSOnState)
		fetchOptions |= TMDBMovieFetchOptionCasts;

	if (self.fetchKeywordsCheckbox.state == NSOnState)
		fetchOptions |= TMDBMovieFetchOptionKeywords;

	if (self.fetchImageURLsCheckbox.state == NSOnState)
		fetchOptions |= TMDBMovieFetchOptionImages;

	// Actually fetch the movie based on the information we have
	if ([self.searchMovieID integerValue] > 0)
	{
		self.movie = [[TMDBMovie alloc] initWithID:[self.searchMovieID integerValue] options:fetchOptions context:self.tmdb];
	}
	else if ([self.movieYear integerValue] > 0)
	{
		self.movie = [[TMDBMovie alloc] initWithName:[self.searchMovieName stringValue] year:(NSUInteger)[self.movieYear integerValue] options:fetchOptions context:self.tmdb];
	}
	else
	{
		self.movie = [[TMDBMovie alloc] initWithName:[self.searchMovieName stringValue] options:fetchOptions context:self.tmdb];
	}
}

- (IBAction)viewAllData:(id)sender
{
	if (_allData == nil)
		return;

	self.allDataTextView.string = [_allData description];

	[self.allDataWindow makeKeyAndOrderFront:self];
}

#pragma mark - TMDBDelegate

- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)aMovie
{
	NSLog(@"Loaded %@", aMovie);

	[self.throbber stopAnimation:self];
	self.goButton.enabled = YES;
	self.viewAllDataButton.enabled = YES;

	_allData = [aMovie.rawResults copy];

	self.movieTitle.stringValue = aMovie.title ? : @"";
	self.movieOverview.string = aMovie.overview ? : @"";
	self.movieRuntime.stringValue = [NSString stringWithFormat:@"%lu minutes", aMovie.runtime] ? : @"";

	self.movieKeywords.stringValue = [aMovie.keywords componentsJoinedByString:@", "] ? : @"";

	static NSDateFormatter *releaseDateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		releaseDateFormatter = [[NSDateFormatter alloc] init];
		releaseDateFormatter.timeStyle = NSDateFormatterNoStyle;
		releaseDateFormatter.dateStyle = NSDateFormatterMediumStyle;
	});
	self.movieReleaseDate.stringValue = [releaseDateFormatter stringFromDate:aMovie.released] ? : @"";

	self.moviePostersCount.stringValue = [NSString stringWithFormat:@"%lu (%lu sizes total)", [aMovie.posters count], [context.configuration.imagesPosterSizes count]];
	self.movieBackdropsCount.stringValue = [NSString stringWithFormat:@"%lu (%lu sizes total)", [aMovie.backdrops count], [context.configuration.imagesBackdropSizes count]];

	self.posters = aMovie.posters;
	[self.castAndCrewTableView reloadData];
}
		
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error
{
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];

	self.movieTitle.stringValue = @"";
	self.movieOverview.string = @"";
	self.movieRuntime.stringValue = @"";
	self.movieReleaseDate.stringValue = @"";
	self.moviePostersCount.stringValue = @"";
	self.movieBackdropsCount.stringValue = @"";

	[self.throbber stopAnimation:self];
	self.goButton.enabled = YES;
	self.viewAllDataButton.enabled = NO;

	self.postersCollectionView.content = @[];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_movie.cast count];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	TMDBPerson *person = _movie.cast[row];
	NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

	if ([tableColumn.identifier isEqualToString:@"imageAndName"])
	{
		view.textField.stringValue = person.name;

		NSURL *imageURL = nil;
		if (person.imageURL != nil)
		{
			TMDBConfiguration *config = _movie.context.configuration;
			imageURL = config.imagesBaseURL;
			imageURL = [imageURL URLByAppendingPathComponent:config.imagesPosterSizes[0]];
			imageURL = [imageURL URLByAppendingPathComponent:[person.imageURL path]];
		}

		if (imageURL != nil)
		{
			__block NSImage *image = [_cache objectForKey:imageURL];

			if (image != nil)
				view.imageView.image = image;
			else
			{
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					image = [[NSImage alloc] initWithContentsOfURL:imageURL];

					dispatch_async(dispatch_get_main_queue(), ^{
						[_cache setObject:image forKey:imageURL];
						view.imageView.image = image;
					});
				});
			}
		}
		else
			view.imageView.image = nil;
	}
	else if ([tableColumn.identifier isEqualToString:@"character"])
	{
		if ([person.job isEqualToString:@"Actor"])
			view.textField.stringValue = person.character ? : person.job ? : @"";
		else
			view.textField.stringValue = person.job ? : @"";
	}
	else if ([tableColumn.identifier isEqualToString:@"other"])
	{
		if ([person.job isEqualToString:@"Actor"])
			view.textField.stringValue = person.job ? : @"";
		else
			view.textField.stringValue = @"";
	}
	else
		view = nil;

	return view;
}

#pragma mark -

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
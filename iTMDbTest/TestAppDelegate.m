//
//  TestAppDelegate.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TestAppDelegate.h"

@interface TestAppDelegate ()

@property (nonatomic, strong) TMDB *tmdb;
@property (nonatomic, strong) TMDBMovie *movie;
@property (nonatomic, strong) NSDictionary *allData;

@end

@implementation TestAppDelegate

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

	_tmdb = nil;

	NSFont *font = [NSFont fontWithName:@"Lucida Console" size:11.0];
	if (!font)
		font = [NSFont fontWithName:@"Courier" size:11.0];
	[_allDataTextView setFont:font];

	self.postersCollectionView.content = @[
		@"Hello",
		@"There",
		@"Test",
		@"Poster"
	];
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
							 informativeTextWithFormat:@"Please enter both API key, and a movie ID or title.\n\n"
													   @"You can obtain an API key from themoviedb.org."];
		[alert beginSheetModalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];

		return;
	}

	[self.throbber startAnimation:self];
	self.goButton.enabled = NO;
	self.viewAllDataButton.enabled = NO;

	if (!_tmdb || ![_tmdb.apiKey isEqualToString:apiKey])
		_tmdb = [[TMDB alloc] initWithAPIKey:apiKey delegate:self language:nil];

	if (_allData)
		_allData = nil;

	NSString *lang = [self.language stringValue];
	if (lang && [lang length] > 0)
		_tmdb.language = lang;
	else
		_tmdb.language = @"en";

	TMDBMovieFetchOptions fetchOptions = TMDBMovieFetchOptionBasic;

	if (self.fetchCastAndCrewCheckbox.state == NSOnState)
		fetchOptions |= TMDBMovieFetchOptionCasts;

	if (self.fetchKeywordsCheckbox.state == NSOnState)
		fetchOptions |= TMDBMovieFetchOptionKeywords;

	if (self.fetchImageURLsCheckbox.state == NSOnState)
		fetchOptions |= TMDBMovieFetchOptionImages;

	if ([self.searchMovieID integerValue] > 0)
		self.movie = [[TMDBMovie alloc] initWithID:[self.searchMovieID integerValue] options:fetchOptions context:_tmdb];
	else if ([self.movieYear integerValue] > 0)
		self.movie = [[TMDBMovie alloc] initWithName:[self.searchMovieName stringValue] year:(NSUInteger)[self.movieYear integerValue] options:fetchOptions context:_tmdb];
	else
		self.movie = [[TMDBMovie alloc] initWithName:[self.searchMovieName stringValue] options:fetchOptions context:_tmdb];
}

- (IBAction)viewAllData:(id)sender
{
	if (!_allData)
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
	self.movieRuntime.stringValue = [NSString stringWithFormat:@"%lu", aMovie.runtime] ? : @"";

	self.movieKeywords.stringValue = [aMovie.keywords componentsJoinedByString:@", "] ? : @"";

	static NSDateFormatter *releaseDateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		releaseDateFormatter = [[NSDateFormatter alloc] init];
		[releaseDateFormatter setDateFormat:@"dd-MM-yyyy"];
	});
	self.movieReleaseDate.stringValue = [releaseDateFormatter stringFromDate:aMovie.released] ? : @"";

	self.moviePostersCount.stringValue = [NSString stringWithFormat:@"%lu (%lu sizes total)", [aMovie.posters count], [context.configuration.imagesPosterSizes count]];
	self.movieBackdropsCount.stringValue = [NSString stringWithFormat:@"%lu (%lu sizes total)", [aMovie.backdrops count], [context.configuration.imagesBackdropSizes count]];

	self.postersCollectionView.content = aMovie.posters;
}
		
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error
{
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];

	self.movieTitle.stringValue = @"";
	self.movieOverview.string = @"";
	self.movieRuntime.stringValue = @"0";
	self.movieReleaseDate.stringValue = @"00-00-0000";
	self.moviePostersCount.stringValue = @"0 (0 sizes total)";
	self.movieBackdropsCount.stringValue = @"0 (0 sizes total)";

	[self.throbber stopAnimation:self];
	self.goButton.enabled = YES;
	self.viewAllDataButton.enabled = NO;

	self.postersCollectionView.content = @[];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return 10;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier isEqualToString:@"imageAndName"])
	{
		NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];

		view.textField.stringValue = [NSString stringWithFormat:@"Row %li", row];

		return view;
	}
	else if ([tableColumn.identifier isEqualToString:@"secondary"])
	{
		NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];

		view.textField.stringValue = [NSString stringWithFormat:@"Row %li", row];

		return view;
	}

	return nil;
}

#pragma mark - NSTableViewDelegate

#pragma mark -

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
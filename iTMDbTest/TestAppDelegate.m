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
}

#pragma mark -

- (IBAction)go:(id)sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];

	if (!([[_apiKey stringValue] length] > 0 && ([_movieID integerValue] > 0 || [[_movieName stringValue] length] > 0)))
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

	[_throbber startAnimation:self];
	[_goButton setEnabled:NO];
	[_viewAllDataButton setEnabled:NO];

	if (!_tmdb)
		_tmdb = [[TMDB alloc] initWithAPIKey:[_apiKey stringValue] delegate:self language:nil];

	if (_allData)
	{
		_allData = nil;
	}

	NSString *lang = [_language stringValue];
	if (lang && [lang length] > 0)
		[_tmdb setLanguage:lang];
	else
		[_tmdb setLanguage:@"en"];

	if ([_movieID integerValue] > 0)
		_movie = [TMDBMovie movieWithID:[_movieID integerValue] options:TMDBMovieFetchOptionBasic context:_tmdb];
	else if ([_movieYear integerValue] > 0)
		_movie = [TMDBMovie movieWithName:[_movieName stringValue] year:(NSUInteger)[_movieYear integerValue] options:TMDBMovieFetchOptionBasic context:_tmdb];
	else
		_movie = [TMDBMovie movieWithName:[_movieName stringValue] options:TMDBMovieFetchOptionBasic context:_tmdb];
}

- (IBAction)viewAllData:(id)sender
{
	if (!_allData)
		return;

	[_allDataTextView setString:[_allData description]];

	[_allDataWindow makeKeyAndOrderFront:self];
}

#pragma mark - TMDBDelegate

- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)aMovie
{
	printf("%s\n", [[aMovie description] UTF8String]);

	[_throbber stopAnimation:self];
	[_goButton setEnabled:YES];
	[_viewAllDataButton setEnabled:YES];

	_allData = [aMovie.rawResults copy];

	[_movieTitle setStringValue:aMovie.title ? : @""];
	[_movieOverview setString:aMovie.overview ? : @""];
	[_movieRuntime setStringValue:[NSString stringWithFormat:@"%lu", aMovie.runtime] ? : @""];

	[_movieKeywords setStringValue:[aMovie.keywords componentsJoinedByString:@", "] ? : @""];

	NSDateFormatter *releaseDateFormatter = [[NSDateFormatter alloc] init];
	[releaseDateFormatter setDateFormat:@"dd-MM-yyyy"];
	[_movieReleaseDate setStringValue:[releaseDateFormatter stringFromDate:aMovie.released] ? : @""];

	NSUInteger posterSizeCount = 0;
	for (TMDBImage *poster in aMovie.posters)
		posterSizeCount += [poster sizeCount];
	[_moviePostersCount setStringValue:[NSString stringWithFormat:@"%lu (%lu sizes total)", [aMovie.posters count], posterSizeCount]];
	NSUInteger backdropSizeCount = 0;
	for (TMDBImage *backdrop in aMovie.backdrops)
		backdropSizeCount += [backdrop sizeCount];
	[_movieBackdropsCount setStringValue:[NSString stringWithFormat:@"%lu (%lu sizes total)", [aMovie.backdrops count], backdropSizeCount]];
}
		
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error
{
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];

	[_movieTitle setStringValue:@""];
	[_movieOverview setString:@""];
	[_movieRuntime setStringValue:@"0"];
	[_movieReleaseDate setStringValue:@"00-00-0000"];
	[_moviePostersCount setStringValue:@"0 (0 sizes total)"];
	[_movieBackdropsCount setStringValue:@"0 (0 sizes total)"];

	[_throbber stopAnimation:self];
	[_goButton setEnabled:YES];

	[_viewAllDataButton setEnabled:NO];
}

#pragma mark -

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
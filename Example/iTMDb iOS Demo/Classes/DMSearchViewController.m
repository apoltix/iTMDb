//
//  DMSearchViewController.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSearchViewController.h"
#import "DetailViewController.h"
#import "DMAppDelegate.h"
#import "DMSettingsManager.h"
#import <TMDb.h>
#import "TMDBMovie+DMBlocks.h"

@interface DMSearchViewController () <UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *objects;

@property (nonatomic, strong) TMDBMovie *movie;

@end

@implementation DMSearchViewController {
@private
	NSTimer *_searchTimer;
}

+ (void)initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
		@"hasSeenInitialSettings": @NO
	}];
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.objects = @[];
}

#pragma mark -

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenInitialSettings"]) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[self performSegueWithIdentifier:@"showSettings" sender:self];
		});
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenInitialSettings"];
	}
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showDetail"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSDate *object = self.objects[indexPath.row];
		[segue.destinationViewController setDetailItem:object];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	id object = self.objects[indexPath.row];
	cell.textLabel.text = [object description];
	return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([_searchTimer isValid]) {
		[_searchTimer invalidate];
	}

	_searchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(search:) userInfo:nil repeats:NO];
}

#pragma mark -

- (IBAction)search:(id)sender {
	[_searchTimer invalidate];
	_searchTimer = nil;

	DMSettingsManager *settings = [DMSettingsManager sharedManager];

	NSString *apiKey = [settings settingsItemNamed:@"apiKey"].value,
			 *searchMovieName = self.searchBar.text;//[settings settingsItemNamed:@"movieTitle"].value;

	NSNumber *searchMovieID = [settings settingsItemNamed:@"movieID"].value;

	if (!(apiKey.length > 0 && (searchMovieID.integerValue > 0 || searchMovieName.length > 0))) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing either API key, movie ID or title"
															message:@"Please enter both API key, and a movie ID or title.\n\nYou can obtain an API key from themoviedb.org."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		return;
	}

//	[self.throbber startAnimation:self];
//	self.goButton.enabled = NO;
//	self.viewAllDataButton.enabled = NO;

	TMDB *tmdb = ((DMAppDelegate *)[UIApplication sharedApplication].delegate).tmdb;

	// Initialize or update the framework setup
	if (![tmdb.apiKey isEqualToString:apiKey]) {
		tmdb.apiKey = apiKey;
	}

	// Clear previous data, if any
//	if (_allData) {
//		_allData = nil;
//	}

	// Set the language, if specified
	NSString *lang = [settings settingsItemNamed:@"lang"].value;

	if (lang.length > 0) {
		tmdb.language = lang;
	}
	else {
		tmdb.language = @"en";
	}

	// Define the amount of detail we want to fetch
	TMDBMovieFetchOptions fetchOptions = TMDBMovieFetchOptionBasic;

	if ([(NSNumber *)[settings settingsItemNamed:@"fetchCastCrew"].value boolValue]) {
		fetchOptions |= TMDBMovieFetchOptionCasts;
	}

	if ([(NSNumber *)[settings settingsItemNamed:@"fetchKeywords"].value boolValue]) {
		fetchOptions |= TMDBMovieFetchOptionKeywords;
	}

	if ([(NSNumber *)[settings settingsItemNamed:@"fetchImageURLs"].value boolValue]) {
		fetchOptions |= TMDBMovieFetchOptionImages;
	}

	// Actually fetch the movie based on the information we have
	NSUInteger year = [(NSNumber *)[settings settingsItemNamed:@"movieYear"].value unsignedIntegerValue];

	if (searchMovieID.integerValue > 0) {
		self.movie = [[TMDBMovie alloc] initWithID:searchMovieID.integerValue options:fetchOptions context:tmdb];
	}
	else if (year > 0) {
		self.movie = [[TMDBMovie alloc] initWithName:searchMovieName year:year options:fetchOptions context:tmdb];
	}
	else {
		self.movie = [[TMDBMovie alloc] initWithName:searchMovieName options:fetchOptions context:tmdb];
	}

	self.movie.didFinishLoadingBlock = ^(NSError *error) {
		NSLog(@"%@", error);
	};
}

@end

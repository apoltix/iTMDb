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

@interface DMSearchViewController () <UISearchBarDelegate>

@property (nonatomic, weak) UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *objects;

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

	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.hidesWhenStopped = YES;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
	self.spinner = spinner;

	self.objects = [NSMutableArray array];
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

	TMDBMovie *movie = self.objects[indexPath.row];
	cell.textLabel.text = [movie description];
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

	if (apiKey.length == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing API key"
															message:@"Please enter your API key in Settings. You can obtain an API key from themoviedb.org."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		return;
	}
	else if (searchMovieID.integerValue == 0 && searchMovieName.length == 0) {
		return;
	}

	[self.spinner startAnimating];

	TMDB *tmdb = [TMDB sharedInstance];

	// Initialize or update the framework setup
	if (![tmdb.apiKey isEqualToString:apiKey]) {
		tmdb.apiKey = apiKey;
		[tmdb.configuration reload:^(NSError *error) {
			[self search:searchMovieID name:searchMovieName];
		}];
	}
	else {
		[self search:searchMovieID name:searchMovieName];
	}
}

- (void)search:(NSNumber *)movieID name:(NSString *)movieName {
	DMSettingsManager *settings = [DMSettingsManager sharedManager];
	TMDB *tmdb = [TMDB sharedInstance];

	// Set the language, if specified
	NSString *lang = [settings settingsItemNamed:@"language"].value;

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

	TMDBMovie *movie = nil;

	if (movieID.integerValue > 0) {
		movie = [[TMDBMovie alloc] initWithID:movieID.integerValue options:fetchOptions];
	}
	else if (year > 0) {
		movie = [[TMDBMovie alloc] initWithName:movieName year:year options:fetchOptions];
	}
	else {
		movie = [[TMDBMovie alloc] initWithName:movieName options:fetchOptions];
	}

	__weak TMDBMovie *weakMovie = movie;
	[movie load:^(NSError *error) {
		[self.spinner stopAnimating];

		if (error != nil) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error fetching movie"
																message:error.localizedDescription
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView show];
			return;
		}

		[self.tableView beginUpdates];
		[self.objects insertObject:weakMovie atIndex:0];
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.tableView endUpdates];
	}];

	self.movie = movie;
}

@end

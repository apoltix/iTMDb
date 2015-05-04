//
//  DetailViewController.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DetailViewController.h"
#import "TMDBMovie.h"
#import "DMSettingsManager.h"

@implementation DetailViewController

- (void)setMovie:(TMDBMovie *)movie {
	if (movie == self.movie) {
		return;
	}

	_movie = movie;

	[self configureView];
}

- (void)configureView {
	if (self.movie == nil) {
		self.detailDescriptionLabel.text = @"";
		return;
	}

	self.detailDescriptionLabel.text = @"Loading";

	DMSettingsManager *settings = [DMSettingsManager sharedManager];

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

	[self.movie load:fetchOptions completion:^(NSError *error) {
		TMDBMovie *movie = self.movie;
		NSMutableString *text = [NSMutableString string];
		[text appendFormat:@"%@ (%@)\n\n", movie.title, @(movie.year)];
		[text appendFormat:@"OVERVIEW:\n%@\n\n", movie.overview];
		[text appendFormat:@"CAST:\n%@\n\n", movie.cast];
		[text appendFormat:@"KEYWORDS:\n%@\n\n", movie.keywords];
		[text appendFormat:@"CATEGORIES:\n%@\n\n", movie.categories];
		self.detailDescriptionLabel.text = text;
	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self configureView];
}

@end

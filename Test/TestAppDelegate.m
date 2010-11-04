//
//  TestAppDelegate.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TestAppDelegate.h"

@implementation TestAppDelegate

@synthesize window;
@dynamic isGoButtonEnabled;

- (void)awakeFromNib
{
	tmdb = nil;
}

#pragma mark -
- (IBAction)go:(id)sender
{
	if (!([[apiKey stringValue] length] > 0 && [movieID integerValue] > 0))
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Missing either API key or movie ID"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Please enter both API key and movie ID.\n\n"
													   @"You can obtain an API key from themoviedb.org."];
		[alert beginSheetModalForWindow:window
						  modalDelegate:nil
						 didEndSelector:nil
							contextInfo:nil];

		return;
	}

	[throbber startAnimation:self];
	[goButton setEnabled:NO];

	tmdb = [[[TMDB alloc] initWithAPIKey:[apiKey stringValue] delegate:self] retain];

	[tmdb movieWithID:[movieID integerValue]];
}

#pragma mark -
#pragma mark TMDBDelegate

- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)movie
{
	printf("Did finish loading movie\n");

	[movieTitle setStringValue:movie.title];
	[movieOverview setString:movie.overview];
	[movieRuntime setStringValue:[NSString stringWithFormat:@"%lu", movie.runtime]];

	[tmdb release];

	[throbber stopAnimation:self];
	[goButton setEnabled:YES];
}
		
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error
{
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:window
					  modalDelegate:nil
					 didEndSelector:nil
						contextInfo:nil];
	

	[throbber stopAnimation:self];
	[goButton setEnabled:YES];
}

@end
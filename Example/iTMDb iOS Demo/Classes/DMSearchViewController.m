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
#import <TMDb.h>

@interface DMSearchViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *objects;

@end

@implementation DMSearchViewController

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
		@"hasSeenInitialSettings": @NO
	}];
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.objects = @[];
}

#pragma mark -

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenInitialSettings"])
	{
		[self performSegueWithIdentifier:@"showSettings" sender:self];
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

	NSDate *object = self.objects[indexPath.row];
	cell.textLabel.text = [object description];
	return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	printf("%s\n", [searchText UTF8String]);
}

@end

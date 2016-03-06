# iTMDb

iTMDb is an Objective-C Cocoa wrapper (framework) for the [TMDb.org](http://tmdb.org/) v3.0 API. © Christian Rasmussen, 2010–2016.

This software is dual-licensed (pick either one you want): **MIT License** or **New BSD License**. See the `LICENSE` file. If you would like to use a different license, please contact me at code at devify dot dk.

iTMDb supports **OS X 10.9 and iOS 7.0** and up, but should be compatible with Mac OS X 10.8 Mountain Lion and iOS 6 and up without modification. It is tested working on OS X 10.10 Yosemite and iOS 8 (though it has not been tested as a framework under iOS 8, only as a static library). The project ships with framework targets for OS X and iOS 8+, and a static library for iOS 7.

You need Xcode 7.2 or higher to build the project.

Please remember to read the TMDb API [Terms of Use](https://www.themoviedb.org/about/api-terms). You need an API key to use the framework.

You can safely submit your apps using iTMDb to the App Store (it's been approved for use with [Collection](http://collectionapp.com/)). It fully supports OS X's sandboxing requirements (requires outgoing/client internet connection).

## Documentation

Most of the classes are documented using [appledoc](https://github.com/tomaz/appledoc). A generated copy of the documentation can be found [here](http://docs.apoltix.com/itmdb/). The documentation is also available directly in Xcode through Quick Look/Quick Help.

Certain classes have no specific documentation, but they are internal classes used by other classes, and are not intended to be interacted with directly.

## How to integrate

There are a few ways to add the framework to your project. The easiest is to add the Xcode project as a subproject in your own project. Another way is to copy the compiled framework or static library to your project. Both are added in the same way. A third way is to copy all the source files to your own project. The following instructions describes the two first ways to add the framework.

Either drag the iTMDb project, or framework, or static library, to your project, or add it through `File > Add Files to (project name)…`. If you add the framework or static library, Xcode will offer to add it to your target. You can choose to say yes or no to this (if you say no, you'll do it manually in the next step).

If your app is a **Mac app** (or an iOS 8 app):

1. Under `Project > Target > Build Phases > Link Binary With Libraries`, add `iTMDb.framework` (if it is not already there).

2. Add a new Copy Files phase. Rename it "Copy Frameworks" (or whatever you want). Add `iTMDb.framework` from under `iTMDb.xcodeproj > Products`.

If your app is an **iOS app**:

1. Under `Project > Target > Build Phases > Link Binary With Libraries`, add `libiTMDb.a` (if it is not already there).

### Signing the framework

On OS X (and iOS 8+ if you use the framework instead of the static library) you must sign the bundled framework with your own certificate. Xcode is able to do this for you, and does so by default. For more information, see Apple's tech note [TN2206](https://developer.apple.com/library/mac/technotes/tn2206/_index.html#//apple_ref/doc/uid/DTS40007919-CH1-TNTAG13).

## How to use

You can check out the included sample projects for Mac and iOS within the Xcode workspace to see how the framework is used.

All iTMDb classes are prefixed with `TMDB`, and the main class, just called `TMDB`, is known as the "context" in many API calls.

1. Add the following line to the header (or source) files where you will be using iTMDb:

```objective-c
 #import <iTMDb/iTMDb.h>
```

2. Set the API key in the `TMDB` singleton's `apiKey` property. You need your own API key, provided by [TMDb](http://api.themoviedb.org/).

```objective-c
[TMDB sharedInstance].apiKey = @"api_key";
```

3. Look up a movie by name and year.

Searching for movies can be done in a number of ways. If you have the movie's TMDb ID, you can create an instance of `TMDBMovie` like this:

```objective-c
TMDBMovie *movie = [[TMDBMovie alloc] initWithID:157336];
```

The movie's properties (title, year, cast, etc.) is not populated until the information has been fetched. This is done by the `load:` method.

```objective-c
[movie load:TMDBMovieFetchOptionAll completion:^(NSError *error) {
	// Do something with the movie
}];
```

If you only know the movie's title (and optionally year), use the `TMDBMovieSearch` class:

```objective-c
[TMDBMovieSearch moviesWithTitle:@"Deadpool" year:2016 completion:^(NSArray *movies, NSError *error) {
	// Look in movies array and find the TMDBMovie that is the correct one
	TMDBMovie *movie = movies.firstObject;
	[movie load:TMDBMovieFetchOptionAll completion:^(NSError *error) {
		// Do something with the movie
	}];
}];
```

If you don't know the movie's year, just call the same method without the `year` parameter.

4. An API request is made. Once information has been downloaded, the block provided in the `-load:completion:` method is called.  At this point, the movie's properties are populated, depending on the fetch options given in the `-load:completion:` call.

## Dependencies

There are no third-party dependencies; only system-available Apple frameworks are used in iTMDb (specifically Foundation and Core Graphics).

## What's missing

iTMDb does not cover the entire TMDb API, and only movie search and lookup works – including Cast & Crew and Posters. Things like authentication is not implemented.

There is no unit testing, which is probably something that should be added.

There is no CocoaPods integration yet.

If you are up for it, feel free to develop on the framework and submit a pull request.

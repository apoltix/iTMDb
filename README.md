# iTMDb

iTMDb is an Objective-C Cocoa wrapper (framework) for [TMDb.org](http://tmdb.org/). © Christian Rasmussen, 2010–2011.

This software is dual-licensed (pick either one you want): **MIT License** or **New BSD License**. See the `LICENSE` file.

iTMDb is developed for **Mac OS X** 10.6 Snow Leopard and 10.7 Lion, but it should work fine with **iOS** 4 and 5 (though not tested — and the Cocoa framework will have to be replaced with Cocoa Touch). You need Xcode 4.2 to build the project.

Please remember to read the TMDb API [Terms of Use](http://api.themoviedb.org/2.1/terms-of-use).

You can safely submit your apps using iTMDb to the App Store (it's been approved for use with [Collection](http://collectionapp.com/)).

## Documentation

Most of the classes are documented using [appledoc](https://github.com/tomaz/appledoc). A generated copy of the documentation can be found [here](http://docs.apoltix.com/itmdb/).

Certain classes have no specific documentation, but they are internal classes used by other classes, and are not intended to be interacted with directly.

The framework was built to be as easy and intuitive to use, so looking at the header files should give you an idea of how it is structured. Please see the test application (available in the Xcode project) for code samples.

## How to use

You can check out the included test project (`iTMDbTest`) within the Xcode workspace for an example of how to use the framework. All iTMDb classes are prefixed with `TMDB`, and the main class, from which most common operations can be made, just called `TMDB`, is known as the "context".

1. Add the framework to your project like any other framework (use Google if you don't know how to do this).

2. Add the following line to the header (or source) files where you will be using iTMDb:

	``` objective-c
	 #import <iTMDb/iTMDb.h>
	```

3. You create an instance of iTMDb like this. Replace ``api_key`` with your own API key, provided by [TMDb](http://api.themoviedb.org/). iTMDb performs fetch requests asynchronously, so setting a delegate is required. The delegate will receive notifications when the loading is done. The object should follow the TMDBDelegate protocol.

	``` objective-c
	TMDB *tmdb = [[TMDB alloc] initWithAPIKey:@"api_key" delegate:self];
	```

4. Look up a movie (while knowing it's id).

	``` objective-c
	[tmdb movieWithID:22538];
	```

5. An API request is made. Once information has been downloaded, the context object (`tmdb`) will receive a notification. The fetched properties are available through the returned object, which is sent to the context delegate (`tmdb.delegate`) with the following method:

	``` objective-c
	-[tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)movie]
	```

	Set the movie's title to a text field:

	``` objective-c
	-[movieTitleTextField setStringValue:movie.title];
	```

## ARC Support

iTMDb was originally developed using classic retain/release, but it has since switched to using ARC. There is no support for garbage collection.

## Other stuff

### What's missing

iTMDb does not yet cover the entire TMDb API, but movie search and lookup works. Things like authentication is not implemented.

### Third-party code

iTMDb includes the following third-party code:

 * [SBJson](https://github.com/stig/json-framework) (New BSD License) - If on OS X Lion or iOS 5 then [NSJSONSerialization](http://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html) is used instead.

I appreciate their contribution to the open source community. It is your responsibility to attribute the above mentioned authors accordingly in your project.
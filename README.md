iTMDb
=====

Objective-C Cocoa wrapper for TMDb.org. © Christian Rasmussen, 2010.

This software is dual-licensed (pick either one you want): **MIT License** or **New BSD License**. Thus, attribution is not required, but it is appreciated.

iTMDb is developed for **Mac OS X 10.6 Snow Leopard**, but should work fine with **iOS**.

Please remember to read the TMDb API Terms of Use.

How to use
==========

You can check out the included test target (iTMDbTest) within the Xcode project for code samples.

1. Add the framework to your project like any other framework (use Google if you don't know how to do this).

2. Add the following line to the header (or source) files where you will be using iTMDb:

        #import <iTMDb/iTMDb.h>

3. You create an instance of iTMDb like this. Replace "<code>api_key</code>" with your own API key, provided by TMDb, and set an object to be the delegate — this object will receive notifications when the loading is done. The object should follow the TMDBDelegate protocol.

        TMDB *tmdb = [[TMDB alloc] initWithAPIKey:@"api_key" delegate:self];

4. Look up a movie (while knowing it's id).

        [tmdb movieWithID:22538];

5. An API request is made. Once information has been downloaded, the context object (<code>tmdb</code>) will receive a notification. The fetched properties are available through the returned object, which is sent to the context delegate (tmdb.delegate) with the following method:

        - [delegate tmdb:context didFinishLoadingMovie:movie]

   Set the movie's title to a text field:

        [movieTitleTextField setStringValue:movie.title];

Documentation
=============

Documentation is in the works. Please see the test application (available in the Xcode project) for code samples.

Support for Garbage Collection
==============================

iTMDb was developed with support for both garbage supported and unsupported applications. Out of the box, iTMDb compiles to an unsupported binary, but the target can easily be set to supported.

Third-party code
================

iTMDb includes the following third-party code:

 * [JSON][] (New BSD License)

I appreciate their contribution to the open source community.

[JSON]: http://code.google.com/p/json-framework/
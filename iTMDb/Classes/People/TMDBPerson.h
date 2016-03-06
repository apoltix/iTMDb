//
//  TMDBPerson.h
//  iTMDb
//
//  Created by Christian Rasmussen on 29/12/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

@import Foundation;

@class TMDBMovie;

typedef NS_OPTIONS(NSUInteger, TMDBPersonUpdateOptions) {
	/** Indicates that basic information should be fetched. */
	TMDBPersonUpdateOptionBasic = 1 << 1,
	/** Indicates that credits, i.e. cast and crew, should be fetched.  */
	TMDBPersonUpdateOptionCredits = 1 << 2,
	/** Indicates that image URLs should be fetched. */
	TMDBPersonUpdateOptionImages = 1 << 3
};

/**
 * A block called when a person object has been updated, or failed to be
 * updated.
 */
typedef void (^TMDBPersonUpdateCompletionBlock)(NSError * _Nullable error);

/**
 * A `TMDBPerson` object contains information about a person associated with a
 * `TMDBMovie` object.
 *
 * By default Person objects contain only basic information. To fetch more
 * information use the `-update:` and `-update:completion:` metods.
 */
@interface TMDBPerson : NSObject

/** @name Batch Processing */

/**
 * Returns an array of `TMDBPerson` objects with the information provided in the
 * `personsInfo` array.
 *
 * @param movie The movie with which the persons should be associated.
 * @param personInfo An array of `NSDictionary` objects with information about
 * the persons for which objects are to be created.
 * @return An array of `TMDBPerson` objects. If an object in `personsInfo` is
 * not valid, a `TMDBPerson` object will not be created for that object.
 */
+ (nonnull NSArray<TMDBPerson *> *)personsWithMovie:(nonnull TMDBMovie *)movie personsInfo:(nonnull NSArray<NSDictionary *> *)d;

/** @name Creating an Instance */

/**
 * Returns a person object populated only with the provided ID. Fetch person
 * information by calling `-update:`.
 *
 * @param personID The ID of the person.
 */
- (nonnull instancetype)initWithID:(NSUInteger)personID NS_DESIGNATED_INITIALIZER;

/**
 * Returns a person object populated with the provided person information.
 *
 * @param movie The movie object with which the person should be associated.
 * @param personInfo A dictionary containing information about the person.
 * @return An immutable person object populated with the provided person
 * information.
 */
- (nonnull instancetype)initWithMovie:(nonnull TMDBMovie *)movie personInfo:(nonnull NSDictionary *)d;

/** @name Basic Information */

/** The TMDb ID of the person. */
@property (nonatomic, readonly) NSUInteger id;

/** The name of the person. */
@property (nonatomic, copy, nullable, readonly) NSString *name;

/** The name of the character the person played in the movie. */
@property (nonatomic, copy, nullable,readonly) NSString *character;

/** The movie in which the person played a character or was part of a crew. */
@property (nonatomic, strong, nullable,readonly) TMDBMovie *movie;

/** The job position of the person in this movie. */
@property (nonatomic, copy, nullable,readonly) NSString *job;

/** The person's job department. */
@property (nonatomic, copy, nullable,readonly) NSString *department;

/**
 * The order in which the person should be listed in the Cast and Crew list for
 * the movie.
 */
@property (nonatomic, readonly) NSUInteger order;

/** The */
@property (nonatomic, readonly) NSInteger castID;

/** @name External Resources */

/** A URL to an official website of this person. */
@property (nonatomic, copy, nullable,readonly) NSURL *url;

/** A URL fragment pointing to the TMDb profile image of this person. */
@property (nonatomic, copy, nullable,readonly) NSURL *imageURL;

/** @name Updating */

/**
 * Updates the Person with the basic information.
 *
 * @param completionBlock A block called when the update succeeds or fails.
 */
- (void)update:(nullable TMDBPersonUpdateCompletionBlock)completionBlock;

/**
 * Updates the Person with the specified information.
 *
 * @param options The information to be fetched.
 * @param completionBlock A block called when the update succeeds or fails.
 */
- (void)update:(TMDBPersonUpdateOptions)options completion:(nullable TMDBPersonUpdateCompletionBlock)completionBlock;

@end

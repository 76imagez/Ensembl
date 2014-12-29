//
//  UserProfile.h
//  gigPals
//
//  Created by Adam on 8/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseUserProfile.h"

@protocol UserProfileDelegate;

@interface UserProfile : NSObject

@property (nonatomic, weak) id<UserProfileDelegate> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *profileID;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *facebook;
@property (nonatomic, strong) NSString *twitter;
@property (nonatomic, strong) NSString *instagram;
@property (nonatomic, strong) NSString *aboutMe;
@property (nonatomic, strong) NSArray *bandArray;
@property (nonatomic, strong) NSMutableArray *registeredGigs;
@property (nonatomic, strong) NSMutableArray *potentialGigPals;
@property (nonatomic, strong) NSMutableArray *actualGigPals;
@property (nonatomic, strong) UIImage *profilePic;

-(void)saveUserToParseAppDelegateAndCoreData:(NSManagedObjectContext *)managedObjectContext;
-(void)loadProfileFromParse:(ParseUserProfile *)parseProfile;
-(void)loadProfileFromCoreData: (NSManagedObjectContext *)managedObjectContext;
-(void)saveToAppDelegate;

-(void)getProfilePicture;
-(void)requestMusicInfo:(NSString *)urlString withArray:(NSArray *)array;
-(void)requestUserProfileInfo;



@end

@protocol UserProfileDelegate <NSObject>

-(void)onFinishedLoadingMusic;
-(void)onFinishedLoadingUserProfile;
-(void)onFinishedGettingProfilePicture;
-(void)onFinishedLoadingUserProfileFromCoreData;

@end

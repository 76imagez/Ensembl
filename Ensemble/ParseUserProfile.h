//
//  ParseUserProfile.h
//  gigPals
//
//  Created by Adam on 8/18/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Parse/Parse.h>

@interface ParseUserProfile : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (retain) NSString *name;
@property (retain) NSString *profileID;
@property (retain) NSString *age;
@property (retain) NSString *facebook;
@property (retain) NSString *twitter;
@property (retain) NSString *instagram;
@property (retain) NSString *aboutMe;
@property (retain) NSArray *bandArray;
@property (retain) NSArray *registeredGigs;
@property (retain) NSArray *potentialGigPals;
@property (retain) NSArray *actualGigPals;
@property (retain) PFFile *profileImage;


@end

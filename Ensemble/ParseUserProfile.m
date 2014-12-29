//
//  ParseUserProfile.m
//  gigPals
//
//  Created by Adam on 8/18/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ParseUserProfile.h"
#import <Parse/PFObject+Subclass.h>

@implementation ParseUserProfile

@dynamic name;
@dynamic profileID;
@dynamic age;
@dynamic facebook;
@dynamic twitter;
@dynamic instagram;
@dynamic aboutMe;
@dynamic bandArray;
@dynamic registeredGigs;
@dynamic potentialGigPals;
@dynamic actualGigPals;
@dynamic profileImage;


+(void)load
{
	[self registerSubclass];
}

+(NSString *)parseClassName {
	return @"UserProfile";
}

@end

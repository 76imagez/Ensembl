//
//  ParseConcert.m
//  Ensemble
//
//  Created by Adam on 9/20/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ParseConcert.h"
#import <Parse/PFObject+Subclass.h>


@implementation ParseConcert

@dynamic concertName;
@dynamic concertDate;
@dynamic concertID;
@dynamic concertURI;
@dynamic registrees;

+(void)load
{
	[self registerSubclass];
}

+(NSString *)parseClassName
{
	return @"ParseConcert";
}

@end

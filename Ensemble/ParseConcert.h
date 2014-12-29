//
//  ParseConcert.h
//  Ensemble
//
//  Created by Adam on 9/20/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Parse/Parse.h>

@interface ParseConcert : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (retain) NSString *concertName;
@property (retain) NSDate *concertDate;
@property (retain) NSString *concertID;
@property (retain) NSString *concertURI;
@property (retain) NSNumber *registrees;

@end

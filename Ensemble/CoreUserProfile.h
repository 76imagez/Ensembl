//
//  CoreUserProfile.h
//  Ensemble
//
//  Created by Adam on 9/15/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreUserProfile : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileID;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * instagram;
@property (nonatomic, retain) NSString * aboutMe;
@property (nonatomic, retain) NSData * bandArray;
@property (nonatomic, retain) NSData * registeredGigs;
@property (nonatomic, retain) NSData * potentialGigPals;
@property (nonatomic, retain) NSData * actualGigPals;
@property (nonatomic, retain) NSData * profilePic;
@property (nonatomic, retain) NSString * age;

@end

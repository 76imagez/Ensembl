//
//  Concert.m
//  Ensemble
//
//  Created by Adam on 9/20/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "Concert.h"


@implementation Concert

-(void)saveConcertToParseAndCoreData:(NSManagedObjectContext *)managedObjectContext
{
	CoreConcert *concert;
	NSError *error;
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"CoreConcert"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == concertID", self.concertID];
	request.predicate = predicate;
	NSArray *concertArray = [managedObjectContext executeFetchRequest: request
																error: &error];
	if (!error)
	{
		if (concertArray.count > 0)
		{
			concert = [concertArray firstObject];
		}
		else
		{
			//this shoudl only happen once
			concert = [NSEntityDescription insertNewObjectForEntityForName: @"CoreConcert"
													inManagedObjectContext: managedObjectContext];
		}
		concert.concertName = self.concertName;
		concert.concertID = self.concertID;
		concert.concertDate = self.concertDate;
		concert.concertURI = self.concertURI;
		concert.registrees = self.registrees;
		[managedObjectContext save: &error];
		if (error)
		{
			NSLog(@"%@", [error localizedDescription]);
		}
	}
	else
	{
		NSLog(@"%@", [error localizedDescription]);
	}
	
	PFQuery *query = [ParseConcert query];
	[query whereKey: @"concertID"
			equalTo: self.concertID];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			if (objects.count > 0)
			{
				ParseConcert *concerto = [objects firstObject];
				concerto.concertName = self.concertName;
				concerto.concertID = self.concertID;
				concerto.concertDate = self.concertDate;
				concerto.concertURI = self.concertURI;
				concerto.registrees = self.registrees;
				[concerto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					if (error)
					{
						if ([error code] == kPFErrorObjectNotFound)
						{
							NSLog(@"No objects");
						}
						if ([error code] == kPFErrorConnectionFailed)
						{
							[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
														message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
													   delegate: self
											  cancelButtonTitle: @"Ok"
											  otherButtonTitles:nil, nil] show];
						}
						[concerto saveEventually];
					}
				}];
			}
			else
			{
				ParseConcert *concerto = [ParseConcert object];
				concerto.concertName = self.concertName;
				concerto.concertID = self.concertID;
				concerto.concertDate = self.concertDate;
				concerto.concertURI = self.concertURI;
				concerto.registrees = self.registrees;
				[concerto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					if (error)
					{
						if ([error code] == kPFErrorObjectNotFound)
						{
							NSLog(@"No objects");
						}
						if ([error code] == kPFErrorConnectionFailed)
						{
							[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
														message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
													   delegate: self
											  cancelButtonTitle: @"Ok"
											  otherButtonTitles:nil, nil] show];
						}
						[concerto saveEventually];
					}
				}];
			}
		}
		else
		{
			if ([error code] == kPFErrorObjectNotFound)
			{
				NSLog(@"No objects");
			}
			if ([error code] == kPFErrorConnectionFailed)
			{
				[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
											message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
										   delegate: self
								  cancelButtonTitle: @"Ok"
								  otherButtonTitles:nil, nil] show];
			}
		}
	}];
}

-(instancetype)loadConcertFromParse:(ParseConcert *)concert
{
	self.concertName = concert.concertName;
	self.concertDate = concert.concertDate;
	self.concertURI = concert.concertURI;
	self.concertID = concert.concertID;
	self.registrees = concert.registrees;
	
	return self;
}

-(instancetype)loadConcertFromCore:(CoreConcert *)concert
{
	self.concertName = concert.concertName;
	self.concertDate = concert.concertDate;
	self.concertURI = concert.concertURI;
	self.concertID = concert.concertID;
	self.registrees = concert.registrees;
	
	return self;
}

@end

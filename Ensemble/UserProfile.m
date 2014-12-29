//
//  UserProfile.m
//  gigPals
//
//  Created by Adam on 8/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "UserProfile.h"
#import "ParseUserProfile.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CoreUserProfile.h"

@implementation UserProfile

-(NSArray *)bandArray
{
	if (!_bandArray)
	{
		_bandArray = [[NSArray alloc] init];
	}
	return _bandArray;
}

-(NSMutableArray *)registeredGigs
{
	if (!_registeredGigs)
	{
		_registeredGigs = [[NSMutableArray alloc] init];
	}
	return _registeredGigs;
}

-(NSMutableArray *)potentialGigPals
{
	if (!_potentialGigPals)
	{
		_potentialGigPals = [[NSMutableArray alloc] init];
	}
	return _potentialGigPals;
}
-(NSMutableArray *)actualGigPals
{
	if (!_actualGigPals)
	{
		_actualGigPals = [[NSMutableArray alloc] init];
	}
	return _actualGigPals;
}


-(void)loadProfileFromParse: (ParseUserProfile *)parseProfile
{
	self.name = parseProfile.name;
	self.profileID = parseProfile.profileID;
	self.age = parseProfile.age;
	self.facebook = parseProfile.facebook;
	self.twitter = parseProfile.twitter;
	self.instagram = parseProfile.instagram;
	self.aboutMe = parseProfile.aboutMe;
	self.bandArray = [parseProfile.bandArray mutableCopy];
	self.registeredGigs = [parseProfile.registeredGigs mutableCopy];
	self.potentialGigPals = [parseProfile.potentialGigPals mutableCopy];
	self.actualGigPals = [parseProfile.actualGigPals mutableCopy];
	
	PFFile *profilePic = parseProfile.profileImage;
	[profilePic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			UIImage *prof = [UIImage imageWithData: data];
			self.profilePic = prof;
			[self saveToAppDelegate];
		}
		else
		{
			NSLog(@"%@", [error localizedDescription]);
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

-(void)loadProfileFromCoreData: (NSManagedObjectContext *)managedObjectContext
{
	CoreUserProfile *userProfile;
	NSError *error;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *profileID = [defaults objectForKey:@"profileID"];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreUserProfile"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%@ == profileID", profileID];
	fetchRequest.predicate = predicate;
	NSArray *profileArray = [managedObjectContext executeFetchRequest: fetchRequest
																error: &error];
	if (!error)
	{
		if ([profileArray firstObject])
		{
			userProfile = [profileArray firstObject];
			self.name = userProfile.name;
			self.profileID = userProfile.profileID;
			self.facebook = userProfile.facebook;
			self.twitter = userProfile.twitter;
			self.instagram = userProfile.instagram;
			self.aboutMe = userProfile.aboutMe;
			self.age = userProfile.age;
			self.bandArray = [NSKeyedUnarchiver unarchiveObjectWithData: userProfile.bandArray];
			self.potentialGigPals = [NSKeyedUnarchiver unarchiveObjectWithData: userProfile.potentialGigPals];
			self.registeredGigs = [NSKeyedUnarchiver unarchiveObjectWithData: userProfile.registeredGigs];
			self.actualGigPals = [NSKeyedUnarchiver unarchiveObjectWithData: userProfile.actualGigPals];
			self.profilePic = [UIImage imageWithData: userProfile.profilePic];
		}
	}
	else
	{
		NSLog(@"load %@", [error localizedDescription]);
	}
	
	[self saveToAppDelegate];
	[[self delegate] onFinishedLoadingUserProfileFromCoreData];
}

//save to app delegate too
-(void)saveUserToParseAppDelegateAndCoreData:(NSManagedObjectContext *)managedObjectContext
{
	[self saveToAppDelegate];
	
	CoreUserProfile *coreProfile;
	NSError *error;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreUserProfile"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == profileID", self.profileID];
	[fetchRequest setPredicate: predicate];
	NSArray *profileArray = [managedObjectContext executeFetchRequest: fetchRequest
																error: &error];
	if ([profileArray firstObject])
	{
		coreProfile = [profileArray firstObject];
	}
	else
	{
		coreProfile = [NSEntityDescription insertNewObjectForEntityForName:@"CoreUserProfile"
													inManagedObjectContext: managedObjectContext];
	}
	coreProfile.name = self.name;
	coreProfile.profileID = self.profileID;
	coreProfile.facebook = self.facebook;
	coreProfile.twitter = self.twitter;
	coreProfile.instagram = self.instagram;
	coreProfile.aboutMe = self.aboutMe;
	coreProfile.age = self.age;
	coreProfile.bandArray = [NSKeyedArchiver archivedDataWithRootObject: self.bandArray];
	coreProfile.registeredGigs = [NSKeyedArchiver archivedDataWithRootObject: self.registeredGigs];
	coreProfile.potentialGigPals = [NSKeyedArchiver archivedDataWithRootObject: self.potentialGigPals];
	coreProfile.actualGigPals = [NSKeyedArchiver archivedDataWithRootObject: self.actualGigPals];
	coreProfile.profilePic = UIImagePNGRepresentation(self.profilePic);
	
	[managedObjectContext save:&error];
	if (error)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving data"
														message:[error localizedDescription]
													   delegate:self
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil, nil];
		[alert show];
	}
	
	//save to parse if there is an internet connection
	PFQuery *profileQuery = [ParseUserProfile query];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *profileID = [defaults objectForKey:@"profileID"];
	if (profileID)
	{
		[profileQuery whereKey: @"profileID"
					   equalTo: profileID];
		
		[profileQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		 {
			 if (!error)
			 {
				 ParseUserProfile *parseProfile;
				 if ((objects.count > 0) && (objects != nil))
				 {
					 parseProfile = [objects firstObject];
				 }
				 else
				 {
					 parseProfile = [ParseUserProfile object];
				 }
				 parseProfile.name = self.name;
				 parseProfile.profileID = self.profileID;
				 parseProfile.age = self.age;
				 parseProfile.facebook = self.facebook;
				 parseProfile.twitter = self.twitter;
				 parseProfile.instagram = self.instagram;
				 parseProfile.aboutMe = self.aboutMe;
				 parseProfile.bandArray = self.bandArray;
				 parseProfile.profileImage = [PFFile fileWithName:@"profilePicture"
															 data:UIImagePNGRepresentation(self.profilePic)];
				 [parseProfile.profileImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					 if (!error)
					 {
						 if (self.registeredGigs.count > parseProfile.registeredGigs.count)
						 {
							 [parseProfile addUniqueObjectsFromArray: self.registeredGigs
															  forKey: @"registeredGigs"];
						 }
						 else
						 {
							 parseProfile.registeredGigs = self.registeredGigs;
						 }
						 
						 if (self.potentialGigPals.count > parseProfile.potentialGigPals.count)
						 {
							 [parseProfile addUniqueObjectsFromArray: self.potentialGigPals
															  forKey: @"potentialGigPals"];
						 }
						 else
						 {
							 parseProfile.potentialGigPals = self.potentialGigPals;
						 }
						 
						 if (self.actualGigPals.count > parseProfile.actualGigPals.count)
						 {
							 [parseProfile addUniqueObjectsFromArray: self.actualGigPals
															  forKey: @"actualGigPals"];
						 }
						 else
						 {
							 parseProfile.actualGigPals = self.actualGigPals;
						 }
						 
						 [parseProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
						  {
							  if (error)
							  {
								  NSLog(@"save err%@", [error localizedDescription]);
								  if ([error code] == kPFErrorConnectionFailed)
								  {
									  [[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
																  message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on. Profile will save when connection is re-established."
																 delegate: self
														cancelButtonTitle: @"Ok"
														otherButtonTitles:nil, nil] show];
								  }
								  [parseProfile saveEventually];
							  }
						  }];

					 }
					 else
					 {
						 NSLog(@"save err 2 %@", [error localizedDescription]);
						 if ([error code] == kPFErrorConnectionFailed)
						 {
							 [[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
														 message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on. Profile will save when connection is re-established."
														delegate: self
														cancelButtonTitle: @"Ok"
														otherButtonTitles:nil, nil] show];
						 }
						 [parseProfile saveEventually];
					 }
				 }];
			 }
			 else
			 {
				 NSLog(@"save err 2 %@", [error localizedDescription]);
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
	
}

-(void)saveToAppDelegate
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.userProfile = self;
}

-(void)requestUserProfileInfo
{
	[FBRequestConnection startWithGraphPath: @"me?fields=id,first_name,birthday"
						  completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	{
		if (!error)
		{
			self.name = [result first_name];			
			if ([result birthday])
			{
				NSString *dateString = [result birthday];
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"MM/dd/yyyy"];
				NSDate *birthdate = [formatter dateFromString: dateString];
				NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate: birthdate];
				int ageInYears = (int)(interval / (86400 * 365));
				self.age = [NSString stringWithFormat:@"%d", ageInYears];
			}
			
			[[self delegate] onFinishedLoadingUserProfile];
		}
		else
		{
			NSLog(@"prof req %@", [error localizedDescription]);
			[self handleAPICallError:error];
		}
	}];
}

-(void)getProfilePicture
{
	NSString *profPicURLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.profileID];
	NSURL *url = [NSURL URLWithString:profPicURLString];
	UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: url]];
	self.profilePic = image;
	[[self delegate] onFinishedGettingProfilePicture];
}

-(void)requestMusicInfo:(NSString *)urlString withArray:(NSArray *)array
{
	if ([urlString isEqualToString:@"start"])
	{
		[FBRequestConnection startWithGraphPath: @"me/music?fields=id,name"
							  completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
		{
			if (!error)
			{
				NSArray *newArray = (NSArray *)result[@"data"];
				NSDictionary *pagingDic = result[@"paging"];
				[self requestMusicInfo: pagingDic[@"next"]
							 withArray: newArray];
			}
			else
			{
				NSLog(@"req 1 %@", [error localizedDescription]);
				[self handleAPICallError:error];
			}
		}];
	}
	if (urlString == nil)
	{
		self.bandArray = array;
		[[self delegate] onFinishedLoadingMusic];
	}
	if (urlString != nil && ![urlString isEqualToString:@"start"])
	{
		NSURL *url = [NSURL URLWithString: urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		[NSURLConnection sendAsynchronousRequest:request
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
		{
			if (!connectionError)
			{
				NSError *error;
				NSDictionary *mainDic = (NSDictionary *)[NSJSONSerialization
														 JSONObjectWithData: data
														 options:NSJSONReadingAllowFragments
														 error: &error];
				if (!error)
				{
					NSArray *bands = mainDic[@"data"];
					NSArray *newNewArray = [[NSArray alloc] init];
					newNewArray = [array arrayByAddingObjectsFromArray: bands];
					NSDictionary *pagingDic = mainDic[@"paging"];
					[self requestMusicInfo: pagingDic[@"next"]
								 withArray: newNewArray];
				}
				else
				{
					NSLog(@"req 2 %@", [error localizedDescription]);
				}
				
			}
			else
			{
				NSLog(@"req error %@, %@", [connectionError localizedDescription], urlString);
				[[[UIAlertView alloc] initWithTitle:@"Error connecting to the server"
											message:@"Make sure there is a valid network connection"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}];
	}
}

// Helper method to handle errors during API calls
- (void)handleAPICallError:(NSError *)error
{
	// For all other errors...
	NSString *alertText;
	NSString *alertTitle;
	
	// If the user should be notified, we show them the corresponding message
	if ([FBErrorUtility shouldNotifyUserForError:error])
	{
		alertTitle = @"Something Went Wrong";
		alertText = [FBErrorUtility userMessageForError:error];
		
	}
	else
	{
		// show a generic error message
		NSLog(@"Unexpected error using open graph: %@", error);
		alertTitle = @"Something went wrong";
		alertText = @"Please try again later.";
	}
	[self showMessage: alertText withTitle:alertTitle];
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
	[[[UIAlertView alloc] initWithTitle:title
								message:text
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

@end

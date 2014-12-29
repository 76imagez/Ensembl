//
//  GigViewController.m
//  Ensemble
//
//  Created by Adam on 9/18/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "GigViewController.h"
#import "ProfileViewController.h"
#import "ParseUserProfile.h"
#import "UserProfile.h"
#import "CoreConcert.h"
#import "Concert.h"
#import "ParseConcert.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "OtherProfileViewController.h"
#import "GigWebViewController.h"
#import "AppDelegate.h"

#define registreeCell @"registreeCell"

@interface GigViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *concertName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *uriButton;
@property (weak, nonatomic) IBOutlet UIButton *unregisterButton;

@property (strong, nonatomic) NSArray *registreesArray;

@property (strong, nonatomic) UIAlertView *unregisterAlert;

@end

@implementation GigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *backgroundImage = [UIImage imageNamed:@"nhbdblur.png"];
	backgroundImage = [ProfileViewController imageWithImage: backgroundImage
											   scaledToSize: self.view.frame.size];
	backgroundImageView.image = backgroundImage;
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	self.concertName.text = self.passedConcert.concertName;
	
	self.uriButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.uriButton.layer.borderWidth = .5;
	self.uriButton.layer.cornerRadius = 5;
	
	self.unregisterButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.unregisterButton.layer.borderWidth = .5;
	self.unregisterButton.layer.cornerRadius = 5;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self queryForRegistrees];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onUnregisterClicked:(UIButton *)sender
{
	self.unregisterAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to unregister from this concert?" message:nil delegate:self cancelButtonTitle:@"No, Nevermind" otherButtonTitles: @"Yes, I'm Sure", nil];
	[self.unregisterAlert show];
}



-(void)queryForRegistrees
{
	PFQuery *query = [ParseUserProfile query];
	[query whereKey: @"registeredGigs"
			equalTo: self.passedConcert.concertID];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			if (objects.count == 0)
			{
				[[[UIAlertView alloc] initWithTitle: @"Nobody has registered for this event yet"
											message: nil
										   delegate: self
								  cancelButtonTitle: @"Ok"
								  otherButtonTitles:nil, nil] show];
			}
			else
			{
				self.registreesArray = (NSArray *)objects;
				[self.tableView reloadData];
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
		[self.tableView reloadData];
	}];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate.userProfile.registeredGigs removeObject: self.passedConcert.concertID];
		[appDelegate.userProfile saveUserToParseAppDelegateAndCoreData: appDelegate.managedObjectContext];
		
		PFQuery *query = [ParseConcert query];
		[query whereKey: @"concertID" equalTo: self.passedConcert.concertID];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error)
			{
				if (objects.count > 0)
				{
					ParseConcert *concert = [objects firstObject];
					int registrees = [concert.registrees intValue] - 1;
					concert.registrees = [NSNumber numberWithInt: registrees];
					[concert saveInBackground];
				}
			}
		}];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreConcert"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == concertID", self.passedConcert.concertID];
		request.predicate = predicate;
		NSError *error;
		NSArray *concerts = [appDelegate.managedObjectContext executeFetchRequest: request
																			error: &error];
		if (!error)
		{
			if (concerts.count > 0)
			{
				CoreConcert *concert = [concerts firstObject];
				[appDelegate.managedObjectContext deleteObject: concert];
				NSError *saveError;
				[appDelegate.managedObjectContext save: &saveError];
			}
		}
		else
		{
			NSLog(@"%@", [error localizedDescription]);
		}
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"otherProfile"])
	{
		OtherProfileViewController *otherProfile = [segue destinationViewController];
		otherProfile.passedParseProfile = [self.registreesArray objectAtIndex: self.tableView.indexPathForSelectedRow.row];
		otherProfile.concertObject = self.passedConcert;
	}
	if ([[segue identifier] isEqualToString: @"webView"])
	{
		GigWebViewController *webVC = [segue destinationViewController];
		webVC.passedConcert = self.passedConcert;
	}
}

#pragma mark - UITableView Delegate and Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.registreesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: registreeCell];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:registreeCell];
	}
	cell.backgroundColor = [UIColor clearColor];
	ParseUserProfile *registreeProfile = [self.registreesArray objectAtIndex: indexPath.row];
	cell.textLabel.text = registreeProfile.name;
	cell.imageView.layer.cornerRadius = 5;
	cell.imageView.clipsToBounds = YES;
	NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", registreeProfile.profileID];
	NSURL *url = [NSURL URLWithString: urlString];
	cell.imageView.clipsToBounds = YES;
	[cell.imageView setImageWithURL: url
				   placeholderImage: [ProfileViewController imageWithImage: [UIImage imageNamed: @"Placeholder.png"]
															  scaledToSize: CGSizeMake(70, 70)]];
	
	return cell;
}


@end

//
//  RegisteredGigsViewController.m
//  Ensemble
//
//  Created by Adam on 9/18/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "RegisteredGigsViewController.h"
#import "CoreConcert.h"
#import "ParseConcert.h"
#import "ParseUserProfile.h"
#import "AppDelegate.h"
#import "UserProfile.h"
#import "Reachable.h"
#import "Concert.h"
#import "GigViewController.h"
#import "ProfileViewController.h"

#define gigCellID @"gigCell"

@interface RegisteredGigsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *gigArray;

@end

@implementation RegisteredGigsViewController
{
	NSInteger selectedRow;
}

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
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.layer.cornerRadius = 5;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: YES];
	self.gigArray = [[NSArray alloc] init];
	[self.tableView reloadData];
	[self retrieveRegisteredConcerts];
}

-(void)retrieveRegisteredConcerts
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if ([Reachable internetNetworkIsUnreachable] && [Reachable wifiNetworkIsUnreachable])
	{
		NSLog(@"No internet or Wifi Connection Available");
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreConcert"];
		NSError *err;
		NSArray *concertos = [appDelegate.managedObjectContext executeFetchRequest: request
														error: &err];
		if (!err)
		{
			if (concertos.count == 0)
			{
				[[[UIAlertView alloc] initWithTitle: @"You're Not Registered For Any Concerts Yet"
											  message: @"Head to the Concerts section to register."
											 delegate: self
									cancelButtonTitle: @"Ok"
									otherButtonTitles:nil, nil] show];
			}
			else
			{
				self.gigArray = concertos;
				[self.tableView reloadData];
			}
		}
		
		
	}
	else
	{
		NSArray *registreredGigs = appDelegate.userProfile.registeredGigs;
		PFQuery *concertQuery = [ParseConcert query];
		[concertQuery whereKey:@"concertID" containedIn: registreredGigs];
		[concertQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (objects.count == 0)
			{
				[[[UIAlertView alloc] initWithTitle: @"You're Not Registered For Any Concerts Yet"
											message: @"Head to the Concerts section to register."
										   delegate: self
								  cancelButtonTitle: @"Ok"
								  otherButtonTitles:nil, nil] show];
			}
			else
			{
				//array of concert objects
				self.gigArray = objects;
				[self.tableView reloadData];
			}
			
		}];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	GigViewController *gigVC = [segue destinationViewController];
	Concert *concert = [[Concert alloc] init];
	id concertObject = self.gigArray[selectedRow];
	if ([concertObject isKindOfClass: [ParseConcert class]])
	{
		concert = [concert loadConcertFromParse: concertObject];
	}
	if ([concertObject isKindOfClass: [CoreConcert class]])
	{
		concert = [concert loadConcertFromCore: concertObject];
	}
	gigVC.passedConcert = concert;
}

#pragma mark - UITableView Delegate and Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.gigArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: gigCellID];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier: gigCellID];
	}
	
	Concert *concert = [[Concert alloc] init];
	id concertObject = self.gigArray[indexPath.row];
	if ([concertObject isKindOfClass: [ParseConcert class]])
	{
		concert = [concert loadConcertFromParse: concertObject];
	}
	if ([concertObject isKindOfClass: [CoreConcert class]])
	{
		concert = [concert loadConcertFromCore: concertObject];
	}
	cell.textLabel.text = concert.concertName;
	
	return cell;
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	selectedRow = indexPath.row;
	[self performSegueWithIdentifier:@"concert" sender: self];
}

@end

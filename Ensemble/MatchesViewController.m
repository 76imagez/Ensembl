//
//  MatchesViewController.m
//  Ensemble
//
//  Created by Adam on 9/15/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "MatchesViewController.h"
#import "AppDelegate.h"
#import "MatchProfileViewController.h"
#import "ProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define matchCell @"matchCell"

@interface MatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *matchesArray;
@property (strong, nonatomic) NSArray *arrayOfParseProfiles;

@end

@implementation MatchesViewController

-(NSArray *)arrayOfParseProfiles
{
	if (!_arrayOfParseProfiles)
	{
		_arrayOfParseProfiles = [[NSArray alloc] init];
	}
	return _arrayOfParseProfiles;
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
	self.arrayOfParseProfiles = [[NSArray alloc] init];
	[self.tableView reloadData];
	[self retrieveParseProfiles];
}

-(void)retrieveParseProfiles
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	PFQuery *myQuery = [ParseUserProfile query];
	[myQuery whereKey:@"profileID" equalTo: appDelegate.userProfile.profileID];
	[myQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			ParseUserProfile *profile = [objects firstObject];
			self.matchesArray = profile.actualGigPals;
			NSMutableArray *profileIDArrayM = [[NSMutableArray alloc] init];
			for (NSDictionary *dic in self.matchesArray)
			{
				NSString *profileID = dic[@"profileID"];
				[profileIDArrayM addObject: profileID];
			}
			NSArray *profileIDArray = profileIDArrayM;
			PFQuery *query = [ParseUserProfile query];
			[query whereKey: @"profileID" containedIn: profileIDArray];
			[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
				if (!error)
				{
					if (objects.count > 0)
					{
						self.arrayOfParseProfiles = objects;
						[self.tableView reloadData];
					}
					else
					{
						[[[UIAlertView alloc] initWithTitle: @"No Matches Yet!"
													message: @"Keep checking your registered concerts to see if anybody new registered."
												   delegate: self
										  cancelButtonTitle: @"Ok"
										  otherButtonTitles:nil, nil] show];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	MatchProfileViewController *mpvc = [segue destinationViewController];
	mpvc.passedParseProfile = [self.arrayOfParseProfiles objectAtIndex: self.tableView.indexPathForSelectedRow.row];
}

#pragma mark - UITableViewDataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.arrayOfParseProfiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: matchCell];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
									  reuseIdentifier: matchCell];
	}
	ParseUserProfile *profile = [self.arrayOfParseProfiles objectAtIndex: indexPath.row];
	NSDictionary *profileDic;
	for (NSDictionary *dic in self.matchesArray)
	{
		if ([dic[@"profileID"] isEqualToString: profile.profileID])
		{
			profileDic = dic;
		}
	}
	
	cell.textLabel.text = profile.name;
	cell.detailTextLabel.numberOfLines = 4;
	cell.detailTextLabel.minimumScaleFactor = .5;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Matched for %@", profileDic[@"gigName"]];
	NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", profile.profileID];
	NSURL *url = [NSURL URLWithString: urlString];
	cell.imageView.clipsToBounds = YES;
	[cell.imageView setImageWithURL: url
					   placeholderImage: [ProfileViewController imageWithImage: [UIImage imageNamed: @"Placeholder.png"]
																	 scaledToSize: CGSizeMake(70, 70)]];
	
	return cell;
}

@end

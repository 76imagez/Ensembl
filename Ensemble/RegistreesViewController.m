//
//  RegistreesViewController.m
//  Ensemble
//
//  Created by Adam on 9/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "RegistreesViewController.h"
#import "ParseUserProfile.h"
#import "UserProfile.h"
#import "OtherProfileViewController.h"
#import "ProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define registreeCell @"registreeCell"

@interface RegistreesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *concertDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *registreesArray;

@end

@implementation RegistreesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *backgroundImage = [UIImage imageNamed:@"nhbdblur.png"];
	backgroundImage = [ProfileViewController imageWithImage: backgroundImage
											   scaledToSize: self.view.frame.size];
	backgroundImageView.image = backgroundImage;
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	self.concertDisplayNameLabel.text = [NSString stringWithFormat:@"People Registered For %@", self.concertObject.concertName];
	
	[self queryForRegistrees];
	
}

-(void)queryForRegistrees
{
	PFQuery *query = [ParseUserProfile query];
	[query whereKey: @"registeredGigs"
			equalTo: self.concertObject.concertID];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	OtherProfileViewController *otherProfile = [segue destinationViewController];
	otherProfile.passedParseProfile = [self.registreesArray objectAtIndex: self.tableView.indexPathForSelectedRow.row];
	otherProfile.concertObject = self.concertObject;
}

#pragma mark - UITableViewDataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.registreesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: registreeCell];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
									  reuseIdentifier: registreeCell];
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

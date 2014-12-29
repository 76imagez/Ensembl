//
//  OtherProfileViewController.m
//  Ensemble
//
//  Created by Adam on 9/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "OtherProfileViewController.h"
#import "BandCollectionViewCell.h"
#import "ProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"

#define bandCellReuseID @"bandCell"

@interface OtherProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutMeTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *bandCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *facebookTextField;
@property (weak, nonatomic) IBOutlet UITextField *instagramTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UIView *viewOnScrollView;

@end

@implementation OtherProfileViewController


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
	
	self.bandCollectionView.delegate = self;
	self.bandCollectionView.dataSource = self;
	
	//register custom cell class
	[self.bandCollectionView registerClass: [BandCollectionViewCell class]
				 forCellWithReuseIdentifier: bandCellReuseID];
	
	//format prof pic
	self.profileImageView.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
	self.profileImageView.layer.borderWidth = 1.2;
	self.profileImageView.layer.cornerRadius = 10;
	self.profileImageView.clipsToBounds = YES;
	
	//format text inputs in views
	for (UIView *view in self.viewOnScrollView.subviews)
	{
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
		{
            view.layer.borderColor = [[UIColor blackColor] CGColor];
			view.layer.borderWidth = 1.5;
			view.layer.cornerRadius = 5;
			view.clipsToBounds = YES;
        }
    }
	
	self.addButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.addButton.layer.borderWidth = 1;
	self.addButton.layer.cornerRadius = 5;
	
	[self fillInViewsFromParse];
	[self checkToSeeIfAdded];
	
	for (UIView *view in self.viewOnScrollView.subviews)
	{
		if ([view isKindOfClass: [UITextField class]])
		{
			UITextField *field = (UITextField *)view;
			field.enabled = NO;
		}
		if ([view isKindOfClass: [UITextView class]])
		{
			UITextView *textView = (UITextView *)view;
			textView.selectable = NO;
			textView.editable = NO;
			
		}
	}
	
}

-(void)checkToSeeIfAdded
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	PFQuery *myQuery = [ParseUserProfile query];
	[myQuery whereKey: @"profileID"
			  equalTo: appDelegate.userProfile.profileID];
	[myQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			ParseUserProfile *profile = [objects firstObject];
			if ([profile.potentialGigPals containsObject: self.passedParseProfile.profileID])
			{
				[self.addButton setTitle: @"Already Added"
								forState: UIControlStateNormal];
				self.addButton.enabled = NO;
			}
			else
			{
				[self.addButton setTitle: @"Add As Potential Match"
								forState: UIControlStateNormal];
				self.addButton.enabled = YES;
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

-(void)fillInViewsFromParse
{
	if (self.passedParseProfile.age == nil)
	{
		self.passedParseProfile.age = @"";
	}
	if (self.passedParseProfile.name == nil)
	{
		self.passedParseProfile.name = @"";
	}
	self.nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.passedParseProfile.name, self.passedParseProfile.age];
	self.aboutMeLabel.text = [NSString stringWithFormat:@"About %@:", self.passedParseProfile.name];
	self.aboutMeTextView.text = self.passedParseProfile.aboutMe;
	self.twitterTextField.text = self.passedParseProfile.twitter;
	self.facebookTextField.text = self.passedParseProfile.facebook;
	self.instagramTextField.text = self.passedParseProfile.instagram;
	
	PFFile *profilePicture = self.passedParseProfile.profileImage;
	[profilePicture getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
	{
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
		}
		else
		{
			self.profileImageView.image = [UIImage imageWithData: data];
		}
	}];
}

-(void)viewDidLayoutSubviews
{
	self.scrollView.contentSize = self.viewOnScrollView.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddButtonPressed:(UIButton *)sender
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.userProfile.potentialGigPals addObject: self.passedParseProfile.profileID];
	[self.addButton setTitle: @"Already Added"
					forState: UIControlStateNormal];
	self.addButton.enabled = NO;
	if ([self.passedParseProfile.potentialGigPals containsObject: appDelegate.userProfile.profileID])
	{
		//match alert view
		[[[UIAlertView alloc] initWithTitle: @"You have a match!"
									message: [NSString stringWithFormat:@"You matched with %@, head over to matches to strike up a conversation", self.passedParseProfile.name]
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
		
		//push query to alert for the match
		NSTimeInterval interval = 60*60*24*7;
		PFQuery *pushQuery = [PFInstallation query];
		[pushQuery whereKey:@"user" equalTo: self.passedParseProfile.profileID];
		
		PFPush *push = [[PFPush alloc] init];
		[push setQuery: pushQuery];
		[push expireAfterTimeInterval: interval];
		
		NSDictionary *data = @{@"type" : @"match", @"badge" : @"Increment", @"alert" : @"You have a new concert match!"};
		[push setData: data];
		[push sendPushInBackground];
		
		
		//add concert match to the passed profile
		[self.passedParseProfile addUniqueObject: @{@"profileID" : appDelegate.userProfile.profileID,
													@"gigName" : self.concertObject.concertName}
										  forKey: @"actualGigPals"];
		
		[self.passedParseProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
					
					[self.passedParseProfile saveEventually];
				}
			}
		}];
		
		[appDelegate.userProfile.actualGigPals addObject: @{@"profileID" : self.passedParseProfile.profileID,
															@"gigName" : self.concertObject.concertName}];
	}
	[appDelegate.userProfile saveUserToParseAppDelegateAndCoreData: appDelegate.managedObjectContext];
}
- (IBAction)onBackButtonPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}

#pragma mark - UICollectionViewDelegate and Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.passedParseProfile.bandArray.count;
}

- (BandCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	BandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: bandCellReuseID
																			 forIndexPath:indexPath];
	NSDictionary *bandDictionary = [self.passedParseProfile.bandArray objectAtIndex:indexPath.row];
	NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", bandDictionary[@"id"]];
	NSURL *url = [NSURL URLWithString: urlString];
	cell.bandImageView.clipsToBounds = YES;
	[cell.bandImageView setImageWithURL: url
					   placeholderImage: [ProfileViewController imageWithImage: [UIImage imageNamed: @"Placeholder.png"]
																  scaledToSize: CGSizeMake(70, 70)]];
	cell.bandLabel.text = bandDictionary[@"name"];
	
	return cell;
}

@end

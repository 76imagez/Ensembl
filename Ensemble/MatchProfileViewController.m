//
//  MatchProfileViewController.m
//  Ensemble
//
//  Created by Adam on 9/18/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "MatchProfileViewController.h"
#import "MatchMessageViewController.h"
#import "ProfileViewController.h"
#import "BandCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"


#define bandCellReuseID @"bandCell"


@interface MatchProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutMeTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *bandCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *facebookTextField;
@property (weak, nonatomic) IBOutlet UITextField *instagramTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (strong, nonatomic) UIAlertView *removeAlertView;

@end

@implementation MatchProfileViewController

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
	[self.bandCollectionView registerClass:[BandCollectionViewCell class]
				forCellWithReuseIdentifier: bandCellReuseID];
	
	//handle possible null values in age and name
	if (self.passedParseProfile.age == nil)
	{
		self.passedParseProfile.age = @"";
	}
	if (self.passedParseProfile.name == nil)
	{
		self.passedParseProfile.name = @"";
	}
	self.aboutLabel.text = [NSString stringWithFormat:@"About %@", self.passedParseProfile.name];
	self.nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.passedParseProfile.name, self.passedParseProfile.age];
	self.aboutMeTextView.text = self.passedParseProfile.aboutMe;
	self.facebookTextField.text = self.passedParseProfile.facebook;
	self.twitterTextField.text = self.passedParseProfile.twitter;
	self.instagramTextField.text = self.passedParseProfile.instagram;
	self.messageButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.messageButton.layer.borderWidth = .5;
	self.messageButton.layer.cornerRadius = 5;
	self.removeButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.removeButton.layer.borderWidth = .5;
	self.removeButton.layer.cornerRadius = 5;
	//format text inputs in views
	for (UIView *view in self.contentView.subviews)
	{
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
		{
			view.layer.borderColor = [[UIColor blackColor] CGColor];
			view.layer.borderWidth = 1.5;
			view.layer.cornerRadius = 5;
			view.clipsToBounds = YES;
		}
	}

	for (UIView *view in self.contentView.subviews)
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
	PFFile *profilePicFile = self.passedParseProfile.profileImage;
	[profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		if (!error)
		{
			UIImage *profilePicture = [UIImage imageWithData: data];
			self.imageView.image = profilePicture;
		}
		else
		{
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

-(void)viewDidLayoutSubviews
{
	self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRemovePressed:(UIButton *)sender
{
	self.removeAlertView = [[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"Are you sure you want to remove %@ from your matches?", self.passedParseProfile.name]
													  message: nil
													 delegate: self
											cancelButtonTitle: @"No, Nevermind"
											otherButtonTitles:@"Yes, I'm Sure", nil];
	[self.removeAlertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		for (NSDictionary *dic in appDelegate.userProfile.actualGigPals)
		{
			if ([dic[@"profileID"] isEqualToString: self.passedParseProfile.profileID])
			{
				[appDelegate.userProfile.actualGigPals removeObject: dic];
			}
		}
		[appDelegate.userProfile.potentialGigPals removeObject: self.passedParseProfile.profileID];
		[appDelegate.userProfile saveUserToParseAppDelegateAndCoreData: appDelegate.managedObjectContext];
		
		NSMutableArray *actuals = [self.passedParseProfile.actualGigPals mutableCopy];
		for (NSDictionary *dic in actuals)
		{
			if ([dic[@"profileID"] isEqualToString: appDelegate.userProfile.profileID])
			{
				[actuals removeObject: dic];
			}
		}
		self.passedParseProfile.actualGigPals = (NSArray *)actuals;
		
		NSMutableArray *potentials = [self.passedParseProfile.potentialGigPals mutableCopy];
		[potentials removeObject: appDelegate.userProfile.profileID];
		self.passedParseProfile.potentialGigPals = (NSArray *)potentials;
		
		[self.passedParseProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (error)
			{
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
	}
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	MatchMessageViewController *chatView = [segue destinationViewController];
	chatView.passedParseProfile = self.passedParseProfile;
	chatView.passedProfilePicture = self.imageView.image;
}

//class method to resize images
+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.passedParseProfile.bandArray.count;
}

- (BandCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	BandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: bandCellReuseID forIndexPath:indexPath];
	
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

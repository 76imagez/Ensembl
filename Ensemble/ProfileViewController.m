//
//  ProfileViewController.m
//  Ensemble
//
//  Created by Adam on 9/14/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserProfile.h"
#import "AppDelegate.h"
#import "BandCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "FBLoginViewController.h"
#import "ContainerViewController.h"
#import "MainViewController.h"

#define bandCellReuseID @"bandCell"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate, UserProfileDelegate, FBLoginViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UITextView *aboutMeTextView;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UITextField *facebookTextField;
@property (weak, nonatomic) IBOutlet UITextField *instagramTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *bandsCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) UIBarButtonItem *doneB;

@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) NSMutableArray *bandsArray;

@end

@implementation ProfileViewController
{
	BOOL isEditing;
	CGRect scrollViewFrame;
}

-(UserProfile *)userProfile
{
	if (!_userProfile)
	{
		_userProfile = [[UserProfile alloc] init];
		_userProfile.delegate = self;
	}
	return _userProfile;
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
	
	self.aboutMeTextView.inputAccessoryView = self.keyboardToolbar;
	self.twitterTextField.inputAccessoryView = self.keyboardToolbar;
	self.instagramTextField.inputAccessoryView = self.keyboardToolbar;
	self.facebookTextField.inputAccessoryView = self.keyboardToolbar;
	self.aboutMeTextView.delegate = self;
	self.twitterTextField.delegate = self;
	self.instagramTextField.delegate = self;
	self.facebookTextField.delegate = self;
	self.scrollView.delaysContentTouches = NO;
	
	[self disableTextFieldsAndViews];
	
	
	self.bandsCollectionView.delegate = self;
	self.bandsCollectionView.dataSource = self;
	
	//register custom cell class
	[self.bandsCollectionView registerClass: [BandCollectionViewCell class]
				 forCellWithReuseIdentifier: bandCellReuseID];
	
	//format prof pic
	self.profilePicView.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
	self.profilePicView.layer.borderWidth = 1.2;
	self.profilePicView.layer.cornerRadius = 10;
	self.profilePicView.clipsToBounds = YES;
	
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
	
	self.editButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.editButton.layer.borderWidth = 1;
	self.editButton.layer.cornerRadius = 5;
	self.logOutButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.logOutButton.layer.borderWidth = 1;
	self.logOutButton.layer.cornerRadius = 5;

}

-(void)viewWillAppear:(BOOL)animated
{
	if (![FBSession activeSession].isOpen)
	{
		
		[self performSegueWithIdentifier: @"fblogin"
								  sender: self];
		 
	}
	else
	{
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		if (appDelegate.userProfile)
		{
			self.aboutMeTextView.text = appDelegate.userProfile.aboutMe;
			self.twitterTextField.text = appDelegate.userProfile.twitter;
			self.facebookTextField.text = appDelegate.userProfile.facebook;
			self.instagramTextField.text = appDelegate.userProfile.instagram;
			
			self.userProfile = appDelegate.userProfile;
			
			//handle possible null values in age or name
			if (self.userProfile.age == nil)
			{
				self.userProfile.age = @"";
			}
			if (self.userProfile.name == nil)
			{
				self.userProfile.name = @"";
			}
			self.nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.userProfile.name, self.userProfile.age];

			self.bandsArray = [appDelegate.userProfile.bandArray mutableCopy];
			self.profilePicView.image = appDelegate.userProfile.profilePic;
			[self.userProfile requestUserProfileInfo];
			[self.userProfile requestMusicInfo: @"start"
									 withArray: @[]];
			[self.userProfile getProfilePicture];
		}
		else
		{
			[self.userProfile loadProfileFromCoreData: appDelegate.managedObjectContext];
			PFQuery *query = [ParseUserProfile query];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSString *facebookID = [defaults objectForKey:@"profileID"];
			
			if (facebookID)
			{
				self.userProfile.profileID = facebookID;
				[query whereKey: @"profileID"
						equalTo: self.userProfile.profileID];
				[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
				 {
					 if (!error)
					 {
						 if (objects.count > 0)
						 {
							 [self.userProfile loadProfileFromParse: [objects firstObject]];
							 [self.userProfile requestUserProfileInfo];
							 [self.userProfile requestMusicInfo:@"start"
													  withArray: @[]];
							 [self.userProfile getProfilePicture];
						 }
						 else
						 {
							 [self.userProfile saveToAppDelegate];
							 [self.userProfile requestUserProfileInfo];
							 [self.userProfile requestMusicInfo:@"start"
													  withArray: @[]];
							 [self.userProfile getProfilePicture];
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
							 [self.userProfile loadProfileFromCoreData: appDelegate.managedObjectContext];
							 
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
				NSLog(@"Facebook ID not being retrieved from NSUserDefaults");
			}
		}
		
	}
}


- (IBAction)onEditProfilePressed:(UIButton *)sender
{
	if (!isEditing)
	{
		isEditing = YES;
		
		[self enableTextFieldsAndViews];
		[self.editButton setTitle:@"Save Changes" forState: UIControlStateNormal];
		ContainerViewController *container = (ContainerViewController *)self.parentViewController;
		for (UIGestureRecognizer *gestureRecognizer in container.view.gestureRecognizers)
		{
			gestureRecognizer.enabled = NO;
		}
		MainViewController *main = (MainViewController *)container.parentViewController;
		[main toggleMenuEnabled];
		
	}
	else
	{
		isEditing = NO;
		
		[self disableTextFieldsAndViews];
		
		self.userProfile.twitter = self.twitterTextField.text;
		self.userProfile.facebook = self.facebookTextField.text;
		self.userProfile.instagram = self.instagramTextField.text;
		self.userProfile.aboutMe = self.aboutMeTextView.text;
				
		ContainerViewController *container = (ContainerViewController *)self.parentViewController;
		for (UIGestureRecognizer *gestureRecognizer in container.view.gestureRecognizers)
		{
			gestureRecognizer.enabled = YES;
		}
		MainViewController *main = (MainViewController *)container.parentViewController;
		[main toggleMenuEnabled];
		
		[self.editButton setTitle:@"Edit Profile" forState: UIControlStateNormal];
		
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[self.userProfile saveUserToParseAppDelegateAndCoreData: appDelegate.managedObjectContext];
	}
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

//configure toolbar
-(UIToolbar *)keyboardToolbar
{
	if (!_keyboardToolbar)
	{
		_keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
		self.doneB = [[UIBarButtonItem alloc] initWithTitle: @"Done"
													  style: UIBarButtonItemStyleBordered
													 target: self
													 action: @selector(done)];
		UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
																					target:nil
																					action:nil];
		[_keyboardToolbar setItems:@[extraSpace, self.doneB]];
		_keyboardToolbar.barTintColor = [UIColor blackColor];
		_keyboardToolbar.barStyle = UIBarStyleBlackOpaque;
	}
	
	return _keyboardToolbar;
}

//resign keyboard
-(void)done
{
	for (UIView *view in self.contentView.subviews)
	{
		[view resignFirstResponder];
	}
}

#pragma mark - Enabling and Disabling Views

-(void)disableTextFieldsAndViews
{
	self.aboutMeTextView.editable = NO;
	self.aboutMeTextView.userInteractionEnabled = NO;
	self.instagramTextField.enabled = NO;
	self.facebookTextField.enabled = NO;
	self.twitterTextField.enabled = NO;
}

-(void)enableTextFieldsAndViews
{
	self.aboutMeTextView.editable = YES;
	self.aboutMeTextView.userInteractionEnabled = YES;
	self.instagramTextField.enabled = YES;
	self.facebookTextField.enabled = YES;
	self.twitterTextField.enabled = YES;
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
	return self.userProfile.bandArray.count;
}

- (BandCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	BandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: bandCellReuseID forIndexPath:indexPath];
	
	NSDictionary *bandDictionary = [self.userProfile.bandArray objectAtIndex:indexPath.row];
	NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", bandDictionary[@"id"]];
	NSURL *url = [NSURL URLWithString: urlString];
	cell.bandImageView.clipsToBounds = YES;
	[cell.bandImageView setImageWithURL: url
						placeholderImage: [ProfileViewController imageWithImage: [UIImage imageNamed: @"Placeholder.png"]
																	 scaledToSize: CGSizeMake(70, 70)]];
	cell.bandLabel.text = bandDictionary[@"name"];
	
	return cell;
}

#pragma mark - UITextField and UITextView Delegates

//Scroll View Version
-(CGFloat)quantityToShiftSoThatKeyboardIsRightUnderView:(UIView *)firstResponder inFrame:(CGRect)frame
{
	CGRect keyboardRect = CGRectMake(0,
									 (frame.size.height - 300),
									 frame.size.width,
									 300);
	double distanceBetweenKeyboardAndViewBottonOrigin = keyboardRect.origin.y - (firstResponder.frame.origin.y + firstResponder.frame.size.height);
	if ((distanceBetweenKeyboardAndViewBottonOrigin + self.scrollView.contentOffset.y) > 0)
	{
		return 0;
	}
	return (distanceBetweenKeyboardAndViewBottonOrigin + self.scrollView.contentOffset.y);
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	scrollViewFrame = self.scrollView.frame;
	[UIView animateWithDuration: .3f
						  delay: 0
		 usingSpringWithDamping: .95
		  initialSpringVelocity: 10
						options: UIViewAnimationOptionCurveEaseIn
					 animations: ^{
						 CGRect frame = self.view.frame;
						 frame.origin.y = [self quantityToShiftSoThatKeyboardIsRightUnderView: textField
																					  inFrame: self.scrollView.frame];
						 self.view.frame = frame;
					 
					 }
					 completion:^(BOOL finished) {
						 
					 }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	[UIView animateWithDuration: .3f
						  delay: 0
		 usingSpringWithDamping: .95
		  initialSpringVelocity: 10
						options: UIViewAnimationOptionCurveEaseOut
					 animations: ^{
						 CGRect frame = self.view.frame;
						 frame.origin.y = 0;
						 self.view.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 
					 }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
	scrollViewFrame = self.scrollView.frame;
	if (textView.frame.origin.y < self.scrollView.contentOffset.y)
	{
		[UIView animateWithDuration: .3f
							  delay: 0
			 usingSpringWithDamping: .95
			  initialSpringVelocity: 10
							options: UIViewAnimationOptionCurveEaseIn
						 animations: ^{
							 [self.scrollView setContentOffset: CGPointMake(0, textView.frame.origin.y)];
							 
						 }
						 completion:^(BOOL finished) {
			 
		 }];

	}
	else
	{
		scrollViewFrame = self.scrollView.frame;
		[UIView animateWithDuration: .3f
							  delay: 0
			 usingSpringWithDamping: .95
			  initialSpringVelocity: 10
							options: UIViewAnimationOptionCurveEaseIn
						 animations: ^{
							 CGRect frame = self.view.frame;
							 frame.origin.y = [self quantityToShiftSoThatKeyboardIsRightUnderView: textView
																						  inFrame: self.scrollView.frame];
							 self.view.frame = frame;
							 
						 }
						 completion:^(BOOL finished) {
							 
						 }];
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
	[UIView animateWithDuration: .3f
						  delay: 0
		 usingSpringWithDamping: .95
		  initialSpringVelocity: 10
						options: UIViewAnimationOptionCurveEaseOut
					 animations: ^{
						 CGRect frame = self.view.frame;
						 frame.origin.y = 0;
						 self.view.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 
					 }];
}

#pragma mark - User Profile Delegate

-(void)fillInEditableViews
{
	self.aboutMeTextView.text = self.userProfile.aboutMe;
	self.twitterTextField.text = self.userProfile.twitter;
	self.facebookTextField.text = self.userProfile.facebook;
	self.instagramTextField.text = self.userProfile.instagram;
}

-(void)onFinishedLoadingMusic
{
	[self.bandsCollectionView reloadData];
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[self.userProfile saveUserToParseAppDelegateAndCoreData: appDelegate.managedObjectContext];
}

-(void)onFinishedLoadingUserProfile
{
	[self fillInEditableViews];
	
	//handle possible null values
	if (self.userProfile.age == nil)
	{
		self.userProfile.age = @"";
	}
	if (self.userProfile.name == nil)
	{
		self.userProfile.name = @"";
	}
	self.nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.userProfile.name, self.userProfile.age];
	self.nameLabel.text = [NSString stringWithFormat:@"%@", self.userProfile.name];
	
}

-(void)onFinishedGettingProfilePicture
{
	self.profilePicView.image = self.userProfile.profilePic;
}

-(void)onFinishedLoadingUserProfileFromCoreData
{
	if (self.userProfile.age == nil)
	{
		self.userProfile.age = @"";
	}
	if (self.userProfile.name == nil)
	{
		self.userProfile.name = @"";
	}
	self.profilePicView.image = self.userProfile.profilePic;
	self.twitterTextField.text = self.userProfile.twitter;
	self.facebookTextField.text = self.userProfile.facebook;
	self.instagramTextField.text = self.userProfile.instagram;
	self.aboutMeTextView.text = self.userProfile.aboutMe;
	self.nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.userProfile.name, self.userProfile.age];
	[self.bandsCollectionView reloadData];
}

#pragma mark - FBLoginViewController

-(void)onSuccessfulLogin:(NSString *)facebookID
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setObject: facebookID
							forKey: @"user"];
	[currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	 {
		 if (error)
		 {
			 if ([error code] == kPFErrorConnectionFailed)
			 {
				 [[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
											 message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
											delegate: self
								   cancelButtonTitle: @"Ok"
								   otherButtonTitles:nil, nil] show];
			 }
			 [currentInstallation saveEventually];
		 }
		 
	 }];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"fblogin"])
	{
		FBLoginViewController *login = [segue destinationViewController];
		login.delegate = self;
	}
}

@end

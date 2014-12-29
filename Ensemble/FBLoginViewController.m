//
//  FBLoginViewController.m
//  Ensemble
//
//  Created by Adam on 9/16/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "FBLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface FBLoginViewController () <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *facebookLoginView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbProfilePicView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) NSString *profileID;

@end

@implementation FBLoginViewController
{
	BOOL loggedIn;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	UIView *blackView = [[UIView alloc] initWithFrame: self.view.frame];
	blackView.backgroundColor = [UIColor blackColor];
	blackView.alpha = .7;
	[self.view addSubview: blackView];
	[self.view sendSubviewToBack: blackView];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *backgroundImage = [UIImage imageNamed:@"nhbdblur.png"];
	backgroundImage = [FBLoginViewController imageWithImage: backgroundImage
												scaledToSize: self.view.frame.size];
	backgroundImageView.image = backgroundImage;
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	self.facebookLoginView.delegate = self;
	self.facebookLoginView.readPermissions = @[@"public_profile", @"user_likes", @"user_birthday"];
	self.confirmButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.confirmButton.layer.borderWidth = .5;
	self.confirmButton.layer.cornerRadius = 5;
	
	self.fbProfilePicView.layer.borderWidth = 1;
	self.fbProfilePicView.layer.borderColor = [[UIColor blackColor] CGColor];
	self.fbProfilePicView.layer.cornerRadius = 5;
	self.fbProfilePicView.clipsToBounds = YES;
	
	if ([Reachable wifiNetworkIsUnreachable] && [Reachable internetNetworkIsUnreachable])
	{

		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];

	}

}


-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: YES];
	[[self delegate] onSuccessfulLogin: self.profileID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onConfirmPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated: YES
							 completion: nil];
}
- (IBAction)onBackButtonPressed:(id)sender
{
	if (loggedIn)
	{
		[self dismissViewControllerAnimated: YES
								 completion: nil];
	}
	else
	{
		UIAlertView *logInAlert = [[UIAlertView alloc] initWithTitle: @"Log In First To Continue"
															 message: nil
															delegate: self
												   cancelButtonTitle: @"Ok"
												   otherButtonTitles: nil, nil];
		[logInAlert show];
	}
}
#pragma mark - Facebook Login View Delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
	self.fbProfilePicView.hidden = NO;
	self.nameLabel.hidden = NO;
	self.confirmButton.hidden = NO;
	loggedIn = YES;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: self.profileID forKey:@"profileID"];
	[defaults synchronize];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
	loggedIn = YES;
	self.fbProfilePicView.profileID = user.objectID;
	self.profileID = user.objectID;
	self.nameLabel.text = user.name;
	[self.confirmButton setTitle: @"Enter"
						forState: UIControlStateNormal];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: self.profileID forKey:@"profileID"];
	[defaults synchronize];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
	loggedIn = NO;
	self.fbProfilePicView.hidden = YES;
	self.nameLabel.hidden = YES;
	self.confirmButton.hidden = YES;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: nil forKey:@"profileID"];
	[defaults synchronize];
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.userProfile = nil;
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error
{
	[self handleAuthError:error];
}

- (void)handleAuthError:(NSError *)error
{
	NSString *alertText;
	NSString *alertTitle;
	if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
	{
		// Error requires people using you app to make an action outside your app to recover
		alertTitle = @"Something went wrong";
		alertText = [FBErrorUtility userMessageForError:error];
		[self showMessage:alertText withTitle:alertTitle];
		
	}
	else
	{
		// You need to find more information to handle the error within your app
		if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
			//The user refused to log in into your app, either ignore or...
			alertTitle = @"Login cancelled";
			alertText = @"You need to login to access this part of the app";
			[self showMessage:alertText withTitle:alertTitle];
			
		}
		else
		{
			// All other errors that can happen need retries
			// Show the user a generic error message
			alertTitle = @"Something went wrong";
			alertText = @"Please retry";
			[self showMessage:alertText withTitle:alertTitle];
		}
	}
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

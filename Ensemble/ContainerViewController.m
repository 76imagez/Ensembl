//
//  ContainerViewController.m
//  Ensemble
//
//  Created by Adam on 9/14/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ContainerViewController.h"
#import "ProfileViewController.h"
#import "ConcertsViewController.h"
#import "MainViewController.h"

#define ProfileSegue @"profile"
#define ConcertsSegue @"concerts"
#define MatchesSegue @"matches"

@interface ContainerViewController ()

@property (nonatomic, strong) NSString *currentSegueIdentifier;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation ContainerViewController
{
	BOOL transitionInProgress;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	transitionInProgress = NO;
	self.currentSegueIdentifier = ProfileSegue;
	[self performSegueWithIdentifier: self.currentSegueIdentifier
							  sender: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController: toViewController];
	
    [self transitionFromViewController: fromViewController
					  toViewController: toViewController
							  duration: .7
							   options: UIViewAnimationOptionTransitionCrossDissolve
							animations: nil
							completion:^(BOOL finished) {
								
								[fromViewController removeFromParentViewController];
								[toViewController didMoveToParentViewController:self];
								transitionInProgress = NO;
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if (!self.currentViewController)
	{
		self.currentViewController = segue.destinationViewController;
		[self addChildViewController: segue.destinationViewController];
		UIView *destView = ((UIViewController *)segue.destinationViewController).view;
		destView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		[self.view addSubview:destView];
		[segue.destinationViewController didMoveToParentViewController: self];
	}
	else if (self.currentViewController == segue.destinationViewController)
	{
		[self swapFromViewController: self.currentViewController
					toViewController: self.currentViewController];
	}
	else
	{
		[self swapFromViewController: self.currentViewController
					toViewController: segue.destinationViewController];
		self.currentViewController = segue.destinationViewController;
	}
}

- (IBAction)onDownswipe:(UISwipeGestureRecognizer *)sender
{
	MainViewController *mVC = (MainViewController *)self.parentViewController;
	[mVC menuAction];
}

- (IBAction)onUpswipe:(UISwipeGestureRecognizer *)sender
{
	MainViewController *mVC = (MainViewController *)self.parentViewController;
	[mVC menuAction];
}

@end

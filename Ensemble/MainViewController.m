//
//  MainViewController.m
//  Ensemble
//
//  Created by Adam on 9/12/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "MainViewController.h"
#import "ContainerViewController.h"

#define ProfileSegue @"profile"
#define ConcertsSegue @"concerts"
#define MatchesSegue @"matches"
#define RegisteredGigsSegue @"gigs"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSArray *menuArray;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) ContainerViewController *container;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation MainViewController
{
	BOOL menuIsDown;
	CGRect containerFrame;
	BOOL menuIsEnabled;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.menuTableView.delegate = self;
	self.menuTableView.dataSource = self;
	self.title = @"Profile";
	[self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size: 22.0]}];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	//self.menuTableView.separatorColor = [UIColor whiteColor];
	self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.menuTableView.backgroundColor = [UIColor clearColor];
	self.menuTableView.scrollEnabled = NO;
	
	self.menuArray = @[@"", @"Profile", @"Concerts", @"Matches", @"Registered Concerts"];
	
	containerFrame = self.containerView.frame;
	
	menuIsEnabled = YES;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onMenuPressed:(UIButton *)sender
{
	[self menuAction];
}

-(void)toggleMenuEnabled
{
	if (menuIsEnabled)
	{
		menuIsEnabled = NO;
		self.menuButton.enabled = NO;
	}
	else
	{
		menuIsEnabled = YES;
		self.menuButton.enabled = YES;
	}
}

-(void)menuAction
{
	if (menuIsDown)
	{
		[UIView animateWithDuration: .3f
							  delay: 0
			 usingSpringWithDamping: 1
			  initialSpringVelocity: 10
							options: UIViewAnimationOptionCurveEaseOut
						 animations: ^{
							 CGRect frame = self.containerView.frame;
							 frame.origin.y = containerFrame.origin.y;
							 self.containerView.frame = frame;
						 }
						 completion:^(BOOL finished) {
							 menuIsDown = NO;
						 }];
	}
	else
	{
		[UIView animateWithDuration: .3f
							  delay: 0
			 usingSpringWithDamping: .7
			  initialSpringVelocity: 10
							options: UIViewAnimationOptionCurveEaseOut
						 animations: ^{
							 CGRect frame = self.containerView.frame;
							 frame.origin.y = self.menuTableView.frame.origin.y + self.menuTableView.frame.size.height;
							 self.containerView.frame = frame;
						 }
						 completion:^(BOOL finished) {
							 menuIsDown = YES;
						 }];
	}

}

-(void)returnMenuToOriginalPosition
{
	[UIView animateWithDuration: .3f
						  delay: 0
		 usingSpringWithDamping: .9
		  initialSpringVelocity: 10
						options: UIViewAnimationOptionCurveEaseOut
					 animations: ^{
						 CGRect frame = self.containerView.frame;
						 frame.origin.y = containerFrame.origin.y;
						 self.containerView.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 menuIsDown = NO;
					 }];
}

//class method to resize images
+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma  UITableView Delegate and Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *menuCellReuse = @"menuCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: menuCellReuse];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
									  reuseIdentifier: menuCellReuse];
	}
	
	cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.text = [self.menuArray objectAtIndex: indexPath.row];
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 22];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 1)
	{
		[self.container performSegueWithIdentifier: ProfileSegue
											sender: self];
		[self returnMenuToOriginalPosition];
		self.title = @"Profile";
	}
	if (indexPath.row == 2)
	{
		[self.container performSegueWithIdentifier: ConcertsSegue
											sender: self];
		[self returnMenuToOriginalPosition];
		self.title = @"Concerts";
	}
	if (indexPath.row == 3)
	{
		[self.container performSegueWithIdentifier: MatchesSegue
											sender: self];
		[self returnMenuToOriginalPosition];
		self.title = @"Matches";
	}
	if (indexPath.row == 4)
	{
		[self.container performSegueWithIdentifier: RegisteredGigsSegue
											sender: self];
		[self returnMenuToOriginalPosition];
		self.title = @"Registered Concerts";
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: @"embed"])
	{
		self.container = (ContainerViewController *)segue.destinationViewController;
	}
}


@end

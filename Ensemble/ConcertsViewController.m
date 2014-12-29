//
//  ConcertsViewController.m
//  Ensemble
//
//  Created by Adam on 9/14/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "ConcertsViewController.h"
#import "RegistreesViewController.h"
#import "AppDelegate.h"
#import "Concert.h"
#import "ParseConcert.h"
#import "CoreConcert.h"

#define concertCell @"concertCell"
#define songkickAPIKey @"OX40tOGzn7BvhMak"

#define registreesSegue @"toRegistrees"

@interface ConcertsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *finderView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *finderLabel;
@property (weak, nonatomic) IBOutlet UIButton *startOverButton;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (strong, nonatomic) NSArray *cityArray; //arry of dictionaries with city name and id
@property (strong, nonatomic) NSDictionary *chosenCityDictionary;

@property (strong, nonatomic) NSArray *concertObjectArray;
@property (strong, nonatomic) Concert *chosenConcertObject;

@property (strong, nonatomic) UIAlertView *registerForEventAlert;

@end

@implementation ConcertsViewController
{
	BOOL pickYourCityIsActive;
	BOOL searchArtistIsActive;
	BOOL noResults;
	NSString *searchTerm;
}


-(NSArray *)cityArray
{
	if (!_cityArray)
	{
		_cityArray = [[NSArray alloc] init];
	}
	return _cityArray;
}

-(NSArray *)concertObjectArray
{
	if (!_concertObjectArray)
	{
		_concertObjectArray = [[NSArray alloc] init];
	}
	return _concertObjectArray;
}

-(NSDictionary *)chosenCityDictionary
{
	if (!_chosenCityDictionary)
	{
		_chosenCityDictionary = [[NSDictionary alloc] init];
	}
	return _chosenCityDictionary;
}

-(UIToolbar *)keyboardToolbar
{
	if (!_keyboardToolbar)
	{
		_keyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
		self.doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Dismiss"
														   style: UIBarButtonItemStyleBordered
														  target: self
														  action: @selector(done)];
		[_keyboardToolbar setItems: @[self.doneButton]];
		_keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
		
	}
	return _keyboardToolbar;
}

-(void)done
{
	[UIView animateWithDuration: .3f
						  delay: 0
		 usingSpringWithDamping: .8
		  initialSpringVelocity: 10
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect frame = self.view.frame;
						 frame.origin.y = 0;
						 self.view.frame = frame;
					 }
					 completion:^(BOOL finished) {
						 
					 }];
	[self.searchBar resignFirstResponder];
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
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: self.view.frame];
	UIImage *backgroundImage = [UIImage imageNamed:@"nhbdblur.png"];
	backgroundImage = [ConcertsViewController imageWithImage: backgroundImage
												scaledToSize: self.view.frame.size];
	backgroundImageView.image = backgroundImage;
	[self.view addSubview: backgroundImageView];
	[self.view sendSubviewToBack: backgroundImageView];
	
	pickYourCityIsActive = NO;
	searchArtistIsActive = NO;
		
	self.searchBar.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];
	
	self.searchBar.inputAccessoryView = self.keyboardToolbar;
	
	self.startOverButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.startOverButton.layer.borderWidth = 1;
	self.startOverButton.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onStartOverPressed:(UIButton *)sender
{
	[self configureSearchCityView];
}

#pragma mark - UITableViewDelegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (pickYourCityIsActive && !searchArtistIsActive && !noResults)
	{
		return self.cityArray.count;
	}
	
	if (!pickYourCityIsActive && searchArtistIsActive && !noResults)
	{
		return self.concertObjectArray.count;
	}
	
	if (noResults)
	{
		return 1;
	}
	
	return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//when there person is picking their city and they had results
	if (pickYourCityIsActive && !searchArtistIsActive && !noResults)
	{
		
		return 44;
	}
	
	//when the person is picking their artist and they had results
	if (!pickYourCityIsActive && searchArtistIsActive && !noResults)
	{
		return 118;
	}
	
	return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: concertCell];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
									  reuseIdentifier: concertCell];
	}
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.backgroundColor = [UIColor blackColor];
	cell.alpha = .6;
	
	//when there person is picking their city and they had results
	if (pickYourCityIsActive && !searchArtistIsActive && !noResults)
	{
		if (self.cityArray.count == 0 || !self.cityArray)
		{
			return cell;
		}
		
		NSDictionary *cityDictionary = self.cityArray[indexPath.row];
		//NSString *cityID = cityDictionary[@"cityID"];
		NSString *city = cityDictionary[@"cityDisplayName"];
		NSString *state = cityDictionary[@"stateDisplayName"];
		//NSString *idvalue = [cityDictionary[@"cityID"] stringValue];
		NSString *cellLabelText = [NSString stringWithFormat: @"%@, %@", city, state];
		cell.textLabel.text = cellLabelText;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		
		return cell;
	}
	//when the person is picking their artist and they had results
	if (!pickYourCityIsActive && searchArtistIsActive && !noResults)
	{
		if (self.concertObjectArray.count == 0 || !self.concertObjectArray)
		{
			return cell;
		}
		Concert *cobject = self.concertObjectArray[indexPath.row];
		cell.textLabel.text = cobject.concertName;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	//when no results are returned
	if (noResults)
	{
		cell.textLabel.text = [NSString stringWithFormat: @"No results matched \"%@\", Try Again", searchTerm];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		return cell;
	}
	
	return cell;
	
}

//change to artists view
-(void)configureSearchArtistsView
{
	[UIView animateWithDuration: .3
					 animations:^{
						 self.searchBar.text = @"";
						 self.finderLabel.text = [NSString stringWithFormat:@"Search Artist In %@, %@", self.chosenCityDictionary[@"cityDisplayName"], self.chosenCityDictionary[@"stateDisplayName"]];
						 self.searchBar.placeholder = @"Search Artist You Want To See";
						 self.startOverButton.hidden = NO;
					 }];
}

//reset to search cities
-(void)configureSearchCityView
{
	[UIView animateWithDuration: .3
					 animations:^{
						 self.concertObjectArray = nil;
						 self.searchBar.text = @"";
						 self.finderLabel.text = @"First, Pick Your City";
						 self.searchBar.placeholder = @"Search City (Aim for Largest Nearby)";
						 noResults = NO;
						 pickYourCityIsActive = NO;
						 searchArtistIsActive = NO;
						 self.startOverButton.hidden = YES;
						 self.chosenCityDictionary = nil;
						 [self.tableView reloadData];
						 
					 }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//when the person is picking their city and they had results
	if (pickYourCityIsActive && !searchArtistIsActive && !noResults)
	{
		self.chosenCityDictionary = self.cityArray[indexPath.row];
		
		[self configureSearchArtistsView];
	}
	//when the person is picking their artist and they had results
	if (!pickYourCityIsActive && searchArtistIsActive && !noResults)
	{
		self.chosenConcertObject = self.concertObjectArray[indexPath.row];
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		if ([appDelegate.userProfile.registeredGigs containsObject: self.chosenConcertObject.concertID])
		{
			[self performSegueWithIdentifier: registreesSegue sender: self];
		}
		else
		{
			self.registerForEventAlert = _registerForEventAlert = [[UIAlertView alloc] initWithTitle: @"Would you like to register as a potential concert match for this event?"
																							 message: @"Registering for an event allows you to match up with others who have registered for the event"
																							delegate: self
																				   cancelButtonTitle: @"No Thanks"
																				   otherButtonTitles: @"Register Me", nil];
			[self.registerForEventAlert show];
		}
		
	}
	noResults = NO;
	pickYourCityIsActive = NO;
	searchArtistIsActive = YES;
	[self.tableView reloadData];
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self performSegueWithIdentifier: registreesSegue sender: self];
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate.userProfile.registeredGigs addObject: self.chosenConcertObject.concertID];
		[appDelegate.userProfile saveUserToParseAppDelegateAndCoreData: appDelegate.managedObjectContext];
		
		//save concert to core data
		CoreConcert *concert;
		NSError *coreError;
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CoreConcert"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == concertID", self.chosenConcertObject.concertID];
		fetchRequest.predicate = predicate;
		NSArray *concerts = [appDelegate.managedObjectContext executeFetchRequest: fetchRequest
																			error: &coreError];
		if (!coreError)
		{
			if (concerts.count == 0)
			{
				concert = [NSEntityDescription insertNewObjectForEntityForName:@"CoreConcert"
														inManagedObjectContext: appDelegate.managedObjectContext];
				concert.concertDate = self.chosenConcertObject.concertDate;
				concert.concertID = self.chosenConcertObject.concertID;
				concert.concertName = self.chosenConcertObject.concertName;
				concert.concertURI = self.chosenConcertObject.concertURI;
				NSError *error;
				[appDelegate.managedObjectContext save: &error];
				if (error)
				{
					NSLog(@"%@", [error localizedDescription]);
				}
			}
		}
		else
		{
			NSLog(@"%@", [coreError localizedDescription]);
		}
		
		//save concert to parse, its primary place
		PFQuery *concertQuery = [ParseConcert query];
		[concertQuery whereKey: @"concertID" equalTo: self.chosenConcertObject.concertID];
		[concertQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			ParseConcert *concert;
			if (objects.count > 0)
			{
				concert = [objects firstObject];
				int registrees = [concert.registrees intValue] + 1;
				concert.registrees = [NSNumber numberWithInt: registrees];
			}
			else
			{
				concert = [ParseConcert object];
				concert.concertDate = self.chosenConcertObject.concertDate;
				concert.concertID = self.chosenConcertObject.concertID;
				concert.concertName = self.chosenConcertObject.concertName;
				concert.concertURI = self.chosenConcertObject.concertURI;
				concert.registrees = @1;
			}
			[concert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (error)
				{
					NSLog(@"%@", [error localizedDescription]);
					[concert saveEventually];
				}
			}];
		}];
	}
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: registreesSegue])
	{
		RegistreesViewController *rvc = [segue destinationViewController];
		rvc.concertObject = self.chosenConcertObject;
	}
}

#pragma mark - UISearchBar Delegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	if (!searchArtistIsActive && !pickYourCityIsActive)
	{
		pickYourCityIsActive = YES;
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	noResults = NO;
	//when the person is picking their city and they had results
	if (pickYourCityIsActive && (searchBar == self.searchBar))
	{
		[searchBar resignFirstResponder];
		//use entered city name to retrieve concert info
		searchTerm = searchBar.text;
		NSURL *yurl = [NSURL URLWithString:[NSString stringWithFormat: @"http://api.songkick.com/api/3.0/search/locations.json?query=%@&apikey=%@", [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"], songkickAPIKey]];
		NSURLRequest *request = [NSURLRequest requestWithURL: yurl];
		if ([Reachable internetNetworkIsUnreachable] && [Reachable wifiNetworkIsUnreachable])
		{
			NSLog(@"No internet or Wifi Connection Available");
			[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
										message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
									   delegate: self
							  cancelButtonTitle: @"Ok"
							  otherButtonTitles:nil, nil] show];
		}
		else
		{
			[NSURLConnection sendAsynchronousRequest: request
											   queue: [NSOperationQueue mainQueue]
								   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
									   
									   if (!connectionError)
									   {
										   NSError *error;
										   id jsonShit = [NSJSONSerialization JSONObjectWithData: data
																						 options: NSJSONReadingMutableContainers
																						   error: &error];
										   if (!error)
										   {
											   NSDictionary *topLevelJSON = (NSDictionary *)jsonShit;
											   NSDictionary *resultsPageDictionary = (NSDictionary *)topLevelJSON[@"resultsPage"];
											   NSDictionary *resultsDictionary = (NSDictionary *)resultsPageDictionary[@"results"];
											   NSNumber *numberOfEntries = resultsPageDictionary[@"totalEntries"];
											   NSArray *returnedCitiesArray = (NSArray *)resultsDictionary[@"location"];
											   NSMutableArray *cityArray = [[NSMutableArray alloc] initWithCapacity: returnedCitiesArray.count];
											   if (![numberOfEntries isEqualToNumber: @0])
											   {
												   NSMutableArray *arrayOfFoundIDs = [NSMutableArray new];
												   for (int i = 0; i < returnedCitiesArray.count; i++)
												   {
													   NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
													   NSDictionary *cityArrayDictionary = returnedCitiesArray[i];
													   NSDictionary *metroAreaDictionary = cityArrayDictionary[@"metroArea"];
													   NSString *cityID = metroAreaDictionary[@"id"];
													   NSDictionary *stateDictionary = metroAreaDictionary[@"state"];
													   NSString *stateDisplayName = stateDictionary[@"displayName"];
													   NSString *cityDisplayName = metroAreaDictionary[@"displayName"];
													   if (![arrayOfFoundIDs containsObject: cityID])
													   {
														   [mutableDictionary setObject: cityID
																				 forKey: @"cityID"];
														   [mutableDictionary setObject: cityDisplayName
																				 forKey: @"cityDisplayName"];
														   [mutableDictionary setObject: stateDisplayName
																				 forKey: @"stateDisplayName"];
														   
														   [cityArray addObject: (NSDictionary *)mutableDictionary];
														   [arrayOfFoundIDs addObject: cityID];
													   }
													   
												   }
												   self.cityArray = (NSArray *)cityArray;
												   noResults = NO;
												   [self.tableView reloadData];
											   }
											   else
											   {
												   self.cityArray = nil;
												   noResults = YES;
												   [self.tableView reloadData];
											   }
										   }
										   else
										   {
											   NSLog(@"%@", [error localizedDescription]);
											   
											   [[[UIAlertView alloc] initWithTitle:@"Error With Request"
																		   message:@"Unable to connect to Songkick right now, try again later"
																		  delegate: self
																 cancelButtonTitle:@"Ok"
																 otherButtonTitles:nil, nil] show];
										   }
									   }
									   else
									   {
										   NSLog(@"%@", [connectionError localizedDescription]);
										   
										   [[[UIAlertView alloc] initWithTitle:@"Error With Request"
																	   message:@"Unable to connect to Songkick right now, try again later"
																	  delegate: self
															 cancelButtonTitle:@"Ok"
															 otherButtonTitles:nil, nil] show];
									   }
								   }];
		}

	}
	//when the person is picking their artist and they had results
	if (searchArtistIsActive && (searchBar == self.searchBar))
	{
		[searchBar resignFirstResponder];
		NSString *cityID = self.chosenCityDictionary[@"cityID"];
		searchTerm = [searchBar.text stringByReplacingOccurrencesOfString:@" "
																	 withString:@"+"];
		NSURL *yurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.songkick.com/api/3.0/events.json?apikey=%@&artist_name=%@&location=sk:%@", songkickAPIKey, searchTerm, cityID]];
		NSURLRequest *request = [NSURLRequest requestWithURL: yurl];
		if ([Reachable internetNetworkIsUnreachable] && [Reachable wifiNetworkIsUnreachable])
		{
			NSLog(@"No internet or Wifi Connection Available");
			[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
										message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
									   delegate: self
							  cancelButtonTitle: @"Ok"
							  otherButtonTitles:nil, nil] show];
		}
		else
		{
			[NSURLConnection sendAsynchronousRequest: request
											   queue: [NSOperationQueue mainQueue]
								   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
									   if (!connectionError)
									   {
										   NSError *error;
										   id jsonshit = [NSJSONSerialization JSONObjectWithData: data
																						 options: NSJSONReadingMutableContainers
																						   error: &error];
										   if (!error)
										   {
											   NSDictionary *topLevelDictionary = (NSDictionary *)jsonshit;
											   NSDictionary *resultsPageDictionary = topLevelDictionary[@"resultsPage"];
											   NSNumber *numberOfEntries = resultsPageDictionary[@"totalEntries"];
											   
											   if ([numberOfEntries isEqualToNumber: @0])
											   {
												   self.concertObjectArray = nil;
												   noResults = YES;
												   [self.tableView reloadData];
											   }
											   else
											   {
												   NSDictionary *resultsDictionary = resultsPageDictionary[@"results"];
												   NSArray *eventArray = resultsDictionary[@"event"];
												   NSMutableArray *concertObjectMutableArray = [NSMutableArray new];
												   for (NSDictionary *eventDic in eventArray)
												   {
													   Concert *cobject = [[Concert alloc] init];
													   cobject.concertName = eventDic[@"displayName"];
													   cobject.concertID = [eventDic[@"id"] stringValue];
													   cobject.concertURI = eventDic[@"uri"];
													   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
													   formatter.dateFormat = @"yyyy-MM-dd";
													   NSDictionary *startDic = eventDic[@"start"];
													   NSString *dateString = startDic[@"date"];
													   NSDate *date = [formatter dateFromString: dateString];
													   NSLog(@"%@", [date description]);
													   cobject.concertDate = date;
													   [concertObjectMutableArray addObject: cobject];
												   }
												   self.concertObjectArray = (NSArray *)concertObjectMutableArray;
												   [self.tableView reloadData];
											   }
											   
										   }
										   else
										   {
											   NSLog(@"%@", [error localizedDescription]);
											   [[[UIAlertView alloc] initWithTitle:@"Error With Request"
																		   message:@"Unable to connect to Songkick right now, try again later"
																		  delegate: self
																 cancelButtonTitle:@"Ok"
																 otherButtonTitles:nil, nil] show];
										   }
										   
										   
									   }
									   else
									   {
										   NSLog(@"%@", [connectionError localizedDescription]);
										   
										   [[[UIAlertView alloc] initWithTitle:@"Error With Request"
																	   message:@"Unable to connect to Songkick right now, try again later"
																	  delegate: self
															 cancelButtonTitle:@"Ok"
															 otherButtonTitles:nil, nil] show];
									   }
								   }];
		}
	}
	
	
	
}

@end

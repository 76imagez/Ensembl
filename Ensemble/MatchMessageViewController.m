//
//  MatchMessageViewController.m
//  Ensemble
//
//  Created by Adam on 9/24/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "MatchMessageViewController.h"
#import "AppDelegate.h"
#import "ParseMessage.h"
#import "CoreMessage.h"

@interface MatchMessageViewController ()<JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSArray *arrayOfMessageDictionaries;
@property (strong, nonatomic) NSMutableArray *arrayOfJSQMessages;
@property (strong, nonatomic) NSArray *arrayOfParseMessages;

@property (nonatomic, strong) NSDictionary *idDictionary;
@property (nonatomic, strong) NSDictionary *idDictionaryReverse;

@property (nonatomic, strong) UIImage *myAvatar;
@property (nonatomic, strong) UIImage *yourAvatar;

@end

@implementation MatchMessageViewController

-(NSMutableArray *)arrayOfJSQMessages
{
	if (!_arrayOfJSQMessages)
	{
		_arrayOfJSQMessages = [[NSMutableArray alloc] init];
	}
	return _arrayOfJSQMessages;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentView = @"message";
	
	self.title = self.passedParseProfile.name;
	self.sender = appDelegate.userProfile.name;
	
	
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(onIncomingChat)
												 name: @"messageReceived"
											   object: nil];
	
	CGFloat outgoingDiameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
	CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
	self.myAvatar = [JSQMessagesAvatarFactory avatarWithImage: appDelegate.userProfile.profilePic
													 diameter: outgoingDiameter];
	self.yourAvatar = [JSQMessagesAvatarFactory avatarWithImage: self.passedProfilePicture
													   diameter:incomingDiameter];
	
	self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
	self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	
	if ([Reachable wifiNetworkIsUnreachable] && [Reachable internetNetworkIsUnreachable])
	{
		NSLog(@"No internet or Wifi Connection Available");
		[[[UIAlertView alloc] initWithTitle: @"No Internet Connection Is Available"
									message: @"No network connection is available. Check to make sure either wifi or cellular data is turned on."
								   delegate: self
						  cancelButtonTitle: @"Ok"
						  otherButtonTitles:nil, nil] show];
		
		[self loadMessagesFromCoreData];
	}
	else
	{
		[self queryForParseMessages];
	}
	
	
}

-(void)viewWillDisappear:(BOOL)animated
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentView = @"";
}

-(void)queryForParseMessages
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	PFQuery *messageIDquery = [ParseMessage query];
	[messageIDquery whereKey: @"messageSenderID" containedIn: @[appDelegate.userProfile.profileID, self.passedParseProfile.profileID]];
	[messageIDquery whereKey: @"messageReceiverID" containedIn: @[appDelegate.userProfile.profileID, self.passedParseProfile.profileID]];
	
	[messageIDquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		self.arrayOfParseMessages = objects;
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
																   ascending: YES];
		self.arrayOfParseMessages = [self.arrayOfParseMessages sortedArrayUsingDescriptors: @[descriptor]];
		for (ParseMessage *message in self.arrayOfParseMessages)
		{
			[self.arrayOfJSQMessages addObject: [self jsqmessageFromParseMessage: message]];
		}
		[self.collectionView reloadData];
		
		//autoscroll to bottom of chat
		NSIndexPath *path = [NSIndexPath indexPathForItem: self.arrayOfJSQMessages.count - 1
												inSection: 0];
		if (self.arrayOfJSQMessages.count > 0)
		{
			[self.collectionView scrollToItemAtIndexPath: path
										atScrollPosition: UICollectionViewScrollPositionBottom
												animated: YES];
		}
		
	}];
}

-(void)loadMessagesFromCoreData
{
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"CoreMessage"];
	request.predicate = [NSPredicate predicateWithFormat:@"messageSenderID IN %@ && messageReceiverID IN %@", @[self.passedParseProfile.profileID, appDelegate.userProfile.profileID], @[self.passedParseProfile.profileID, appDelegate.userProfile.profileID]];
	NSError *error;
	NSArray *messages = [appDelegate.managedObjectContext executeFetchRequest: request
													error: &error];
	if (!error)
	{
		if (messages.count > 0)
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:YES];
			messages = [messages sortedArrayUsingDescriptors: @[sortDescriptor]];
			for (CoreMessage *message in messages)
			{
				[self.arrayOfJSQMessages addObject: [self jsqmessageFromCoreMessage:message]];
			}
			[self.collectionView reloadData];
		}
	}
	else
	{
		NSLog(@"%@", [error localizedDescription]);
	}
}

-(void)onIncomingChat
{
	[self queryForParseMessages];
}

-(JSQMessage *)jsqmessageFromParseMessage:(ParseMessage *)parseMessage
{
	JSQMessage *message = [[JSQMessage alloc] init];
	message.sender = parseMessage.messageSenderName;
	message.date = parseMessage.createdAt;
	message.text = parseMessage.messageText;
	
	return message;
}

-(JSQMessage *)jsqmessageFromCoreMessage:(CoreMessage *)coreMessage
{
	JSQMessage *message = [[JSQMessage alloc] init];
	message.sender = coreMessage.messageSenderName;
	message.date = coreMessage.messageDate;
	message.text = coreMessage.messageText;
	
	return message;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - JSQMessages implementation

- (void)didPressSendButton:(UIButton *)button
		   withMessageText:(NSString *)text
					sender:(NSString *)sender
					  date:(NSDate *)date
{
	JSQMessage *message = [[JSQMessage alloc] initWithText:text
													sender:sender
													  date:date];
	[self.arrayOfJSQMessages addObject:message];
	[self.collectionView reloadData];
	
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSDictionary *messageDic = @{@"type": @"message", @"profileID" : appDelegate.userProfile.profileID, @"badge" : @"Increment", @"alert" : [NSString stringWithFormat:@"%@ just sent you a message!", appDelegate.userProfile.name]};
	
	PFQuery *pushQuery = [PFInstallation query];
	[pushQuery whereKey: @"user"
				equalTo: self.passedParseProfile.profileID];
	
	PFPush *push = [[PFPush alloc] init];
	[push setQuery: pushQuery];
	[push setData: messageDic];
	
	[push sendPushInBackground];
	[self finishSendingMessage];
	
	//save message to parse
	ParseMessage *parseMessageToSave = [ParseMessage object];
	parseMessageToSave.messageReceiverID = self.passedParseProfile.profileID;
	parseMessageToSave.messageReceiverName = self.passedParseProfile.name;
	parseMessageToSave.messageSenderID = appDelegate.userProfile.profileID;
	parseMessageToSave.messageSenderName = appDelegate.userProfile.name;
	parseMessageToSave.messageText = text;
	[parseMessageToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		
	}];
	
	//save message to Core Data
	CoreMessage *coreMessage = [NSEntityDescription insertNewObjectForEntityForName:@"CoreMessage"
															 inManagedObjectContext: appDelegate.managedObjectContext];
	coreMessage.messageReceiverID = self.passedParseProfile.profileID;
	coreMessage.messageReceiverName = self.passedParseProfile.name;
	coreMessage.messageSenderID = appDelegate.userProfile.profileID;
	coreMessage.messageSenderName = appDelegate.userProfile.name;
	coreMessage.messageText = text;
	coreMessage.messageDate = date;
	
	NSError *error;
	[appDelegate.managedObjectContext save: &error];
	if (error)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving data"
														message:[error localizedDescription]
													   delegate:self
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil, nil];
		[alert show];
	}
	
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
}

//configure bubbles
- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	
	if ([message.sender isEqualToString:self.sender])
	{
		return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
								 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
	}
	
	return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
							 highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.row];
	if ([message.sender isEqualToString:self.sender])
	{
		UIImageView *imageView = [[UIImageView alloc] initWithImage:self.myAvatar];
		return imageView;
	}
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:self.yourAvatar];
	
	return imageView;
	
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate: message.date];
	}
	
	return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessage *message = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	
	/**
	 *  iOS7-style sender name labels
	 */
	if ([message.sender isEqualToString:self.sender])
	{
		return nil;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [self.arrayOfJSQMessages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString: message.sender]) {
			return nil;
		}
	}
	
	/**
	 *  Don't specify attributes to use the defaults.
	 */
	return [[NSAttributedString alloc] initWithString: message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.arrayOfJSQMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *msg = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	
	if ([msg.sender isEqualToString:self.sender])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	
	cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
										  NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
	
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	
	return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	/**
	 *  iOS7-style sender name labels
	 */
	JSQMessage *currentMessage = [self.arrayOfJSQMessages objectAtIndex:indexPath.item];
	if ([[currentMessage sender] isEqualToString:self.sender])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0) {
		JSQMessage *previousMessage = [self.arrayOfJSQMessages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:[currentMessage sender]])
		{
			return 0.0f;
		}
	}
	
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return 0.0f;
}



@end

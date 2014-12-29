//
//  MatchMessageViewController.h
//  Ensemble
//
//  Created by Adam on 9/24/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "ParseUserProfile.h"

@interface MatchMessageViewController : JSQMessagesViewController

@property (nonatomic, strong) ParseUserProfile *passedParseProfile;
@property (nonatomic, strong) UIImage *passedProfilePicture;

@end

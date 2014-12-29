//
//  OtherProfileViewController.h
//  Ensemble
//
//  Created by Adam on 9/17/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseUserProfile.h"
#import "Concert.h"

@interface OtherProfileViewController : UIViewController

@property (nonatomic, strong) ParseUserProfile *passedParseProfile;
@property (strong, nonatomic) Concert *concertObject;


@end

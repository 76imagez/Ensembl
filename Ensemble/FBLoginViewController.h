//
//  FBLoginViewController.h
//  Ensemble
//
//  Created by Adam on 9/16/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FBLoginViewControllerDelegate;

@interface FBLoginViewController : UIViewController

@property (weak, nonatomic) id<FBLoginViewControllerDelegate> delegate;

@end

@protocol FBLoginViewControllerDelegate <NSObject>

-(void)onSuccessfulLogin:(NSString *)facebookID;

@end

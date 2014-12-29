//
//  BandCollectionViewCell.m
//  gigPals
//
//  Created by Adam on 8/16/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import "BandCollectionViewCell.h"

@implementation BandCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self addSubview: self.bandImageView];
		[self addSubview: self.bandLabel];
    }
    return self;
}

-(UILabel *)bandLabel
{
	if (!_bandLabel)
	{
		_bandLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 71, 84, 24)];
		_bandLabel.textColor = [UIColor whiteColor];
		_bandLabel.font = [UIFont fontWithName: @"HelveticaNeue-Thin" size: 20];
		_bandLabel.textAlignment = NSTextAlignmentCenter;
		_bandLabel.adjustsFontSizeToFitWidth = YES;
		_bandLabel.minimumScaleFactor = .5;
		_bandLabel.shadowColor = [UIColor darkGrayColor];
		_bandLabel.shadowOffset = CGSizeMake(1, 1);
		
	}
	return _bandLabel;
}

-(UIImageView *)bandImageView
{
	if (!_bandImageView)
	{
		_bandImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, 70, 70)];
		_bandImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
		_bandImageView.layer.borderWidth = .5;
		_bandImageView.layer.cornerRadius = 8;
		_bandImageView.clipsToBounds = YES;
		
	}
	return _bandImageView;
}

@end

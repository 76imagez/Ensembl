//
//  CoreConcert.h
//  Ensemble
//
//  Created by Adam on 9/20/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreConcert : NSManagedObject

@property (nonatomic, retain) NSString * concertName;
@property (nonatomic, retain) NSDate * concertDate;
@property (nonatomic, retain) NSString * concertID;
@property (nonatomic, retain) NSString * concertURI;
@property (nonatomic, retain) NSNumber * registrees;

@end

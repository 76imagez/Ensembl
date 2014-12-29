//
//  Concert.h
//  Ensemble
//
//  Created by Adam on 9/20/14.
//  Copyright (c) 2014 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreConcert.h"
#import "ParseConcert.h"

@interface Concert : NSObject

@property (nonatomic, strong) NSString *concertName;
@property (nonatomic, strong) NSDate *concertDate;
@property (nonatomic, strong) NSString *concertID;
@property (nonatomic, strong) NSString *concertURI;
@property (nonatomic, strong) NSNumber *registrees;

-(void)saveConcertToParseAndCoreData:(NSManagedObjectContext *)managedObjectContext;
-(instancetype)loadConcertFromParse:(ParseConcert *)concert;
-(instancetype)loadConcertFromCore:(CoreConcert *)concert;

@end
